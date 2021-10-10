import UIKit
import SimpleCamera
import AVFoundation

final class CameraUIViewController: UIViewController {

    @IBOutlet private var cameraFinderView: CameraFinderView!
    @IBOutlet private var photoImageView: UIImageView!
    @IBOutlet private var stillImageView: UIImageView!
    @IBOutlet private var silentImageView: UIImageView!

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
        photoImageView.contentMode = .scaleToFill
        stillImageView.contentMode = .scaleToFill
        silentImageView.contentMode = .scaleToFill
    }

    @IBAction private func touchUpInsideAspectFitButton(_ sender: UIButton) {
        cameraFinderView.contentMode = .scaleAspectFit
        photoImageView.contentMode = .scaleAspectFit
        stillImageView.contentMode = .scaleAspectFit
        silentImageView.contentMode = .scaleAspectFit
    }

    @IBAction private func touchUpInsideAspectFillButton(_ sender: UIButton) {
        cameraFinderView.contentMode = .scaleAspectFill
        photoImageView.contentMode = .scaleAspectFill
        stillImageView.contentMode = .scaleAspectFill
        silentImageView.contentMode = .scaleAspectFill
    }

    @IBAction private func touchUpInsidePresetPhotoButton(_ sender: UIButton) {
        SimpleCamera.shared.setPhotoMode()
    }

    @IBAction private func touchUpInsidePresetMovieButton(_ sender: UIButton) {
        SimpleCamera.shared.setMovieMode()
    }

    @IBAction private func touchUpInsidePhotoImageButton(_ sender: UIButton) {
    }

    @IBAction private func touchUpInsideStillImageButton(_ sender: UIButton) {
        SimpleCamera.shared.captureStillImageAsynchronously { (image: UIImage?, metadata: [String: Any]?) -> Void in
            self.stillImageView.image = image
            if let image = image {
                print(image)
            }
            if let metadata = metadata {
                print(metadata)
            }
        }
    }

    @IBAction private func touchUpInsideSilentImageButton(_ sender: UIButton) {
        SimpleCamera.shared.captureSilentImageAsynchronously { (image: UIImage?, metadata: [String: Any]?) -> Void in
            self.silentImageView.image = image
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
