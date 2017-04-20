import UIKit

final class RootTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 2):
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                // imagePickerController を UINavigationController に push すると怒られる。
                present(imagePickerController, animated: true, completion: nil)
            }
        case (2, 0):
            if let explorer = DPFileListViewController.root() {
                show(explorer, sender: self)
            }
        default:
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
