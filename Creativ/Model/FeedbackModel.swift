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
    var contents:[FeedbackContentModel]
    
    init() {
        self.score = 0
        self.overview = ""
        self.contents = FeedbackContentModel()
    }
}
