//
//  RotateMapManager.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

public protocol RotateMapManagerDelegate: NSObjectProtocol {
    func bitMapViewZooming(scale: CGFloat)
}

@objcMembers public class RotateMapManager: NSObject {
 
    public var bitMapModel: BitMapModel? {
        didSet {
            self.updateBitmodel()
        }
    }

    public weak var delegate: RotateMapManagerDelegate?
    
    internal var mapScrollView: MapScrollView?
    
    internal var areaViewPoints:[[CGPoint]] = []
    internal var areaNameArray:[String] = []
    internal var selectedAreas: [Int] = []
    internal var temScale: CGFloat = 1.0
    
    public init(model: BitMapModel) {
        self.bitMapModel = model
    }
    
    
    private func initMapScrollerView(superView: UIView) {
        guard mapScrollView == nil else {
            superView.sendSubview(toBack: mapScrollView!)
            return
        }
        
        mapScrollView = MapScrollView.init(frame: superView.bounds)
        mapScrollView?.bitMapModel = bitMapModel
        mapScrollView?.scaleDelegate = self
        superView.addSubview(mapScrollView!)
         
        
        
    }
    private func updateBitmodel() {
        Log("地图的大小--- \(bitMapModel?.mapWidth)---\(bitMapModel?.mapHeight)")
        guard mapScrollView != nil else {return}
        mapScrollView?.bitMapModel = bitMapModel
    }

}

//
extension RotateMapManager {
    // 底部视图，用于外部视图添加
    public func getMapScrollView() -> UIScrollView? {
        return mapScrollView
    }
    
    public func getBitmapView() -> UIView? {
        
        return mapScrollView?.bottomView
    }
    
    public func zoomScale() -> CGFloat {
        return self.mapScrollView!.zoomScale
    }
     
    public func getBaseScale() -> CGFloat {
        return self.mapScrollView!.baseScale
    }
    
    //获取地图图片 用于分享地图
    public func bitmap() -> UIImage {
        guard let bottomView = self.mapScrollView?.bottomView else {
            return UIImage()
        }
        return (bottomView.screenShot())!
    }
    
    //
    public func getRobotCurrentPoint() -> CGPoint {
        if let point = self.mapScrollView?.sweepPoint {
            
            return CGPoint(x: point.x * self.mapScrollView!.lastScaleFactor, y: point.y * self.mapScrollView!.lastScaleFactor)
        }
        return .zero
    }
    
}

//MARK： --- 绘制公版扫地机
extension RotateMapManager {

    /*绘制地图
     *superView: 绘制地图的画布
     */
    public func drawPublicMapView(superView: UIView, mapData: NSData) {
        let lz4Tool = LZ4ZipUncompressTool.init()
        let data = lz4Tool.lz4ZipUncompress(mapData as Data)
//        let data = (mapData as Data).gzipUncompress()
        // 获取地图的宽高
        let rect = PublicRobotDataManager.resolvingmMapSize(data: data as NSData, byteLen: 4)
        let point = PublicRobotDataManager.resolvingmMapPxPy(data: data as NSData, byteLen: 8)
        let model = bitMapModel
        model?.mapWidth = rect.width
        model?.mapHeight = rect.height
        model?.minPoint = point
        self.bitMapModel = model
        self.initMapScrollerView(superView: superView)
        mapScrollView?.drawBitMapView(mapData: data as NSData, startByte: 12)
    }
    
    // 绘制路径
    public func drawPublicMapPath(pathData: NSData) {
        guard mapScrollView != nil else { return }
        mapScrollView?.drawV690MapPath(pathData: pathData)
    }
    
    // 获取本地缓存的地图
    public func loadLocationCacheMap(superView: UIView) {
        initMapScrollerView(superView: superView)
        mapScrollView?.getLocationCacheMap()
    }
    // 获取区域点相对与地图坐标的真实坐标
    public func getMapRelativeCoordinates(point: CGPoint) -> CGPoint {
        let p = (self.mapScrollView?.relativeMapCoordinatesPoint(point: point))!
        return getRealMapCoordinates(point: p)
    }
    
    // 获取真实坐标
    public func getRealMapCoordinates(point: CGPoint) -> CGPoint {
        guard let offset = self.bitMapModel?.minPoint else {
            return .zero
        }
        let x = point.x + offset.x / 0.05
        let y = offset.y / 0.05 - point.y
        return CGPoint(x: x * 0.05, y: y * 0.05)
    }
    
