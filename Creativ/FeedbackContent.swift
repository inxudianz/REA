//
//  FeedbackContent.swift
//  Creativ
//
//  Created by Owen Prasetya on 08/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

class FeedbackContent {
    // Array yang berisi data feedback section
    var images: [UIImage] = []
    var titles: [String] = []
    
    var comments:[String] = []
    // var comment:[Int:String]?
    
    var recommendations:[String] = []
    // var recommendation:[Int:String]?

    func createFeedbackSection() {
        images = [UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp")] as! [UIImage]
        titles = ["Profile", "Education", "Summary", "Working Experience", "Organisational Experience", "Skills"]
        comments = ["Good job", "G Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good job Good jobGood jobGood jobGood jobGood jobGood jobGood job", "Y", "K", "O", "H"]
        recommendations = ["Good job", "G", "Y", "K", "O", "H"]
    }
}
