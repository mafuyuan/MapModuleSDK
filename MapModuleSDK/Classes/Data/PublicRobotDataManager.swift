//
//  PublicRobotDataManager.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

struct PublicRobotDataManager {
    // 获取地图的宽高
    internal static func resolvingmMapSize(data: NSData,byteLen: Int) -> CGSize {
        var width: UInt16 = 0, height: UInt16 = 0
        data.getBytes(&width, range: NSRange(location: 0, length: byteLen / 2))
        data.getBytes(&height, range: NSRange(location: byteLen / 2, length: byteLen / 2))
        return CGSize(width: CGFloat(CFSwapInt16(width)), height: CGFloat(CFSwapInt16(height)))
    }
    
    internal static func resolvingmMapPxPy(data: NSData,byteLen: Int) -> CGPoint {
           var width: CFSwappedFloat32 = CFSwappedFloat32(v: 0), height: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
           data.getBytes(&width, range: NSRange(location: 4, length: byteLen / 2))
           data.getBytes(&height, range: NSRange(location: 8, length: byteLen / 2))
           return CGPoint(x: CGFloat(CFConvertFloatSwappedToHost(width)), y: CGFloat(CFConvertFloatSwappedToHost(height)))
       }
    //转化为字符串
    internal static func decTobin(number:Int32) -> String {
        var num = number
        var str = ""
        while num > 0 {
            str = "\(num % 2)" + str
            num /= 2
        }
        for _ in 0 ..< 8 - str.count {
            str = "0" + str
        }
        return str
    }
    
    // 解析路径数据
    internal static func resolvingVM690PathData(data: NSData) -> [[Double]] {
        let dataArr: [[Int16]] = resolvingPath(data: data, isSwap: true)
        return dataArr.map {
            return [Double($0[0]) / 100.0, Double($0[1]) / 100.0]
        }
    }
    
    internal static func resolvingPath<T: FixedWidthInteger>(data: NSData, isSwap: Bool) -> [[T]] {
        let byteW = T.bitWidth / 8
        let step = byteW * 2
        
        var dataArr:[[T]] = []
        let count = data.length
        
        var index = 0
        while index < count {
            var x: T = 0
            var y: T = 0
            if (index + step) <= count {
                data.getBytes(&x, range: NSRange(location: index, length: byteW))
                data.getBytes(&y, range: NSRange(location: index + byteW, length: byteW))
                // 大小端转换
                if isSwap {
                    x = x >> 8 & 0x00ff | x << 8
                    y = y >> 8 & 0x00ff | y << 8
                }
                
                let xy = [T(x), T(y)]
                dataArr.append(xy)
                index += step
            }
        }
        return dataArr
        
    }
}
