//
//  BitMapModel.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

@objcMembers public class BitMapModel: NSObject {
    //设备ID
    public var robotId: String = "Robot"
    // 可清扫区域颜色
    public var cleanedColor: String = "#383841"
    // 未开发区域颜色
    public var unCleanColor: String = "#000000"
    // 障碍物颜色
    public var obstacleColor:String = "#979797"
    
    // 可清扫区域标志
    public var cleanedMark: String?
    // 未开发区域标志
    public var uncleanMark: String?
    // 障碍物标志
    public var obstacleMark: String?
    // 路径颜色
    public var pathColor: String? = "#ff3636"
    
    // 地图缩放倍率
    public var mapScale: CGFloat = 1
    // 路径宽度
    public var pathWidth: Int = 1
    // 地图宽度(像素)
    public var mapWidth: CGFloat = 800
    // 地图高度(像素)
    public var mapHeight: CGFloat = 800
    //分辨率  表示每隔像素代表的世界坐标系下的距离  单位米
    public var resolution: CGFloat = 0.05
    //x偏移 地图左下角对应的x世界坐标(米)
    public var x_min: CGFloat = 0.0
    //y偏移 地图左下角对应的y世界坐标(米)
    public var y_min: CGFloat = 0.0
    //地图ID 表示当前地图的ID号，当重新建图的时候会发生变化
    public var mapId: Int = 0
    //路径ID 表示当前地图匹配的PathID,当新的清扫任务来的时候会发生变化
    public var pathId: Int = 0
    
    // 充电桩位置
    public var chargePos: (Int32,Int32)? = (0,0)
    
    // 设备图标
    public var robotImage: UIImage?
    // 充电桩图标
    public var chargeImage: UIImage?
    //自适应倍率
    public var autoScale: CGFloat = 1.0
    
    //
    public var minPoint: CGPoint = .zero
    
    public var areaColor: String = "#cfdbe5"
    public var forbidColor: String = "#d8d8d8"
    public var areaBorderColor: String = "#bebebe"
    public var forbidBorderColor: String = "#bebebe"
    public var vritualColor:String = "#f33e0d"
    
    
    
}
