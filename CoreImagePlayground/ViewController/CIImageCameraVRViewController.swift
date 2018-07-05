import UIKit
import SimpleCamera
import AVFoundation
import GPUCIImageView
import CoreImage
import CIFilterExtension
import GameController

final class CIImageCameraVRViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imageView: GLCIImageView!
    
    @IBOutlet private weak var controlsView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var speedSlider: UISlider!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var levelSlider: UISlider!
    @IBOutlet private weak var levelLabel: UILabel!
    
    fileprivate var detector: CIDetector?
    
    // MARK:- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speedLabel.text = String(format: "%.2f", speedSlider.value)
        levelLabel.text = String(format: "%.2f", levelSlider.value)
        
        SimpleCamera.shared.add(videoOutputObserver: self)
        
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: true
        ]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: imageView.ciContext, options: options)
        
        if let gamepad = GCController.controllers().first?.gamepad {
            register(gamepad: gamepad)
        }
        /*
        else {
            GCController.startWirelessControllerDiscovery {
                print("GCController.startWirelessControllerDiscovery completionHandler")
                GCController.controllers().forEach { (controller: GCController) -> Void in
                    print(controller)
                }
            }
        }
         */
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: .GCControllerDidDisconnect, object: nil)
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
        return .landscapeRight
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK:- IBActions
    
    @IBAction private func touchUpInsideXButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func valueChangedSegmentedControl(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction private func valueChangedSpeedSlider(_ sender: UISlider) {
        speedLabel.text = String(format: "%.2f", speedSlider.value)
    }
    
    @IBAction private func valueChangedLevelSlider(_ sender: UISlider) {
        levelLabel.text = String(format: "%.2f", levelSlider.value)
    }
    
    @IBAction private func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        controlsView.isHidden = !controlsView.isHidden
    }
    
    // MARK:- NSNotification
    
    @objc private func handle(notification: Notification) {
        print(notification)
        if notification.name == NSNotification.Name.GCControllerDidConnect {
            if let gamepad = (notification.object as? GCController)?.gamepad {
                register(gamepad: gamepad)
            }
        }
    }
    
    // MARK:- Gamepad
    
    private func register(gamepad: Any) {
        guard let gamepad = gamepad as? GCExtendedGamepad else {
            return
        }
        gamepad.valueChangedHandler = { [weak self] (gamepad: GCExtendedGamepad, element: GCControllerElement) -> Void in
            self?.handle(gamepad: gamepad, element: element)
        }
        gamepad.buttonA.pressedChangedHandler = { [weak self] (button: GCControllerButtonInput, value: Float, isPressed: Bool) -> Void in
            guard let `self` = self else { return }
            if isPressed {
                self.controlsView.isHidden = !self.controlsView.isHidden
            }
        }
        gamepad.leftShoulder.pressedChangedHandler = { [weak self] (button: GCControllerButtonInput, value: Float, isPressed: Bool) -> Void in
            guard let `self` = self else { return }
            if isPressed {
                self.segmentedControl.selectedSegmentIndex -= 1
            }
        }
        gamepad.rightShoulder.pressedChangedHandler = { [weak self] (button: GCControllerButtonInput, value: Float, isPressed: Bool) -> Void in
            guard let `self` = self else { return }
            if isPressed {
                self.segmentedControl.selectedSegmentIndex += 1
            }
        }
        gamepad.leftTrigger.pressedChangedHandler = { [weak self] (button: GCControllerButtonInput, value: Float, isPressed: Bool) -> Void in
            guard let `self` = self else { return }
            if isPressed {
                self.levelSlider.value -= max(min(value, 0.3), 0.01)
                self.valueChangedLevelSlider(self.levelSlider)
            }
        }
        gamepad.rightTrigger.pressedChangedHandler = { [weak self] (button: GCControllerButtonInput, value: Float, isPressed: Bool) -> Void in
            guard let `self` = self else { return }
            if isPressed {
                self.levelSlider.value += max(min(value, 0.3), 0.01)
                self.valueChangedLevelSlider(self.levelSlider)
            }
        }
    }
    
    private func handle(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        // GCGamepad と GCExtendedGamepad がある。似てる名前だけど継承関係はなくて親は両方 NSObject
        // HORIPAD は GCExtendedGamepad っぽい感じがする…。
        // 以下の print は iOS 9.3.5 の iPhone 6s Plus に HORIPAD を繋げた時のもの。
        // print(Thread.isMainThread) // true // GCController の方に `var handlerQueue: DispatchQueue` があって、デフォルトは mainQueue だよって書いてあるけど、このプロパティが iOS 9 以降から。GCController 自体は iOS 7 からある…。
        // print(gamepad) // <_GCMFiExtendedGamepadControllerProfile: 0x13f5b0f70>
        // print(type(of: gamepad)) // _GCMFiExtendedGamepadControllerProfile
        // print(element) // Button B (value: 0.070, pressed: YES) とか Right Thumbstick (x: 0.221, y: -0.205) とか連続的に取れる。
        // print(element.collection) // nil
        // print(type(of: element)) // _GCControllerButtonInput だったり _GCControllerDirectionPad だったりする。
        switch element {
        case gamepad.leftThumbstick:
            let x: CGFloat = CGFloat(gamepad.leftThumbstick.xAxis.value) * 0.3
            let y: CGFloat = CGFloat(gamepad.leftThumbstick.yAxis.value) * 0.3
            centerOffset = CGPoint(x: x, y: y)
        default:
            break
        }
    }
    
    // MARK:- CIFilter
    
    private let date = Date()
    private var centerOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    fileprivate func generateFilter(extent: CGRect) -> Filter {
        let factor = CGFloat(sin(date.timeIntervalSinceNow * Double(speedSlider.value)))
        let level = CGFloat(levelSlider.value)
        let center = XYPosition(x: extent.midX + extent.width  * centerOffset.x,
                                y: extent.midY + extent.height * centerOffset.y)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return BumpDistortion.filter(inputCenter: center,
                                         inputRadius: min(extent.width, extent.height) * level,
                                         inputScale: factor * 0.9 * level)
        case 1:
            return HoleDistortion.filter(inputCenter: center,
                                         inputRadius: min(extent.width, extent.height) * level * 0.8 * (factor + 1.0) * 0.5)
        case 2:
            return PinchDistortion.filter(inputCenter: center,
                                          inputRadius: min(extent.width, extent.height) * level,
                                          inputScale: factor * 0.9 * level)
        case 3:
            return TwirlDistortion.filter(inputCenter: center,
                                          inputRadius: min(extent.width, extent.height) * level,
                                          inputAngle: factor * CGFloat.pi * level)
        case 4:
            return VortexDistortion.filter(inputCenter: center,
                                           inputRadius: min(extent.width, extent.height) * level,
                                           inputAngle: factor * CGFloat.pi * 20.0 * level)
        case 5:
            return Pixellate.filterWithClampAndCrop(inputCenter: center, inputScale: 80.0 * level * (factor + 1.0) * 0.5)
        case 6:
            return GaussianBlur.filterWithClampAndCrop(inputRadius: 20.0 * level * (factor + 1.0) * 0.5)
        default:
            return { image in return image }
        }
    }
    
    fileprivate var dropCount: UInt64 = 0
}

