//
//  FeedbackModel.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct FeedbackModel {
    var score:Int
    var overview:String
    var contents:[FeedbackDetailModel]
    
    init() {
        self.score = 0
        self.overview = ""
        self.contents = [FeedbackDetailModel()]
    }
    
    init(score: Int, overview: String, contents: [FeedbackDetailModel]) {
        self.score = score
        self.overview = overview
        self.contents = contents
    }
}
