//
//  ResolvingDataManager.swift
//  SweeperMap
//
//  Created by 拓邦 on 2019/3/2.
//  Copyright © 2019 拓邦. All rights reserved.
//

import UIKit
import Compression
struct  ResolvingDataManager {
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
    // 解析R60机型地图数据
    internal static func resolvingR60RobotMapData(data: NSData, startByte: Int, width: CGFloat, height: CGFloat) -> [Int8] {
        
        // LZ4 解密
        let decodedCapacity = width * height
        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(decodedCapacity))
        
        let decodedData = (data as Data).withUnsafeBytes {
            (encodedSourceBuffer: UnsafePointer<UInt8>) -> Data? in
            
            let decodedCharCount = compression_decode_buffer(decodedDestinationBuffer,
                                                             Int(decodedCapacity),
                                                             encodedSourceBuffer,
                                                             (data.length),
                                                             nil,
                                                             COMPRESSION_LZ4_RAW)
            if decodedCharCount == 0 {
                fatalError("Decoding failed.")
            }
            return Data(bytesNoCopy: decodedDestinationBuffer, count: decodedCharCount, deallocator: .free)
            }! as NSData
        
        var byteArray:[Int8] = []
        for i in startByte ..< (decodedData.length) {
            autoreleasepool {
                var temp:Int8 = 0
                decodedData.getBytes(&temp, range: NSRange(location: i,length:1))
                byteArray.append(temp)
            }
        }
        return byteArray
        
    }
}

// 解析路经数据
extension ResolvingDataManager {
    
   
    
    internal static func resolvingStandardPathData(data: NSData,bitModel: BitMapModel) -> [[Int32]]{
        //解析路径数据流
        let dataArr:[[Int32]] = resolvingPath(data: data, isSwap: false, bitModel: bitModel)
        return dataArr
    }
    
    internal static func resolvingPath<T: FixedWidthInteger>(data: NSData, isSwap: Bool,bitModel: BitMapModel) -> [[T]] {
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

