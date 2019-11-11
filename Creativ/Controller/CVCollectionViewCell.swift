//
//  CVCollectionViewCell.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class CVCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cvThumbnailImage: UIImageView!
    @IBOutlet weak var cvNameLbl: UILabel!
    @IBOutlet weak var cvDateLbl: UILabel!
    
    var content: HomeContent! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        cvThumbnailImage.image = content.cvImage
        cvNameLbl.text = content.cvName
        cvDateLbl.text = content.cvCreated
        
        cvThumbnailImage.layer.borderWidth = 3.0
        cvThumbnailImage.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        cvThumbnailImage.layer.cornerRadius = 8.0
        cvThumbnailImage.layer.masksToBounds = false
        cvThumbnailImage.clipsToBounds = true
        
    }
}
