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

            guard let filteredCIImage = filteredCIImage else {
                imageView.image = nil
                mtciImageView.image = nil
                return
            }
            if uikitSwitch.isOn {
                if let cgImage = ciContext.createCGImage(filteredCIImage, from: filteredCIImage.extent) {
                    // let image = UIImage(cgImage: cgImage, scale: imageView.window!.screen.scale, orientation: image!.imageOrientation)
                    let image = UIImage(cgImage: cgImage)
                    imageView.image = image
                } else {
                    print("cgImage is nil")
                }
            }
            if mtciSwitch.isOn {
                mtciImageView.image = filteredCIImage
            }
        }
    }

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var mtciImageView: MTCIImageView!

    @IBOutlet private var uikitSegmentedControl: UISegmentedControl!
    @IBOutlet private var mtciSegmentedControl: UISegmentedControl!

    @IBOutlet private var uikitSwitch: UISwitch!
    @IBOutlet private var mtciSwitch: UISwitch!

    @IBOutlet private var tableView: CIFilterListTableView!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.filterListTableViewDelegate = self
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
        if !mtciSwitch.isOn {
            mtciImageView.image = ciImage
        }
    }

    // MARK: - IBActions

    @IBAction private func valueChangedUIKitSegmentedControl(_ sender: UISegmentedControl) {
        let contentMode: UIView.ContentMode
        switch sender.selectedSegmentIndex {
        case 0:
            contentMode = .scaleToFill
        case 1:
            contentMode = .scaleAspectFill
        case 2:
            contentMode = .scaleAspectFit
        default:
            return
        }
        imageView.contentMode = contentMode
    }

    @IBAction private func valueChangedMetalSegmentedControl(_ sender: UISegmentedControl) {
        let contentMode: UIView.ContentMode
        switch sender.selectedSegmentIndex {
        case 0:
            contentMode = .scaleToFill
        case 1:
            contentMode = .scaleAspectFill
        case 2:
            contentMode = .scaleAspectFit
        default:
            return
        }
        mtciImageView.contentMode = contentMode
    }

    @IBAction private func valueChangedUIKitSwitch(_ sender: UISwitch) {

    }

    @IBAction private func valueChangedMetalSwitch(_ sender: UISwitch) {

    }

    func filterDidUpdate(tableView: CIFilterListTableView) {
        guard let ciImage = ciImage else {
            return
        }
        filteredCIImage = tableView.filter(ciImage)
    }

}
