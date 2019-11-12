//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit


class onGoingProcess {
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

        // Do any additional setup after loading the view.
        onGoingRow.rowIndexPath = IndexPath(row: 0, section: processCollectionView.numberOfSections - 1)
        onGoingRow.doneArray = []
        
        setCollectionViewLayout()
    }

    // Change this function with the function to be called automatically upon completion on certain progress
    @IBAction func moveTableCellTapped(_ sender: Any) {
        
        var cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        
        if onGoingRow.rowIndexPath!.row < processDetails.count - 1 {
            onGoingRow.doneArray?.append(onGoingRow.rowIndexPath?.row ?? -1)
            cell?.setCellStatus(statusType: .done)
            
            onGoingRow.rowIndexPath?.row += 1
            cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
            cell?.setCellStatus(statusType: .working)
            
            processCollectionView.scrollToItem(at: onGoingRow.rowIndexPath!, at: .centeredVertically, animated: true)
        }
        else {
            if !(onGoingRow.doneArray?.contains(onGoingRow.rowIndexPath!.row))! {
                onGoingRow.doneArray?.append(onGoingRow.rowIndexPath!.row)
                cell?.setCellStatus(statusType: .done)
            }
            else {
                onGoingRow.rowIndexPath?.row = 0
                performSegue(withIdentifier: "goToOverview", sender: self)
            }
        }

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
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(
            top: (processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!)?.frame.size.height ?? processCollectionView.frame.height / 2),
            left: processCollectionView.frame.size.width / 4,
            bottom: (processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!)?.frame.size.height ?? processCollectionView.frame.height / 4),
            right: processCollectionView.frame.size.width / 4)
        layout.itemSize = CGSize(width: self.processCollectionView.frame.width, height: processCollectionView.frame.height / 4)
        
        processCollectionView.collectionViewLayout = layout
    }
    
}
