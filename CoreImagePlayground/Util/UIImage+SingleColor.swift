import UIKit

extension UIImage {

    convenience init?(color: UIColor, size: CGSize) {
        if size.width <= 0 || size.height <= 0 {
            self.init()
            return nil
        }

        UIGraphicsBeginImageContext(size)
        defer{
            UIGraphicsEndImageContext()
        }
        let rect = CGRect(origin: CGPoint.zero, size: size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        self.init(cgImage: image)
    }

}
