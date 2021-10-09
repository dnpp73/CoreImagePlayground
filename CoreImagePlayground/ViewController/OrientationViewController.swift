import UIKit
import SimpleCamera
import AVFoundation

final class OrientationViewController: UIViewController, SimpleCameraVideoOutputObservable {

    @IBOutlet private var captureVideoPreviewView: AVCaptureVideoPreviewView!

    @IBOutlet private var sub1ImageView: UIImageView!
    @IBOutlet private var sub2ImageView: UIImageView!
    @IBOutlet private var sub3ImageView: UIImageView!

    @IBOutlet private var zoomLabel: UILabel!
    @IBOutlet private var zoomSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // SimpleCamera.shared.add(videoOutputObserver: self)
        SimpleCamera.shared.setSession(to: captureVideoPreviewView)
        SimpleCamera.shared.captureLimitSize = CGSize(width: 120.0, height: 120.0)
        SimpleCamera.shared.setPhotoMode()
        SimpleCamera.shared.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SimpleCamera.shared.stopRunning()
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

    @objc
    private func handle(notification: Notification) {
        if notification.name == UIDevice.orientationDidChangeNotification {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                print("UIDevice.landscapeLeft")
            case .landscapeRight:
                print("UIDevice.landscapeRight")
            case .faceDown:
                print("UIDevice.faceDown")
            case .faceUp:
                print("UIDevice.faceUp")
            case .portraitUpsideDown:
                print("UIDevice.portraitUpsideDown")
            case .portrait:
                print("UIDevice.portrait")
            default:
                break
            }
        }
    }

    @IBAction private func touchUpInsideStartButton(_ sender: UIButton) {
        SimpleCamera.shared.startRunning()
    }

    @IBAction private func touchUpInsideStopButton(_ sender: UIButton) {
        SimpleCamera.shared.stopRunning()
    }

    @IBAction private func touchUpInsideShotButton(_ sender: UIButton) {
        SimpleCamera.shared.captureStillImageAsynchronously { (image: UIImage?, metadata: [String: Any]?) -> Void in
            if let image = image, let metadata = metadata {
                print(metadata)
                print("\(image), scale: \(image.scale), imageOrientation: \(image.imageOrientation.rawValue)")
                self.sub1ImageView.image = image
            }
        }
    }

    @IBAction private func touchUpInsideSilentButton(_ sender: UIButton) {
        SimpleCamera.shared.captureSilentImageAsynchronously { (image: UIImage?, metadata: [String: Any]?) -> Void in
            if let image = image, let metadata = metadata {
                print(metadata)
                print("\(image), scale: \(image.scale), imageOrientation: \(image.imageOrientation.rawValue)")
                self.sub2ImageView.image = image
            }
        }
    }

    @IBAction private func touchUpInsideFrontButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToFront()
    }

    @IBAction private func touchUpInsideBackButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToBack()
    }

    @IBAction private func touchUpInsideFollowToggleButton(_ sender: UIButton) {
        SimpleCamera.shared.isFollowDeviceOrientationWhenCapture.toggle()
        sender.setTitle("follow: \(SimpleCamera.shared.isFollowDeviceOrientationWhenCapture)", for: .normal)
    }

    @IBAction private func touchUpInsideMirroredToggleButton(_ sender: UIButton) {
        SimpleCamera.shared.isMirroredImageIfFrontCamera.toggle()
        sender.setTitle("mirrored: \(SimpleCamera.shared.isMirroredImageIfFrontCamera)", for: .normal)
    }

    @IBAction private func touchUpInsideButton(_ sender: UIButton) {
        // print("front: \(SimpleCamera.shared.isCurrentInputFront), back: \(SimpleCamera.shared.isCurrentInputBack)")
        if SimpleCamera.shared.mode == .movie {
            SimpleCamera.shared.setPhotoMode()
        } else {
            SimpleCamera.shared.setMovieMode()
        }
    }

    @IBAction private func touchUpInsideAddButton(_ sender: UIButton) {
        SimpleCamera.shared.add(videoOutputObserver: self)
    }

    @IBAction private func touchUpInsideRemoveButton(_ sender: UIButton) {
        SimpleCamera.shared.remove(videoOutputObserver: self)
    }

    @IBAction private func touchUpInsideClearButton(_ sender: UIButton) {
        sub1ImageView.image  = nil
        sub2ImageView.image  = nil
        sub3ImageView.image  = nil
    }

    @IBAction private func handleCaptureVideoPreviewViewTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        // print(#function)
    }

    @IBAction private func valueChangedZoomSlider(_ sender: UISlider) {
        SimpleCamera.shared.zoomFactor = CGFloat(sender.value)
    }

    private var dropCount: UInt64 = 0

    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onMainThread {
            var limitSize = self.sub3ImageView.bounds.size
            let scale = UIScreen.main.scale // iPhone 7 Plus において UIScreen.main.scale は 3.0 で UIScreen.main.nativeScale は 2.60869565217391
            limitSize.width *= scale
            limitSize.height *= scale
            let image = createUIImage(from: sampleBuffer, limitSize: limitSize, imageOrientation: SimpleCamera.shared.preferredUIImageOrientationForVideoOutput)
            self.sub3ImageView.image = image
        }
    }

    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }

}
