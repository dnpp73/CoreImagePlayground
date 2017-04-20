// https://github.com/dennisweissmann/DeviceKit/blob/master/Source/Device.swift
// もっと大規模に必要になったら Carthage で入れるかもしれない。

import Foundation
import UIKit

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
}
