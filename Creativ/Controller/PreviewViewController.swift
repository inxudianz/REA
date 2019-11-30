//
//  PreviewViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    let feedbackDatas = FeedbackData()
    let customFont = CustomFont()
    var finalFeedbackResult: [String] = []
    var headerCv: [String] = ["Summary", "Identity", "Education", "Working Experience", "Organisational Experience", "Skills"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneReview))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: customFont.getCustomFontType(type: .Regular, size: 17)], for: .normal)
        self.navigationItem.title = "Feedback"
        feedbackCollectionView.delegate = self
        feedbackCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        
        // Do any additional setup after loading the view.
        setCollectionViewLayout()
        feedbackDatas.createFeedbackSection()
    }
    
    // Unwind back to the All Resume Page
    @objc func doneReview(_ unwindSegue: UIStoryboardSegue) {
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = CGSize(width: self.feedbackCollectionView.bounds.width, height: self.feedbackCollectionView.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2, bottom: 0, right: (self.feedbackCollectionView.bounds.width - layout.estimatedItemSize.width) / 2)
        feedbackCollectionView.collectionViewLayout = layout
    }
}

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbackDatas.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = feedbackCollectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCollectionViewCell", for: indexPath) as! FeedbackCollectionViewCell

        if finalFeedbackResult.isEmpty == true {
            let cellFeedback = Feedbacks(image: feedbackDatas.images[indexPath.row], title: feedbackDatas.titles[indexPath.row], overviewText: feedbackDatas.overviewTexts[indexPath.row], commentedText: feedbackDatas.commentedTexts[indexPath.row], comment: feedbackDatas.comments[indexPath.row], recommendation: feedbackDatas.recommendations[indexPath.row])
            
            cell.setColorGreen(colorView: &cell.feedbackView)
            cell.setColorGreen(colorView: &cell.notchView)
            cell.setColorGreen(colorView: &cell.commentView)
            cell.setupUI()
            cell.displayFeedbackContent(feedback: cellFeedback)
            
            return cell
        } else {
            
            checkFeedback()
            
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
        //return CGSize(width: collectionView.frame.width, height: collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0))?.frame.height ?? collectionView.frame.height / 4)
        
        return CGSize(width: collectionView.frame.width, height: 180)
    }
    
    func checkFeedback() {
        feedbackDatas.comments = finalFeedbackResult
        
        for x in 0 ..< finalFeedbackResult.count {
            
            //kalo semua konten salah (kotak warna merah)
            if finalFeedbackResult[0].contains("Your summary is getting too long, reduce few words to make it more simple.") && finalFeedbackResult[0].contains("It seems that you used 'words' too much, try to use another words!") && finalFeedbackResult[0].contains("You have to use more action verbs in your summary.") && finalFeedbackResult[0].contains("Vague") && finalFeedbackResult[0].contains("Not Passionate") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You must improve this part!"
            }
            
            if finalFeedbackResult[1].contains("No phone number? Please put your email in your summary!") && finalFeedbackResult[1].contains("No email? Please put your email in your summary!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You must improve this part!"
            }
            
            /* Masih belum di pakai karena blm ada perbandingan (hanya satu hal yang di validasi)
            if finalFeedbackResult[2].contains("It's better not to show your GPA in your resume.") || finalFeedbackResult[2].contains("You can add your GPA if it's more than equal to 3.") {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
                feedbackDatas.commentedTexts[2] = "You can be better!"
            }
            
            if finalFeedbackResult[3].contains("Rearrange your working experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
                feedbackDatas.commentedTexts[3] = "You can be better!"
            }
            
            if finalFeedbackResult[4].contains("Rearrange your organisational experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
                feedbackDatas.commentedTexts[4] = "You can be better!"
            }
            
            if finalFeedbackResult[5].contains("You have to put your skills that match with job that you've applied.") {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
                feedbackDatas.commentedTexts[5] = "You can be better!"
            }
             */
            
            // kalo semuanya konten salah semua (kotak warna merah)
            if finalFeedbackResult[0].contains("Your summary is getting too long, reduce few words to make it more simple.") || finalFeedbackResult[0].contains("It seems that you used 'words' too much, try to use another words!") || finalFeedbackResult[0].contains("You have to use more action verbs in your summary.") || finalFeedbackResult[0].contains("Vague") || finalFeedbackResult[0].contains("Half Vague") || finalFeedbackResult[0].contains("Half Passionate") || finalFeedbackResult[0].contains("Not Passionate") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You can be better!"
            }
            
            if finalFeedbackResult[1].contains("No phone number? Please put your email in your summary!") || finalFeedbackResult[1].contains("No email? Please put your email in your summary!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You can be better!"
            }
            
            if finalFeedbackResult[2].contains("It's better not to show your GPA in your resume.") || finalFeedbackResult[2].contains("You can add your GPA if it's more than equal to 3.") {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
                feedbackDatas.commentedTexts[2] = "You can be better!"
            }
            
            if finalFeedbackResult[3].contains("Rearrange your working experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
                feedbackDatas.commentedTexts[3] = "You can be better!"
            }
            
            if finalFeedbackResult[4].contains("Rearrange your organisational experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
                feedbackDatas.commentedTexts[4] = "You can be better!"
            }
            
            if finalFeedbackResult[5].contains("You have to put your skills that match with job that you've applied.") {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
                feedbackDatas.commentedTexts[5] = "You can be better!"
            }
            
            //kalo konten gaada (kotak warna biru)
            if finalFeedbackResult[x].isEmpty {
                finalFeedbackResult[x] = "We're missing \(headerCv[x]) in your resume! It's either you haven't add it or we can't detect it because it's in another format."
                feedbackDatas.commentedTexts[x] = "Missing Content!"
            }
            
            if finalFeedbackResult[0].isEmpty {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
            }
            
            if finalFeedbackResult[1].isEmpty {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
            }
            
            if finalFeedbackResult[2].isEmpty {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
            }
            
            if finalFeedbackResult[3].isEmpty {
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
            }
            
            if finalFeedbackResult[4].isEmpty {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
            }
            
            if finalFeedbackResult[5].isEmpty {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
            }
            
        }
    }
}
