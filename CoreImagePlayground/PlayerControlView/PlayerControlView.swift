import UIKit
import SimpleAVPlayer
import AVFoundation

final class PlayerControlView: NibCreatableView, PlayerControlDelegate {

    weak var playerView: AVPlayerView? {
        didSet {
            playerView?.delegate = self
        }
    }

    weak var filterablePlayerView: FilterablePlayerView? {
        didSet {
            filterablePlayerView?.delegate = self
        }
    }

    private var player: PlayerControllable {
        get {
            if let playerView = playerView {
                return playerView
            } else if let filterablePlayerView = filterablePlayerView {
                return filterablePlayerView
            } else {
                fatalError()
            }
        }
    }

    @IBOutlet private weak var timeLabelLeft: UILabel!
    @IBOutlet private weak var timeLabelRight: UILabel!
    @IBOutlet private weak var timeMinus10Button: UIButton!
    @IBOutlet private weak var timePlus10Button: UIButton!
    @IBOutlet private weak var timeSlider: UISlider!

    @IBOutlet private weak var volumeSlider: UISlider!
    @IBOutlet private weak var volumeLabel: UILabel!

    @IBOutlet private weak var rateSlider: UISlider!
    @IBOutlet private weak var rateButton: UIButton!

    @IBOutlet private weak var prevButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!

    @IBOutlet private weak var contentModeSegmentedControl: UISegmentedControl!

    @IBAction private func touchUpInsideButton(_ sender: UIButton) {
        switch sender {

        case timeMinus10Button:
            break
        case timePlus10Button:
            break

        case rateButton:
            player.rate = 1.0

        case prevButton:
            player.seek(to: .zero)
        case pauseButton:
            player.pause()
        case playButton:
            player.play()
        case nextButton:
            break

        default:
            break
        }
    }

    private var slideBeforeRate: Float = 0.0

    @IBAction private func touchDownSlider(_ sender: UISlider) {
        slideBeforeRate = player.rate
        player.pause()
    }

    @IBAction private func touchUpSlider(_ sender: UISlider) {
        player.rate = slideBeforeRate
    }

    @IBAction private func valueChangedSlider(_ sender: UISlider) {
        switch sender {

        case timeSlider:
            if player.isSeeking == false {
                let time = CMTime(seconds: (player.duration.seconds * Double(sender.value)), preferredTimescale: player.duration.timescale)
                player.seek(to: time)
                setCurrentTimeForLabel(time: time.seconds)
            }

        case volumeSlider:
            player.volume = sender.value
            volumeLabel.text = String(format: "%.2f", sender.value)

        case rateSlider:
            player.rate = sender.value
            rateButton.setTitle(String(format: "%.2f", sender.value), for: .normal)

        default:
            break
        }
    }

    @IBAction private func valueChangedSegmentedControl(_ sender: UISegmentedControl) {
        let contentMode: UIView.ContentMode
        switch sender.selectedSegmentIndex {
        case 0:
            contentMode = .scaleToFill
        case 1:
            contentMode = .scaleAspectFill
        case 2:
            contentMode = .scaleAspectFit
        default:
            contentMode = .scaleToFill
        }
        playerView?.contentMode = contentMode
        filterablePlayerView?.contentMode = contentMode
    }

    // MARK:- PlayerControlDelegate

    func playerItemDidChangeStatus(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        print(#function, playerItem.status.rawValue)
    }

    func playerItemDidChangeLoadedTimeRanges(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        // print(#function)
    }

    func playerItemStalled(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        print(#function)
    }

    func playerItemFailedToPlayToEnd(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        print(#function)
    }

    func playerItemDidPlayToEndTime(_ player: PlayerControllable, playerItem: AVPlayerItem) {
        // print(#function)
        // ここに来るときには rate は 0 になってる。
        // とりあえずデバッグに便利なので簡単にループ再生させとくけど、ここに来る前の rate がマイナスだったら…とか考えて保持しておいた方が良いのかもしれない。
        player.seek(to: .zero)
        player.play()
    }

    func playerDidFinishSeeking(_ player: PlayerControllable) {
        // print(#function)
    }

    func playerDidFailSeeking(_ player: PlayerControllable) {
        print(#function)
    }

    func playerDidChangePlayTimePeriodic(_ player: PlayerControllable) {
        if timeSlider.isTracking == false {
            let progress = Float(player.currentTime.seconds/player.duration.seconds)
            timeSlider.value = min(max(progress, 0.0), 1.0)
            setCurrentTimeForLabel(time: player.currentTime.seconds)
        }
    }

    private func setCurrentTimeForLabel(time: Double) {
        if time.isNaN {
            return
        }
        let t = Int(round(time))
        let s = t % 60
        let m = t / 60
        let h = t / 3600
        let str = String(format: "%02d:%02d:%02d", h, m, s)
        timeLabelLeft.text = str
    }

    func playerDidChangeRate(_ player: PlayerControllable) {
        if rateSlider.isTracking == false {
            rateSlider.value = player.rate
            rateButton.setTitle(String(format: "%.2f", player.rate), for: .normal)
        }
    }

    func playerDidChangeVolume(_ player: PlayerControllable) {
        if volumeSlider.isTracking == false {
            volumeSlider.value = player.volume
            volumeLabel.text = String(format: "%.2f", player.volume)
        }
    }

}
