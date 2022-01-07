//
//  MapScrollView+RobotAndCharge.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/8/4.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import Foundation
import UIKit

// 设备位置和充电桩位置

extension MapScrollView {
    //更新设备的位置
    internal func updateSweepMachineLocation(point: CGPoint) {
        if sweepMachineView == nil {
            sweepMachineView = UIImageView(frame: CGRect(x: -20, y: -20, width: 16, height: 16))
            
            self.addSubview(sweepMachineView!)
        }
        sweepMachineView?.center = CGPoint(x: point.x , y: point.y )
        animationView?.center = CGPoint(x: point.x , y: point.y )
        sweepMachineView?.image = bitMapModel?.robotImage
        
        self.bringSubview(toFront: sweepMachineView!)
    }
    
    
    
    //展示充电桩的位置
    internal func showChargingPileLocation(){
        if charging == nil {
            charging = UIImageView.init(frame: CGRect.init(x: -18, y: -18, width: 11, height: 11))
            charging?.image = bitMapModel?.chargeImage
            self.addSubview(charging!)
        }
        let pt = self.realCoordiToRealativeCoord(point: chargingPoint,isZoom: false)
        
        
        charging?.center = CGPoint(x: pt.x * lastScaleFactor, y: pt.y * lastScaleFactor)
        charging?.autoresizingMask = .init(rawValue: 0)
        self.bringSubview(toFront: charging!)
    }
    
    // 更新充电桩的位置
    internal func updateChargingPileLocation() {
        showChargingPileLocation()
    }
    
}

//MARK: --- 添加语音播放动画
extension MapScrollView {
    internal func showSoundWavesAnimation(images: [UIImage],deadTime: Int)  {
        guard let robot = sweepMachineView else {
            return
        }
        if animationView == nil {
            animationView = AnimationView(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
            self.addSubview(animationView!)
            self.animationView?.image = images[0]
            
        }
        animationView?.animationTime = deadTime
        animationView?.center = robot.center
        animationView?.showSoundWavesAnimation(images: images)
    }
}
