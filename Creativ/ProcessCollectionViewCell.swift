//
//  ProcessCollectionViewCell.swift
//  Creativ
//
//  Created by Owen Prasetya on 11/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit
import Foundation

enum StatusType {
    case idle, working, done
}

class ProcessCollectionViewCell: UICollectionViewCell {
    
    private var status: StatusType?
    
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var statusIndicator: UIView!
    
    func setProcessContent(text: String) {
        processLabel.text = text
    }
    
    func setCellStatus(statusType: StatusType) {
        status = statusType
        setStatusIndicator(statusType: status ?? StatusType.idle)
    }
    
    func setStatusIndicator(statusType: StatusType) {
        switch statusType {
        case .idle:
           // print("\(String(describing: processLabel.text)) \(statusType)")
            processLabel.alpha = 0.4
            //Set indicator view to nothing
        case .working:
           // print("\(String(describing: processLabel.text)) \(statusType)")
            processLabel.alpha = 1.0
            // Set indicator view to indicator view image
        case .done:
            // print("\(String(describing: processLabel.text)) \(statusType)")
            processLabel.alpha = 0
            statusIndicator.alpha = 0
            // Set indicator view to checkmark
            break
        }
    }
    
}