extension CIImageCameraVRViewController: SimpleCameraVideoOutputObservable {
    
    // @objc private を付けてもダメで、 internal func にしないといけない。
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        /*
        switch degrees {
        case   0: preferredCGImagePropertyOrientation = 1 // Top, left
        case  90: preferredCGImagePropertyOrientation = 6 // Right, top
        case 180: preferredCGImagePropertyOrientation = 3 // Bottom, right
        case -90: preferredCGImagePropertyOrientation = 8 // Left, Bottom
        default : preferredCGImagePropertyOrientation = 1
        }
         */
        let image = CIImage(cvPixelBuffer: imageBuffer).oriented(forExifOrientation: 8)
        
        let screenScale: CGFloat = imageView.window?.screen.scale ?? 1.0
        let size = imageView.bounds.size.applying(CGAffineTransform(scaleX: screenScale, y: screenScale))
        let finalRect = CGRect(origin: .zero, size: size)
        
        let margin: CGFloat = 10.0
        let halfSize = CGSize(width: size.width * 0.5 - margin, height: size.height - margin)
        
        // 別にこうじゃなくて良いんだけど画角を最大に取りたかったのでアス比を合わせるコード引っ張ってきた。
        let limitWidth  = halfSize.width
        let limitHeight = halfSize.height
        let imageWidth  = image.extent.width
        let imageHeight = image.extent.height
        let scaleWidth  = limitWidth / imageWidth
        let scaleHeight = limitHeight / imageHeight
        let scale = min(scaleWidth, scaleHeight)
        let imageScale = min(1.0, scale)
        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: imageScale, y: imageScale))
//        print("scaledImage.extent", scaledImage.extent)
        
        // scaledImage を左右に分けて中心に表示する。
        let leftRect  = CGRect(origin: CGPoint(x: margin * 0.5,                  y: margin * 0.5), size: halfSize)
        let rightRect = CGRect(origin: CGPoint(x: margin * 1.5 + halfSize.width, y: margin * 0.5), size: halfSize)
        
        let dxLeft:  CGFloat = leftRect.midX  - scaledImage.extent.midX
        let dyLeft:  CGFloat = leftRect.midY  - scaledImage.extent.midY
        let dxRight: CGFloat = rightRect.midX - scaledImage.extent.midX
        let dyRight: CGFloat = rightRect.midY - scaledImage.extent.midY
        
        let leftImage  = scaledImage.transformed(by: CGAffineTransform.identity.translatedBy(x:  dxLeft, y:  dyLeft)).cropped(to: leftRect)
        let rightImage = scaledImage.transformed(by: CGAffineTransform.identity.translatedBy(x: dxRight, y: dyRight)).cropped(to: rightRect)
//        print("leftImage.extent", leftImage.extent)
//        print("rightImage.extent", rightImage.extent)
        
        // こういう感じで下に背景色を引いてから crop しないと extent がアレして良い感じに表示できなくなってしまう
        guard let constantColor = ConstantColorGenerator.image(inputColor: CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)) else {
            imageView.image = nil
            return
        }
//        print("constantColor.extent", constantColor.extent)
        
        // 左右別々に面白いフィルタを掛ける。当初は先に filter を掛けたものを左右に分けていたんだけど、どう頑張っても表示がおかしい。
        let leftFilter = generateFilter(extent: leftImage.extent)
        guard let leftFiltered = leftFilter(leftImage)?.cropped(to: leftImage.extent),
              let left = SourceOverCompositing.filter(inputBackgroundImage: constantColor)(leftFiltered) else {
            imageView.image = nil
            return
        }
        
        let rightFilter = generateFilter(extent: rightImage.extent)
        guard let rightFiltered = rightFilter(rightImage)?.cropped(to: rightImage.extent),
              let final = SourceOverCompositing.filter(inputBackgroundImage: left)(rightFiltered)?.cropped(to: finalRect) else {
            imageView.image = nil
            return
        }
        imageView.image = final
    }
    
    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }
    
}
