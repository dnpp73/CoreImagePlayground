import UIKit
import SimpleCamera
import AVFoundation

final class VineRecViewController: UIViewController, SimpleCameraVideoOutputObservable, SimpleCameraAudioOutputObservable {

    @IBOutlet private weak var cameraFinderView: CameraFinderView!
    @IBOutlet private weak var recButton: UIButton!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleCamera.shared.add(videoOutputObserver: self)
        SimpleCamera.shared.add(audioOutputObserver: self)
        SimpleCamera.shared.isEnabledAudioRecording = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SimpleCamera.shared.setSession(to: cameraFinderView.captureVideoPreviewView)
        SimpleCamera.shared.setMovieMode()
        SimpleCamera.shared.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SimpleCamera.shared.stopRunning()
    }

    // MARK: - IBActions

    @IBAction private func touchUpInsideScaleToFillButton(_ sender: UIButton) {
        cameraFinderView.contentMode = .scaleToFill
    }

    @IBAction private func touchUpInsideAspectFitButton(_ sender: UIButton) {
        cameraFinderView.contentMode = .scaleAspectFit
    }

    @IBAction private func touchUpInsideAspectFillButton(_ sender: UIButton) {
        cameraFinderView.contentMode = .scaleAspectFill
    }

    @IBAction private func touchUpInsidePresetPhotoButton(_ sender: UIButton) {
        SimpleCamera.shared.setPhotoMode()
    }

    @IBAction private func touchUpInsidePresetMovieButton(_ sender: UIButton) {
        SimpleCamera.shared.setMovieMode()
    }

    @IBAction private func touchUpInsideRecButton(_ sender: UIButton) {
        if isRecording {
            sender.setTitle("Start Rec", for: .normal)
            isRecording = false
            fileWriter.finishWriting {
            }
        } else {
            sender.setTitle("Recording...", for: .normal)
            createAndConfigureAVAssetWriter()
            isRecording = true
        }
    }

    @IBAction private func touchUpInsideFrontButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToFront()
    }

    @IBAction private func touchUpInsideBackButton(_ sender: UIButton) {
        SimpleCamera.shared.switchCameraInputToBack()
    }

    @IBAction private func touchUpInsideGridButton(_ sender: UIButton) {
        switch cameraFinderView.gridType {
        case .none:
            cameraFinderView.gridType = .equalDistance(vertical: 2, horizontal: 2)
        case .equalDistance(let vertical, let horizontal):
            if vertical > 2 || horizontal > 2 {
                cameraFinderView.gridType = .none
            } else {
                cameraFinderView.gridType = .equalDistance(vertical: 8, horizontal: 8)
            }
        }
    }

    private var fileWriter: AVAssetWriter!
    private var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!

    private var isRecording: Bool = false

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // dateFormatter.dateFormat = "yyyyMMdd-HHmmss.SSSSSS" // SSSSSS はマイクロ秒らしい
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    private func createAndConfigureAVAssetWriter() {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            guard let documentsDirectory = paths.first else {
                return
            }
            // let filePath = (documentsDirectory as NSString).appendingPathComponent("vine/tmp.mp4")
            let dateString = type(of: self).dateFormatter.string(from: Date())
            let fileDir = (documentsDirectory as NSString).appendingPathComponent("vine")
            let filePath = ((fileDir as NSString).appendingPathComponent(dateString) as NSString).appendingPathExtension("mp4")
            let fileURL = URL(fileURLWithPath: filePath!) // swiftlint:disable:this force_unwrapping
            try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: false, attributes: nil)
            fileWriter = try AVAssetWriter(url: fileURL, fileType: AVFileType.mov)
        } catch let error /* as NSError */ {
            print(error)
            return
        }

        let videoOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: widthForVideoInput,
            AVVideoHeightKey: heightForVideoInput
        ]
        videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        if fileWriter.canAdd(videoInput) {
            fileWriter.add(videoInput)
        }

        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: numberOfChannelsForAudioInput,
            AVSampleRateKey: sampleRateForAudioInput,
            AVEncoderBitRateKey: 128000
        ]
        audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = true
        if fileWriter.canAdd(audioInput) {
            fileWriter.add(audioInput)
        }
    }

    // MARK: - SimpleCameraVideoOutputObservable

    // (2160/3840)/(720/1280) == 1

    private var widthForVideoInput: Int32 = 720 {
        willSet {
            if widthForVideoInput != newValue {
                print("widthForVideoInput = \(newValue)")
            }
        }
    }

    private var heightForVideoInput: Int32 = 1280 {
        willSet {
            if heightForVideoInput != newValue {
                print("heightForVideoInput = \(newValue)")
            }
        }
    }

    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !isRecording {
            if let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let d = CMVideoFormatDescriptionGetDimensions(fmt)
                widthForVideoInput = d.width
                heightForVideoInput = d.height
            }
        } else {
            write(sampleBuffer: sampleBuffer, isVideo: true)
        }
    }

    private var dropCount: UInt64 = 0

    func simpleCameraVideoOutputObserve(captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dropCount += 1
        print(dropCount)
    }

    // MARK: - SimpleCameraAudioOutputObservable

    private var numberOfChannelsForAudioInput: Int = 1 {
        willSet {
            if numberOfChannelsForAudioInput != newValue {
                print("numberOfChannelsForAudioInput = \(newValue)")
            }
        }
    }

    private var sampleRateForAudioInput: Float64 = 44100.0 {
        willSet {
            if sampleRateForAudioInput != newValue {
                print("sampleRateForAudioInput = \(newValue)")
            }
        }
    }

    func simpleCameraAudioOutputObserve(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !isRecording {
            if let fmt = CMSampleBufferGetFormatDescription(sampleBuffer), let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                numberOfChannelsForAudioInput = Int(asbd.pointee.mChannelsPerFrame)
                sampleRateForAudioInput = asbd.pointee.mSampleRate
            }
        } else {
            write(sampleBuffer: sampleBuffer, isVideo: false)
        }
    }

    // MARK: -

    private func write(sampleBuffer: CMSampleBuffer, isVideo: Bool) {
        if fileWriter.status == .failed {
            return
        }

        if fileWriter.status == .unknown {
            let startTime: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            fileWriter.startWriting()
            fileWriter.startSession(atSourceTime: startTime)
        }

        if isVideo {
            if videoInput.isReadyForMoreMediaData {
                videoInput.append(sampleBuffer)
            }
        } else {
            if audioInput.isReadyForMoreMediaData {
                audioInput.append(sampleBuffer)
            }
        }
    }

}
