//
//  mapScrollView.swift
//  SweepRobotMapDraw
//
//  Created by 马伟龙 on 2020/7/30.
//  Copyright © 2020 马伟龙. All rights reserved.
//

import UIKit

public typealias getPinPiontBlock = (_ piont:CGPoint) -> ()
public protocol MapScrollViewDelegate: NSObjectProtocol {
    // 地图缩放
    func mapStartZoomWithScale(zoomScale:CGFloat)
}

// 地图和路径的底部父视图
class MapScrollView: UIScrollView {
    
    //地图画布 用于放大地图时候
    internal var bottomView: UIView?
    
    // 地图
    internal var bitMapView: BitMapView?
    // 路径
    internal var traceView: MapTraceView?
    // 地图的缩放倍率
    internal var lastScaleFactor: CGFloat = 1.0
    // 真实地图相对于UI界面的基础倍率
    internal var baseScale: CGFloat = 1.0
    //扫地机图标
    internal var sweepMachineView: UIImageView?
    // 充电桩
    internal var charging: UIImageView?
    // 动画
    internal var animationView: AnimationView?
    // 大头针view
    internal var pinView: UIImageView?
    // 大头针的相对坐标点
    internal var pinPoint: CGPoint?
    // 点按手势
    internal var pinTap: UITapGestureRecognizer?
    // 大头针的大小
    internal var pinWidth:CGFloat = 18.0
    // 获取大头针坐标
    internal var getPinPiont:getPinPiontBlock?
    // 已存在的区域
    internal var fixedAreaView: DrawAreaView?
    // 已存在的区域数据
    internal var areaModels: AreaModel?
    
    // 代理
    internal weak var scaleDelegate: MapScrollViewDelegate?
    
    var lastScale: CGFloat = 1.0
    
    internal var bitMapModel: BitMapModel? {
        didSet {
            self.setupMapView()
        }
    }
    
    //机器的位置
    internal var sweepPoint: CGPoint = CGPoint(x: -20, y: -20) {
        didSet {
            let midPiont = CGPoint(x: sweepPoint.x * lastScaleFactor , y: sweepPoint.y * lastScaleFactor )
            self.updateSweepMachineLocation(point: midPiont)
        }
    }
    internal var chargingPoint:CGPoint = CGPoint(x: -20, y: -20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bottomView = UIView(frame: self.frame)
        self.bottomView?.backgroundColor = .clear
        self.addSubview(self.bottomView!)
        self.InitializationScrollView()
    }
    
