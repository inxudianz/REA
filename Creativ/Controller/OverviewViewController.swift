//
//  OverviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {

    var nama: String?
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    let feedbackData = FeedbackData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = nama
        feedbackCollectionView.delegate = self
        feedbackCollectionView.register(UINib(nibName: "FeedbackHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedbackHeaderCollectionReusableView")
        feedbackCollectionView.register(UINib(nibName: "FeedbackCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedbackCollectionViewCell")
        
        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackData.createFeedbackSection()
    }
    
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = layout.minimumInteritemSpacing * 2
        layout.sectionInset = UIEdgeInsets(top: 0, left:
            0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.feedbackCollectionView.frame.width, height: self.feedbackCollectionView.frame.height * 7/11)
        feedbackCollectionView.collectionViewLayout = layout
    }
    
    
}


extension OverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbackData.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = feedbackCollectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCollectionViewCell", for: indexPath) as! FeedbackCollectionViewCell
       let cellFeedback = Feedbacks(image: feedbackData.images[indexPath.row], title: feedbackData.titles[indexPath.row], overviewText: feedbackData.overviewTexts[indexPath.row], commentedText: feedbackData.commentedTexts[indexPath.row], comment: feedbackData.comments[indexPath.row], recommendation: feedbackData.recommendations[indexPath.row])
       
       cell.setColor(colorView: &cell.feedbackView)
       cell.setColor(colorView: &cell.notchView)
       cell.setColor(colorView: &cell.commentView)
       cell.setupUI()

       cell.displayFeedbackContent(feedback: cellFeedback)
       
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
        UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedbackHeaderCollectionReusableView", for: indexPath) as? UICollectionReusableView {
            return headerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0))?.frame.height ?? collectionView.frame.height / 5)
    }
}
