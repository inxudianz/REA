//
//  HomeViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit

class HomeViewController: UIViewController{
    
    @IBOutlet weak var resumeCollectionView: UICollectionView!
    
    var contents: [ResumeModel] = []
    var tempContents : [ResumeModel] = []
    var segmentModel: SegmentedModel?
    var segmentedModel: SegmentedModel?
    var urlPicked: URL?
    var cellColour = true
    var segmentedResult: Segment?
    
    var isEdit = false
    var selectedItem = [Int]()
    var filePath = Bundle.main.url(forResource: "file", withExtension: "txt")
    var myData: Data!
    var fontMean: Float = 0
    var checkFileImage = 0
    var totalFont = 0
    
    
    @IBOutlet weak var testImg: UIImageView!

    var selectedResume:ResumeModel?
    
    let customFont = CustomFont()
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var cvCollectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem! {
        didSet {
            navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
            navBar.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
        }
    }
    
    @objc func deleteButton() {
        navBar.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButton))
        navBar.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(doneButton))
        navBar.leftBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
        navBar.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
        navBar.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: customFont.getCustomFontType(type: .Regular, size: 17)], for: .normal)
        navBar.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: customFont.getCustomFontType(type: .Regular, size: 17)], for: .normal)
        isEdit = true
        cvCollectionView.reloadData()
    }
    
    @objc func cancelButton() {
        let clearSelectedItem = [Int]()
        
        self.navBar.leftBarButtonItem?.isEnabled = false
        self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
        self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
        self.navBar.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
        self.selectedItem = clearSelectedItem
        
        self.isEdit = false
        cvCollectionView.reloadData()
    }
    
    @objc func doneButton() {
        let clearSelectedItem = [Int]()
        
        if selectedItem.count == 0 {
            self.navBar.leftBarButtonItem?.isEnabled = false
            self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
            self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
            self.navBar.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
            
            self.isEdit = false
            cvCollectionView.reloadData()
        } else {
            
            let alert = UIAlertController(title: "Delete Resume", message: "This CV will be deleted from iCloud Documents on all your devices.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete Resume", style: .destructive, handler: { action in
                
                let deletedItem = self.getDeletedItem()
                CoreDataHelper.delete(names: deletedItem )
                
                self.selectedItem.removeAll()
                self.tempContents = self.contents
                self.populateContent()
                self.cvCollectionView.reloadData()
                
                self.cvCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.navBar.leftBarButtonItem?.isEnabled = false
                self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
                self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
                self.navBar.rightBarButtonItem?.tintColor = UIColor.init(hex: "#FFD296FF")
                
                self.isEdit = false
                self.cvCollectionView.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.selectedItem = clearSelectedItem
                self.isEdit = true
                self.cvCollectionView.reloadData()
            }))
            
            present(alert, animated: true, completion: nil)
            
            self.isEdit = false
            cvCollectionView.reloadData()
        }
    }
    
    func getDeletedItem() ->[String] {
        var deletedContent:[String] = []
        
        for (index,content) in contents.enumerated() {
            if selectedItem.contains(index + 1) {
                deletedContent.append(content.name)
            }
        }
            return deletedContent
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        registerXIB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateContent()
        resumeCollectionView.reloadData()
    }
    
    func fetchData() -> [ResumeModel] {
        let fetchedDatas:[Resume] = CoreDataHelper.fetch(entityName: "Resume")
        
        var results:[ResumeModel] = []
        
        for fetchedData in fetchedDatas {
            var resume:ResumeModel = ResumeModel()
            var feedback:FeedbackModel = FeedbackModel()
            let feedbackDetails = fetchedData.hasFeedback?.hasManyDetail?.allObjects as! [FeedbackDetail]
            for feedbackDetail in feedbackDetails {
                let detailModel:FeedbackDetailModel = FeedbackDetailModel(type: feedbackDetail.type!, score: 0, overview: feedbackDetail.overview!)
                feedback.contents.append(detailModel)
            }
            resume.feedback = feedback
            resume.name = fetchedData.name!
            resume.dateCreated = fetchedData.dateCreated!
            resume.thumbnailImage = fetchedData.thumbnailImage!
            results.append(resume)
            
        }
        
        return results
    }
    
    func populateContent() {
        contents = fetchData()
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOverview" {
            if let overviewViewController = segue.destination as? OverviewViewController {
                    overviewViewController.fetchedResume = selectedResume!
            }
        } else if segue.identifier == "gotoprocess" {
            if let processingViewController = segue.destination as? ProcessingViewController {
                processingViewController.resultContent = segmentedResult
            }
        }
    }
    
    func registerXIB() {
        cvCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        cvCollectionView.register(UINib(nibName: "AddNewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddNewCollectionViewCellID")
        cvCollectionView.register(UINib(nibName: "CVNewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CVNewCollectionViewCellID")
        
        //print(listFilesFromDocumentsFolder())
        
        //read file
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let getImagePath = paths.appendingPathComponent("TIKET INDONESIA PERTAMA.pdf")
        //testImg.image = UIImage(contentsOfFile: getImagePath)

    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableViewID", for: indexPath) as? HomeCollectionReusableView {
            headerView.textDescription.text = "Here are the resumes that I've given feedback on. You can see them over and over again!"

            headerView.textDescription.sizeToFit()
            headerView.textDescription.numberOfLines = 0
            headerView.textDescription.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 162, height: headerView.textDescription.bounds.height)
            headerView.addBubble(height: headerView.textDescription.frame.maxY, width: UIScreen.main.bounds.width - 162)
            headerView.bringSubviewToFront(headerView.textDescription)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cellAddCv = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewCollectionViewCellID", for: indexPath) as? AddNewCollectionViewCell
            
            cellAddCv?.addNewCvBtn.tag = indexPath.row
            cellAddCv?.addNewCvBtn.addTarget(self, action: #selector(importCV(sender:)), for: .touchUpInside)
            
            if isEdit == true {
                cellAddCv?.isUserInteractionEnabled = false
            } else {
                cellAddCv?.isUserInteractionEnabled = true
            }
            
            return cellAddCv!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVNewCollectionViewCellID", for: indexPath) as? CVNewCollectionViewCell
            let content = contents[indexPath.row - 1]
            
            cell?.content = content
            
            if isEdit == true {
                if selectedItem.contains(indexPath.row){
                    cell?.backgroundColor = .lightGray
                    cell?.checklistImg.image = UIImage(named: "Checklist")
                } else {
                    cell?.backgroundColor = .clear
                    cell?.checklistImg.image = UIImage(named: "CombinedShape")
                }
            } else {
                cell?.checklistImg.image = .none
                cell?.backgroundColor = .clear
            }
            return cell!
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEdit == true {
            if !selectedItem.contains(indexPath.row){
                selectedItem.append(indexPath.row)
                collectionView.reloadData()
            } else {
                selectedItem.removeAll{$0 == indexPath.row}
                collectionView.reloadData()
            }
        } else {
            let content = contents[indexPath.row - 1]
            selectedResume = content
            performSegue(withIdentifier: "goToOverview", sender: self)
            print("Delete button not selected")
        }
    }
    
    
}

extension HomeViewController: UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    //mengambil url file
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        urlPicked = myURL
        
        let size = CGSize(width: 140, height: 211)
        let thumbnail = generatePdfThumbnail(of: size, for: urlPicked!, atPage: 0)
        let fileName = urlPicked!.lastPathComponent
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        let formattedDate = format.string(from: date)
        
        //save file to directory
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let ImageName = fileName
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(ImageName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = thumbnail!.jpegData(compressionQuality:  1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                // print("file saved")
            } catch {
                //  print("error saving file:", error)
            }
        }
        
        //cek ada filenya di directory atau tidak
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("RobbyC.pdf") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
        
        readPDFFile()
        
        if checkFileImage != 0 {
            currentData.name = fileName
            currentData.dateCreated = formattedDate
            currentData.thumbnailImage = thumbnail!.pngData()!
            
            checkFileImage = 0
        } else {
            self.cvCollectionView.reloadData()
        }
        
        tempContents = contents
        cvCollectionView.reloadData()
        performSegue(withIdentifier: "gotoprocess", sender: self)
    }
    
    //cek isi directory
    func listFilesFromDocumentsFolder() -> [String]? {
        let fileMngr = FileManager.default;
        
        // Full path to documents directory
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        // List all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs)
    }
    
    @objc func importCV(sender: UIButton!) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    //view was cancelled
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //menampilkan pdf file
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    //ubah pdf ke string
    func readPDFFile(){
        var cvContents:[(String,Double,Bool)] = []
        var pointAvg:Double = 0
        var arrFontSize: [Double] = []
        var categorisedcvContent:[SegmentedModel] = []
        
        if let pdf = PDFDocument(url: urlPicked!) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()

            for i in 0 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
            }
            
            documentContent.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, documentContent.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                guard let currentFont = value as? UIFont else {
                    return
                }
                let floatFontSize = Double(currentFont.pointSize)
                arrFontSize.append(floatFontSize)
                
                
                let content = documentContent.string
                let rangeContent = content[range.location..<range.location + range.length]
                let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
                checkFileImage += 1
                pointAvg += Double(currentFont.pointSize)
                
                cvContents.append((rangeContent, Double(currentFont.pointSize),isBold))
            }
            
        }
        
        if checkFileImage != 0 {
            let sortWithoutDuplicates = Array(Set(arrFontSize))
            let fontSizeSorted = sortWithoutDuplicates.sorted()
            let medianFontSize = fontSizeSorted[fontSizeSorted.count/2]
            
            pointAvg = pointAvg / Double(checkFileImage)

            let fontSizeSortedSplit = fontSizeSorted.split(separator: medianFontSize)
            var arrHeading:[(String,String)] = []
            var arrBody:[(String,String)] = []
            let checkMedian:Bool = pointAvg < medianFontSize
            
            for cvContent in cvContents {
                if cvContent.1 >= Double(medianFontSize)  {
                    for (index,largeFont) in fontSizeSortedSplit[1].enumerated() {
                        if cvContent.1 == largeFont {
                            arrHeading.append((cvContent.0,"Header\(index + 2)"))
                            categorisedcvContent.append(SegmentedModel(label: cvContent.0, type: "H\(index+2)", fontSize: cvContent.1, isBold: cvContent.2))
                        }
                        else if cvContent.1 == fontSizeSorted[fontSizeSorted.count/2] && checkMedian  {
                            arrHeading.append((cvContent.0,"Header1"))
                            categorisedcvContent.append(SegmentedModel(label: cvContent.0, type: "H1", fontSize: cvContent.1, isBold: cvContent.2))
                        }
                        
                    }
                }
                else {
                    for (index,smallFont) in fontSizeSortedSplit[0].enumerated() {
                        if cvContent.1 == smallFont {
                            arrBody.append((cvContent.0,"Body\(index + 2)"))
                            categorisedcvContent.append(SegmentedModel(label: cvContent.0, type: "B\(index+2)", fontSize: cvContent.1, isBold: cvContent.2))
                        }
                        else if cvContent.1 == fontSizeSorted[fontSizeSorted.count/2] && !checkMedian{
                            arrBody.append((cvContent.0,"Body1"))
                            categorisedcvContent.append(SegmentedModel(label: cvContent.0, type: "B1", fontSize: cvContent.1, isBold: cvContent.2))
                        }
                    }
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Couldn't Detect Resume!", message: "It appears that your resume is an image. Try to convert it to readable format.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
                self.cvCollectionView.reloadData()
            }))
            
            present(alert, animated: true, completion: nil)
        }
        segmentedResult = segmentContent(contents: categorisedcvContent)
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
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