    //MARK: --  scrollView  初始化配置
    internal func InitializationScrollView() {
        self.delegate = self
        self.isUserInteractionEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.layer.allowsEdgeAntialiasing = true
        self.bouncesZoom = false
//        self.decelerationRate = UIScrollView.DecelerationRate.nan
        self.backgroundColor = UIColor.clear
        self.scrollsToTop = false
        
        //点按手势  用于指哪扫哪
        pinTap = UITapGestureRecognizer.init(target: self, action: #selector(tapTouch))
        pinTap?.isEnabled = false
        self.addGestureRecognizer(pinTap!)
        
        self.minimumZoomScale = 1
        self.maximumZoomScale = 5
         
    }
    
    internal func setupMapView() {
        if bitMapView == nil {
            bitMapView = BitMapView.init(frame:frame)
            bottomView?.addSubview(bitMapView!)
        }
        bitMapView?.bitMapMode = bitMapModel
        self.setBaseScale()
    }
    
    internal func setBaseScale() {
        guard let model = self.bitMapModel else {
            return
        }
        let xScale = self.frame.width / model.mapWidth
        let yScale = self.frame.height / model.mapHeight
        let scale: CGFloat = model.mapWidth > model.mapHeight ? xScale : yScale//1.0
        
        let x = (self.frame.width - scale * model.mapWidth ) / 2
        let y = (self.frame.height - scale * model.mapHeight) / 2
        self.baseScale = scale
        bitMapModel?.autoScale = scale
        
        let frame = CGRect(x: x , y: y, width: scale * model.mapWidth, height: model.mapHeight * scale )
        
        if bitMapView?.frame != frame {
            Log("地图frame---- \(bitMapView?.frame)")
            bitMapView?.frame = frame
            self.updateChargingPileLocation()
            self.drawAndUpdateAlreadedArea()
        }
        self.setZoomScale(lastScaleFactor, animated: false)
    }
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapScrollView: UIScrollViewDelegate {
    
}




//MARK: --- 地图缩放
extension MapScrollView {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //需要缩放的视图
        return self.bottomView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //缩放结果
        self.lastScaleFactor = scrollView.zoomScale
        bitMapModel?.mapScale = self.lastScaleFactor
        self.handlePathAndAreaFrame()
        self.calculateRelativePosition(scale: self.lastScaleFactor)
        self.scaleDelegate?.mapStartZoomWithScale(zoomScale: scrollView.zoomScale)
    }
        
    
    // 计算区域和路径的相对位置
    fileprivate func handlePathAndAreaFrame() {
        
        traceView?.scale = self.lastScaleFactor
        traceView?.drawPathWithLayer()
        traceView?.frame = (bottomView?.frame)!
        traceView?.center = bottomView!.center
        
        fixedAreaView?.frame = (bottomView?.frame)!
        fixedAreaView?.scale = self.lastScaleFactor
        fixedAreaView?.drawAndUpdateArea()
    }
    //计算相对坐标
    private func calculateRelativePosition(scale:CGFloat){
        //缩放时候 点的相对移动
        if self.pinPoint != nil {
            let pt = self.realCoordiToRealativeCoord(point: self.pinPoint!, isZoom: false)
            self.pinView?.center = CGPoint(x: pt.x * scale , y: pt.y * scale)
        }
        self.sweepMachineView?.center = CGPoint(x: self.sweepPoint.x * scale , y: self.sweepPoint.y * scale )
        
        let chargePt = self.realCoordiToRealativeCoord(point: chargingPoint, isZoom: false)
        self.charging?.center = CGPoint(x: chargePt.x * scale , y: chargePt.y * scale )
        animationView?.center = (self.sweepMachineView?.center)!
      
    }
    
    
    // 重写触摸事件  解决scrollView 与子控件的手势冲突
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIImageView.self) {
            return true
        }
        return false
    }
}


extension MapScrollView {
    
    /*
    *isZoom: 是否需要提前计算缩放倍率
    */
    internal func relativeBottomViewCoordinatesPoint(point: CGPoint, isZoom: Bool = true) -> CGPoint {
        let scale = isZoom ? lastScaleFactor : 1
        let Px = ((self.bottomView?.bounds.width)! - (self.bitMapView?.bounds.width)!) / 2
        let Py = ((self.bottomView?.bounds.height)! - (self.bitMapView?.bounds.height)!) / 2
        let pointNew = CGPoint(x: (point.x + Px) * scale, y: (point.y + Py) * scale)
        return pointNew
    }
    
    // 转化为相对地图的坐标
    internal func relativeMapCoordinatesPoint(point: CGPoint) -> CGPoint {
        let Px = ((self.bottomView?.bounds.width)! - (self.bitMapView?.bounds.width)!) / 2
        let Py = ((self.bottomView?.bounds.height)! - (self.bitMapView?.bounds.height)!) / 2
        let pointNew = CGPoint(x: (point.x / self.lastScaleFactor - Px) / self.baseScale  , y: (point.y / self.lastScaleFactor - Py)  / self.baseScale)
        
        return pointNew
    }
    
    
    /*
     *isZoom: 是否需要提前计算缩放倍率
     */
    internal func realCoordiToRealativeCoord(point: CGPoint,isZoom: Bool = true) -> CGPoint {
        let scale = self.baseScale
        guard let minPoint = self.bitMapModel?.minPoint else { return .zero}
        let X = point.x - minPoint.x
        let Y = minPoint.y - point.y
        let point1 = CGPoint(x: X / 0.05 * scale, y: Y / 0.05 * scale)
        return relativeBottomViewCoordinatesPoint(point: point1,isZoom: isZoom) as! CGPoint
    }
}
