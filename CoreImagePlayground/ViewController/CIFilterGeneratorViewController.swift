import UIKit
import CIFilterExtension
import GPUCIImageView

final class CIFilterGeneratorViewController: UIViewController, CIGeneratorListTableViewDelegate, CIFilterListTableViewDelegate {
    
    @IBOutlet private weak var imageView: GLCIImageView!
    @IBOutlet private weak var generatorListTableView: CIGeneratorListTableView! {
        didSet {
            generatorListTableView.generatorListTableViewDelegate = self
        }
    }
    @IBOutlet private weak var filterListTableView: CIFilterListTableView! {
        didSet {
            filterListTableView.filterListTableViewDelegate = self
        }
    }
    
    private func updateImageView() {
        guard let imageView = imageView, let scale = imageView.window?.screen.scale else {
            return
        }
        let rect = imageView.bounds.applying(CGAffineTransform(scaleX: scale, y: scale))
        if let image = generatorListTableView.image {
            // print(image.extent)
            if let filter = filterListTableView?.filter {
                imageView.image = filter(image)?.cropping(to: rect)
            } else {
                imageView.image = image.cropping(to: rect)
            }
            // print(imageView.image!.extent) // QR コードなどの画像は (0.0, 0.0, 27.0, 27.0) とかで生成されるんだけど、Crop しても変わらなかった。サイズがそもそも小さければ何もされないっぽい。
        } else {
            imageView.image = nil
        }
    }
        
    func imageDidUpdate(tableView: CIGeneratorListTableView) {
        updateImageView()
    }
    
    func filterDidUpdate(tableView: CIFilterListTableView) {
        updateImageView()
    }
    
}
