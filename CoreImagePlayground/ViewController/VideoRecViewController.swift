import UIKit
import SimpleCamera

final class VideoRecViewController: UIViewController {
    
    @IBOutlet private weak var cameraFinderView: CameraFinderView!
    @IBOutlet private weak var recButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // dateFormatter.dateFormat = "yyyyMMdd-HHmmss.SSSSSS" // SSSSSS はマイクロ秒らしい
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    @IBAction private func touchUpInsideRecButton(_ sender: UIButton) {
        if !SimpleCamera.shared.isRecordingMovie {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            guard let documentsDirectory = paths.first else { return }
            // let filePath = (documentsDirectory as NSString).appendingPathComponent("video/tmp.mp4")
            let dateString = type(of: self).dateFormatter.string(from: Date())
            let filePath = (((documentsDirectory as NSString).appendingPathComponent("video") as NSString).appendingPathComponent(dateString) as NSString).appendingPathExtension("mp4")
            let fileURL = URL(fileURLWithPath: filePath!)
            if SimpleCamera.shared.startRecordMovie(to: fileURL) {
                sender.setTitle("Recording...", for: .normal)
            } else {
                sender.setTitle("Start Fail", for: .normal)
            }
        } else {
            SimpleCamera.shared.stopRecordMovie()
            sender.setTitle("Start Rec", for: .normal)
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
            }
            else {
                cameraFinderView.gridType = .equalDistance(vertical: 8, horizontal: 8)
            }
        }
    }
    
}
