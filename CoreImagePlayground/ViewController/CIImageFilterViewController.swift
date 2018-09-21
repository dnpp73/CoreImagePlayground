import UIKit
import CIFilterExtension
import GPUCIImageView

private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

final class CIImageFilterViewController: UIViewController, CIFilterListTableViewDelegate {

    private var ciImage: CIImage? {
        didSet {
            filteredCIImage = ciImage
        }
    }

    private var filteredCIImage: CIImage? {
        didSet {
            guard isViewLoaded else {
                return
            }

            if let filteredCIImage = filteredCIImage {
                if uikitSwitch.isOn {
                    if let cgImage = ciContext.createCGImage(filteredCIImage, from: filteredCIImage.extent) {
                        // let image = UIImage(cgImage: cgImage, scale: imageView.window!.screen.scale, orientation: image!.imageOrientation)
                        let image = UIImage(cgImage: cgImage)
                        imageView.image = image
                    } else {
                        print("cgImage is nil")
                    }
                }
                if glciSwitch.isOn {
                    glciImageView.image = filteredCIImage
                }
                if mtciSwitch.isOn {
                    if #available(iOS 9.0, *) {
                        if let mtciImageView = mtciView.subviews.first as? MTCIImageView {
                            mtciImageView.image = filteredCIImage
                        }
                    }
                }
            }
            else {
                imageView.image = nil
                glciImageView.image = nil
                if #available(iOS 9.0, *) {
                    if let mtciImageView = mtciView.subviews.first as? MTCIImageView {
                        mtciImageView.image = nil
                    }
                }
            }
        }
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var glciImageView: GLCIImageView!
    @IBOutlet private weak var mtciView: UIView!

    @IBOutlet private weak var uikitSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var glciSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var mtciSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var uikitSwitch: UISwitch!
    @IBOutlet private weak var glciSwitch: UISwitch!
    @IBOutlet private weak var mtciSwitch: UISwitch!

    @IBOutlet private weak var tableView: CIFilterListTableView!

    // MARK:- UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.filterListTableViewDelegate = self

        if #available(iOS 9.0, *) {
            let mtciImageView = MTCIImageView(frame: mtciView.bounds)
            mtciImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mtciImageView.contentMode = mtciView.contentMode
            mtciView.addSubview(mtciImageView)
        }

        reloadImage()
    }

    private func reloadImage() {
        let image = UIImage.nextSampleImage
        if let i = image.ciImage {
            ciImage = i
        } else if let i = CIImage(image: image) {
            ciImage = i
        }
        if !uikitSwitch.isOn {
            imageView.image = image
        }
        if !glciSwitch.isOn {
            glciImageView.image = ciImage
        }
        if !mtciSwitch.isOn {
            if #available(iOS 9.0, *) {
                if let mtciImageView = mtciView.subviews.first as? MTCIImageView {
                    mtciImageView.image = ciImage
                }
            }
        }
    }

    // MARK:- IBActions

    @IBAction func valueChangedOpenGLSegmentedControl(_ sender: UISegmentedControl) {
        let targetView = glciImageView!
        switch sender.selectedSegmentIndex {
        case 0:
            targetView.contentMode = .scaleToFill
        case 1:
            targetView.contentMode = .scaleAspectFill
        case 2:
            targetView.contentMode = .scaleAspectFit
        default:
            break
        }
    }

    @IBAction func valueChangedUIKitSegmentedControl(_ sender: UISegmentedControl) {
        let targetView = imageView!
        switch sender.selectedSegmentIndex {
        case 0:
            targetView.contentMode = .scaleToFill
        case 1:
            targetView.contentMode = .scaleAspectFill
        case 2:
            targetView.contentMode = .scaleAspectFit
        default:
            break
        }
    }

    @IBAction func valueChangedMetalSegmentedControl(_ sender: UISegmentedControl) {
        if #available(iOS 9.0, *) {
            if let mtciImageView = mtciView.subviews.first as? MTCIImageView {
                let targetView = mtciImageView
                switch sender.selectedSegmentIndex {
                case 0:
                    targetView.contentMode = .scaleToFill
                case 1:
                    targetView.contentMode = .scaleAspectFill
                case 2:
                    targetView.contentMode = .scaleAspectFit
                default:
                    break
                }
            }
        }
    }

    @IBAction func valueChangedOpenGLSwitch(_ sender: UISwitch) {

    }

    @IBAction func valueChangedUIKitSwitch(_ sender: UISwitch) {

    }

    @IBAction func valueChangedMetalSwitch(_ sender: UISwitch) {

    }

    func filterDidUpdate(tableView: CIFilterListTableView) {
        guard let ciImage = ciImage else {
            return
        }
        filteredCIImage = tableView.filter(ciImage)
    }

}
