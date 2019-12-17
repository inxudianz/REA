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
    var headerCv: [String] = ["summary", "identity", "education", "working experience", "organisational experience", "skills"]
    
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
            if feedbackResult[0].overview.contains("- Fill in your summary with things your passionate about and tell a little bit about it!") && feedbackResult[0].overview.contains("- It’s better for you to tell more detailed about what you want to do next and what goals you want to achieve in your journey!\n\n") && feedbackResult[0].overview.contains("- Your summary has a typo\n\n") &&  feedbackResult[0].overview.contains("- Your summary is too long, reduce few words to make it more simple.\n\n") && feedbackResult[0].overview.contains("- It seems that you overused some words. Try to change some words!\n\n") && feedbackResult[0].overview.contains("- You have to use more action verbs in your summary.") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You must improve this part!"
            }
            
            if feedbackResult[1].overview.contains("You haven't put your phone number!") && feedbackResult[1].overview.contains("You haven't put your e-mail!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You must improve this part!"
            }
            
            if feedbackResult[3].overview.contains("- You have to explain more of what you did in each of your working experiences so it can be more detailed!\n\n") && feedbackResult[3].overview.contains("- Rearrange your working experiences from the most current until the latest one!"){
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
                feedbackDatas.commentedTexts[3] = "You must improve this part!"
            }
            
            if feedbackResult[4].overview.contains("- You can elaborate more on each of your experiences and give some details on it.\n\n") && feedbackResult[4].overview.contains("- Rearrange your organisational experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
                feedbackDatas.commentedTexts[4] = "You must improve this part!"
            }
            
            if feedbackResult[2].overview.contains("- You may provide your GPA to boost the chance of being accepted!") {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
                feedbackDatas.commentedTexts[2] = "You must improve this part!"
            }
            
            /* Masih belum di pakai karena blm ada perbandingan (hanya satu hal yang di validasi)
            
            if feedbackResult[5].contains("You have to put your skills that match with job that you've applied.") {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
                feedbackDatas.commentedTexts[5] = "You can be better!"
            }
             */
            
            // kalo ada beberapa konten yang salah semua (kotak warna merah)
            if feedbackResult[0].overview.contains("- Fill in your summary with things your passionate about and tell a little bit about it!") || feedbackResult[0].overview.contains("- It’s better for you to tell more detailed about what you want to do next and what goals you want to achieve in your journey!\n\n") || feedbackResult[0].overview.contains("- Your summary has a typo\n\n") ||  feedbackResult[0].overview.contains("- Your summary is too long, reduce few words to make it more simple.\n\n") || feedbackResult[0].overview.contains("- It seems that you overused some words. Try to change some words!\n\n") || feedbackResult[0].overview.contains("- You have to use more action verbs in your summary.") {
                feedbackDatas.overviewTexts[0] = "You have vague summary that explain about yourself. Try to tell brief description about things that you're proud of in few sentences."
                feedbackDatas.commentedTexts[0] = "You can be better!"
            }
            
            if feedbackResult[1].overview.contains("You haven't put your phone number!") || feedbackResult[1].overview.contains("You haven't put your e-mail!") {
                feedbackDatas.overviewTexts[1] = "You haven't given personal information completely. Provide your identity so company will be able to contact you."
                feedbackDatas.commentedTexts[1] = "You can be better!"
            }
            
            if feedbackResult[2].overview.contains("- Your GPA seems lower than the recommended boundaries.") {
                feedbackDatas.overviewTexts[2] = "You have shown vague information about your last education. Make it detailed and make sure to include what you learn as well."
                feedbackDatas.commentedTexts[2] = "You can be better!"
            }
            
            if feedbackResult[3].overview.contains("- You have to explain more of what you did in each of your working experiences so it can be more detailed!\n\n") || feedbackResult[3].overview.contains("- Your working experiences are great but add a little more details of it!\n\n") || feedbackResult[3].overview.contains("- Rearrange your working experiences from the most current until the latest one!"){
                feedbackDatas.overviewTexts[3] = "Your working experiences aren't detailed. You can improve it by highlighting your achievement and your activity there!"
                feedbackDatas.commentedTexts[3] = "You can be better!"
            }
            
            if feedbackResult[4].overview.contains("- You can elaborate more on each of your experiences and give some details on it.\n\n") || feedbackResult[4].overview.contains("- Your organisational experiences are good enough but you can explain more details of what you did there.\n\n") || feedbackResult[4].overview.contains("- Rearrange your organisational experiences from the most current until the latest one!") {
                feedbackDatas.overviewTexts[4] = "Your organisational experiences weren't great. Try to Elaborate your duty and accomplishment there."
                feedbackDatas.commentedTexts[4] = "You can be better!"
            }
            
            if feedbackResult[5].overview.contains("- You have to put more skills which are relevant with the job you're applying for.") {
                feedbackDatas.overviewTexts[5] = "Your skills should be things that can point out what's best in you. You put skills that are irrelevant to the job that you’re applying to."
                feedbackDatas.commentedTexts[5] = "You can be better!"
            }
            
            //kalo konten gaada (kotak warna biru)
            if feedbackResult[x].overview.isEmpty {
                feedbackDatas.comments[x] = "We're missing \(headerCv[x]) section in your resume! It's either you haven't add it or we can't detect it because it's in another format."
                feedbackDatas.commentedTexts[x] = "Missing content!"
            } else {
                feedbackDatas.comments[x] = feedbackResult[x].overview
            }
            
            if feedbackResult[0].overview.isEmpty {
                feedbackDatas.overviewTexts[0] = "You haven't provided a summary about yourself. Try to tell brief description about things you're proud of in few sentences."
            }
            
            if feedbackResult[1].overview.isEmpty {
                feedbackDatas.overviewTexts[1] = "You haven't given any personal information. Provide your contact so the company will be able to contact you."
            }
            
            if feedbackResult[2].overview.isEmpty {
                feedbackDatas.overviewTexts[2] = "You haven't shown any information about your education. Provide a detailed history and include what you learned as well."
            }
            
            if feedbackResult[3].overview.isEmpty {
                feedbackDatas.overviewTexts[3] = "You haven't put your work experiences. You can highlight your achievement and activity during your experience!"
            }
            
            if feedbackResult[4].overview.isEmpty {
                feedbackDatas.overviewTexts[4] = "You haven't provided any organisational experiences. Elaborate a little bit about your duty and show what you accomplished there."
            }
            
            if feedbackResult[5].overview.isEmpty {
                feedbackDatas.overviewTexts[5] = "You forgot to mention your best traits. Put in relevant skills to the job that you’re applying to."
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
            if feedbackDatas.commentedTexts[indexPath.row] == "Missing content!" {
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
