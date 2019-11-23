//
//  FeedbackHeaderCollectionReusableView.swift
//  Creativ
//
//  Created by Owen Prasetya on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class FeedbackHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var reaImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBubble()
        // Initialization code
    }
    
    func addBubble(){
        let width: CGFloat = UIScreen.main.bounds.width - 162
        let height: CGFloat = 87
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 22, y: height))
        bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
        bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
        bezierPath.addLine(to: CGPoint(x: width, y: 17))
        bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: 21, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
        bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
        bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
        bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
        bezierPath.close()
        
        let outgoingMessageLayer = CAShapeLayer()
        outgoingMessageLayer.path = bezierPath.cgPath
        outgoingMessageLayer.frame = CGRect(x: 122,
                                            y: 15,
                                            width: 68,
                                            height: 34)
        outgoingMessageLayer.fillColor = UIColor(hex: "#4B96DCFF")?.cgColor

        self.layer.addSublayer(outgoingMessageLayer)
    }

}
