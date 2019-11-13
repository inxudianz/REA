//
//  PreviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var previewNavigationBar: UINavigationItem!
    
    // Images
    @IBOutlet weak var mascotSprite: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    let feedbackContents = FeedbackContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewNavigationBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneReview))

        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackContents.createFeedbackSection()
    }
    
    // Unwind back to the All Resume Page
    @objc func doneReview(_ unwindSegue: UIStoryboardSegue) {}
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = layout.minimumInteritemSpacing * 2
        layout.sectionInset = UIEdgeInsets(top: 2, left:
            layout.minimumInteritemSpacing, bottom: 2, right: layout.minimumInteritemSpacing)
        layout.itemSize = CGSize(width: self.feedbackCollectionView.frame.width, height: self.feedbackCollectionView.frame.height * 9/10)
        feedbackCollectionView.collectionViewLayout = layout
    }

}

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbackContents.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedbackCollectionView.dequeueReusableCell(withReuseIdentifier: "feedbackCollectionViewCell", for: indexPath) as! FeedbackCollectionViewCell
        
        let cellFeedback = Feedbacks(image: feedbackContents.images[indexPath.row], title: feedbackContents.titles[indexPath.row], overviewText: feedbackContents.overviewTexts[indexPath.row], commentedText: feedbackContents.commentedTexts[indexPath.row], comment: feedbackContents.comments[indexPath.row], recommendation: feedbackContents.recommendations[indexPath.row])
        
        print(cellFeedback.title)
        
        cell.setColor(colorView: &cell.feedbackView)
        cell.setColor(colorView: &cell.notchView)
        cell.setColor(colorView: &cell.commentView)
        cell.setupUI()

        cell.displayFeedbackContent(feedback: cellFeedback)

        return cell
    }
}
