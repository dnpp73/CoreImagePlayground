import UIKit

protocol NibCreatableReusableCell: AnyObject {
    static func nibForRegisterTableView() -> UINib
    static var  defaultReuseIdentifier: String { get }
}

extension NibCreatableReusableCell where Self: UIView {

    static func nibForRegisterTableView() -> UINib {
        UINib(nibName: className, bundle: Bundle.main)
    }

    static var defaultReuseIdentifier: String {
        className
    }

    private static var className: String {
        NSStringFromClass(self).components(separatedBy: ".").last! // swiftlint:disable:this force_unwrapping
    }

}

extension UICollectionViewCell: NibCreatableReusableCell {}

extension UITableViewCell: NibCreatableReusableCell {}
