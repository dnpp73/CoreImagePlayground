import UIKit
import GPUCIImageView
import SimpleAVPlayer
import AVFoundation

final class GPUCIImageCollectionViewController: UICollectionViewController {

    private var fileURL: URL?

    private let playingCellIndexes: [Int] = [0, 3, 5, 8, 12]

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
        let videoListTableView = VideoListTableView(frame: .zero, style: .plain)
        fileURL = videoListTableView.fileURLs.first
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = floor(collectionView.frame.width / 3.0)
            let height = width * 2.0
            flowLayout.itemSize = CGSize(width: width, height: height)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        90
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GPUCIImageCell.reuseIdentifier, for: indexPath) as? GPUCIImageCell else {
            fatalError("It is not GPUCIImageCell")
        }
        guard let fileURL = fileURL else {
            return cell
        }
        if playingCellIndexes.contains(indexPath.item) {
            if cell.imageRenderer.playerItem == nil {
                let playerItem = AVPlayerItem(url: fileURL)
                cell.imageRenderer.playerItem = playerItem
                cell.imageRenderer.play()
            } else {
                cell.imageRenderer.play()
            }
        } else {
            cell.imageRenderer.pause()
            cell.imageRenderer.playerItem = nil
        }
        return cell
    }

}

final class GPUCIImageCell: UICollectionViewCell, PlayerControlDelegate, ImageRendererDelegate {

    fileprivate static let reuseIdentifier = "GPUCIImageCell"

    @IBOutlet private var imageView: GPUCIImageView!

    // swiftlint:disable:next implicitly_unwrapped_optional
    fileprivate var imageRenderer: AVPlayerBasedCIImageRenderer!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageRenderer = AVPlayerBasedCIImageRenderer(delegate: self, imageRendererDelegate: self)
    }

    func imageRendererDidUpdateImage(_ renderer: AVPlayerBasedCIImageRenderer) {
        imageView.image = renderer.image
    }

    func playerItemDidChangeStatus(_ player: PlayerControllable, playerItem: AVPlayerItem) {
    }

    func playerItemDidChangeLoadedTimeRanges(_ player: PlayerControllable, playerItem: AVPlayerItem) {
    }

    func playerItemStalled(_ player: PlayerControllable, playerItem: AVPlayerItem) {
    }

    func playerItemFailedToPlayToEnd(_ player: PlayerControllable, playerItem: AVPlayerItem) {
    }

    func playerItemDidPlayToEndTime(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        imageRenderer.seek(to: .zero) { [weak self] _ in
            self?.imageRenderer.play()
        }
    }

    func playerDidFinishSeeking(_ player: PlayerControllable) {
    }

    func playerDidFailSeeking(_ player: PlayerControllable) {
    }

    func playerDidChangePlayTimePeriodic(_ player: PlayerControllable) {
    }

    func playerDidChangeRate(_ player: PlayerControllable) {
    }

    func playerDidChangeVolume(_ player: PlayerControllable) {
    }

}
