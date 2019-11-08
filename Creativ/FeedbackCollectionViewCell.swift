//
//  FeedbackCollectionViewCell.swift
//  Creativ
//
//  Created by Owen Prasetya on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit


//struct Feedback {
//    let glyph: UIImage
//    let title: String
//    let comment: String
//    let recommendation: String
//}

class FeedbackCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var feedbackGlyph: UIImageView!
    @IBOutlet var feedbackOverview: UILabel!
    @IBOutlet weak var feedbackCommentedContent: UILabel!
    @IBOutlet var feedbackComment: UILabel!
    @IBOutlet var feedbackRecommendation: UILabel!
    
    
    func displayFeedbackContent(image: UIImage, title: String, comment: String, recommendation: String) {

        // Menggunakan array dulu sebagai patokan jenis-jenis feedback
        feedbackGlyph.image = image
        feedbackOverview.text = title
        feedbackComment.text = comment
        feedbackRecommendation.text = recommendation
    }
    
    
}
