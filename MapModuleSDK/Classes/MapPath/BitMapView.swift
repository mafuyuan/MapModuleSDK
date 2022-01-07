//
//  BitMapView.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

class BitMapView: UIImageView {

    var bitMapMode : BitMapModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear//UIColor.black
        self.isUserInteractionEnabled = true
        // 解决imageView放大模糊的问题
//        self.layer.magnificationFilter = CALayerContentsFilter(string: "nearest") as String
        self.layer.magnificationFilter = CALayerContentsFilter.init(string: "nearest") as String

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BitMapView {
    internal func drawPublicMap(data: NSData, startByte: Int, rect: CGSize) {
        DispatchQueue.global().async {
            let width = 213
            let height = 154
            //width":213,"height":154
            // 位图的大小 ＝ 图片宽 ＊ 图片高 ＊ 图片中每点包含的信息量
            // 使用系统的颜色空间
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            // 计算总大小,申请内存空间
            let shapeByteCount = width * height * 4
            let shapeVoideData = malloc(shapeByteCount)
            defer {free(shapeVoideData)}
            let shapeData = unsafeBitCast(shapeVoideData, to: UnsafeMutablePointer<CUnsignedChar>.self)
        
            var value = ""
            var count = 0;
                        
            for i in 0..<data.length{
                var temp:Int32 = 0
                data.getBytes(&temp, range: NSRange(location:i ,length:1))
//                print(temp)
                ///获取到16进制字符串
                value = PublicRobotDataManager.decTobin(number: temp)
//                print(value)
                for j in 0..<4 {
                    let loc = j+1
                    let pointee = value.subString(start: loc, length: 2)
                    for _ in 0..<4 {
                        if (count <= shapeByteCount ) {
                            if (count % 4 == 0) {
                                let alph:CGFloat = 255;
                                (shapeData+count).pointee = CUnsignedChar(alph)
                            }else if (count % 4 == 1){
                                if (pointee == "00") {
                                    (shapeData+count).pointee = CUnsignedChar(255)
                                }
                                if (pointee == "01") {
                                    (shapeData+count).pointee = CUnsignedChar(50)
                                }
                                if (pointee == "11") {
                                    (shapeData+count).pointee = CUnsignedChar(0)
                                }
                            }else if (count % 4 == 2){
                                if (pointee == "00") {
                                    (shapeData+count).pointee = CUnsignedChar(100)
                                }
                                if (pointee == "01") {
                                    (shapeData+count).pointee = CUnsignedChar(100)
                                }
                                if (pointee == "11") {
                                    (shapeData+count).pointee = CUnsignedChar(10)
                                }
                            }else if (count % 4 == 3){
                                if (pointee == "00") {
                                    (shapeData+count).pointee = CUnsignedChar(255)
                                }
                                if (pointee == "01") {
                                    (shapeData+count).pointee = CUnsignedChar(40)
                                }
                                if (pointee == "11") {
                                    (shapeData+count).pointee = CUnsignedChar(50)
                                }
                            }
                        }
                        count = count + 1
                    }
                }
            }
            // 创建位图
            let imgContext = CGContext(data: shapeData,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: 8,
                                       bytesPerRow: width * 4,// 4 表示每个像素大小
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            let outImage = imgContext?.makeImage()
            
            let path = FilePathUtils.setupFilePath(directory: .documents, name: "V690Map" + self.bitMapMode!.robotId)
            _ = FileUtils.writeFile(content: UIImagePNGRepresentation(UIImage(cgImage: outImage!))!, filePath: path)
            //绘制图片
            DispatchQueue.main.async {
                //设置显示的区域
                self.image = UIImage(cgImage: outImage!)
//                self.image = image
            }
        }
    }
}

extension BitMapView {
    func drawStandardRobotMapView(mapTypeArray: [Int8], rect: CGSize) {
        DispatchQueue.global().async {
            let width = Int(rect.width)
            let height = Int(rect.height)
            // 使用系统的颜色空间
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            // 计算总大小,申请内存空间 位图的大小 ＝ 图片宽 ＊ 图片高 ＊ 图片中每点包含的信息量
            let shapeByteCount = width * height * 4
            let shapeVoideData = malloc(shapeByteCount)
            defer {free(shapeVoideData)}
            let shapeData = unsafeBitCast(shapeVoideData, to: UnsafeMutablePointer<CUnsignedChar>.self)
            if width * height != mapTypeArray.count{
                return
            }
            for i in 0 ..< height {
                for j in 0 ..< width {
                    let offset = ((height - i - 1)*width + j)*4
                    
                    let pointee = mapTypeArray[i*width + j]
                    //  根据获得的数据值的范围  填充需要的颜色
                    if ( pointee == -1) {
                        self.fillBitMapColor(shapeData: shapeData, offset: offset, color: self.bitMapMode!.cleanedColor)
                    }else if (pointee == 127) {
                        // 未开发区域
                        self.fillBitMapColor(shapeData: shapeData, offset: offset, color: self.bitMapMode!.unCleanColor,alpha: 0)
                    }else if (pointee == 0) {
                        // 障碍物
                        self.fillBitMapColor(shapeData: shapeData, offset: offset, color: self.bitMapMode!.obstacleColor)
                    }
                }
            }
            // 创建位图
            let imgContext = CGContext(data: shapeData,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: 8,
                                       bytesPerRow: width * 4,// 4 表示每个像素大小
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            let outImage = imgContext?.makeImage()
            // 绘制图片
            DispatchQueue.main.async {
                //设置显示的区域
                self.image = UIImage(cgImage: outImage!)
            }
        }
    }
    
}

extension BitMapView {
    fileprivate func  fillBitMapColor(shapeData:UnsafeMutablePointer<CUnsignedChar>,offset: Int ,color: String,alpha: CGFloat = 255) {
        let model = color.resolvingColor()
        (shapeData+offset).pointee = CUnsignedChar(alpha)
        (shapeData+offset+1).pointee = CUnsignedChar(model.0)
       (shapeData+offset+2).pointee = CUnsignedChar(model.1)
       (shapeData+offset+3).pointee = CUnsignedChar(model.2)
   }
}
