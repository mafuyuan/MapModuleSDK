//
//  AreaModel.swift
//  PublicDeviceModule
//
//  Created by 马伟龙 on 2020/9/17.
//

import Foundation
import UIKit

enum areaType {
    case zoneArea
    case forbidArea
    case virtual
}

struct AreaModel {
    var points: [[CGPoint]]
    var names: [String]
    var type: [areaType]
}



