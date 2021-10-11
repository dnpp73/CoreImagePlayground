import UIKit
import AVFoundation
import SimpleCamera
import GPUCIImageView
import CIFilterExtension

final class CIImagePerformanceViewController: UIViewController {

    @IBOutlet private var imageView: MTCIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
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

extension CIImage {
    func move(translationX: CGFloat, translationY: CGFloat) -> CIImage {
        transformed(by: CGAffineTransform(translationX: translationX, y: translationY))
    }

    func moveToOriginZero() -> CIImage {
        move(translationX: -extent.origin.x, translationY: -extent.origin.y)
    }

    func squareCropped() -> CIImage {
        let squareCroppedImage: CIImage
        if extent.width > extent.height {
            // 横長
            let shortSide = extent.height
            let diff = extent.width - extent.height
            let croppedImage = cropped(to: CGRect(x: diff / 2.0, y: 0.0, width: shortSide, height: shortSide))
            squareCroppedImage = croppedImage.moveToOriginZero()
        } else if extent.width < extent.height {
            // 縦長
            let shortSide = extent.width
            let diff = extent.height - extent.width
            let croppedImage = cropped(to: CGRect(x: 0.0, y: diff / 2.0, width: shortSide, height: shortSide))
            squareCroppedImage = croppedImage.moveToOriginZero()
        } else {
            // 既に正方形
            squareCroppedImage = self
        }
        return squareCroppedImage
    }

    func resized(to size: CGSize) -> CIImage {
        let t = CGAffineTransform(scaleX: size.width / extent.width, y: size.height / extent.height)
        return transformed(by: t)
    }
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
        let tileSourceImage = squaredImage.resized(to: tileSize) // タイルのサイズに縮小する

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

        if let blured = GaussianBlur.filterWithClampAndCrop(inputRadius: 20.0)(imageMatrix[2][1]) {
            imageMatrix[2][1] = blured
        }
        if let cmyk = CMYKHalftone.filter()(imageMatrix[1][2]) {
            imageMatrix[1][2] = cmyk
        }
        if let a = PhotoEffect.chrome(alpha: 1.0)(imageMatrix[3][3]) {
            imageMatrix[3][3] = a
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
