//
//  FeedbackContent.swift
//  Creativ
//
//  Created by Owen Prasetya on 08/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

struct Feedbacks {
    var image = UIImage()
    var title = String()
    var overviewText = String()
    var commentedText = String()
    var comment = String()
    var recommendation = String()
}

class FeedbackContent {
    
    // Array yang berisi data feedback section
    var images: [UIImage] = []
    var titles: [String] = []
    var overviewTexts: [String] = []
    var commentedTexts: [String] = []
    
    var comments:[String] = []
    // var comment:[Int:String]?
    
    var recommendations:[String] = []
    // var recommendation:[Int:String]?

    func createFeedbackSection() {
        images = [UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp")] as! [UIImage]
        titles = ["Profile", "Education", "Summary", "Working Experience", "Organisational Experience", "Skills"]
        overviewTexts = ["Good job", "Good", "Yay!!", "Kayyyy", "Ol right", "Huperb!"]
        commentedTexts = ["I am diligent", "I am a nice and hard working man", "Hello", "Hello", "Hello", "Hello"]
        comments = ["Good job", "G Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job", "Y", "K", "O", "H"]
        recommendations = ["Good job", "Good", "Yay!!", "Kayyyy", "Ol right", "Huperb!"]
    }
}
