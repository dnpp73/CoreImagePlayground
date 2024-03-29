import UIKit
import AVFoundation
import SimpleCamera
import GPUCIImageView
import CIFilterExtension

final class CIImagePerformanceViewController: UIViewController {

    @IBOutlet private var imageView: MTCIImageView!

    private static let fontSizeScale: CGFloat = 240.0
    private static let scaleFactorScale: CGFloat = 4.0

    @IBOutlet private var textTextField: UITextField!
    @IBOutlet private var fontTextField: UITextField!
    @IBOutlet private var fontSizeLabel: UILabel!
    @IBOutlet private var fontSizeSlider: UISlider!
    @IBOutlet private var scaleFactorLabel: UILabel!
    @IBOutlet private var scaleFactorSlider: UISlider!
    @IBOutlet private var angleLabel: UILabel!
    @IBOutlet private var angleSlider: UISlider!

    @IBOutlet fileprivate var zoomLabel: UILabel!
    @IBOutlet fileprivate var zoomSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.waitUntilCompleted = false
        updateTextImage()
        SimpleCamera.shared.add(simpleCameraObserver: self)
        SimpleCamera.shared.add(videoDataOutputObserver: self)
    }

    private var firstTimeAppear = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTimeAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                SimpleCamera.shared.startRunning()
                SimpleCamera.shared.setMovieMode()
            }
            firstTimeAppear = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SimpleCamera.shared.stopRunning()
    }

    private func updateTextImage() {
        let text = (textTextField.text ?? "CoreImage\\nPerformance\\n日本語").replacingOccurrences(of: "\\n", with: "\n")
        let fontName = fontTextField.text ?? "HelveticaNeue"
        let fontSize = CGFloat(roundf(fontSizeSlider.value * Float(Self.fontSizeScale)))
        let scaleFactor = CGFloat(scaleFactorSlider.value) * Self.scaleFactorScale
        let image = TextImageGenerator.image(inputText: text, inputFontName: fontName, inputFontSize: fontSize, inputScaleFactor: scaleFactor)

        let angle = CGFloat(angleSlider.value)
        textImage = image?.transformed(by: CGAffineTransform(rotationAngle: angle)).moveToOriginZero()
    }

    // MARK: IBActions

    @IBAction private func editingDidEndTextTextField(_ sender: UITextField) {
        updateTextImage()
    }

    @IBAction private func touchUpInsideTextButton(_ sender: UIButton) {
        if textTextField.text?.count ?? 0 == 0 {
            textTextField.text = "CoreImage Performance\\n日本語"
        }
        textTextField.resignFirstResponder()
        updateTextImage()
    }

    @IBAction private func touchUpInsideFontButton(_ sender: UIButton) {
        updateTextImage()
    }

    @IBAction private func valueChangedFontSizeSlider(_ sender: UISlider) {
        let fontSize = Int(roundf(fontSizeSlider.value * Float(Self.fontSizeScale)))
        fontSizeLabel.text = "FontSize: \(fontSize)"
        updateTextImage()
    }

    @IBAction private func touchUpInsideFontSizeButton(_ sender: UIButton) {
        let fontSize = Int(round(Self.fontSizeScale * 0.5))
        fontSizeLabel.text = "FontSize: \(fontSize)"
        if fontSizeSlider.isTracking == false {
            fontSizeSlider.value = 0.5
        }
        updateTextImage()
    }

    @IBAction private func valueChangedScaleFactorSlider(_ sender: UISlider) {
        let scaleFactor = CGFloat(scaleFactorSlider.value) * Self.scaleFactorScale
        scaleFactorLabel.text = String(format: "ScaleFactor: %.2f", scaleFactor)
        updateTextImage()
    }

    @IBAction private func touchUpInsideScaleFactorButton(_ sender: UIButton) {
        let scaleFactor = 0.5 * Self.scaleFactorScale
        scaleFactorLabel.text = String(format: "ScaleFactor: %.2f", scaleFactor)
        if scaleFactorSlider.isTracking == false {
            scaleFactorSlider.value = 0.5
        }
        updateTextImage()
    }

    @IBAction private func valueChangedAngleSlider(_ sender: UISlider) {
        let angle = Double(angleSlider.value)
        angleLabel.text = String(format: "Angle: %.2f", angle)
        updateTextImage()
    }

    @IBAction private func touchUpInsideAngleButton(_ sender: UIButton) {
        let angle = 0.0
        angleLabel.text = String(format: "Angle: %.2f", angle)
        if angleSlider.isTracking == false {
            angleSlider.value = Float(angle)
        }
        updateTextImage()
    }

    @IBAction private func valueChangedZoomSlider(_ sender: UISlider) {
        SimpleCamera.shared.zoomFactor = CGFloat(sender.value)
        updateTextImage()
    }

    @IBAction private func touchUpInsideZoomButton(_ sender: UIButton) {
        let zoomFactor: CGFloat
        switch SimpleCamera.shared.zoomFactor {
        case 0.5: zoomFactor = 1.0
        case 1.0: zoomFactor = 2.0
        case 2.0: zoomFactor = 3.0
        default: zoomFactor = 1.0
        }
        SimpleCamera.shared.zoomFactor = zoomFactor
    }

    @IBAction private func touchUpInsideStartButton(_ sender: UIButton) {
        SimpleCamera.shared.startRunning()
    }

    @IBAction private func touchUpInsideStopButton(_ sender: UIButton) {
        SimpleCamera.shared.stopRunning()
    }

    @IBAction private func touchUpInsidePhotoButton(_ sender: UIButton) {
        SimpleCamera.shared.setPhotoMode()
    }

    @IBAction private func touchUpInsideMovieButton(_ sender: UIButton) {
        SimpleCamera.shared.setMovieMode()
    }

    @IBAction private func touchUpInsideFrontButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToFront()
    }

    @IBAction private func touchUpInsideBackButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToBack()
    }

    // MARK: Vars for SimpleCamera

    fileprivate var dropCount: UInt64 = 0

    private let imageCanvasSize = CGSize(width: 1920.0, height: 1920.0)
    private let imageTileCount = 4 // 4 * 4 で表示するよ
    private lazy var canvasImage: CIImage = {
        guard let canvasImage = ConstantColorGenerator.image(inputColor: CIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))?.cropped(to: CGRect(origin: .zero, size: imageCanvasSize)) else {
            fatalError("must not here")
        }
        return canvasImage
    }()

    private var textImage: CIImage? {
        didSet {
            updateImageViewImage()
        }
    }

    fileprivate var cameraRawImage: CIImage? {
        didSet {
            guard let originalImage = cameraRawImage else {
                tiledAndEffectedImage = nil
                return
            }

            let squaredImage = originalImage.squareCropped() // 正方形にクロップして
            let tileSize = imageCanvasSize.applying(CGAffineTransform(scaleX: 1.0 / CGFloat(imageTileCount), y: 1.0 / CGFloat(imageTileCount)))
            // タイルのサイズに縮小する。
            // transform を当てるだけの resize もあるが、そちらでは実際に縮小処理をする訳ではないのでメモリ使用量が爆発してしまう。
            // Lanczos は Bicubic より重い。
            let tileSourceImage = squaredImage.resizedWithLanczos(to: tileSize) // この中では最も重い
            // let tileSourceImage = squaredImage.resizedWithBicubic(to: tileSize) // 重い
            // let tileSourceImage = squaredImage.resizedWithNearest(to: tileSize) // 最も軽量
            // let tileSourceImage = squaredImage.resized(to: tileSize) // そもそも縮小処理自体をしていないので元画像のサイズによってはメモリが爆発する

            /*
             CoreImage は右下原点なので imageMatrix はこんな感じにする。
             [3][0] [3][1] [3][2] [3][3]
             [2][0] [2][1] [2][2] [2][3]
             [1][0] [1][1] [1][2] [1][3]
             [0][0] [0][1] [0][2] [0][3]
             */
            var imageMatrix: [[CIImage]] = (0..<imageTileCount).map { (y: Int) -> [CIImage] in
                (0..<imageTileCount).map { (x: Int) -> CIImage in
                    tileSourceImage.move(translationX: tileSize.width * CGFloat(x), translationY: tileSize.height * CGFloat(y))
                }
            }

            if let image = Pixellate.filterWithClampAndCrop(inputScale: 30.0)(imageMatrix[0][0]) {
                imageMatrix[0][0] = image
            }
            if let image = Crystallize.filterWithClampAndCrop(inputRadius: 30.0)(imageMatrix[0][1]) {
                imageMatrix[0][1] = image
            }
            if let image = Pointillize.filterWithClampAndCrop(inputRadius: 30.0)(imageMatrix[0][2]) {
                imageMatrix[0][2] = image
            }
            if let image = EdgeWork.filterWithClampAndCrop()(imageMatrix[0][3]) {
                imageMatrix[0][3] = image
            }

            if let image = DotScreen.filter()(imageMatrix[1][0]) {
                imageMatrix[1][0] = image
            }
            if let image = CMYKHalftone.filter()(imageMatrix[1][1]) {
                imageMatrix[1][1] = image
            }
            if let image = HatchedScreen.filter()(imageMatrix[1][2]) {
                imageMatrix[1][2] = image
            }
            if let image = LineScreen.filter()(imageMatrix[1][3]) {
                imageMatrix[1][3] = image
            }

            if let image = GaussianBlur.filterWithClampAndCrop(inputRadius: 20.0)(imageMatrix[2][1]) {
                imageMatrix[2][1] = image
            }
            if let image = DiscBlur.filterWithClampAndCrop(inputRadius: 40.0)(imageMatrix[2][2]) {
                imageMatrix[2][2] = image
            }
            if let image = ZoomBlur.filterWithClampAndCrop(inputCenter: XYPosition(x: imageMatrix[2][3].extent.midX, y: imageMatrix[2][3].extent.midY), inputRadius: 20.0)(imageMatrix[2][3]) {
                imageMatrix[2][3] = image
            }

            let effectAlpha = 0.9
            if let image = PhotoEffect.chrome(alpha: effectAlpha)(imageMatrix[3][0]) {
                imageMatrix[3][0] = image
            }
            if let image = PhotoEffect.fade(alpha: effectAlpha)(imageMatrix[3][1]) {
                imageMatrix[3][1] = image
            }
            if let image = PhotoEffect.instant(alpha: effectAlpha)(imageMatrix[3][2]) {
                imageMatrix[3][2] = image
            }
            if let image = PhotoEffect.mono(alpha: effectAlpha)(imageMatrix[3][3]) {
                imageMatrix[3][3] = image
            }

            // キャンバスとして想定している単色の背景画像を最下層のレイヤーとして、全ての画像を重ねて終わり。
            var compositeImage = canvasImage
            for tileImages in imageMatrix {
                for tileImage in tileImages {
                    compositeImage = tileImage.composited(over: compositeImage)
                }
            }

            tiledAndEffectedImage = compositeImage
        }
    }

    private var tiledAndEffectedImage: CIImage? {
        didSet {
            guard let tiledAndEffectedImage = tiledAndEffectedImage else {
                maskTargetImage = nil
                return
            }

            // 文字の画像をマスクとして使って、全体をボカした画像が浮かび上がる感じにしてみる。
            let bluredAllImage: CIImage = castOrFatalError(GaussianBlur.filterWithClampAndCrop(inputRadius: 1.0)(tiledAndEffectedImage))
            maskTargetImage = ColorInvert.filter(bluredAllImage)
        }
    }

    private var maskTargetImage: CIImage? {
        didSet {
            updateImageViewImage()
        }
    }

    private func updateImageViewImage() {
        guard let maskTargetImage = maskTargetImage, let textImage = textImage else {
            imageView.image = tiledAndEffectedImage
            return
        }
        if let tiledAndEffectedImage = tiledAndEffectedImage {
            imageView.image = BlendWithMask.image(image: maskTargetImage, inputBackgroundImage: tiledAndEffectedImage, inputMaskImage: textImage)
        } else {
            imageView.image = nil
        }
    }

}

