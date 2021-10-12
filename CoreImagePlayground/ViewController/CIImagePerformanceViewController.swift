import UIKit
import AVFoundation
import SimpleCamera
import GPUCIImageView
import CIFilterExtension

final class CIImagePerformanceViewController: UIViewController {

    @IBOutlet private var imageView: MTCIImageView!

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
        SimpleCamera.shared.add(simpleCameraObserver: self)
        SimpleCamera.shared.add(videoDataOutputObserver: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SimpleCamera.shared.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SimpleCamera.shared.stopRunning()
    }

    // MARK: IBActions

    @IBAction private func valueChangedTextTextField(_ sender: UITextField) {
    }

    @IBAction private func touchUpInsideTextButton(_ sender: UIButton) {
        textTextField.text = "CoreImage Performance\\n日本語"
        textTextField.resignFirstResponder()
    }

    @IBAction private func touchUpInsideFontButton(_ sender: UIButton) {
    }

    @IBAction private func valueChangedFontSizeSlider(_ sender: UISlider) {
        let fontSize = Int(roundf(fontSizeSlider.value))
        fontSizeLabel.text = "FontSize: \(fontSize)"
    }

    @IBAction private func touchUpInsideFontSizeButton(_ sender: UIButton) {
        let fontSize = 24
        fontSizeLabel.text = "FontSize: \(fontSize)"
        if fontSizeSlider.isTracking == false {
            fontSizeSlider.value = Float(fontSize)
        }
    }

    @IBAction private func valueChangedScaleFactorSlider(_ sender: UISlider) {
        let scaleFactor = Double(scaleFactorSlider.value)
        scaleFactorLabel.text = String(format: "ScaleFactor: %.2f", scaleFactor)
    }

    @IBAction private func touchUpInsideScaleFactorButton(_ sender: UIButton) {
        let scaleFactor = 1.0
        scaleFactorLabel.text = String(format: "ScaleFactor: %.2f", scaleFactor)
        if scaleFactorSlider.isTracking == false {
            scaleFactorSlider.value = Float(scaleFactor)
        }
    }

    @IBAction private func valueChangedAngleSlider(_ sender: UISlider) {
        let angle = Double(angleSlider.value)
        angleLabel.text = String(format: "Angle: %.2f", angle)
    }

    @IBAction private func touchUpInsideAngleButton(_ sender: UIButton) {
        let angle = 0.0
        angleLabel.text = String(format: "Angle: %.2f", angle)
        if angleSlider.isTracking == false {
            angleSlider.value = Float(angle)
        }
    }

    @IBAction private func valueChangedZoomSlider(_ sender: UISlider) {
        SimpleCamera.shared.zoomFactor = CGFloat(sender.value)

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

    // MARK: Vars for SimpleCamera

    fileprivate var dropCount: UInt64 = 0

    fileprivate let imageCanvasSize = CGSize(width: 1920.0, height: 1920.0)
    fileprivate let imageTileCount = 4 // 4 * 4 で表示するよ
    fileprivate lazy var canvasImage: CIImage = {
        guard let canvasImage = ConstantColorGenerator.image(inputColor: CIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))?.cropped(to: CGRect(origin: .zero, size: imageCanvasSize)) else {
            fatalError("must not here")
        }
        return canvasImage
    }()

}

extension CIImagePerformanceViewController: SimpleCameraVideoDataOutputObservable {

    func simpleCameraVideoDataOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let originalImage = CIImage(cvPixelBuffer: imageBuffer) // カメラからの生画像を
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
        imageView.image = compositeImage
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
