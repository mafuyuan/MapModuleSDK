//
//  MapTraceView.swift
//  SweeperMap
//
//  Created by 拓邦 on 2019/3/3.
//  Copyright © 2019 拓邦. All rights reserved.
//

import UIKit

class MapTraceView: UIView {
    
    internal var pathArray = [[Double]]()
    // 地图缩放倍数
    internal var scale: CGFloat = 1
    
    internal var pathColor: String?
    // 是否是增量
    internal var isIncrement: Bool = true
    private var pathLayer:CAShapeLayer?
    //倍率
    var resolution: CGFloat = 0.05
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.orange
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 绘制路径
    func drawPathWithLayer() {
        let path = UIBezierPath()
//        self.drawStandardRobotPath(path: path)
        self.drawPublicRobotPath(path: path)
        if pathLayer == nil {
            pathLayer = CAShapeLayer.init()
            self.layer.addSublayer(pathLayer!)
        }
        pathLayer?.lineWidth = 1
        pathLayer?.strokeColor = self.pathColor?.hexColor().cgColor
        pathLayer?.fillColor = UIColor.clear.cgColor
//        pathLayer?.lineJoin = kCALineJoinRound
        pathLayer?.path = path.cgPath
    }
    
    
    fileprivate func drawPublicRobotPath(path: UIBezierPath) {
        if pathArray.count == 0 { return }
        for index in 0 ..< self.pathArray.count {
            let point =  CGPoint(x: CGFloat( CGFloat(self.pathArray[index][0])  * scale ), y: CGFloat(self.pathArray[index][1]) * scale )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
    }

   fileprivate func drawStandardRobotPath(path: UIBezierPath) {
       guard self.pathArray.count > 0 else { return }
       for index in 0 ..< self.pathArray.count {
           if index == 0 {
            path.move(to: CGPoint(x: CGFloat(pathArray[index][0]) * scale, y:  CGFloat(pathArray[index][1]) * scale))
           } else {
            path.addLine(to: CGPoint(x: CGFloat(pathArray[index][0]) * scale, y: CGFloat(pathArray[index][1]) * scale ))
           }
       }
       
   }
    
}
