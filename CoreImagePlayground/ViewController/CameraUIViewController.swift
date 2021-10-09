import UIKit
import SimpleCamera
import AVFoundation

final class CameraUIViewController: UIViewController {

    @IBOutlet private var cameraFinderView: CameraFinderView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SimpleCamera.shared.setSession(to: cameraFinderView.captureVideoPreviewView)
        SimpleCamera.shared.setPhotoMode()
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

    @IBAction private func touchUpInsideSilentImageButton(_ sender: UIButton) {
        SimpleCamera.shared.captureSilentImageAsynchronously { (image: UIImage?, metadata: [String: Any]?) -> Void in
            if let image = image {
                print(image)
            }
            if let metadata = metadata {
                print(metadata)
            }
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

}
