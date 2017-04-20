import UIKit
import GPUCIImageView

final class CIImageTransformViewController: UIViewController {
    
    private var image: CIImage = CIImage(image: UIImage.nextSampleImage)!
    
    @IBOutlet private weak var imageView: GLCIImageView!
    
    @IBOutlet private weak var tuningAngleSlider: UISlider!
    @IBOutlet private weak var tuningAngleLabel: UILabel!
    @IBOutlet private weak var scaleSlider: UISlider!
    @IBOutlet private weak var scaleLabel: UILabel!
    @IBOutlet private weak var xSlider: UISlider!
    @IBOutlet private weak var xLabel: UILabel!
    @IBOutlet private weak var ySlider: UISlider!
    @IBOutlet private weak var yLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeImage()
    }
    
    private func changeImage() {
        if let i = CIImage(image: UIImage.nextSampleImage) {
            image = i
            imageView.image = i
        }
    }
    
    private func resetSliders() {
        tuningAngleSlider.value = 0.0
        scaleSlider.value = 1.0
        xSlider.value = 0.5
        ySlider.value = 0.5
    }
    
    private var transform: CGAffineTransform {
        get {
            let angle = CGFloat(tuningAngleSlider.value) * CGFloat(M_PI_2)
            let scale = CGFloat(scaleSlider.value)
            let dx = CGFloat(xSlider.value) * 0.0
            let dy = CGFloat(ySlider.value) * 0.0
            return CGAffineTransform.identity.translatedBy(x: dx, y: dy).rotated(by: angle).scaledBy(x: scale, y: scale)
        }
    }
    
    private func updateImageTransform() {
        imageView.image = image.applying(transform)
    }
    
    @IBAction private func touchUpInsideResetAllButton(_ sender: UIButton) {
        resetSliders()
        imageView.image = image
    }
    
    @IBAction private func touchUpInsideRotate0Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRotate90Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRotate180Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRotate270Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideFlipXButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideFlipYButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatioOriginalButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatio4_3Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatio16_9Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatio1_1Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatio3_4Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideRatio9_16Button(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideGridOffButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideGridOnButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpInsideChangeImageButton(_ sender: UIButton) {
        resetSliders()
        changeImage()
    }
    
    @IBAction private func valueChangedTuningAngleSlider(_ sender: UISlider) {
        tuningAngleLabel.text = String(format: "%.2f", sender.value)
        updateImageTransform()
    }
    
    @IBAction private func valueChangedScaleSlider(_ sender: UISlider) {
        scaleLabel.text = String(format: "%.2f", sender.value)
        updateImageTransform()
    }
    
    @IBAction private func valueChangedXSlider(_ sender: UISlider) {
        xLabel.text = String(format: "%.2f", sender.value)
        updateImageTransform()
    }
    
    @IBAction private func valueChangedYSlider(_ sender: UISlider) {
        yLabel.text = String(format: "%.2f", sender.value)
        updateImageTransform()
    }
    
}
