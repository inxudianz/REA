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
    let customFont = CustomFont()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = nama
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: customFont.getCustomFontType(type: .Regular, size: 17)], for: .normal)
        feedbackCollectionView.delegate = self
        feedbackCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        feedbackCollectionView.register(UINib(nibName: "FeedbackCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedbackCollectionViewCell")
        
        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackData.createFeedbackSection()
    }
    
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = CGSize(width: self.feedbackCollectionView.bounds.width, height: self.feedbackCollectionView.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2, bottom: 0, right: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2)
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
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableViewID", for: indexPath) as? HomeCollectionReusableView {
                headerView.textDescription.text = "Here are the analysis of your resume based on each content!"
                headerView.textDescription.sizeToFit()
                headerView.textDescription.numberOfLines = 0
                headerView.textDescription.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 162, height: headerView.textDescription.bounds.height)
                headerView.addBubble(height: headerView.textDescription.frame.maxY, width: headerView.textDescription.frame.maxX)
                headerView.bringSubviewToFront(headerView.textDescription)
                return headerView
            }
            return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 180)
    }
}
