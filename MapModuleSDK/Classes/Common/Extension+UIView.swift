//
//  Extension+UIView.swift
//  PublicDeviceModule
//
//  Created by 马伟龙 on 2020/8/21.
//

import UIKit
extension UIView {
    
    func screenShot() -> UIImage? {
        
        guard bounds.size.height > 0 && bounds.size.width > 0 else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        
        // 之前解决不了的模糊问题就是出在这个方法上
//        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        
        // Renders a snapshot of the complete view hierarchy as visible onscreen into the current context.
        self.drawHierarchy(in: self.frame, afterScreenUpdates: true)  // 高清截图
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}


extension Dictionary {
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }
}
