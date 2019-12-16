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
    
    @IBOutlet weak var processCollectionView: UICollectionView! {
        didSet {
            processCollectionView.isUserInteractionEnabled = false
        }
    }
    
    var sharedResources = [String]()
    var resumeClassification = [String]()
    let dispatchQueue = DispatchQueue.global(qos: .background)
    let dispatchMain = DispatchQueue.main
    
    // DESC: Process Details memuat detail dari proses yang akan dijalankan
    var processDetails: [String] = ["Checking Identity", "Looking at Summary", "Viewing Education", "Evaluating", "Analyzing Skills", "Finalizing"]
    
    // DESC: instance onGoingProcessp; berisi row yang sedang berjalan dan array proses yang telah selesai berjalan
    var onGoingRow = onGoingProcess()
    var resultContent: Segment?
    var segmentedContent: [SegmentedModel]?
    
    var extractedContent: [String] = []
    var brain = Brain()
    var timer = Timer()
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

        processCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        setCollectionViewLayout()
        
        dispatchQueue.async {
            self.resultContent = self.segmentContent(contents: self.segmentedContent!)
            self.extractContent(result: self.resultContent!)
            self.divideExtractedContent(extractedContent: self.extractedContent)
            self.decideAppropriateFeedback(dividedExtractedContent: self.segmentationExtractedResult)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOverview" {
            if let PreviewViewController = segue.destination as? PreviewViewController {
                PreviewViewController.feedbackResult = finalFeedbackResult
            }
        }
    }
    
    func segmentContent(contents:[SegmentedModel]) -> Segment {
        var result:Segment = Segment()
        
        if contents.isEmpty {
            return result
        }
        
        var currLevelNode: [SegmentedModel] = []
        var currNode: SegmentedModel = SegmentedModel()
        var prevNode: SegmentedModel = SegmentedModel()
        var lastHeader: SegmentedModel = SegmentedModel()
        var currSegment:Segment = Segment()
        var nestedSegment:Segment = Segment()
        
        var nestedHeaderLevel = -1
        
        for (index,content) in contents.enumerated() {
            currNode = content
            
            if currNode == prevNode {
                continue
            }
            // Start of segment
            if index == 0 {
                prevNode = currNode
                if currNode.type.first == "H" {
                    lastHeader = currNode
                }
                currLevelNode.append(currNode)
                
                continue
            }
            else if index == 1 {
                prevNode = currNode
                if currNode.type.first == "H" {
                    
                    currSegment.addContents(contents: currLevelNode)
                    
                    result.addSegment(segment: currSegment)
                    
                    currSegment = Segment()
                    lastHeader = currNode
                    
                    currLevelNode.removeAll()
                    currLevelNode.append(currNode)
                    nestedHeaderLevel += 1
                    
                }
                else if currNode.type.first == "B" {
                    currLevelNode.append(currNode)
                }
                continue
            }
            
            // if node is header
            if currNode.type.first == "H" {
                // check if node(header) value is lower than equal to the last header
                if (currNode.type.last?.hexDigitValue)! <= (lastHeader.type.last?.hexDigitValue)! {
                    // if the previous node is also header
                    if prevNode.type.first == "H" {
                        lastHeader = currNode
                        
                        nestedSegment.addContents(contents: currLevelNode)
                        
                        currLevelNode.removeAll()
                        currLevelNode.append(currNode)
                        nestedHeaderLevel += 1
                    }
                        // if previous node is a body
                    else if prevNode.type.first == "B" {
                        // if the current node header value is equal to the last header value
                        if (currNode.type.last?.hexDigitValue)! == (lastHeader.type.last?.hexDigitValue)! {
                            if nestedHeaderLevel > 0 {
                                nestedSegment.addContents(contents: currLevelNode)
                                currLevelNode.removeAll()
                                currSegment.addSegment(segment: nestedSegment)
                                currLevelNode.append(currNode)
                            }
                            else {
                                nestedSegment.addContents(contents: currLevelNode)
                                currLevelNode.removeAll()
                                currLevelNode.append(currNode)
                                currSegment.addSegment(segment: nestedSegment)
                                nestedSegment = Segment()
                                
                            }
                        }
                            // if the current node header value is not equal to the last header value
                        else {
                            lastHeader = currNode
                            currLevelNode.append(currNode)
                            
                            nestedSegment.addContents(contents: currLevelNode)
                            currLevelNode.removeAll()
                            
                            result.addSegment(segment: currSegment)
                            
                            currSegment = Segment()
                            nestedHeaderLevel -= 1
                            
                        }
                    }
                }
                    // If current header is higher than last header
                else {
                    if prevNode.type.first == "H" {
                        lastHeader = currNode
                        currLevelNode.append(currNode)
                        
                        currSegment.addContents(contents: currLevelNode)
                        
                        currLevelNode.removeAll()
                        currLevelNode.append(currNode)
                        
                    }
                    else if prevNode.type.first == "B" {
                        if nestedHeaderLevel > 0 {
                            nestedSegment.addContents(contents: currLevelNode)
                            
                            currLevelNode.removeAll()
                            currLevelNode.append(currNode)
                            
                            nestedHeaderLevel -= 1
                        }
                        else {
                            
                            nestedSegment.addContents(contents: currLevelNode)
                            currLevelNode.removeAll()
                            currLevelNode.append(currNode)
                            
                            currSegment.addSegment(segment: nestedSegment)
                            
                            result.addSegment(segment: currSegment)
                            
                            currSegment = Segment()
                            nestedSegment = Segment()
                            
                            nestedHeaderLevel -= 1
                            
                        }
                    }
                }
                
            }
                // If current node is a body
            else if currNode.type.first == "B" {
                currLevelNode.append(currNode)
            }
            prevNode = currNode
        }
        
        currSegment.addContents(contents: currLevelNode)
        currLevelNode.removeAll()
        result.addSegment(segment: currSegment)
        currSegment = Segment()
        
        return result
    }
    
    var temp:[String]?
    func appointSummaryFeedback(for text: String) {
        var summary: [Substring] = []
        if brain.isSummaryFound(in: text){
            summary = text.split(separator: "\n")
        }
        
        var tempForEach = 0
        var summarySetelahPersonalProfile = ""
        summary.forEach { (cekTemp) in
            /*
                         yg punya robby
            if cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "Personal Profile".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "About Me".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "About".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "Profile".lowercased() || cekTemp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "In Words".lowercased() || text.lowercased().contains("Summary".lowercased()){
                summarySetelahPersonalProfile.append(String(summary[tempForEach+1]))
                return
            }
            else if tempForEach == summary.count - 1 {
                         */
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
        
        print(output1)
        print(output2)
        
        if Float(output1)! < 50 {
            finalFeedbackResult[0].overview.append("- Fill in your summary with things your passionate about and tell a little bit about it!\n\n")
        } else if Float(output1)! >= 50 {
            finalFeedbackResult[0].overview.append("- Wow, you have passion in everything that you do! It’s great to see you explain it well in your summary!\n\n")
        }
        
        if Float(output2)! < 50 {
            finalFeedbackResult[0].overview.append("- It’s better for you to tell more detailed about what you want to do next and what goals you want to achieve in your journey!\n\n")
        } else if Float(output2)! >= 50 {
            finalFeedbackResult[0].overview.append("- You also mentioned about what you want to do in your company you applied for and it’s a good thing to do!\n\n")
        }
        
        //finalFeedbackResult[0].overview.append("\(output1)% Passionate\n")
        //finalFeedbackResult[0].overview.append("\(output2)% Personal\n")
        
        //Check typo
        print("typo bool = \(brain.isReal(word: summarySetelahPersonalProfile))")
        if brain.isReal(word: summarySetelahPersonalProfile) == true{
            
        }else if brain.isReal(word: summarySetelahPersonalProfile) == false{
            finalFeedbackResult[0].overview.append("- Your summary has a typo\n\n")
        }
        
        // Check word count
        let words =  summarySetelahPersonalProfile.split { !$0.isLetter }
        if text.count > 200 + words.count {
            finalFeedbackResult[0].overview.append("- Your summary is too long, reduce few words to make it more simple.\n\n")
        } else {
            finalFeedbackResult[0].overview.append("- You showed a good and simple summary about yourself.\n\n")
        }
        
        // Check usage of words and frequency
        let wordDict = brain.createWordDictionary(text: text)
        if !brain.isWordFrequencyAppropriate(dictionary: wordDict) {
            finalFeedbackResult[0].overview.append("- It seems that you overused some words. Try to change some words!\n\n")
        } else {
            finalFeedbackResult[0].overview.append("- Your summary has a lot of word variation.\n\n")
        }
        
        if !brain.isActionVerbAppropriate(text: text) {
            finalFeedbackResult[0].overview.append("- You have to use more action verbs in your summary.")
        } else {
            finalFeedbackResult[0].overview.append("- It's great that you use action verbs in your summary!")
        }
    }
    
    func appointProfileFeedback(for text: String) {
        finalFeedbackResult[1].type = "Profile"
        if !brain.isEmailRegexFound(text: text.replacingOccurrences(of: " ", with: "")) {
            finalFeedbackResult[1].overview.append("- You haven't put your e-mail!\n\n")
        } else if brain.isEmailRegexFound(text: text.replacingOccurrences(of: " ", with: "")) {
            finalFeedbackResult[1].overview.append("- Nice! Providing your e-mail helps to ease the communication between you and the company!\n\n")
        }
        
        if !brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("- You haven't put your phone number!")
        } else if brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].overview.append("- Stating your phone number further increase the communication for you and the company!")
        }
    }
    
    func appointEducationFeedback(for text: String) {
        finalFeedbackResult[2].type = "Education"
        if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .inRange {
            finalFeedbackResult[2].overview.append("- Your GPA looks promising!")
        } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .outOfBound {
            finalFeedbackResult[2].overview.append("- Your GPA seems lower than the recommended boundaries.")
        } else {
            finalFeedbackResult[2].overview.append("- You may provide your GPA to boost the chance of being accepted!")
        }
    }
    
    func appointWorkFeedback(for text: String) {
        
        var workExperience: [Substring] = []
        workExperience = text.split(separator: "\n")
        
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
            finalFeedbackResult[3].overview.append("- You have to explain more of what you did in each of your working experiences so it can be more detailed!\n\n")
        }else if outputWorkExperienceMid >= outputWorkExperienceGood && outputWorkExperienceMid >= outputWorkExperienceBad{
            finalFeedbackResult[3].overview.append("- Your working experiences are great but add a little more details of it!\n\n")
        }else if outputWorkExperienceGood >= outputWorkExperienceMid && outputWorkExperienceGood >= outputWorkExperienceBad{
            finalFeedbackResult[3].overview.append("- You did great job in putting all details of your working experiences!\n\n")
        }
        
        finalFeedbackResult[3].type = "Work Experience"
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[3].overview.append("- Rearrange your working experiences from the most current until the latest one!")
        } else {
            finalFeedbackResult[3].overview.append("- You showed your working experiences at chronological order!")
        }
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
            finalFeedbackResult[4].overview.append("- You can elaborate more on each of your experiences and give some details on it.\n\n")
        }else if outputOrganisationExperienceMid >= outputOrganisationExperienceGood && outputOrganisationExperienceMid >= outputOrganisationExperienceBad{
            finalFeedbackResult[4].overview.append("- Your organisational experiences are good enough but you can explain more details of what you did there.\n\n")
        }else if outputOrganisationExperienceGood >= outputOrganisationExperienceMid && outputOrganisationExperienceGood >= outputOrganisationExperienceBad{
            finalFeedbackResult[4].overview.append("- Wow, your organisational experiences were explained very detailed and easy to understand what you did there.\n\n")
        }
        
        finalFeedbackResult[4].type = "Organisational Experience"
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[4].overview.append("- Rearrange your organisational experiences from the most current until the latest one!")
        } else {
            finalFeedbackResult[4].overview.append("- You showed your organisational experiences at chronological order!")
        }
    }
    
    func appointSkillsFeedback(for text: String) {
        finalFeedbackResult[5].type = "Skills"
        if !brain.isRelatedSkillsAppropriate(text: text) {
            finalFeedbackResult[5].overview.append("- You have to put more skills which are relevant with the job you're applying for.")
        } else {
            finalFeedbackResult[5].overview.append("- Great! Your skills are relevant with job that you've applied!")
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
            switch self.brain.checkContentFound(in: key) {
            case .personalInfo:
                self.appointProfileFeedback(for: dividedExtractedContent[key]!)
            case .education:
                self.appointEducationFeedback(for: dividedExtractedContent[key]!)
            case .workExperience:
                self.appointWorkFeedback(for: dividedExtractedContent[key]!)
            case .organisationExperience:
                self.appointOrganisationFeedback(for: dividedExtractedContent[key]!)
            case .skills:
                self.appointSkillsFeedback(for: dividedExtractedContent[key]!)
            case .summary:
                self.appointSummaryFeedback(for: dividedExtractedContent[key]!)
                if self.brain.isEmailRegexFound(text: dividedExtractedContent[key]!) || self.brain.isPhoneNumberRegexFound(text: dividedExtractedContent[key]!) {
                    self.appointProfileFeedback(for: dividedExtractedContent[key]!)
                }
            default:
                break
            }
        }
        
        dispatchMain.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { (timer) in
                UIView.animate(withDuration: 1.0) {
                    self.moveItem()
                }
            }
        }
        
        print("final result\(self.finalFeedbackResult)")
        
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
                timer.invalidate()
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
