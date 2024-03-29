import UIKit
import AVFoundation
import GPUCIImageView
import SimpleAVPlayer
import CIFilterExtension

final class FilterablePlayerViewController: UIViewController, CIFilterListTableViewDelegate, VideoListTableViewDelegate, ImageRendererDelegate {

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var imageRenderer: AVPlayerBasedCIImageRenderer!

    @IBOutlet private var playerImageView: MTCIImageView!
    @IBOutlet private var playerControlView: PlayerControlView!

    @IBOutlet private var videoListTableView: VideoListTableView!
    @IBOutlet private var filterListTableView: CIFilterListTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageRenderer = AVPlayerBasedCIImageRenderer(delegate: playerControlView, imageRendererDelegate: self)
        playerControlView.imageRenderer = imageRenderer
        playerControlView.gpuImageView = playerImageView

        filterListTableView.filterListTableViewDelegate = self
        videoListTableView.videoListTableViewDelegate = self
        if let fileURL = videoListTableView.fileURLs.first {
            let playerItem = AVPlayerItem(url: fileURL)
            imageRenderer.playerItem = playerItem
            // imageRenderer.play()
        }
    }

    func didSelect(tableView: VideoListTableView, fileURL: URL) {
        let playerItem = AVPlayerItem(url: fileURL)
        imageRenderer.playerItem = playerItem
    }

    func filterDidUpdate(tableView: CIFilterListTableView) {
        updateImage()
    }

    @IBAction private func handlePlayerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        playerControlView.isHidden.toggle()
    }

    private func updateImage() {
        guard let imageView = playerImageView, let renderer = imageRenderer else {
            return
        }
        if let f = filterListTableView?.filter {
            if let image = renderer.image {
                imageView.image = f(image)
            } else {
                imageView.image = nil
            }
        } else {
            imageView.image = renderer.image
        }
    }

    // MARK: - ImageRendererDelegate

    func imageRendererDidUpdateImage(_ renderer: AVPlayerBasedCIImageRenderer) {
        updateImage()
    }

}
