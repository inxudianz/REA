//
//  ProcessTableViewCell.swift
//  Creativ
//
//  Created by Owen Prasetya on 08/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class ProcessTableViewCell: UITableViewCell {

    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayFeedbackContent(text: String) {
        // Menggunakan array dulu sebagai patokan jenis-jenis feedback
        processLabel.text = text
    }

}
