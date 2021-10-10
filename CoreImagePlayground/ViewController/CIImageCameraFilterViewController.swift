import UIKit
import CoreImage
import CIFilterExtension
import AVFoundation
import SimpleCamera
import GPUCIImageView

final class CIImageCameraFilterViewController: UIViewController {

    @IBOutlet fileprivate var imageView: MTCIImageView!
    @IBOutlet fileprivate var tableView: CIFilterListTableView!

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

    fileprivate var limitSize: CGSize = .zero // メインスレッド外で UI 関連の部品に触られないように値を分離している

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // メインスレッド外で UI 関連の部品に触られないように値を分離している
        let screenScale: CGFloat = imageView.window?.screen.scale ?? 1.0
        limitSize = imageView.bounds.size.applying(CGAffineTransform(scaleX: screenScale, y: screenScale))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }

    override var prefersStatusBarHidden: Bool {
        false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .slide
    }

    fileprivate var dropCount: UInt64 = 0

}

extension CIImageCameraFilterViewController: SimpleCameraVideoDataOutputObservable {

    func simpleCameraVideoDataOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        // let image = CIImage(cvImageBuffer: imageBuffer, options: nil)
        let image = CIImage(cvPixelBuffer: imageBuffer)

        let limitWidth  = limitSize.width
        let limitHeight = limitSize.height
        let imageWidth  = image.extent.width
        let imageHeight = image.extent.height
        let scaleWidth  = limitWidth / imageWidth
        let scaleHeight = limitHeight / imageHeight
        let scale = min(scaleWidth, scaleHeight)
        let imageScale = min(1.0, scale)
        let scaledCIImage = image.transformed(by: CGAffineTransform(scaleX: imageScale, y: imageScale))

        DispatchQueue.main.sync {
            self.imageView.image = self.tableView.filter(scaledCIImage)
        }
    }

    func simpleCameraVideoDataOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }

}
