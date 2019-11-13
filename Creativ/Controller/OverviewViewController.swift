//
//  OverviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {

    @IBOutlet weak var overviewNavigationBar: UINavigationItem! {
        didSet {
            let standard = UINavigationBarAppearance()
            let button = UIBarButtonItemAppearance(style: .plain)
            standard.buttonAppearance = button

            overviewNavigationBar.backBarButtonItem = UIBarButtonItem(title: "All Resume", style: .plain, target: self, action: #selector(backToHome))
        }
    }
        
    // Images
    @IBOutlet weak var mascotSprite: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    let feedbackContents = FeedbackContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackContents.createFeedbackSection()
    }
    
    // Unwind back to the All Resume Page
    @objc func backToHome(_ unwindSegue: UIStoryboardSegue) { print("back") }
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = layout.minimumInteritemSpacing * 2
        layout.sectionInset = UIEdgeInsets(top: 0, left:
            layout.minimumInteritemSpacing, bottom: 0, right: layout.minimumInteritemSpacing)
        layout.itemSize = CGSize(width: self.feedbackCollectionView.frame.width, height: self.feedbackCollectionView.frame.height * 9/10)
        feedbackCollectionView.collectionViewLayout = layout
    }
}


extension OverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
