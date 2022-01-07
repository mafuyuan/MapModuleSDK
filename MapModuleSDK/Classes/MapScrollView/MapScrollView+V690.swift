//
//  MapScrollView+V690.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/31.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import Foundation
import UIKit
// 绘制公版扫地机
extension MapScrollView {
    // 绘制地图
    internal func drawBitMapView(mapData: NSData, startByte: Int) {
//        let mapData = (mapData as Data).gzipUncompress()
        let rect = PublicRobotDataManager.resolvingmMapSize(data: mapData, byteLen: 4)
        self.bitMapView?.drawPublicMap(data: mapData, startByte: startByte, rect: rect)
    }
    // 绘制路径
    internal func drawV690MapPath(pathData: NSData) {
        if traceView == nil {
           traceView = MapTraceView.init(frame: (bottomView?.frame)!)
//            traceView?.backgroundColor = UIColor.orange
           self.addSubview(traceView!)
        }
        let pathData = (pathData as Data).gzipUncompress()
        // 获取扫地机方向弧度
        var diretion: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
        pathData.getBytes(&diretion, range: NSRange(location: pathData.length - 4, length: 4))
        let temp = CFConvertFloat32SwappedToHost(diretion)
//
        let traceData = pathData.subdata(with: NSRange(location: 0, length: pathData.length - 4))
        var traceBytes = PublicRobotDataManager.resolvingVM690PathData(data: traceData as NSData)
        traceBytes = traceBytes.map({ byte in
            return self.relativeCoordinates(point: byte)
        })
        traceView?.scale = self.lastScaleFactor
        traceView?.pathColor = bitMapModel?.pathColor
        traceView?.pathArray = traceBytes
        traceView?.frame = (bottomView?.frame)!
        traceView?.drawPathWithLayer()
        // 扫地机图标
        guard traceView!.pathArray.count > 0 else {
            return
        }
        sweepPoint  = CGPoint(x: CGFloat(traceView!.pathArray.last![0]), y: CGFloat(traceView!.pathArray.last![1]) )
        print("设备位置---\(sweepPoint)")
        sweepMachineView?.transform = CGAffineTransform(rotationAngle: -CGFloat(temp))
    }
    
    
    internal func getLocationCacheMap() {
        print("路径---")
        let mapfile = FilePathUtils.setupFilePath(directory: .documents, name: "V690Map" + self.bitMapModel!.robotId)
        
        if let map = FileUtils.readFile(filePath: mapfile) {
            self.bitMapView?.image = UIImage(data: map)
        }
        self.InitializationScrollView()
    }
    
    private func relativeCoordinates(point:[Double]) -> [Double] {
        guard let minPoint = self.bitMapModel?.minPoint else { return []}
        let X = Double(point[0]) - Double((Float(minPoint.x)))
        let Y = Double(Float(minPoint.y)) - Double(point[1])
        
        let point_x = X / 0.05 * Double(self.baseScale)
        let point_y = Y / 0.05 * Double(self.baseScale)
        
        let Px = ((self.bottomView?.bounds.width)! - (self.bitMapView?.bounds.width)!) / 2
        let Py = ((self.bottomView?.bounds.height)! - (self.bitMapView?.bounds.height)!) / 2
        
        
        return  [point_x + Double(Px),point_y + Double(Py)]
    }
    
    
    
}
