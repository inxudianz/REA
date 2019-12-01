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
    var thumbnailImage:UIImage
    var dateCreated:String
    var feedback:FeedbackModel
    
    init() {
        self.name = ""
        self.thumbnailImage = UIImage()
        self.dateCreated = ""
        self.feedback = FeedbackModel()
    }
    
    init(name: String, thumbnailImage:UIImage, dateCreated:String, feedback: FeedbackModel) {
        self.name = name
        self.thumbnailImage = thumbnailImage
        self.dateCreated = dateCreated
        self.feedback = feedback
    }
}
