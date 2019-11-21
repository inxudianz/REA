//
//  CVNewCollectionViewCell.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class CVNewCollectionViewCell: UICollectionViewCell {
    
    let customFont = CustomFont()
    
    @IBOutlet weak var cvThumbnailImage: UIImageView!
    @IBOutlet weak var cvNameLbl: UILabel! {
        didSet {
            cvNameLbl.font = customFont.getCustomFontType(type: .Regular, size: 21)
        }
    }
    @IBOutlet weak var cvDateLbl: UILabel! {
        didSet {
            cvDateLbl.font = customFont.getCustomFontType(type: .Light, size: 14)
        }
    }
    @IBOutlet weak var checklistImg: UIImageView!
    
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
        cvThumbnailImage.layer.borderColor = #colorLiteral(red: 0.1882352941, green: 0.4, blue: 0.6078431373, alpha: 1)
        cvThumbnailImage.layer.cornerRadius = 8.0
        cvThumbnailImage.layer.masksToBounds = false
        cvThumbnailImage.clipsToBounds = true
    }
}
