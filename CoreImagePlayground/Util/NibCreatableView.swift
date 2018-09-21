import UIKit

class NibCreatableView: UIView {

    // MARK:- Initializer

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviewsFromXib()
        configureForSubclassing()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviewsFromXib()
        configureForSubclassing()
    }

    private func setupSubviewsFromXib() {
        let klass = type(of: self)
        guard let klassName = NSStringFromClass(klass).components(separatedBy: ".").last else {
            return
        }
        guard let subviewContainer = UINib(nibName: klassName, bundle: Bundle(for: klass)).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        subviewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subviewContainer.frame = bounds
        addSubview(subviewContainer)
    }

    func configureForSubclassing() {
        // for override
    }

}
