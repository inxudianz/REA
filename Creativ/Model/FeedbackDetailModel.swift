//
//  FeedbackContentModel.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct FeedbackDetailModel {
    var type:String
    var id:Int
    var overview:String
    
    init() {
        self.type = ""
        self.id = 0
        self.overview = ""
    }
    
    init(type: String, id: Int, overview:String) {
        self.type = type
        self.id = id
        self.overview = overview
    }
}
