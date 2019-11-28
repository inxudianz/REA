//
//  AddNewCollectionViewCell.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class AddNewCollectionViewCell: UICollectionViewCell {
    
    let customFont = CustomFont()
    
    @IBOutlet weak var addNewCvBtn: UIButton!
    @IBOutlet weak var addNewCvBtnLabel: UILabel! {
        didSet {
            addNewCvBtnLabel.font = customFont.getCustomFontType(type: .Regular, size: 14)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addNewCvBtn.layer.borderColor = #colorLiteral(red: 0.1882352941, green: 0.4, blue: 0.6078431373, alpha: 1)
        addNewCvBtn.layer.borderWidth = 4
        addNewCvBtn.layer.cornerRadius = 8
        addNewCvBtn.layer.masksToBounds = false
        addNewCvBtn.clipsToBounds = true
    }
    
    
    
}
