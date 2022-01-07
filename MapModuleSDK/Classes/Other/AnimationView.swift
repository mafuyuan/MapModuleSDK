//
//  AnimationView.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

class AnimationView: UIImageView {
    
    
    internal var animationTime: Int = 0 //限定动画时效
    private var codeTimer:DispatchSourceTimer?
    
    
    /* 添加语音播放动画*/
    internal func showSoundWavesAnimation(images: [UIImage]) {
        self.isHidden = false
        var timeCount = 0
        codeTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.global())
        codeTimer?.schedule(deadline: .now(), repeating: .milliseconds(500))
        // 设定时间源的触发事件
        codeTimer?.setEventHandler(handler: {
            //到主线程刷新
            timeCount += 1
            DispatchQueue.main.async {
                self.image = images[timeCount % 3]
                if self.animationTime * 2 == timeCount{
                    self.removeSoundAnimation()
                }
            }
            
        })
        codeTimer?.resume()
    }
    
    /* 移除播放动画*/
    internal func removeSoundAnimation() {
        codeTimer?.cancel()
        codeTimer = nil
        self.isHidden = true
    }
}
