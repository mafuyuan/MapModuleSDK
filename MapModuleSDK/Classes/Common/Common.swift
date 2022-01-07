//
//  Common.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import Foundation
import UIKit

func loadImage(name:String) -> UIImage{
    let budle = Bundle(url: Bundle.main.url(forResource: "PublicDeviceModule", withExtension: ".bundle")!)!
    return UIImage.init(named: name, in: budle, compatibleWith: nil)!
}


func Log<T>(_ message: @autoclosure () -> T, method: String = #function, line: Int = #line) {
    assert({
        print("\(method):\(line)->\(message())")
        return true
    }())
}

extension String {
    //根据开始位置和长度截取字符串
    func subString(start:Int, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
    
    // 字符串转UIColor
    func hexColor(_ alpha: CGFloat = 1.0) -> UIColor {
        let model = self.resolvingColor()
        let color = UIColor(red: CGFloat(model.r)/255.0, green: CGFloat(model.g)/255.0, blue: CGFloat(model.b)/255.0, alpha: alpha)
        return color
    }
}


extension String {
    func resolvingColor() -> (r:Int,g: Int,b:Int) {
        var str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if (str.count < 6) {
            return (r:0, g:0, b:0)
        }
        
        if (str.hasPrefix("0X")) {
            str = String(str[str.index(str.startIndex, offsetBy: 2)...])
        }
        if (str.hasPrefix("#")) {
            str = String(str[str.index(str.startIndex, offsetBy: 1)...])
        }
        if (str.count != 6) {
            return (r:0, g:0, b:0)
        }
        
        let rStr = String(str[str.startIndex ..< str.index(str.startIndex, offsetBy: 2)])
        let gStr = String(str[str.index(str.startIndex, offsetBy: 2) ..< str.index(str.startIndex, offsetBy: 4)])
        let bStr = String(str[str.index(str.startIndex, offsetBy: 4) ..< str.index(str.startIndex, offsetBy: 6)])
        
        //Scan values
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
        Scanner(string: rStr).scanHexInt32(&r)
        Scanner(string: gStr).scanHexInt32(&g)
        Scanner(string: bStr).scanHexInt32(&b)
        return  (r:Int(r), g:Int(g), b:Int(b))
        
    }
}
