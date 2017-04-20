import UIKit
import SimpleAVPlayer
import CIFilterExtension
import AVFoundation

final class FilterablePlayerViewController: UIViewController, CIFilterListTableViewDelegate, VideoListTableViewDelegate {
    
    @IBOutlet private weak var playerView: FilterablePlayerView!
    @IBOutlet private weak var playerControlView: PlayerControlView!
    
    @IBOutlet private weak var videoListTableView: VideoListTableView!
    @IBOutlet private weak var filterListTableView: CIFilterListTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerControlView.filterablePlayerView = playerView
        filterListTableView.filterListTableViewDelegate = self
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
    
    func filterDidUpdate(tableView: CIFilterListTableView) {
        playerView.filter = tableView.filter
    }
    
    @IBAction private func handlePlayerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        playerControlView.isHidden = !playerControlView.isHidden
    }
    
}
