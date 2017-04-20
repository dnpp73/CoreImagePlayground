import UIKit

protocol NibCreatableReusableCell: class {
    static func nibForRegisterTableView() -> UINib
    static var  defaultReuseIdentifier: String { get }
}

extension NibCreatableReusableCell where Self: UIView {
    
    static func nibForRegisterTableView() -> UINib {
        return UINib(nibName: className, bundle: Bundle.main)
    }
    
    static var defaultReuseIdentifier: String {
        return className
    }
    
    static private var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
}

extension UICollectionViewCell: NibCreatableReusableCell {}

extension UITableViewCell: NibCreatableReusableCell {}
