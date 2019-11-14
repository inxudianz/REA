//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit


struct onGoingProcess {
    var rowIndexPath: IndexPath?
    var doneArray: [Int]?
}


class ProcessingViewController: UIViewController {

    @IBOutlet weak var mascotSpriteImage: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
    @IBOutlet weak var processCollectionView: UICollectionView! {
        didSet {
            processCollectionView.isUserInteractionEnabled = false
        }
    }
    
    // Explanation: -Process Details memuat detail dari proses yang akan dijalankan-
    var processDetails: [String] = ["Checking Identity", "Looking at Summary", "Viewing Education", "Evaluating Your Work", "Analyzing Skills", "Finalizing"]
    // Explanation: -onGoingRow merupakan instance onGoingProcess, yang berisi row yang sedang berjalan dan array proses yang telah selesai berjalan-
    var onGoingRow = onGoingProcess()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBubble()
        // Do any additional setup after loading the view.
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        setCollectionViewLayout()
    }
    
    func addBubble(){
           let width: CGFloat = 252
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
           outgoingMessageLayer.frame = CGRect(x: 115,
                                               y: self.view.frame.maxY/3,
                                               width: 68,
                                               height: 34)
           outgoingMessageLayer.fillColor = UIColor(red: 0.09, green: 0.54, blue: 1, alpha: 1).cgColor
           
        self.view.layer.addSublayer(outgoingMessageLayer)
       }

    // Change this function with the function to be called automatically upon completion on certain progress
    @IBAction func moveTableCellTapped(_ sender: Any) {
        
        var cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        
        guard let onGoingIndex = onGoingRow.rowIndexPath else { return }
        onGoingRow.doneArray?.append(onGoingIndex.row)
        cell?.setCellStatus(statusType: .done)
        
        onGoingRow.rowIndexPath?.row += 1
        cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        cell?.setCellStatus(statusType: .working)
        
        if onGoingRow.rowIndexPath!.row + 2 < processDetails.count {
            processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row + 1, section: 0), at: .bottom, animated: true)
        }
        else if onGoingRow.rowIndexPath!.row < processDetails.count{
             processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row - 2, section: 0), at: .top, animated: true)
        }
        else {
            if onGoingRow.doneArray!.count < processDetails.count {
                onGoingRow.doneArray?.append(onGoingRow.rowIndexPath!.row)
                cell?.setCellStatus(statusType: .done)
            }
            else {
                onGoingRow.rowIndexPath?.row = 0
                performSegue(withIdentifier: "goToOverview", sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension ProcessingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return processDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  =  processCollectionView.dequeueReusableCell(withReuseIdentifier: "processCell", for: indexPath) as! ProcessCollectionViewCell
        cell.setProcessContent(text: processDetails[indexPath.row])
        
        if indexPath.row == 0 {
            cell.setCellStatus(statusType: .working)
        }
        else {
            cell.setCellStatus(statusType: .idle)
        }
        return cell
    }
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: layout.itemSize.height * 2,
            left: processCollectionView.frame.size.width / 4,
            bottom: layout.itemSize.height * 2,
            right: processCollectionView.frame.size.width / 4)
        layout.itemSize = CGSize(width: self.processCollectionView.frame.width, height: processCollectionView.frame.height / 4)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = layout.itemSize.width
        
        processCollectionView.contentInsetAdjustmentBehavior = .always
        processCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        processCollectionView.collectionViewLayout = layout
    }
    
}
