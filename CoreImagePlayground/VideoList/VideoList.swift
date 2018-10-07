import UIKit

protocol VideoListTableViewDelegate: class {
    func didSelect(tableView: VideoListTableView, fileURL: URL)
}

final class VideoListTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    weak var videoListTableViewDelegate: VideoListTableViewDelegate?

    private(set) var fileURLs: [URL] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    private func commonInit() {
        register(VideoListCell.nibForRegisterTableView(), forCellReuseIdentifier: VideoListCell.defaultReuseIdentifier)
        delegate = self
        dataSource = self

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectoryPath = paths.first else {
            return
        }

        let videoDirPath = (documentsDirectoryPath as NSString).appendingPathComponent("video")
        let videoDirURL = URL(fileURLWithPath: videoDirPath, isDirectory: true)
        do {
            let videoContents = try FileManager.default.contentsOfDirectory(at: videoDirURL, includingPropertiesForKeys: nil, options: [])
            fileURLs += videoContents
        } catch let error {
            print(error)
        }

        let vineDirPath = (documentsDirectoryPath as NSString).appendingPathComponent("vine")
        let vineDirURL = URL(fileURLWithPath: vineDirPath, isDirectory: true)
        do {
            let vineContents = try FileManager.default.contentsOfDirectory(at: vineDirURL, includingPropertiesForKeys: nil, options: [])
            fileURLs += vineContents
        } catch let error {
            print(error)
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return fileURLs.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoListCell.defaultReuseIdentifier) as? VideoListCell else {
            fatalError("must not here")
        }
        if indexPath.section == 0 {
            let pathComponents = fileURLs[indexPath.row].pathComponents
            cell.label.text = "\(pathComponents[pathComponents.count-2])/\(pathComponents[pathComponents.count-1])"
        } else if indexPath.section == 1 {
            cell.label.text = "Choose from Photo Library"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            videoListTableViewDelegate?.didSelect(tableView: self, fileURL: fileURLs[indexPath.row])
        } else if indexPath.section == 1 {
            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.sourceType = .savedPhotosAlbum
            videoPicker.mediaTypes = ["public.movie"]
            tableView.window?.rootViewController?.present(videoPicker, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension VideoListTableView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.referenceURL] as? URL {
            videoListTableViewDelegate?.didSelect(tableView: self, fileURL: url)
        }
    }

}

final class VideoListCell: UITableViewCell {
    @IBOutlet fileprivate weak var label: UILabel!
}
