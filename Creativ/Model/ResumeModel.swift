//
//  Resume.swift
//  Creativ
//
//  Created by William Inx on 15/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

struct ResumeModel {
    var name:String
    var thumbnailImage:Data
    var dateCreated:String
    var feedback:FeedbackModel
    
    init() {
        self.name = ""
        self.thumbnailImage = Data()
        self.dateCreated = ""
        self.feedback = FeedbackModel()
    }
    
    init(name: String, thumbnailImage:Data, dateCreated:String, feedback: FeedbackModel) {
        self.name = name
        self.thumbnailImage = thumbnailImage
        self.dateCreated = dateCreated
        self.feedback = feedback
    }
}
