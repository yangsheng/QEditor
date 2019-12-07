//
//  EditVideoModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/10.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

/// 描述剪辑整个视频轨道的model
struct EditVideoModel {
    var composition: AVMutableComposition
    var formatTime: String
}

struct EditChangeScaleModel {
    let beginTime: Double
    let endTime: Double
    let scaleDuration: Double
}