//
//  OverviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {

    @IBOutlet weak var overviewNavigationBar: UINavigationItem!
        
    // Images
    @IBOutlet weak var mascotSprite: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    let feedbackContents = FeedbackContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overviewNavigationBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneReview))

        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        
        
        feedbackContents.createFeedbackSection()
    }
    
    // Unwind back to the All Resume Page
    @objc func doneReview(_ unwindSegue: UIStoryboardSegue) {}
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 2, left:
            layout.minimumInteritemSpacing, bottom: 2, right: layout.minimumInteritemSpacing)
        layout.itemSize = CGSize(width: self.feedbackCollectionView.frame.width, height: self.feedbackCollectionView.frame.height * 5/6)
        
        feedbackCollectionView.collectionViewLayout = layout
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension OverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbackContents.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = feedbackCollectionView.dequeueReusableCell(withReuseIdentifier: "feedbackCollectionViewCell", for: indexPath) as! FeedbackCollectionViewCell
       
        
       let cellFeedback = Feedbacks(image: feedbackContents.images[indexPath.row], title: feedbackContents.titles[indexPath.row], commentedText: feedbackContents.commentedTexts[indexPath.row], comment: feedbackContents.comments[indexPath.row], recommendation: feedbackContents.recommendations[indexPath.row])

       cell.displayFeedbackContent(feedback: cellFeedback)
       
       return cell
    }

}
