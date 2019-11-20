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
}
