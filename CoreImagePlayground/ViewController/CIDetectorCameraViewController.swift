import UIKit
import SimpleCamera
import AVFoundation
import GPUCIImageView
import CoreImage
import CIFilterExtension

final class CIDetectorCameraViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imageView: GLCIImageView!
    fileprivate var detector: CIDetector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleCamera.shared.add(videoOutputObserver: self)
        
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: true
        ]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: imageView.ciContext, options: options)
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

extension CIDetectorCameraViewController: SimpleCameraVideoOutputObservable {
    
    // @objc private を付けてもダメで、 internal func にしないといけない。
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
        let scaledCIImage = image.transformed(by: CGAffineTransform(scaleX: imageScale, y: imageScale))
        
        var maskedImage = scaledCIImage
        detector?.features(in: scaledCIImage).forEach { feature in
            // print(feature.type, feature.bounds)
            if let mask = ConstantColorGenerator.image(inputColor: CIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 0.5)) {
                if let m = SourceOverCompositing.filter(inputBackgroundImage: maskedImage)(mask.cropped(to: feature.bounds)) {
                    maskedImage = m.cropped(to: scaledCIImage.extent)
                }
            }
        }
        
        imageView.image = maskedImage
    }
    
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }
    
}
