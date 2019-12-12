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
    let customFont = CustomFont()
    
    @IBOutlet weak var processLabel: UILabel! {
        didSet {
            processLabel.font = customFont.getCustomFontType(type: .Regular, size: 16)
        }
    }
    @IBOutlet weak var statusIndicator: UIView! {
        didSet {
            statusIndicator.backgroundColor = UIColor.clear
            statusIndicator.contentMode = .center
        }
    }
    var doneImage = UIImageView()
    var actInd = UIActivityIndicatorView() {
        didSet {
            actInd.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        }
    }
    
    func setProcessContent(text: String) {
        processLabel.text = text
    }
    
    func setCellStatus(statusType: StatusType) {
        setStatusIndicator(statusType: statusType ?? StatusType.idle)
        actInd.layoutSubviews()
    }
    
    func setStatusIndicator(statusType: StatusType) {
        switch statusType {
        case .idle:
            UIView.performWithoutAnimation {
                actInd.frame.origin.y = statusIndicator.frame.height / 2
                actInd.frame.origin.x = statusIndicator.frame.width / 2 + 7
            }
            
            //Set label to half transparent, indicator view to nothing
            processLabel.alpha = 0.4
            statusIndicator.isHidden = false
            break
        case .working:
            UIView.performWithoutAnimation {
                actInd.frame.origin.y = statusIndicator.frame.height / 2
                actInd.frame.origin.x = statusIndicator.frame.width / 2 + 7
            }
            actInd.startAnimating()
            
            //Set label to appear, indicator view to activity indicator
            processLabel.alpha = 1.0
            statusIndicator.isHidden = false
            statusIndicator.addSubview(actInd)
            
            break
        case .done:
            doneImage.image = UIImage(named: "Checkmark")
            doneImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
            //Set label to appear, indicator view to checkmark
            statusIndicator.isHidden = false
            actInd.stopAnimating()
            actInd.isHidden = true
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                self.statusIndicator.addSubview(self.doneImage)
            }) { (true) in
                UIView.animate(withDuration: 0.5, delay: 0.7, options: .curveEaseOut, animations: {
                    self.statusIndicator.alpha = 0
                    self.processLabel.alpha = 0
                })
            }
            break
        }
    }
    
}
