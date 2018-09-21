import UIKit
import SimpleAVPlayer
import AVFoundation

final class AVPlayerViewController: UIViewController, VideoListTableViewDelegate {

    @IBOutlet private weak var videoListTableView: VideoListTableView!

    @IBOutlet private weak var playerView: AVPlayerView!
    @IBOutlet private weak var playerControlView: PlayerControlView!

    @IBOutlet private weak var captureButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerControlView.playerView = playerView
        videoListTableView.videoListTableViewDelegate = self
        if let fileURL = videoListTableView.fileURLs.first {
            let playerItem = AVPlayerItem(url: fileURL)
            playerView.playerItem = playerItem
            playerView.play()
        }
    }

    func didSelect(tableView: VideoListTableView, fileURL: URL) {
        let playerItem = AVPlayerItem(url: fileURL)
        playerView.playerItem = playerItem
    }

    @IBAction private func handlePlayerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        let isHidden = !playerControlView.isHidden
        playerControlView.isHidden = isHidden
        captureButton.isHidden = isHidden
        imageView.isHidden = isHidden
    }

    @IBAction private func touchUpInsideScreenShotButton(_ sender: UIButton) {
        imageView.image = playerView.createScreenShot()
    }

}
