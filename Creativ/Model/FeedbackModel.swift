//
//  FeedbackModel.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct FeedbackModel {
    var id:Int
    var overview:String
    var contents:[FeedbackDetailModel]
    
    init() {
        self.id = 0
        self.overview = ""
        self.contents = [FeedbackDetailModel()]
    }
    
    init(id: Int, overview: String, contents: [FeedbackDetailModel]) {
        self.id = id
        self.overview = overview
        self.contents = contents
    }
}
