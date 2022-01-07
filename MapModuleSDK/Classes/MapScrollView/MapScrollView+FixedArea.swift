//
//  MapScrollView+FixedArea.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/8/4.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import Foundation
import UIKit
// 绘制已存在的区域
extension MapScrollView {
    internal func drawZoneAreaWith(points:[[CGPoint]],cleanAreaName:[String]) {
        if fixedAreaView == nil {
            self.creatAreaView()
        }
    }
    
    private func creatAreaView() {
        fixedAreaView = DrawAreaView.init(frame: (self.bitMapView?.frame)!)
        self.insertSubview(fixedAreaView!, aboveSubview: bitMapView!)
        fixedAreaView?.baseScale = baseScale
    }
    
    /* 展示地图上已存在的区域、禁区、虚拟墙等*/
    public func showEachView(cleanPoints: [[CGPoint]], cleanAreaName: [String], forbidPoints: [[CGPoint]], forbidAreaName: [String], virtualPoints:  [[CGPoint]]) {
        if fixedAreaView == nil  {
            fixedAreaView = DrawAreaView.init(frame: (self.bottomView?.frame)!)
            self.insertSubview(fixedAreaView!, aboveSubview: bitMapView!)
        }
//        fixedAreaView?.baseScale = baseScale
        
        
        var areaPionts:[[CGPoint]] = []
        var areaNames:[String] = []
        var areaTypes:[areaType] = []
        for index in 0 ..< cleanPoints.count {
            if cleanPoints[index].count > 0 {
                let points = cleanPoints[index]
//                    .map {
//                    return self.realCoordiToRealativeCoord(point: $0,isZoom: false)
//                }
                areaPionts.append(points)
                areaNames.append(cleanAreaName[index])
                areaTypes.append(.zoneArea)
            }
        }
        for index in 0 ..< forbidPoints.count {
            if forbidPoints[index].count > 0 {
                let points = forbidPoints[index]
                areaPionts.append(points)
                areaNames.append(forbidAreaName[index])
                areaTypes.append(.forbidArea)
            }
        }
        for points in virtualPoints {
            if points.count > 0 {
                let points = points
                areaPionts.append(points)
                areaTypes.append(.virtual)
            }
        }
        
        areaModels = AreaModel(points: areaPionts, names: areaNames, type: areaTypes)
        drawAndUpdateAlreadedArea()
        
    }
    
    
    /** 绘制分区、禁区 */
    internal func drawAndUpdateAlreadedArea() {
        var areaPoints: [[CGPoint]] = []
        guard let count =  areaModels?.points.count,count > 0 else {
            return
        }
        for index in 0 ..< count  {
            let pt = areaModels?.points[index].map {
                return self.realCoordiToRealativeCoord(point: $0,isZoom: false)
            }
            areaPoints.append(pt!)
        }
        
        fixedAreaView?.bitModel = self.bitMapModel
        fixedAreaView?.areaPiontsArray = areaPoints
        fixedAreaView?.areaNameArray = areaModels?.names as! [String]
        fixedAreaView?.types = areaModels?.type as! [areaType]
        fixedAreaView?.frame = (self.bottomView?.frame)!
        fixedAreaView?.scale = lastScaleFactor
        fixedAreaView?.drawAndUpdateArea()
    }
}







class DrawAreaView: UIView {
    
