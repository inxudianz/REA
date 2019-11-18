//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class ProcessingViewController: UIViewController {
    
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
    var processDetails: [String] = ["Checking Identity", "Looking at Summary", "Viewing Education", "Evaluating Your Work", "Analyzing Skills", "Finalizing"]
    // DESC: instance onGoingProcessp; berisi row yang sedang berjalan dan array proses yang telah selesai berjalan
    var onGoingRow = onGoingProcess()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        onGoingRow = onGoingProcess(rowIndexPath: IndexPath(row: 0, section: processCollectionView.numberOfSections - 1), doneArray: [])
        setCollectionViewLayout()
        dispatchClassificationHandler()
    }
    
    func dispatchClassificationHandler() {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        let dispatchMain = DispatchQueue.main
        
        dispatchQueue.async {
            // 1
            self.resumeClassification.append(self.handleClassification(text: "I love to learn and apply what is learned. Experienced in Mobile Development for both Android with Kotlin and iOS with Swift. Has implemented Git version control and understands Mobile UI and UX design."))
            self.sharedResources.append("1")
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
            }
            semaphore.wait()
            
            // 2
            self.resumeClassification.append(self.handleClassification(text: "i'm passionate at developing apps and really want to make the best app"))
            self.sharedResources.append("2")
            semaphore.signal()
            dispatchMain.sync {
                // Update UI here
            }
            semaphore.wait()
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
    
    // Change this function with the function to be called automatically upon completion on certain progress
    @IBAction func moveTableCellTapped(_ sender: Any) {
        
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
