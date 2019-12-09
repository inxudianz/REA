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
        
        if text.lowercased().contains("Personal Profile".lowercased()) || text.lowercased().contains("About Me".lowercased()) || text.lowercased().contains("About".lowercased()) || text.lowercased().contains("Personal Profile".lowercased()) || text.lowercased().contains("Profile".lowercased()) || text.lowercased().contains("In Words".lowercased()) || text.lowercased().contains("Summary".lowercased()){
            summary = text.split(separator: "\n")
        }
        print(summary)
        var tempForEach = 0
        var summarySetelahPersonalProfile = ""
        summary.forEach { (cekTemp) in
            if cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "Personal Profile".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "About Me".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "About".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "Profile".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "In Words".lowercased() || text.lowercased().contains("Summary".lowercased()){
                summarySetelahPersonalProfile = String(summary[tempForEach+1])
                return
            }
            else {
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
            finalFeedbackResult[0].overview.append("Your summary is getting too long, reduce few words to make it more simple.\n")
        } else {
            finalFeedbackResult[0].overview.append("You showed a good and simple summary about yourself.\n")
        }
        
        // Check usage of words and frequency
        var wordDict = brain.createWordDictionary(text: text)
        if !brain.isWordFrequencyAppropriate(dictionary: wordDict) {
            finalFeedbackResult[0].overview.append("It seems that you used 'words' too much, try to use another words!\n")
        } else {
            finalFeedbackResult[0].overview.append("You used various words and it makes your summary more unique.\n")
        }
        
        if !brain.isActionVerbAppropriate(text: text) {
            finalFeedbackResult[0].overview.append("You have to use more action verbs in your summary.\n")
        } else {
            finalFeedbackResult[0].overview.append("It's great that you use action verbs in your summary!\n")
        }
    }
    
    func appointProfileFeedback(for text: String) {
        finalFeedbackResult[1].type = "Profile"
        if !brain.isEmailRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("No email? Please put your email in your summary!\n")
        } else if brain.isEmailRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("Good! Email found!\n")
        }
        
        if !brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("No phone number? Please put your email in your summary!\n")
        } else if brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("Good! Phone number found!\n")
        }
    }
    
    func appointEducationFeedback(for text: String) {
        finalFeedbackResult[2].type = "Education"
        if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .inRange {
            finalFeedbackResult[2].overview.append("Wow! You have a great GPA!\n")
        } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .outOfBound {
            finalFeedbackResult[2].overview.append("It's better not to show your GPA in your resume.\n")
        } else {
            finalFeedbackResult[2].overview.append("You can add your GPA if it's more than equal to 3.\n")
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
        
//        finalFeedbackResult[3].overview.append("Good Output : \(outputWorkExperienceGood)% Good\n")
//        finalFeedbackResult[3].overview.append("Mid Output : \(outputWorkExperienceMid)% Mid\n")
//        finalFeedbackResult[3].overview.append("Bad Output : \(outputWorkExperienceBad)% Bad\n")
        
        if outputWorkExperienceBad >= outputWorkExperienceMid && outputWorkExperienceBad >= outputWorkExperienceGood{
            finalFeedbackResult[3].overview.append("Your work experience explanation is BAD\n")
        }else if outputWorkExperienceMid >= outputWorkExperienceGood && outputWorkExperienceMid >= outputWorkExperienceBad{
            finalFeedbackResult[3].overview.append("Your work experience explanation is MID\n")
        }else if outputWorkExperienceGood >= outputWorkExperienceMid && outputWorkExperienceGood >= outputWorkExperienceBad{
            finalFeedbackResult[3].overview.append("Your work experience explanation is GOOD\n")
        }
        
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
        var organisationExperience: [Substring] = []
        
        print("*&*&*&*&*&*&*&*&*&*")
        print("Organisation experience = \(text)")
        organisationExperience = text.split(separator: "\n")
        print("\(organisationExperience)")
        var tempForEach = 0
        var organisationExperienceDetail: [String] = []
        var averageWordCount = 0
        for i in 0..<organisationExperience.count{
            print(organisationExperience[i])
            averageWordCount += organisationExperience[i].count
            print(organisationExperience[i].count)
        }
        averageWordCount = averageWordCount/organisationExperience.count
        print("average word count = \(averageWordCount)")
        organisationExperience.forEach { (cekTemp) in
            if cekTemp.count > averageWordCount {
                organisationExperienceDetail.append(String(cekTemp))
                return
            }
            else {
                //                workExperienceDetail = workExperience.joined()
            }
            tempForEach += 1
        }
        print("Organisation Experience Detail = \(organisationExperienceDetail)")
        let modelOrganisationExperience = TextClassifierOrganisationExperience()
        var outputOrganisationExperienceGood = ""
        var outputOrganisationExperienceMid = ""
        var outputOrganisationExperienceBad = ""
        var goodCount: Float = 0
        var midCount: Float = 0
        var badCount: Float = 0
        for sentence in organisationExperienceDetail {
            guard let organisationExperienceOutput = try? modelOrganisationExperience.prediction(text: sentence) else {
                fatalError("Unexpected runtime error.")
            }
            //output1.append("\(passionateOutput.label)\n")
            if organisationExperienceOutput.label == "Good"{
                goodCount += 1
            }else if organisationExperienceOutput.label == "Mid"{
                midCount += 1
            }else if organisationExperienceOutput.label == "Bad"{
                badCount += 1
            }
        }
        
        outputOrganisationExperienceGood = String(goodCount/Float(organisationExperienceDetail.count) * 100)
        outputOrganisationExperienceMid = String(midCount/Float(organisationExperienceDetail.count) * 100)
        outputOrganisationExperienceBad = String(badCount/Float(organisationExperienceDetail.count) * 100)
        
        print("Good Output : \(outputOrganisationExperienceGood)% Good")
        print("Mid Output : \(outputOrganisationExperienceMid)% Mid")
        print("Bad Output : \(outputOrganisationExperienceBad)% Bad")
        
//        finalFeedbackResult[4].overview.append("Good Output : \(outputOrganisationExperienceGood)% Good\n")
//        finalFeedbackResult[4].overview.append("Mid Output : \(outputOrganisationExperienceMid)% Mid\n")
//        finalFeedbackResult[4].overview.append("Bad Output : \(outputOrganisationExperienceBad)% Bad\n")
        
        if outputOrganisationExperienceBad >= outputOrganisationExperienceMid && outputOrganisationExperienceBad >= outputOrganisationExperienceGood{
            finalFeedbackResult[4].overview.append("Your Organisation experience explanation is BAD\n")
        }else if outputOrganisationExperienceMid >= outputOrganisationExperienceGood && outputOrganisationExperienceMid >= outputOrganisationExperienceBad{
            finalFeedbackResult[4].overview.append("Your Organisation experience explanation is MID\n")
        }else if outputOrganisationExperienceGood >= outputOrganisationExperienceMid && outputOrganisationExperienceGood >= outputOrganisationExperienceBad{
            finalFeedbackResult[4].overview.append("Your Organisation experience explanation is GOOD\n")
        }
        
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
            finalFeedbackResult[5].overview.append("You have to put your skills that match with job that you've applied.\n")
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
            if key.lowercased() == "Contact Info".lowercased() || key.lowercased() == "Contact".lowercased() || key.lowercased() == "Personal Information".lowercased() {
                appointProfileFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased() == "Education".lowercased() || key.lowercased() == "Academic History".lowercased() || key.lowercased() == "Academic Background".lowercased() || key.lowercased() == "Education History".lowercased() {
                appointEducationFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased() == "Work Experience".lowercased() || key.lowercased() == "Work History".lowercased() || key.lowercased() == "Working Experience".lowercased() || key.lowercased() == "Job History".lowercased() || key.lowercased() == "Experience".lowercased() {
                appointWorkFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased() == "Organisation Experience".lowercased() || key.lowercased() == "Organisational Experience".lowercased() || key.lowercased() == "Organization Experience".lowercased() || key.lowercased() == "Organizational Experience".lowercased() || key.lowercased() == "Organization History".lowercased() || key.lowercased() == "Organisation History".lowercased() {
                appointOrganisationFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Summary".lowercased()) || key.lowercased().contains("About Me".lowercased()) || key.lowercased().contains("About".lowercased()) || key.lowercased().contains("Personal Profile".lowercased()) || key.lowercased().contains("Profile".lowercased()) || key.lowercased().contains("In Words".lowercased()) {
                if brain.isEmailRegexFound(text: dividedExtractedContent[key]!) || brain.isPhoneNumberRegexFound(text: dividedExtractedContent[key]!) {
                    appointProfileFeedback(for: dividedExtractedContent[key]!)
                }
                appointSummaryFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Skills".lowercased()) || key.lowercased().contains("Skill".lowercased()) || key.lowercased().contains("Expertise".lowercased()) || key.lowercased().contains("Technical Skills".lowercased()) || key.lowercased().contains("Key Skills".lowercased()) {
                appointSkillsFeedback(for: dividedExtractedContent[key]!)
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

/* func ga kepake
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 {
 print("PROFILE SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 //                if !brain.isEmailRegexFound(text: result[i+1]) {
 //                    finalFeedbackResult[0] += "feedback email"
 //                }
 //                if !brain.isPhoneNumberRegexFound(text: result[i+1]) {
 //                    finalFeedbackResult[0] += "feedback phone number"
 //                }
 for i in q ..< result.count{
 if result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) || (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0 || result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) || result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) || result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased()){
 break
 }else{
 stringIndah.append(result[i])
 }
 }
 counterProfile += 1
 print("String indah : \(stringIndah)")
 }else if result[q].lowercased().contains("Education".lowercased()) ||  result[q].lowercased().contains("Academic Background".lowercased())
 ||  result[q].lowercased().contains("Education History".lowercased()) || result[q].lowercased().contains("Academic History".lowercased()){
 for i in q ..< result.count{
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 || (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0 || result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) || result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) || result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased()){
 break
 }else{
 stringEducation.append(result[i])
 }
 }
 print("String Education : \(stringEducation)")
 }else if (result[q].lowercased().contains("Work Experience".lowercased()) ||  result[q].lowercased().contains("Experience".lowercased())
 ||  result[q].lowercased().contains("Work History".lowercased()) ||  result[q].lowercased().contains("Working Experience".lowercased())
 ||  result[q].lowercased().contains("Job History".lowercased())) && counterWork == 0 {
 for i in q ..< result.count{
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 || result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) || result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) || result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) || result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased()){
 break
 }else{
 stringWork.append(result[i])
 }
 }
 print("String Work : \(stringWork)")
 }else if result[q].lowercased().contains("Organisational Experience".lowercased()) ||  result[q].lowercased().contains("Organizational Experience".lowercased()) ||  result[q].lowercased().contains("Organisation Profile".lowercased()) ||  result[q].lowercased().contains("Organization Experience".lowercased()) {
 for i in q ..< result.count{
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 || result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) || (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0  || result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) || result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased()){
 break
 }else{
 stringOrg.append(result[i])
 }
 }
 print("String Org : \(stringOrg)")
 }else if result[q].lowercased().contains("Summary".lowercased()) ||  result[q].lowercased().contains("About Me".lowercased()) ||  result[q].lowercased().contains("About".lowercased()) {
 for i in q ..< result.count{
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 || result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) || (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0  ||  result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) || result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased()){
 break
 }else{
 stringSummary.append(result[i])
 }
 }
 print("String Summary : \(stringSummary)")
 } else if result[q].lowercased().contains("Skills".lowercased()) ||  result[q].lowercased().contains("Language".lowercased()) ||  result[q].lowercased().contains("Skills and Language".lowercased()) ||  result[q].lowercased().contains("Skills & Language".lowercased()) {
 for i in q ..< result.count{
 if (result[q].lowercased().contains("Personal Profile".lowercased()) ||  result[q].lowercased().contains("Profile".lowercased())
 ||  result[q].lowercased().contains("Contact".lowercased()) ||  result[q].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[q])) && counterProfile == 0 || result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) || (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0  ||  result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) || result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()){
 break
 }else{
 stringSkills.append(result[i])
 }
 }
 print("String Skills : \(stringSkills)")
 }
 if temp!.isEmpty{
 print("12345678901234567890 \(result[i]) 12345678901234567890")
 if (result[i].lowercased().contains("Personal Profile".lowercased()) ||  result[i].lowercased().contains("Profile".lowercased())
 ||  result[i].lowercased().contains("Contact".lowercased()) ||  result[i].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[i])) && counterProfile == 0 {
 print("PROFILE SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isEmailRegexFound(text: result[i+1]) {
 finalFeedbackResult[0] += "feedback email"
 }
 if !brain.isPhoneNumberRegexFound(text: result[i+1]) {
 finalFeedbackResult[0] += "feedback phone number"
 }
 counterProfile += 1
 
 } else if result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) {
 
 print("EDUCATION SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: result[i+1]) == .notFound {
 finalFeedbackResult[1] += "MANA GPA LU"
 } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: result[i+1]) == .outOfBound {
 finalFeedbackResult[1] += "HILANGIN AJA CUPS"
 }
 
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[1] += "Tahun lu ga berurutan descending cuy"
 }
 
 } else if (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0 {
 
 print("WORK SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[2] += "Tahun lu ga berurutan descending cuy"
 }
 counterWork += 1
 
 } else if result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) {
 
 print("ORGANISATION SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[3] += "Tahun lu ga berurutan descending cuy"
 }
 
 } else if result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) {
 
 print("SUMMARY SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isWordFrequencyAppropriate(dictionary: brain.createWordDictionary(text: result[i+1])) {
 finalFeedbackResult[4] += "Kebanyakan bacot"
 }
 if result[i].count > 200 {
 finalFeedbackResult[4] += "Summarynya yang kebanyakan bacot, bukan lu tenang"
 }
 
 for i in 0..<result[i].count{
 dipisahSpasi = result[i+1].components(separatedBy: " ")
 }
 print("DIPISAH SPASI = \(dipisahSpasi)")
 
 } else if result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased())
 ||  result[i].lowercased().contains("Skills and Language".lowercased()) ||  result[i].lowercased().contains("Skills & Language".lowercased()) {
 
 print("SKILLS SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 
 }
 }
 print("12345678901234567890 \(result[i]) 12345678901234567890")
 if (result[i].lowercased().contains("Personal Profile".lowercased()) ||  result[i].lowercased().contains("Profile".lowercased())
 ||  result[i].lowercased().contains("Contact".lowercased()) ||  result[i].lowercased().contains("Personal Information".lowercased())
 ||  brain.personalNameEntityRecognitionFound(for: result[i])) && counterProfile == 0 {
 print("PROFILE SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isEmailRegexFound(text: result[i+1]) {
 finalFeedbackResult[0] += "feedback email"
 }
 if !brain.isPhoneNumberRegexFound(text: result[i+1]) {
 finalFeedbackResult[0] += "feedback phone number"
 }
 counterProfile += 1
 
 } else if result[i].lowercased().contains("Education".lowercased()) ||  result[i].lowercased().contains("Academic Background".lowercased())
 ||  result[i].lowercased().contains("Education History".lowercased()) || result[i].lowercased().contains("Academic History".lowercased()) {
 
 print("EDUCATION SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: result[i+1]) == .notFound {
 finalFeedbackResult[1] += "MANA GPA LU"
 } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: result[i+1]) == .outOfBound {
 finalFeedbackResult[1] += "HILANGIN AJA CUPS"
 }
 
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[1] += "Tahun lu ga berurutan descending cuy"
 }
 
 } else if (result[i].lowercased().contains("Work Experience".lowercased()) ||  result[i].lowercased().contains("Experience".lowercased())
 ||  result[i].lowercased().contains("Work History".lowercased()) ||  result[i].lowercased().contains("Working Experience".lowercased())
 ||  result[i].lowercased().contains("Job History".lowercased())) && counterWork == 0 {
 
 print("WORK SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[2] += "Tahun lu ga berurutan descending cuy"
 }
 counterWork += 1
 
 } else if result[i].lowercased().contains("Organisational Experience".lowercased()) ||  result[i].lowercased().contains("Organizational Experience".lowercased())
 ||  result[i].lowercased().contains("Organisation Profile".lowercased()) ||  result[i].lowercased().contains("Organization Experience".lowercased()) {
 
 print("ORGANISATION SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isChronological(text: brain.getYear(for: result[i+1])) {
 finalFeedbackResult[3] += "Tahun lu ga berurutan descending cuy"
 }
 
 } else if result[i].lowercased().contains("Summary".lowercased()) ||  result[i].lowercased().contains("About Me".lowercased())
 ||  result[i].lowercased().contains("About".lowercased()) {
 
 print("SUMMARY SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 if !brain.isWordFrequencyAppropriate(dictionary: brain.createWordDictionary(text: result[i+1])) {
 finalFeedbackResult[4] += "Kebanyakan bacot"
 }
 if result[i].count > 200 {
 finalFeedbackResult[4] += "Summarynya yang kebanyakan bacot, bukan lu tenang"
 }
 
 for i in 0..<result[i].count{
 dipisahSpasi = result[i+1].components(separatedBy: " ")
 }
 print("DIPISAH SPASI = \(dipisahSpasi)")
 
 } else if result[i].lowercased().contains("Skills".lowercased()) ||  result[i].lowercased().contains("Language".lowercased())
 ||  result[i].lowercased().contains("Skills and Language".lowercased()) ||  result[i].lowercased().contains("Skills & Language".lowercased()) {
 
 print("SKILLS SECTION -=*)!&#)!&!)#&!)$&!)*$)!*#@)*!)@(!)@()!*(#@)(!)@()!(@)")
 
 }
 */
