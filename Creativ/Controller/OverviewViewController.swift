//
//  OverviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    var feedbackDatas = FeedbackData()
    var fetchedResume: ResumeModel = ResumeModel()
    let customFont = CustomFont()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = fetchedResume.name
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: customFont.getCustomFontType(type: .Regular, size: 17)], for: .normal)
        feedbackCollectionView.delegate = self
        feedbackCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        
        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackDatas.createFeedbackSection()
    }
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = CGSize(width: self.feedbackCollectionView.bounds.width, height: self.feedbackCollectionView.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2, bottom: 0, right: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2)
        feedbackCollectionView.collectionViewLayout = layout
    }
    
    func checkFeedback(feedbackResult: [FeedbackDetailModel]) {
        for x in 0 ..< feedbackResult.count {
            //kalo semua konten salah (kotak warna merah)
            if feedbackResult[0].overview.contains("Your summary is getting too long, reduce few words to make it more simple.") && feedbackResult[0].overview.contains("It seems that you used 'words' too much, try to use another words!") && feedbackResult[0].overview.contains("You have to use more action verbs in your summary.") && feedbackResult[0].overview.contains("Vague") && feedbackResult[0].overview.contains("Not Passionate") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You must improve this part!"
            }
            
            if feedbackResult[1].overview.contains("No phone number? Please put your email in your summary!") && feedbackResult[1].overview.contains("No email? Please put your email in your summary!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You must improve this part!"
            }
            
            /* Masih belum di pakai karena blm ada perbandingan (hanya satu hal yang di validasi)
             if feedbackResult[2].contains("It's better not to show your GPA in your resume.") || feedbackResult[2].contains("You can add your GPA if it's more than equal to 3.") {
             feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
             feedbackDatas.commentedTexts[2] = "You can be better!"
             }
             
             if feedbackResult[3].contains("Rearrange your working experiences from the most current until the latest one!") {
             feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
             feedbackDatas.commentedTexts[3] = "You can be better!"
             }
             
             if feedbackResult[4].contains("Rearrange your organisational experiences from the most current until the latest one!") {
             feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
             feedbackDatas.commentedTexts[4] = "You can be better!"
             }
             
             if feedbackResult[5].contains("You have to put your skills that match with job that you've applied.") {
             feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
             feedbackDatas.commentedTexts[5] = "You can be better!"
             }
             */
            
            // kalo semuanya konten salah semua (kotak warna merah)
            if feedbackResult[0].overview.contains("Your summary is getting too long, reduce few words to make it more simple.") || feedbackResult[0].overview.contains("It seems that you used 'words' too much, try to use another words!") || feedbackResult[0].overview.contains("You have to use more action verbs in your summary.") || feedbackResult[0].overview.contains("Vague") || feedbackResult[0].overview.contains("Half Vague") || feedbackResult[0].overview.contains("Half Passionate") || feedbackResult[0].overview.contains("Not Passionate") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You can be better!"
            }
            
            if feedbackResult[1].overview.contains("No phone number? Please put your email in your summary!") || feedbackResult[1].overview.contains("No email? Please put your email in your summary!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You can be better!"
            }
            
            if feedbackResult[2].overview.contains("It's better not to show your GPA in your resume.") || feedbackResult[2].overview.contains("You can add your GPA if it's more than equal to 3.") {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
                feedbackDatas.commentedTexts[2] = "You can be better!"
            }
            
            if feedbackResult[3].overview.contains("Rearrange your working experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
                feedbackDatas.commentedTexts[3] = "You can be better!"
            }
            
            if feedbackResult[4].overview.contains("Rearrange your organisational experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
                feedbackDatas.commentedTexts[4] = "You can be better!"
            }
            
            if feedbackResult[5].overview.contains("You have to put your skills that match with job that you've applied.") {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
                feedbackDatas.commentedTexts[5] = "You can be better!"
            }
            
            //kalo konten gaada (kotak warna biru)
            if feedbackResult[x].overview.isEmpty {
                feedbackDatas.comments[x] = "We're missing \(feedbackResult[x].type) in your resume! It's either you haven't add it or we can't detect it because it's in another format."
                feedbackDatas.commentedTexts[x] = "Missing Content!"
            } else {
                feedbackDatas.comments[x] = feedbackResult[x].overview
            }
            
            if feedbackResult[0].overview.isEmpty {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
            }
            
            if feedbackResult[1].overview.isEmpty {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
            }
            
            if feedbackResult[2].overview.isEmpty {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
            }
            
            if feedbackResult[3].overview.isEmpty {
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
            }
            
            if feedbackResult[4].overview.isEmpty {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
            }
            
            if feedbackResult[5].overview.isEmpty {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
            }
        }
    }
}
    


