//
//  SegmentedModel.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 20/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct SegmentedModel: Hashable {
    var label:String
    var type:String
    var fontSize:Double
    var isBold:Bool
    
    init() {
        label = ""
        type = ""
        fontSize = 0.0
        isBold = false
    }
    
    init(label: String, type: String, fontSize: Double, isBold: Bool) {
        self.label = label
        self.type = type
        self.fontSize = fontSize
        self.isBold = isBold
    }
}
