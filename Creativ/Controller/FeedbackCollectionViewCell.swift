//
//  FeedbackCollectionViewCell.swift
//  Creativ
//
//  Created by Owen Prasetya on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class FeedbackCollectionViewCell: UICollectionViewCell {
    
    let customFont = CustomFont()

    @IBOutlet weak var overviewLabel: UILabel! {
        didSet {
            overviewLabel.font = customFont.getCustomFontType(type: .Bold, size: 18)
        }
    }
    @IBOutlet weak var keypointLabel: UILabel! {
        didSet {
            keypointLabel.font = customFont.getCustomFontType(type: .Bold, size: 18)
        }
    }
    @IBOutlet var feedbackGlyph: UIImageView!
    @IBOutlet weak var feedbackSegment: UILabel! {
        didSet {
            feedbackSegment.textColor = UIColor.white
            feedbackSegment.font = customFont.getCustomFontType(type: .Bold, size: 24)
        }
    }
    @IBOutlet var feedbackOverview: UILabel! {
        didSet {
            feedbackOverview.textAlignment = .left
            feedbackOverview.font = customFont.getCustomFontType(type: .Regular, size: 16)
        }
    }
    @IBOutlet weak var feedbackCommentedContent: UILabel! {
        didSet {
            feedbackCommentedContent.font = customFont.getCustomFontType(type: .BoldItalic, size: 18)
        }
    }
    @IBOutlet var feedbackComment: UILabel! {
        didSet {
            feedbackComment.font = customFont.getCustomFontType(type: .Regular, size: 16)
        }
    }
    @IBOutlet var feedbackRecommendation: UILabel! {
        didSet {
            feedbackRecommendation.font = customFont.getCustomFontType(type: .Regular, size: 16)
        }
    }
    @IBOutlet weak var feedbackView: UIView!{
        didSet{
            feedbackView.clipsToBounds = true
        }
    }
    @IBOutlet weak var notchView: UIView! {
        didSet {
            notchView.clipsToBounds = true
        }
    }
    @IBOutlet weak var commentView: UIView! {
        didSet {
            commentView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func displayFeedbackContent(feedback: Feedbacks) {
        // Menggunakan array dulu sebagai patokan jenis-jenis feedback
        feedbackGlyph.image = feedback.image
        feedbackSegment.text = feedback.title
        feedbackOverview.text = feedback.overviewText
        feedbackCommentedContent.text = feedback.commentedText
        feedbackComment.text = feedback.comment
        feedbackRecommendation.text = feedback.recommendation
    }
    
    func setupUI() {
        feedbackView.backgroundColor = UIColor(cgColor: feedbackView.layer.borderColor!)
        feedbackView.layer.cornerRadius = feedbackView.frame.size.width / 20
        
        notchView.backgroundColor = UIColor(cgColor: notchView.layer.borderColor!)
        notchView.layer.cornerRadius = notchView.frame.size.width / 2
        
        //commentView.backgroundColor = UIColor.white
        if traitCollection.userInterfaceStyle == .dark {
            commentView.backgroundColor = UIColor.black
        }
        else if traitCollection.userInterfaceStyle == .light {
            commentView.backgroundColor = UIColor.white
        }
        commentView.layer.cornerRadius = commentView.frame.size.width / 20
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            commentView.backgroundColor = UIColor.black
        }
        else if traitCollection.userInterfaceStyle == .light {
            commentView.backgroundColor = UIColor.white
        }
    }
    
    func setColorBlue(colorView: inout UIView) {
        colorView.layer.borderWidth = 2.0
        colorView.layer.borderColor = UIColor.init(hex: "#4B96DCFF")!.cgColor
    }
    
    func setColorRed(colorView: inout UIView) {
        colorView.layer.borderWidth = 2.0
        colorView.layer.borderColor = UIColor.init(hex: "#C33737FF")!.cgColor
    }
    
    func setColorYellow(colorView: inout UIView) {
        colorView.layer.borderWidth = 2.0
        colorView.layer.borderColor = UIColor.init(hex: "#BE5000FF")!.cgColor
        
    }
    
    func setColorGreen(colorView: inout UIView) {
        colorView.layer.borderWidth = 2.0
        colorView.layer.borderColor = UIColor.init(hex: "#41911EFF")!.cgColor
    }
}

