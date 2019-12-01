//
//  Resume.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct ResumeModel {
    var name:String
    var thumbnailImage:String
    var dateCreated:String
    var feedback:FeedbackModel
    
    init() {
        self.name = ""
        self.thumbnailImage = ""
        self.dateCreated = ""
        self.feedback = FeedbackModel()
    }
}