    var areaPiontsArray:[[CGPoint]] = []
    var areaNameArray: [String] = []
    var types: [areaType] = []
    var scale: CGFloat = 1 {
        didSet {
//            self.updateAreanAndNameLabel()
            drawAndUpdateArea()
        }
    }
    var baseScale: CGFloat = 1.0
    var bitModel: BitMapModel?
    private var pathLayers:[CAShapeLayer] = []
    private var nameLabels:[UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func drawAndUpdateArea() {
        
        for layer in pathLayers {  layer.removeFromSuperlayer() }
        for label in nameLabels {  label.removeFromSuperview() }
        pathLayers.removeAll()
        nameLabels.removeAll()
        
        //  guard areaPiontsArray.count > 0  else { return }
        for index in 0 ..< areaPiontsArray.count {
            if areaPiontsArray[index].count < 0  { continue }
            self.drawLineWithPointArray(array: areaPiontsArray[index],type: types[index])
            if types[index] == .virtual  { continue }
            self.createNameLabel(points: areaPiontsArray[index], name: areaNameArray[index])
        }
        
        
    }
    
    
    
    
    fileprivate func updateAreanAndNameLabel() {
        for index  in 0 ..< pathLayers.count {
            pathLayers[index].path = getBezierPath(array: areaPiontsArray[index],type: types[index]).cgPath
            if types[index] == .virtual { continue }
            if areaNameArray.count < 0 { continue }
            nameLabels[index].frame = calculateNameFrame(points: areaPiontsArray[index], name: areaNameArray[index])
        }
    }
    
    fileprivate func drawLineWithPointArray(array:[CGPoint],type: areaType){
        
        let pathLayer = CAShapeLayer.init()
        self.layer.addSublayer(pathLayer)
        pathLayer.lineWidth = type == .virtual ? 2.0 : 1.0
        if type == .virtual {
            pathLayer.lineDashPattern = [6,6]
            pathLayer.strokeColor = bitModel?.vritualColor.hexColor().cgColor
        }else if type == .zoneArea {
            pathLayer.strokeColor = bitModel?.areaBorderColor.hexColor().cgColor
        }else if type == .forbidArea {
            pathLayer.strokeColor = bitModel?.forbidBorderColor.hexColor().cgColor
        }
        pathLayer.fillColor = (type == .zoneArea ? bitModel?.areaColor : bitModel?.forbidColor)?.hexColor(0.4).cgColor
//        pathLayer.lineJoin = CAShapeLayerLineJoin(string: "round") as String
        pathLayer.lineJoin = CAShapeLayerLineJoin.init(string: "round") as String
        pathLayer.path = getBezierPath(array: array,type: type).cgPath
        pathLayers.append(pathLayer)
    }
    
    fileprivate func getBezierPath(array:[CGPoint],type: areaType) -> UIBezierPath {
        var points:[CGPoint] = array
        let path = UIBezierPath.init()
        let zoom = baseScale * scale
        if type != .virtual {
            if points.count == 2 {
                let point1 = CGPoint(x: points[0].x, y: points[1].y)
                let point2 = CGPoint(x: points[1].x, y: points[0].y)
                points.insert(point1, at: 1)
                points.append(point2)
            }
        }
        for index in 0 ..< points.count {
            if index == 0 {
                path.move(to: CGPoint(x: points[index].x * zoom, y: points[index].y * zoom))
            } else {
                path.addLine(to: CGPoint(x: points[index].x * zoom, y: points[index].y * zoom))
            }
        }
        if type != .virtual {
            // 封闭首尾
            path.addLine(to: CGPoint(x: points[0].x * zoom, y: points[0].y * zoom))
        }
        return path
    }
    
    // 绘制label
    fileprivate func createNameLabel(points: [CGPoint],name: String) {
        let  nameLabel = UILabel.init()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 12.0)
        nameLabel.numberOfLines = 0
        nameLabel.frame = calculateNameFrame(points: points, name: name)
        nameLabels.append(nameLabel)
        self.addSubview(nameLabel)
    }
    
    fileprivate func calculateNameFrame(points: [CGPoint], name: String) -> CGRect {
        let zoom = baseScale * scale
        var width = ((points.last?.x)! - (points.first?.x)!) * zoom
        if width < 40 {
            width = 40
        }
        let height = ga_heightForComment(string: name, width: width)
        return CGRect(x: (points.first?.x)! * zoom, y: ((points.first?.y)! * zoom - height) , width: width, height: height)
    }
    
    //根据字数计算Label高度
    private func ga_heightForComment(string: String, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12.0)
        let rect = NSString(string: string).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
}
