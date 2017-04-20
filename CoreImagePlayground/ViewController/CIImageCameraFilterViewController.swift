import UIKit
import CoreImage
import CIFilterExtension
import AVFoundation
import SimpleCamera
import GPUCIImageView

final class CIImageCameraFilterViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imageView: GLCIImageView!
    @IBOutlet fileprivate weak var tableView: CIFilterListTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleCamera.shared.add(videoOutputObserver: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SimpleCamera.shared.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SimpleCamera.shared.stopRunning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    fileprivate var dropCount: UInt64 = 0
    
}

extension CIImageCameraFilterViewController: SimpleCameraVideoOutputObservable {
    
    // @objc private を付けてもダメで、 internal func にしないといけない。
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        // let image = CIImage(cvImageBuffer: imageBuffer, options: nil)
        let image = CIImage(cvPixelBuffer: imageBuffer)
        
        let screenScale: CGFloat = imageView.window?.screen.scale ?? 1.0
        let limitSize = imageView.bounds.size.applying(CGAffineTransform(scaleX: screenScale, y: screenScale))
        let limitWidth  = limitSize.width
        let limitHeight = limitSize.height
        let imageWidth  = image.extent.width
        let imageHeight = image.extent.height
        let scaleWidth  = limitWidth / imageWidth
        let scaleHeight = limitHeight / imageHeight
        let scale = min(scaleWidth, scaleHeight)
        let imageScale = min(1.0, scale)
        let scaledCIImage = image.applying(CGAffineTransform(scaleX: imageScale, y: imageScale))
        
        DispatchQueue.main.sync {
            self.imageView.image = self.tableView.filter(scaledCIImage)
        }
    }
    
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }
    
}
