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
    
    @IBOutlet weak var mascotSpriteImage: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
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
    var finalFeedbackResult: [String] = ["", "", "", "", "", ""]
    
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
        addBubble()
        // Do any additional setup after loading the view.
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        setCollectionViewLayout()
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(recursiveLoop), userInfo: nil, repeats: false)
        
        addBubble()
        
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
                PreviewViewController.finalFeedbackResult = finalFeedbackResult
            }
        }
    }
    
    var countRecursiveLoop = 0
    @objc func recursiveLoop(){
        if self.countRecursiveLoop <= self.processDetails.count+1{
            UIView.animate(withDuration: 1.0, animations: {
                if self.countRecursiveLoop == 0{
                    self.countRecursiveLoop += 1
                } else {
                    self.moveItem()
                    self.countRecursiveLoop += 1
                }
            }) { (finished) in
                if finished{
                    UIView.animate(withDuration: 1.0, animations: {
                        if self.countRecursiveLoop <= self.processDetails.count{
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
        // Check word count
        let words =  text.split { !$0.isLetter }
        if text.count > 200 + words.count {
            finalFeedbackResult[0].append("Too many words\n")
        } else {
            finalFeedbackResult[0].append("Good and simple\n")
        }
        
        // Check usage of words and frequency
        var wordDict = brain.createWordDictionary(text: text)
        if !brain.isWordFrequencyAppropriate(dictionary: wordDict) {
            finalFeedbackResult[0].append("Too many repeat words\n")
        } else {
            finalFeedbackResult[0].append("Nice less repeat words\n")
        }
        
        if !brain.isActionVerbAppropriate(text: text) {
            finalFeedbackResult[0].append("No action verbs\n")
        } else {
            finalFeedbackResult[0].append("Good use action verbs\n")
        }
    }
    
    func appointProfileFeedback(for text: String) {
        if !brain.isEmailRegexFound(text: text) {
            finalFeedbackResult[1].append("Email not found\n")
        } else if brain.isEmailRegexFound(text: text) {
            finalFeedbackResult[1].append("Good! email found\n")
        }
        
        if !brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].append("Phone number not found\n")
        } else if brain.isPhoneNumberRegexFound(text: text) {
            finalFeedbackResult[1].append("Good! phone number found\n")
        }
    }
    
    func appointEducationFeedback(for text: String) {
        if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .inRange {
            finalFeedbackResult[2].append("Good GPA\n")
        } else if brain.isRangeGPARegexFound(lowerBoundary: 3, upperBoundary: 4, text: text) == .outOfBound {
            finalFeedbackResult[2].append("Bad GPA\n")
        } else {
            finalFeedbackResult[2].append("GPA not found\n")
        }
    }
    
    func appointWorkFeedback(for text: String) {
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[3].append("Work timeline not chronological\n")
        } else {
            finalFeedbackResult[3].append("Work timeline chronological\n")
        }
        
        // Check whether the description is descriptive enough
        // TO DO: Insert using model here
    }
    
    func appointOrganisationFeedback(for text: String) {
        if !brain.isChronological(text: brain.getYear(for: text)) {
            finalFeedbackResult[4].append("Organisation timeline not chronological\n")
        } else {
            finalFeedbackResult[4].append("Organisation timeline chronological\n")
        }
        
        // Check whether the description is action-based or result-based
        // TO DO: Insert using model here
    }
    
    func appointSkillsFeedback(for text: String) {
        if !brain.isRelatedSkillsAppropriate(text: text) {
            finalFeedbackResult[5].append("Not sufficient relevant skills\n")
        } else {
            finalFeedbackResult[5].append("Sufficient relevant skills\n")
        }
    }
    
    func divideExtractedContent(extractedContent: [String]) {
        print(headerCV.count)
        var index = -1
        var temp: String = ""
        for q in 0 ..< extractedContent.count {
            for x in 0 ..< headerCV.count {
                if extractedContent[q] == headerCV[x] {
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
        
//        for l in segmentationExtractedResult.keys{
//            print("segmentationExtractedResult \(l) = \(segmentationExtractedResult[l])\n")
//        }
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
                        if lastTypeNumberString == tempFontSize-1 {
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
                        if lastTypeNumberString == tempFontSize-1 {
                            headerCV.append(result.contents[j].label)
                        }
                    }
                }
            }
        }
    }
    
    func decideAppropriateFeedback(dividedExtractedContent: [String:String]) {
        for key in dividedExtractedContent.keys {
            if key.lowercased().contains("Contact Info".lowercased()) || key.lowercased().contains("Contact".lowercased()) || key.lowercased().contains("Personal Information".lowercased()) {
                appointProfileFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Education".lowercased()) || key.lowercased().contains("Academic History".lowercased()) || key.lowercased().contains("Academic Background".lowercased()) || key.lowercased().contains("Education History".lowercased()) {
                appointEducationFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Work Experience".lowercased()) || key.lowercased().contains("Work History".lowercased()) || key.lowercased().contains("Working Experience".lowercased()) || key.lowercased().contains("Job History".lowercased()) || key.lowercased().contains("Experience".lowercased()) {
                appointWorkFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Organisation Experience".lowercased()) || key.lowercased().contains("Organisational Experience".lowercased()) || key.lowercased().contains("Organization Experience".lowercased()) || key.lowercased().contains("Organizational Experience".lowercased()) || key.lowercased().contains("Organization History".lowercased()) || key.lowercased().contains("Organisation History".lowercased()) || key.lowercased().contains("Organizational".lowercased()) || key.lowercased().contains("Organisational".lowercased()) {
                appointOrganisationFeedback(for: dividedExtractedContent[key]!)
            } else if key.lowercased().contains("Summary".lowercased()) || key.lowercased().contains("About Me".lowercased()) || key.lowercased().contains("About".lowercased()) || key.lowercased().contains("Personal Profile".lowercased()) || key.lowercased().contains("Profile".lowercased()) || key.lowercased().contains("In Words".lowercased()) {
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
            
            print(users![0].classifications[0].tag_name)
            print(users![0].classifications[0].confidence)
            print(users![0].classifications[1].tag_name)
            print(users![0].classifications[1].confidence)
            
            // Check the classification confidence, which one has higher confidence
            for user in users! {
                if user.classifications[0].confidence >= user.classifications[1].confidence {
                    taggedClassification = user.classifications[0].tag_name
                }
                else {
                    taggedClassification = user.classifications[1].tag_name
                }
            }
        }
        task.resume()
        return taggedClassification
    }
    
    
    func addBubble(){
        let width: CGFloat = 252
        let height: CGFloat = 87
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 22, y: height))
        bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
        bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
        bezierPath.addLine(to: CGPoint(x: width, y: 17))
        bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: 21, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
        bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
        bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
        bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
        bezierPath.close()
        
        let outgoingMessageLayer = CAShapeLayer()
        outgoingMessageLayer.path = bezierPath.cgPath
        outgoingMessageLayer.frame = CGRect(x: 145,
                                            y: self.view.frame.maxY/3,
                                            width: 68,
                                            height: 34)
        outgoingMessageLayer.fillColor = UIColor(hex: "#4B96DCFF")?.cgColor
        
        self.view.layer.addSublayer(outgoingMessageLayer)
    }
    
    // Change this function with the function to be called automatically upon completion on certain progress
    func moveItem(){
        var cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        guard let onGoingIndex = onGoingRow.rowIndexPath else { return }
        onGoingRow.doneArray?.append(onGoingIndex.row)
        cell?.setCellStatus(statusType: .done)
        
        onGoingRow.rowIndexPath?.row += 1
        cell = processCollectionView.cellForItem(at: onGoingRow.rowIndexPath!) as? ProcessCollectionViewCell
        cell?.setCellStatus(statusType: .working)
        
        if onGoingRow.rowIndexPath!.row + 2 < processDetails.count {
            processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row + 1, section: 0), at: .bottom, animated: true)
        }
        else if onGoingRow.rowIndexPath!.row < processDetails.count{
            processCollectionView.scrollToItem(at: IndexPath(row: onGoingRow.rowIndexPath!.row - 2, section: 0), at: .top, animated: true)
        }
        else {
            if onGoingRow.doneArray!.count < processDetails.count {
                onGoingRow.doneArray?.append(onGoingRow.rowIndexPath!.row)
                cell?.setCellStatus(statusType: .done)
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
        layout.sectionInset = UIEdgeInsets(
            top: layout.itemSize.height * 2,
            left: processCollectionView.frame.size.width / 4,
            bottom: layout.itemSize.height * 2,
            right: processCollectionView.frame.size.width / 4)
        layout.itemSize = CGSize(width: self.processCollectionView.frame.width, height: processCollectionView.frame.height / 4)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = layout.itemSize.width
        
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
