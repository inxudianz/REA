//
//  FeedbackContentModel.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct FeedbackContentModel {
    var type:String
    var score:Int
    var overview:String
    var details:[FeedbackContentDetailModel]
    
    init() {
        self.type = ""
        self.score = 0
        self.overview = ""
        self.details = [FeedbackContentDetailModel()]
    }
    
    init(type: String, score: Int, overview:String, details: [FeedbackContentDetailModel]) {
        self.type = type
        self.score = score
        self.overview = overview
        self.details = details
    }
}