extension CIImagePerformanceViewController: SimpleCameraVideoDataOutputObservable {

    func simpleCameraVideoDataOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            cameraRawImage = nil
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            cameraRawImage = nil
            return
        }
        cameraRawImage = CIImage(cvPixelBuffer: imageBuffer)
    }

    func simpleCameraVideoDataOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }

}

extension CIImagePerformanceViewController: SimpleCameraObservable {
    func simpleCameraDidStartRunning(simpleCamera: SimpleCamera) {
    }

    func simpleCameraDidStopRunning(simpleCamera: SimpleCamera) {
    }

    func simpleCameraDidChangeZoomFactor(simpleCamera: SimpleCamera) {
        zoomLabel.text = String(format: "Zoom: %.2f", simpleCamera.zoomFactor)
        if zoomSlider.isTracking == false {
            zoomSlider.value = Float(simpleCamera.zoomFactor)
        }
    }

    func simpleCameraDidChangeFocusPointOfInterest(simpleCamera: SimpleCamera) {
    }

    func simpleCameraDidChangeExposurePointOfInterest(simpleCamera: SimpleCamera) {
    }

    func simpleCameraDidResetFocusAndExposure(simpleCamera: SimpleCamera) {
    }

    func simpleCameraDidSwitchCameraInput(simpleCamera: SimpleCamera) {
    }

    func simpleCameraSessionInterruptionEnded(simpleCamera: SimpleCamera) {
    }
}
