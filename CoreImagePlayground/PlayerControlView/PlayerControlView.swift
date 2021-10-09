import UIKit
import SimpleAVPlayer
import AVFoundation

final class PlayerControlView: NibCreatableView, PlayerControlDelegate {

    weak var playerView: AVPlayerView? {
        didSet {
            playerView?.delegate = self
        }
    }

    weak var imageRenderer: AVPlayerBasedCIImageRenderer? {
        didSet {
            imageRenderer?.delegate = self
        }
    }

    weak var gpuImageView: UIView?

    private var player: PlayerControllable {
        if let playerView = playerView {
            return playerView
        } else if let imageRenderer = imageRenderer {
            return imageRenderer
        } else {
            fatalError() // swiftlint:disable:this fatal_error_message
        }
    }

    @IBOutlet private var timeLabelLeft: UILabel!
    @IBOutlet private var timeLabelRight: UILabel!
    @IBOutlet private var timeMinus10Button: UIButton!
    @IBOutlet private var timePlus10Button: UIButton!
    @IBOutlet private var timeSlider: UISlider!

    @IBOutlet private var volumeSlider: UISlider!
    @IBOutlet private var volumeLabel: UILabel!

    @IBOutlet private var rateSlider: UISlider!
    @IBOutlet private var rateButton: UIButton!

    @IBOutlet private var prevButton: UIButton!
    @IBOutlet private var pauseButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var nextButton: UIButton!

    @IBOutlet private var contentModeSegmentedControl: UISegmentedControl!

    @IBAction private func touchUpInsideButton(_ sender: UIButton) {
        switch sender {

        case timeMinus10Button:
            break
        case timePlus10Button:
            break

        case rateButton:
            player.rate = 1.0

        case prevButton:
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero, force: false, completionHandler: nil)
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
            let time = CMTime(seconds: (player.duration.seconds * Double(sender.value)), preferredTimescale: player.duration.timescale)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, force: false, completionHandler: nil)
            setCurrentTimeForLabel(time: time.seconds)

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
        gpuImageView?.contentMode = contentMode
    }

    // MARK: - PlayerControlDelegate

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
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero, force: false) { success in
            player.play()
        }
    }

    func playerDidFinishSeeking(_ player: PlayerControllable) {
        // print(#function)
        if timeSlider.isTracking == false {
            updateTimeSliderValue()
        }
    }

    func playerDidFailSeeking(_ player: PlayerControllable) {
        // print(#function)
        if timeSlider.isTracking == false {
            updateTimeSliderValue()
        }
    }

    func playerDidChangePlayTimePeriodic(_ player: PlayerControllable) {
        if timeSlider.isTracking == false {
            updateTimeSliderValue()
            setCurrentTimeForLabel(time: player.currentTime.seconds)
        }
    }

    private func updateTimeSliderValue() {
        let progress = Float(player.currentTime.seconds / player.duration.seconds)
        timeSlider.value = min(max(progress, 0.0), 1.0)
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
