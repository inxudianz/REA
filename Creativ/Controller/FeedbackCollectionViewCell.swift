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
            feedbackCommentedContent.font = customFont.getCustomFontType(type: .Italic, size: 18)
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
        feedbackView.layer.cornerRadius = feedbackView.frame.size.height / 20
        
        notchView.backgroundColor = UIColor(cgColor: notchView.layer.borderColor!)
        notchView.layer.cornerRadius = notchView.frame.size.width / 2
        
        //commentView.backgroundColor = UIColor.white
        if traitCollection.userInterfaceStyle == .dark {
            commentView.backgroundColor = UIColor.black
        }
        else if traitCollection.userInterfaceStyle == .light {
            commentView.backgroundColor = UIColor.white
        }
        commentView.layer.cornerRadius = commentView.frame.size.height / 20
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
    
    func setColor(colorView: inout UIView) {
        colorView.layer.borderWidth = 2.0
        colorView.layer.borderColor = UIColor(red: 0.294, green: 0.588, blue: 0.863, alpha: 1.0).cgColor
        
        /*
         switch feedbackSegment.text {
            case "Profile":
                colorView.layer.borderColor = UIColor(red: CGFloat(75/255), green: CGFloat(150/255), blue: CGFloat(220/255), alpha: 0.2).cgColor
            case "Education":
                colorView.layer.borderColor = UIColor(red: CGFloat(65/255), green: CGFloat(145/255), blue: CGFloat(30/255), alpha: 0.2).cgColor
            case "Summary":
                colorView.layer.borderColor = UIColor(red: CGFloat(65/255), green: CGFloat(145/255), blue: CGFloat(30/255), alpha: 0.2).cgColor
            case "Work Experience":
                colorView.layer.borderColor = UIColor(red: CGFloat(65/255), green: CGFloat(145/255), blue: CGFloat(30/255), alpha: 0.2).cgColor
            case "Organisational Experience":
                colorView.layer.borderColor = UIColor(red: CGFloat(65/255), green: CGFloat(145/255), blue: CGFloat(30/255), alpha: 0.2).cgColor
            case "Skills":
                colorView.layer.borderColor = UIColor(red: CGFloat(65/255), green: CGFloat(145/255), blue: CGFloat(30/255), alpha: 0.2).cgColor
            default:
                colorView.layer.borderColor = UIColor(red: CGFloat(0/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: 0.2).cgColor
                break
        }
        */
    }
}

