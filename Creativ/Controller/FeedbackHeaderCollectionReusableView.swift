//
//  FeedbackHeaderCollectionReusableView.swift
//  Creativ
//
//  Created by Owen Prasetya on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class FeedbackHeaderCollectionReusableView: UICollectionReusableView {

  //  @IBOutlet weak var reaImage: UIImageView!
    
    @IBOutlet weak var mascotImageView: UIImageView! {
        didSet {
            mascotImageView.image = UIImage(named: "feedback")
        }
    }
    @IBOutlet weak var bubbleMessageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