extension OverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbackDatas.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedbackCollectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCollectionViewCell", for: indexPath) as! FeedbackCollectionViewCell
        
        if fetchedResume.feedback.contents.isEmpty == true {
            let cellFeedback = Feedbacks(image: feedbackDatas.images[indexPath.row], title: feedbackDatas.titles[indexPath.row], overviewText: feedbackDatas.overviewTexts[indexPath.row], commentedText: feedbackDatas.commentedTexts[indexPath.row], comment: feedbackDatas.comments[indexPath.row], recommendation: feedbackDatas.recommendations[indexPath.row])
            
            cell.setColorGreen(colorView: &cell.feedbackView)
            cell.setColorGreen(colorView: &cell.notchView)
            cell.setColorGreen(colorView: &cell.commentView)
            cell.setupUI()
            cell.displayFeedbackContent(feedback: cellFeedback)
            
            return cell
        } else {
            checkFeedback(feedbackResult: fetchedResume.feedback.contents)
            
            let cellFeedback = Feedbacks(image: feedbackDatas.images[indexPath.row], title: feedbackDatas.titles[indexPath.row], overviewText: feedbackDatas.overviewTexts[indexPath.row], commentedText: feedbackDatas.commentedTexts[indexPath.row], comment: feedbackDatas.comments[indexPath.row], recommendation: feedbackDatas.recommendations[indexPath.row])
            
            
            
            cell.setColorGreen(colorView: &cell.feedbackView)
            cell.setColorGreen(colorView: &cell.notchView)
            cell.setColorGreen(colorView: &cell.commentView)
            
            // kalo konten ga ketemu
            if feedbackDatas.commentedTexts[indexPath.row] == "Missing Content!" {
                cell.setColorBlue(colorView: &cell.feedbackView)
                cell.setColorBlue(colorView: &cell.notchView)
                cell.setColorBlue(colorView: &cell.commentView)
            }
            
            // kalo konten ada beberapa yg salah
            if feedbackDatas.commentedTexts[indexPath.row] == "You can be better!" {
                cell.setColorYellow(colorView: &cell.feedbackView)
                cell.setColorYellow(colorView: &cell.notchView)
                cell.setColorYellow(colorView: &cell.commentView)
            }
            
            // kalo semua konten salah
            if feedbackDatas.commentedTexts[indexPath.row] == "You must improve this part!" {
                cell.setColorRed(colorView: &cell.feedbackView)
                cell.setColorRed(colorView: &cell.notchView)
                cell.setColorRed(colorView: &cell.commentView)
            }
            
            cell.setupUI()
            cell.displayFeedbackContent(feedback: cellFeedback)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
        UICollectionReusableView {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableViewID", for: indexPath) as? HomeCollectionReusableView {
                headerView.reaProcessing(reaImages: ["rea1","rea2","rea1","rea2","rea3"])
                headerView.textDescription.text = "Here are the analysis of your resume based on each content!"
                headerView.textDescription.sizeToFit()
                headerView.textDescription.numberOfLines = 0
                headerView.addBubble(height: headerView.textDescription.frame.maxY, width: UIScreen.main.bounds.width - headerView.textDescription.frame.size.width + 15)
                headerView.bringSubviewToFront(headerView.textDescription)
                return headerView
            }
            return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 180)
    }
}
