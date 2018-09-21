import UIKit

extension UIColor {

    convenience init?(hexcode: String, alpha: CGFloat) {
        let hexStr  = hexcode.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexStr)
        var color: UInt32 = 0

        guard scanner.scanHexInt32(&color) else {
            return nil
        }

        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >>  8) / 255.0
        let b = CGFloat((color & 0x0000FF) >>  0) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }

}
