//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit
import CoreML

class ProcessingViewController: UIViewController {
    
    // Untuk collection view
    struct onGoingProcess {
        var rowIndexPath: IndexPath?
        var doneArray: [Int]?
    }
    
    struct Classifications: Codable{
        var tag_name: String
        var tag_id: Int
        var confidence: Float
    }
    
    struct User: Codable{
        var text: String
        var error: Bool
        var classifications: [Classifications]
    }
    
    @IBOutlet weak var processCollectionView: UICollectionView! {
        didSet {
            processCollectionView.isUserInteractionEnabled = false
        }
    }
    
    var sharedResources = [String]()
    var resumeClassification = [String]()
    
    // DESC: Process Details memuat detail dari proses yang akan dijalankan
    var processDetails: [String] = ["Checking Identity", "Looking at Summary", "Viewing Education", "Evaluating", "Analyzing Skills", "Finalizing"]
    
    // DESC: instance onGoingProcessp; berisi row yang sedang berjalan dan array proses yang telah selesai berjalan
    var onGoingRow = onGoingProcess()
    var resultContent: Segment?
    
    var extractedContent: [String] = []
    var brain = Brain()
    var finalFeedbackResult: [FeedbackDetailModel] = [FeedbackDetailModel(type: "", id: 0, overview: ""), FeedbackDetailModel(type: "", id: 0, overview: ""), FeedbackDetailModel(type: "", id: 0, overview: ""), FeedbackDetailModel(type: "", id: 0, overview: ""), FeedbackDetailModel(type: "", id: 0, overview: ""), FeedbackDetailModel(type: "", id: 0, overview: "")]
    
    var stringProfile: String = ""
    var stringEducation: String = ""
    var stringWork: String = ""
    var stringOrg: String = ""
    var stringSummary: String = ""
    var stringSkills: String = ""
    var tempString = 0
    
    var tempFontSize = 0
    var headerCV: [String] = []
    var segmentationExtractedResult:[String:String]=[:]
    
