import UIKit

extension UIImage {
    
    private static var index: Int = 0
    
    private static let names: [String] = [
        "1fac882e",
        "2deb65de",
        "4f6928a0",
        "4fa89ef1",
        "6c49e676"
    ]
    
    static var nextSampleImage: UIImage {
        get {
            let i = UIImage(named: names[index])!
            index += 1
            if index == names.count {
                index = 0
            }
            return i
        }
    }
    
}
