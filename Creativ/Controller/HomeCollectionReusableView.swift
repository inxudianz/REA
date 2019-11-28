//
//  HomeCollectionReusableView.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 13/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class HomeCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var reaImageView: UIImageView!
    @IBOutlet weak var bubbleChatView: UIView!
    @IBOutlet weak var textDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //addBubble()
        // Initialization code
    }
    
    func addBubble(height: CGFloat, width: CGFloat){

//        let width: CGFloat = UIScreen.main.bounds.width - 162
//        let height: CGFloat = 87
        
        let xStart: CGFloat = 22
        
        let bubbleWidth: CGFloat = width
        let bubbleHeight: CGFloat = height + 20
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: xStart, y: bubbleHeight))
        bezierPath.addLine(to: CGPoint(x: bubbleWidth - 17, y: bubbleHeight))
        bezierPath.addCurve(to: CGPoint(x: bubbleWidth, y: bubbleHeight - 17), controlPoint1: CGPoint(x: bubbleWidth - 7.61, y: bubbleHeight), controlPoint2: CGPoint(x: bubbleWidth, y: bubbleHeight - 7.61))
        bezierPath.addLine(to: CGPoint(x: bubbleWidth, y: 17))
        bezierPath.addCurve(to: CGPoint(x: bubbleWidth - 17, y: 0), controlPoint1: CGPoint(x: bubbleWidth, y: 7.61), controlPoint2: CGPoint(x: bubbleWidth - 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: xStart - 1, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: 4, y: bubbleHeight - 11))
        bezierPath.addCurve(to: CGPoint(x: 0, y: bubbleHeight), controlPoint1: CGPoint(x: 4, y: bubbleHeight - 1), controlPoint2: CGPoint(x: 0, y: bubbleHeight))
        bezierPath.addLine(to: CGPoint(x: -0.05, y: bubbleHeight - 0.01))
        bezierPath.addCurve(to: CGPoint(x: 11.04, y: bubbleHeight - 4.04), controlPoint1: CGPoint(x: 4.07, y: bubbleHeight + 0.43), controlPoint2: CGPoint(x: 8.16, y: bubbleHeight - 1.06))
        bezierPath.addCurve(to: CGPoint(x: xStart, y: bubbleHeight), controlPoint1: CGPoint(x: 16, y: bubbleHeight), controlPoint2: CGPoint(x: 19, y: bubbleHeight))
        bezierPath.close()
        
        let outgoingMessageLayer = CAShapeLayer()
        outgoingMessageLayer.path = bezierPath.cgPath
        outgoingMessageLayer.frame = CGRect(x: 0,
                                            y: 0,
                                            width: bubbleWidth,
                                            height: bubbleHeight)
        outgoingMessageLayer.fillColor = UIColor(hex: "#4B96DCFF")?.cgColor
        
//        // 1
//        let textLayer = CATextLayer()
//        textLayer.frame = bubbleChatView.bounds
//
//        // 2
//        let string = String(
//          repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce auctor arcu quis velit congue dictum. ",
//          count: 50
//        )
//
//        textLayer.string = string
//
//        // 3
//        textLayer.font = UIFont(name: "Merriweather", size: 14)
//
//        // 4
//        textLayer.foregroundColor = UIColor.darkGray.cgColor
//        textLayer.isWrapped = true
//        textLayer.alignmentMode = .left
//        textLayer.contentsScale = UIScreen.main.scale
        
        textDescription.font = UIFont(name: "Merriweather", size: 16)
        textDescription.textColor = .white
        textDescription.textAlignment = .left
        
        
        self.bubbleChatView.layer.addSublayer(outgoingMessageLayer)
        bubbleChatView.bringSubviewToFront(textDescription)
        print(textDescription)
        print(bubbleHeight, bubbleWidth)
        //self.bubbleChatView.layer.addSublayer(textLayer)
    }
    
}