    //nlp
    let tagger = NSLinguisticTagger(tagSchemes:[.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(recursiveLoop), userInfo: nil, repeats: false)
        
        processCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        setCollectionViewLayout()
        extractContent(result: resultContent!)
        
        for i in 0 ..< extractedContent.count {
            print("extractedContent [\(i)] ==== \(extractedContent[i])")
        }
        
        divideExtractedContent(extractedContent: extractedContent)
        //print(finalFeedbackResult)
        
        print(headerCV)
        //dispatchFeedbackHandler()
        
        decideAppropriateFeedback(dividedExtractedContent: segmentationExtractedResult)
        print(finalFeedbackResult)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOverview" {
            if let PreviewViewController = segue.destination as? PreviewViewController {
                PreviewViewController.feedbackResult = finalFeedbackResult
            }
        }
    }
    
    var countRecursiveLoop = 0
    @objc func recursiveLoop(){
        if self.countRecursiveLoop <= self.processDetails.count + 2 {
            UIView.animate(withDuration: 0.1, animations: {
                if self.countRecursiveLoop == 0 {
                    self.countRecursiveLoop += 1
                } else {
                    self.moveItem()
                    self.countRecursiveLoop += 1
                }
            }) { (finished) in
                if finished{
                    UIView.animate(withDuration: 0.1, animations: {
                        if self.countRecursiveLoop <= self.processDetails.count + 2{
                            self.recursiveLoop()
                        } else{
                            
                        }
                    })
                }
            }
        } else{
            
        }
    }
    
    var counterProfile = 0
    var counterWork = 0
    var dipisahSpasi: [String] = []
    var temp:[String]?
    var stringIndah: [String] = []
    //    var dataNotFound = "Data Not Found!"
    //    var stringEducation: [String] = []
    //    var stringWork: [String] = []
    //    var stringOrg: [String] = []
    //    var stringSummary: [String] = []
    //    var stringSkills: [String] = []
    //    var tempString = 0
    
    func appointSummaryFeedback(for text: String) {
        var summary: [Substring] = []
        
        print(text)
        print("*&*&*&*&*&*&*&*&*&*")
        
        if brain.isSummaryFound(in: text){
            summary = text.split(separator: "\n")
        }
        print(summary)
        var tempForEach = 0
        var summarySetelahPersonalProfile = ""
        summary.forEach { (cekTemp) in
            if brain.isSummaryFound(in: cekTemp.trimmingCharacters(in: .whitespacesAndNewlines)){
                summarySetelahPersonalProfile = String(summary[tempForEach+1])
                return
            }
            else if tempForEach == summary.count - 1{
                summarySetelahPersonalProfile = summary.joined()
            }
            tempForEach += 1
        }
        print("Summary setelah personal profile = \(summarySetelahPersonalProfile)")
        // ML
        // Do any additional setup after loading the view.
        let modelPassionate = TextClassifierPassionateSentence()
        let modelVague = TextClassifierVagueSentence()
        
        var textToPredict: [String] = []
        
        if summarySetelahPersonalProfile.contains(".") {
            textToPredict = summarySetelahPersonalProfile.components(separatedBy: ". ")
        } else {
            textToPredict.append(summarySetelahPersonalProfile)
        }
        
        var passionateCount:Float = 0
        var personalCount:Float = 0
        
        var output1 = ""
        for sentence in textToPredict {
            guard let passionateOutput = try? modelPassionate.prediction(text: sentence) else {
                fatalError("Unexpected runtime error.")
            }
            //output1.append("\(passionateOutput.label)\n")
            if passionateOutput.label == "Passionate"{
                passionateCount += 1
            }
        }
        
        output1 = String(passionateCount/Float(textToPredict.count) * 100)
        
        print("Passionate Output : \(output1)% Passionate")
        
        var output2 = ""
        for sentence in textToPredict {
            guard let vagueOutput = try? modelVague.prediction(text: sentence) else {
                fatalError("Unexpected runtime error.")
            }
            output2.append(vagueOutput.label)
            if vagueOutput.label == "Personal"{
                personalCount += 1
            }
        }
        
        output2 = String(personalCount/Float(textToPredict.count) * 100)
        print("Vague Output : \(output2)% Personal")
        
        finalFeedbackResult[0].type = "Summary"
        finalFeedbackResult[0].overview.append("\(output1)% Passionate\n")
        finalFeedbackResult[0].overview.append("\(output2)% Personal\n")
        
        //Check typo
        print("typo bool = \(brain.isReal(word: summarySetelahPersonalProfile))")
        if brain.isReal(word: summarySetelahPersonalProfile) == true{
            
        }else if brain.isReal(word: summarySetelahPersonalProfile) == false{
            finalFeedbackResult[0].overview.append("Your summary has a typo\n")
        }
        
        // Check word count
        let words =  summarySetelahPersonalProfile.split { !$0.isLetter }
        if text.count > 200 + words.count {
            finalFeedbackResult[0].overview.append("Your summary is too long, reduce few words to make it more simple.\n")
        } else {
            finalFeedbackResult[0].overview.append("You showed a good and simple summary about yourself.\n")
        }
        
        // Check usage of words and frequency
        let wordDict = brain.createWordDictionary(text: text)
        if !brain.isWordFrequencyAppropriate(dictionary: wordDict) {
            finalFeedbackResult[0].overview.append("It seems that you overused some words. Try to change some words!\n")
        } else {
            finalFeedbackResult[0].overview.append("Your summary has a lot of word variation.\n")
        }
        
        if !brain.isActionVerbAppropriate(text: text) {
            finalFeedbackResult[0].overview.append("You have to use more action verbs in your summary.\n")
        } else {
            finalFeedbackResult[0].overview.append("It's great that you use action verbs in your summary!\n")
        }
    }
    
    func appointProfileFeedback(for text: String) {
        finalFeedbackResult[1].type = "Profile"
        if !brain.isEmailRegexFound(text: text.replacingOccurrences(of: " ", with: "")) {
            finalFeedbackResult[1].overview.append("You haven't put your e-mail!\n")
        } else if brain.isEmailRegexFound(text: text.replacingOccurrences(of: " ", with: "")) {
            finalFeedbackResult[1].overview.append("Nice! Providing your e-mail helps to ease the communication between you and the company!\n")
        }
        
        if !brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("You haven't put your phone number!")
        } else if brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("Stating your phone number further increase the communication for you and the company!")
        }
    }
    
    func appointEducationFeedback(for text: String) {
        finalFeedbackResult[2].type = "Education"
        if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .inRange {
            finalFeedbackResult[2].overview.append("Your GPA looks promising!\n")
        } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .outOfBound {
            finalFeedbackResult[2].overview.append("Your GPA seems lower than the recommended boundaries\n")
        } else {
            finalFeedbackResult[2].overview.append("You may provide your GPA to boost the chance of being accepted!\n")
        }
    }
    
    func appointWorkFeedback(for text: String) {
        
        var workExperience: [Substring] = []
        
        print("*&*&*&*&*&*&*&*&*&*")
        print("Work experience = \(text)")
        workExperience = text.split(separator: "\n")
        print("\(workExperience)")
        var tempForEach = 0
        var workExperienceDetail: [String] = []
        var averageWordCount = 0
        for i in 0..<workExperience.count{
            print(workExperience[i])
            averageWordCount += workExperience[i].count
            print(workExperience[i].count)
        }
        averageWordCount = averageWordCount/workExperience.count
        print("average word count = \(averageWordCount)")
        workExperience.forEach { (cekTemp) in
            if cekTemp.count > averageWordCount {
                workExperienceDetail.append(String(cekTemp))
                return
            }
            else {
                //                workExperienceDetail = workExperience.joined()
            }
            tempForEach += 1
        }
        print("Work Experience Detail = \(workExperienceDetail)")
        let modelWorkExperience = TextClassifierWorkExperience()
        var outputWorkExperienceGood = ""
        var outputWorkExperienceMid = ""
        var outputWorkExperienceBad = ""
        var goodCount: Float = 0
        var midCount: Float = 0
        var badCount: Float = 0
        for sentence in workExperienceDetail {
            guard let workExperienceOutput = try? modelWorkExperience.prediction(text: sentence) else {
                fatalError("Unexpected runtime error.")
            }
            //output1.append("\(passionateOutput.label)\n")
            if workExperienceOutput.label == "Good"{
                goodCount += 1
            }else if workExperienceOutput.label == "Mid"{
                midCount += 1
            }else if workExperienceOutput.label == "Bad"{
                badCount += 1
            }
        }
        
        outputWorkExperienceGood = String(goodCount/Float(workExperienceDetail.count) * 100)
        outputWorkExperienceMid = String(midCount/Float(workExperienceDetail.count) * 100)
        outputWorkExperienceBad = String(badCount/Float(workExperienceDetail.count) * 100)
        
        print("Good Output : \(outputWorkExperienceGood)% Good")
        print("Mid Output : \(outputWorkExperienceMid)% Mid")
        print("Bad Output : \(outputWorkExperienceBad)% Bad")
        
        finalFeedbackResult[3].overview.append("Good Output : \(outputWorkExperienceGood)% Good\n")
        finalFeedbackResult[3].overview.append("Mid Output : \(outputWorkExperienceMid)% Mid\n")
        finalFeedbackResult[3].overview.append("Bad Output : \(outputWorkExperienceBad)% Bad\n")
        
        
        finalFeedbackResult[3].type = "Work Experience"
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[3].overview.append("Rearrange your working experiences from the most current until the latest one!\n")
        } else {
            finalFeedbackResult[3].overview.append("You showed your working experiences at chronological order!\n")
        }
        // Check whether the description is descriptive enough
        // TO DO: Insert using model here
    }
    
    func appointOrganisationFeedback(for text: String) {
        finalFeedbackResult[4].type = "Organisational Experience"
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[4].overview.append("Rearrange your organisational experiences from the most current until the latest one!\n")
        } else {
            finalFeedbackResult[4].overview.append("You showed your organisational experiences at chronological order!\n")
        }
        
        // Check whether the description is action-based or result-based
        // TO DO: Insert using model here
    }
    
    func appointSkillsFeedback(for text: String) {
        finalFeedbackResult[5].type = "Skills"
        if !brain.isRelatedSkillsAppropriate(text: text) {
            finalFeedbackResult[5].overview.append("You have to put more skills which are relevant with the job you're applying for.\n")
        } else {
            finalFeedbackResult[5].overview.append("Great! Your skills are relevant with job that you've applied!\n")
        }
    }
    
    func divideExtractedContent(extractedContent: [String]) {
        var index = -1
        var temp: String = ""
        for q in 0 ..< extractedContent.count {
            for x in 0 ..< headerCV.count {
                if extractedContent[q] == headerCV[x] {
                    headerCV[x] = headerCV[x].trimmingCharacters(in: .whitespacesAndNewlines)
                    print("ketemu \(headerCV[x])")
                    segmentationExtractedResult["\(headerCV[x])"] = ""
                    index = x
                    break
                }
            }
            if index == -1 {
                temp.append(extractedContent[q])
            }
            else {
                segmentationExtractedResult["\(headerCV[index])"]?.append(extractedContent[q])
            }
        }
    }
    
    func dispatchFeedbackHandler() {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        let dispatchMain = DispatchQueue.main
        
        dispatchQueue.async {
            
            // 1
            self.appointProfileFeedback(for: self.stringProfile)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
            
            // 2
            self.appointSummaryFeedback(for: self.stringSummary)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
            
            // 3
            self.appointEducationFeedback(for: self.stringEducation)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
            
            // 4
            self.appointWorkFeedback(for: self.stringWork)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
            
            // 5
            self.appointOrganisationFeedback(for: self.stringOrg)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
            
            // 6
            self.appointSkillsFeedback(for: self.stringSkills)
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
                self.moveItem()
            }
            semaphore.wait()
        }
    }
    
    func extractContent(result: Segment) {
        getHighestFontSize(result: result)
        for jumlah in 0 ..< result.segment.count {
            if result.segment[jumlah].segment.isEmpty {
                for i in 0..<result.segment[jumlah].contents.count {
                    extractedContent.append(result.segment[jumlah].contents[i].label)
                    if result.segment[jumlah].contents[i].type.first == "H"{
                        var lastTypeNumberString = (result.segment[jumlah].contents[i].type.last?.hexDigitValue)!
                        if lastTypeNumberString >= tempFontSize-1 {
                            headerCV.append(result.segment[jumlah].contents[i].label)
                        }
                    }
                }
            }else{
                extractContent(result: result.segment[jumlah])
            }
            if jumlah == result.segment.count - 1 {
                for j in 0 ..< result.contents.count{
                    extractedContent.append(result.contents[j].label)
                    if result.contents[j].type.first == "H"{
                        var lastTypeNumberString = (result.contents[j].type.last?.hexDigitValue)!
                        if lastTypeNumberString >= tempFontSize-1 {
                            headerCV.append(result.contents[j].label)
                        }
                    }
                }
            }
        }
    }
    
    func decideAppropriateFeedback(dividedExtractedContent: [String:String]) {
        for key in dividedExtractedContent.keys {
            if self.brain.isPersonalInfoFound(in: key) {
                self.appointProfileFeedback(for: dividedExtractedContent[key]!)
            } else if self.brain.isEducationFound(in: key) {
                self.appointEducationFeedback(for: dividedExtractedContent[key]!)
            } else if self.brain.isWorkExperienceFound(in: key) {
                self.appointWorkFeedback(for: dividedExtractedContent[key]!)
            } else if self.brain.isOrganisationExperienceFound(in: key) {
                self.appointOrganisationFeedback(for: dividedExtractedContent[key]!)
            } else if self.brain.isSummaryFound(in: key) {
                if self.brain.isEmailRegexFound(text: dividedExtractedContent[key]!) || self.brain.isPhoneNumberRegexFound(text: dividedExtractedContent[key]!) {
                    self.appointProfileFeedback(for: dividedExtractedContent[key]!)
                }
                self.appointSummaryFeedback(for: dividedExtractedContent[key]!)
            } else if self.brain.isSkillsFound(in: key) {
                self.appointSkillsFeedback(for: dividedExtractedContent[key]!)
            }
        }
    }
    
    func getHighestFontSize(result: Segment) {
        //        let a = result.segment[0].contents[0].type.last?.hexDigitValue
        for jumlah in 0 ..< result.segment.count {
            if result.segment[jumlah].segment.isEmpty {
                for i in 0..<result.segment[jumlah].contents.count {
                    if result.segment[jumlah].contents[i].type.first == "H"{
                        var lastTypeNumberString = (result.segment[jumlah].contents[i].type.last?.hexDigitValue)!
                        if lastTypeNumberString > tempFontSize{
                            tempFontSize = lastTypeNumberString
                        }
                    }
                }
            }else{
                //                extractContent(result: result.segment[jumlah])
            }
            if jumlah == result.segment.count - 1 {
                for j in 0 ..< result.contents.count{
                    if result.contents[j].type.first == "H"{
                        var lastTypeNumberString = (result.contents[j].type.last?.hexDigitValue)!
                        if lastTypeNumberString > tempFontSize{
                            tempFontSize = lastTypeNumberString
                        }
                    }
                }
            }
        }
    }
    
    func handleClassification(text: String) -> String {
        let json: [String:[String]] = ["data": [text]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let link = "https://api.monkeylearn.com/v3/classifiers/cl_kTazyVJA/classify/"
        
        // create post request
        let url = URL(string: link)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token 3ee8491aeae2ddc3a7ac4e82f458df3001093c72", forHTTPHeaderField: "Authorization")
        
        // insert json data to the request
        request.httpBody = jsonData
        
        var taggedClassification = ""
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            print(responseJSON as Any)
            
            print("Data :: \(data)")
            let users = try? JSONDecoder().decode([User].self, from: data)
            print("Users :: \(String(describing: users))")
            
            //            print(users![0].classifications[0].tag_name)
            //            print(users![0].classifications[0].confidence)
            //            print(users![0].classifications[1].tag_name)
            //            print(users![0].classifications[1].confidence)
            
            // Check the classification confidence, which one has higher confidence
            //            for user in users! {
            //                if user.classifications[0].confidence >= user.classifications[1].confidence {
            //                    taggedClassification = user.classifications[0].tag_name
            //                }
            //                else {
            //                    taggedClassification = user.classifications[1].tag_name
            //                }
            //            }
        }
        task.resume()
        return taggedClassification
    }
    
    // Change this function with the function to be called automatically upon completion on certain progress
    func moveItem(){
        var cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        guard var onGoingIndex = onGoingRow.rowIndexPath else { return }
        
        onGoingRow.doneArray?.append(onGoingIndex.row)
        cell?.setCellStatus(statusType: .done)
        
        onGoingRow.rowIndexPath?.row += 1
        onGoingIndex.row += 1
        
        cell = processCollectionView.cellForItem(at: onGoingIndex) as? ProcessCollectionViewCell
        cell?.setCellStatus(statusType: .working)
        
        if onGoingRow.rowIndexPath!.row + 2 < processDetails.count {
            processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row + 1, section: 0), at: .bottom, animated: true)
        }
        else if onGoingRow.rowIndexPath!.row < processDetails.count{
            processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row - 2, section: 0), at: .top, animated: true)
        }
        else {
            if onGoingRow.rowIndexPath!.row <= processDetails.count {
                onGoingRow.doneArray?.append(onGoingIndex.row)
                cell?.setCellStatus(statusType: .done)
                onGoingRow.rowIndexPath?.row += 1
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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
        UICollectionReusableView {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableViewID", for: indexPath) as? HomeCollectionReusableView {
                headerView.textDescription.text = "I'm reviewing your resume..."
                headerView.reaProcessing(reaImages: ["reaRollingEyesLeft", "reaRollingEyesCenter", "reaRollingEyesRight"])
                headerView.textDescription.sizeToFit()
                headerView.textDescription.numberOfLines = 0
                headerView.addBubble(height: headerView.textDescription.frame.maxY, width: UIScreen.main.bounds.width - headerView.textDescription.frame.size.width - 60)
                headerView.bringSubviewToFront(headerView.textDescription)
                return headerView
            }
            return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: processCollectionView.frame.width, height: 200)
    }
    
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
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = CGSize(width: self.processCollectionView.frame.width, height: processCollectionView.frame.height / 8)
        layout.sectionInset = UIEdgeInsets(top: 20, left: (self.processCollectionView.bounds.width - layout.estimatedItemSize.width) / 2, bottom: 0, right: (self.processCollectionView.bounds.width - layout.estimatedItemSize.width) / 2)
        layout.headerReferenceSize = CGSize(width: processCollectionView.frame.width, height: 180)
        layout.sectionHeadersPinToVisibleBounds = true
        
        processCollectionView.contentInsetAdjustmentBehavior = .always
        processCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        processCollectionView.collectionViewLayout = layout
    }
    
}
