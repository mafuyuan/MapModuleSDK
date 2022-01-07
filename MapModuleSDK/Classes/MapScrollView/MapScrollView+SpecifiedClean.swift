//
//  MapScrollView+SpecifiedClean.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/8/4.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import Foundation
import UIKit

// 指哪扫那功能
extension MapScrollView {
    // 添加大头针
    internal func addPinView(image: UIImage,pinWidth: CGFloat){
        self.pinWidth = pinWidth
        self.creatPinView(image: image)
        pinTap?.isEnabled = true
        pinView?.isHidden = false
        pinView?.center = CGPoint(x: 0, y: -400)
    }
    
    internal func updatePinView(image: UIImage,pinWidth: CGFloat) {
        self.pinWidth = pinWidth
        if pinView == nil {
            self.creatPinView(image: image)
        }
//        self.pinPoint = point
//        self.pinPoint = CGPoint(x: point.x / lastScaleFactor, y: point.y / lastScaleFactor)
//        let center
        pinView?.center = self.realCoordiToRealativeCoord(point: self.pinPoint!, isZoom: true)//CGPoint(x: point.x , y: point.y )
        
        pinView?.isHidden = false
        pinTap?.isEnabled = pinTap?.isEnabled == true ?  true : false
    }
    
    private func creatPinView(image: UIImage) {
        if pinView == nil {
             pinView = UIImageView.init(frame: CGRect.init(x: -20, y: -20, width: pinWidth, height: pinWidth))

            self.addSubview(pinView!)
        }
        pinView?.image = image
    }
    
    //移除大头针
    internal func removePinViewAndTap(){
        pinView?.isHidden = true
        pinTap?.isEnabled = false
    }
    
    // 移出手势
    internal func removeGestureRecognizer() {
        guard let tap = self.pinTap else {
            return
        }
        self.removeGestureRecognizer(tap)
    }
    
    internal func hidePinView() {
        guard pinView != nil else { return }
        pinView?.center = CGPoint(x: 0, y: -400)
    }
    
    //点按 事件
    @objc internal func tapTouch(tap:UITapGestureRecognizer) {
        let currentPoint = tap.location(in:self)
        guard self.pinView != nil else { return }
        self.pinView?.frame = CGRect.init(x: currentPoint.x, y:currentPoint.y - 400, width: pinWidth, height: pinWidth)
        UIView.animate(withDuration: 0.5, animations: {
            self.pinView?.center = CGPoint(x: currentPoint.x, y: currentPoint.y - self.pinWidth)
            //pin 相对坐标点
            let p2 = self.bitMapView!.layer.convert(self.pinView!.center, from: self.layer)
            let pointX = currentPoint.x / self.lastScaleFactor
            let pointY = (currentPoint.y  - self.pinWidth) / self.lastScaleFactor
            self.pinPoint =   CGPoint(x: pointX, y: pointY)
//        }, completion: { (bool) in
            if self.getPinPiont != nil {
                let point = self.relativeMapCoordinatesPoint(point: CGPoint(x: currentPoint.x , y: (currentPoint.y - self.pinWidth) ))
                let realPt = self.getRealMapCoordinates(point: point)
                self.pinPoint = realPt
                self.getPinPiont!(realPt)
            }
        })
    }
    // 获取真实坐标
    public func getRealMapCoordinates(point: CGPoint) -> CGPoint {
        guard let offset = self.bitMapModel?.minPoint else { return .zero }
        let x = point.x + offset.x / 0.05
        let y = offset.y / 0.05 - point.y
        return CGPoint(x: x * 0.05, y: y * 0.05)
    }
    
    
}