    // UI上两点的间距转化为真实地图上的间距
    public func calculateTwoPointSpace(space: CGFloat) -> CGFloat {
        if let mapView = self.mapScrollView {
            let l = space / mapView.lastScaleFactor / mapView.baseScale
            return l * 0.05
        }
        return 0
    }
    
    
    //
    /* 绘制禁区、分区、虚拟墙等功能*/
    /*
     * cleanPoints 分区清扫坐标点的数组
     * cleanAreaName 分区清扫区域的标题数组
     * forbidPoints 禁区坐标点的数组
     * forbidAreaName 禁区的标题数组
     * virtualPoints 虚拟墙坐标点的数组
     */
    public func showOtherFunctionView(cleanPoints: [[CGPoint]], cleanAreaName: [String], forbidPoints: [[CGPoint]], forbidAreaName: [String], virtualPoints: [[CGPoint]]){
        mapScrollView?.showEachView(cleanPoints: cleanPoints, cleanAreaName: cleanAreaName, forbidPoints: forbidPoints, forbidAreaName: forbidAreaName, virtualPoints: virtualPoints)
    }
    
}




//MARK: -- 其他操作
extension RotateMapManager {
    /* 语音播放时候的声波动画
     *Images: 动画图片
     * deadTime: 动画时长
     */
    public func startShowAnimationOfSoundWaves(images: [UIImage], deadTime: Int){
        mapScrollView?.showSoundWavesAnimation(images: images,deadTime: deadTime)
    }
    
    /*更新充电桩的位置
     *point: 充电桩位置
     */
    public func updateChargingLocation(point: CGPoint) {
        self.mapScrollView?.chargingPoint = point
        self.mapScrollView?.showChargingPileLocation()
//        if let pt = self.mapScrollView?.realCoordiToRealativeCoord(point: point,isZoom: false) {
//           mapScrollView?.chargingPoint = pt
//        }
    }
    /*更新设备的位置
     *point: 设备的位置
     */
    public func updateRobotLocation(point: CGPoint) {
        
    }
    
    public func realCoordiToRealativeCoord(point: CGPoint) -> CGPoint {
        if let point = self.mapScrollView?.realCoordiToRealativeCoord(point: point) {
            return point
        }
        return .zero
//        let scale = mapScrollView?.baseScale
//        guard let minPoint = self.bitMapModel?.minPoint else { return .zero}
//        let X = point.x - minPoint.x
//        let Y = minPoint.y - point.y
//         let point1 = CGPoint(x: X / 0.05 * scale! , y: Y / 0.05 * scale!)
//        return mapScrollView?.relativeBottomViewCoordinatesPoint(point: point1) as! CGPoint
    }
}

//MARK: -- 指哪扫哪
extension RotateMapManager {
    /*添加大头针
     *image: 大头针图片
     *point: 大头针位置
     */
    public func creatPinViewWith(image: UIImage,pinWidth: CGFloat = 18.0,_ completion: @escaping (_ point:CGPoint) -> ()) {
        mapScrollView?.addPinView(image: image, pinWidth: pinWidth)
        mapScrollView?.getPinPiont = { (point) in
            completion(point)
        }
    }
    
    /*添加大头针的手势的禁止和打开
     *bool:
     */
    public func startAndForbidTapGesture(bool: Bool) {
        mapScrollView?.pinTap?.isEnabled = bool
    }
    
    /*更新大头针的位置和图片
     *image: 大头针图片
     *point: 大头针位置
     */
    public func updatePinViewWithImage(point:CGPoint,image: UIImage,pinWidth: CGFloat = 18.0) {
//        if let pinPoint = self.mapScrollView?.realCoordiToRealativeCoord(point: point) {
//            mapScrollView?.updatePinView(point: pinPoint, image: image, pinWidth: pinWidth)
//        }
        self.mapScrollView?.pinPoint = point
        self.mapScrollView?.updatePinView(image: image, pinWidth: pinWidth)
    }
    
    /*移除大头针
     *关闭指哪扫哪功能
     */
    public func removePinView(){
        mapScrollView?.removePinViewAndTap()
    }
    
    // 隐藏大头针 用于暂时隐藏图片，但是还能重新点击设置大头针位置
    public func hidePinView() {
        mapScrollView?.hidePinView()
    }
    
    // 移出手势
    public func removeGestureRecognizer() {
        mapScrollView?.removeGestureRecognizer()
    }
    
}




extension RotateMapManager: MapScrollViewDelegate {
    public func mapStartZoomWithScale(zoomScale: CGFloat) {
        self.delegate?.bitMapViewZooming(scale: zoomScale)
//        self.updateAreaFrame(scale: zoomScale)
    }
}
