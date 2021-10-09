import UIKit

extension UIButton {

    func setBackgroundColor(_ color: UIColor?, for state: UIControlState) {
        if let color = color {
            let image = UIImage(color: color, size: bounds.size)
            setBackgroundImage(image, for: state)
        } else {
            setBackgroundImage(nil, for: state)
        }
    }

    @IBInspectable dynamic var normalBackgroundColor: UIColor? {
        get {
            nil // dummy
        }
        set {
            setBackgroundColor(newValue, for: .normal)
        }
    }

    @IBInspectable dynamic var highlightedBackgroundColor: UIColor? {
        get {
            nil // dummy
        }
        set {
            setBackgroundColor(newValue, for: .highlighted)
        }
    }

    @IBInspectable dynamic var disabledBackgroundColor: UIColor? {
        get {
            nil // dummy
        }
        set {
            setBackgroundColor(newValue, for: .disabled)
        }
    }

}
