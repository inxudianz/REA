//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit


enum IndicatorType {
    case dormant, active, done
}


class ProcessingViewController: UIViewController {

    @IBOutlet weak var mascotSpriteImage: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
    @IBOutlet weak var processTableView: UITableView! {
        didSet {
            processTableView.rowHeight = processTableView.frame.height/4.5
            
            processTableView.separatorStyle = .none
            processTableView.isUserInteractionEnabled = false
        }
    }
    
    var activityIndicator: UIActivityIndicatorView!
    
    // Komponen dalam table view
    var progressDetails: [String] = ["Checking Identity", "Looking at Summary", "Viewing Education", "Evaluating Your Work", "Analyzing Skills", "Finalizing"]
    var flagRow = 2    // Minimal 2 ; karena ada 2 cell kosong di atas dan bawah (0, 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setting up the image/sprite of Rena
        // mascotSpriteImage.image = UIImage(named: "")
        
        activityIndicator = UIActivityIndicatorView.init(style: .medium)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        scrollToRowDelegate(tableView: processTableView, row: flagRow)
//        processTableView.reloadData()
//    }
    
    func scrollToRowDelegate(tableView: UITableView, flagRow: Int) {
        let indexPath = IndexPath(row: flagRow, section: tableView.numberOfSections-1)
        
        if indexPath.row >= 2 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        processTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
        print("Scroll success")
    }

    // Change this function with the function to be called automatically upon completion on certain progress
    @IBAction func moveTableCellTapped(_ sender: Any) {
//        let deleteIndexPath = IndexPath(row: 1, section: 0)
//        let insertIndexPath = IndexPath(row: 3, section: 0)
//        processTableView.deleteRows(at: [deleteIndexPath], with: .top)
//        processTableView.insertRows(at: [insertIndexPath], with: .bottom)
        
        print("HI \(flagRow)")
        //activityIndicator.stopAnimating()
        
        if flagRow < progressDetails.count + 2 {
//            processTableView.cellForRow(at: IndexPath(row: flagRow, section: processTableView.numberOfSections-1))?.accessoryView = activityIndicator
            scrollToRowDelegate(tableView: processTableView, flagRow: flagRow)
    
            flagRow += 1
        }
        else{
            performSegue(withIdentifier: "goToOverview", sender: self)
            flagRow = 2
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProcessingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressDetails.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = processTableView.dequeueReusableCell(withIdentifier: "processDetail", for: indexPath) as! ProcessTableViewCell
        
        if flagRow != indexPath.row {
            cell.accessoryType = .none
        }
        
        if indexPath.row > 1 && indexPath.row < progressDetails.count + 2 {
            cell.displayFeedbackContent(text: progressDetails[indexPath.row - 2])
        }
        else {
            cell.displayFeedbackContent(text: "")
        }
        
        return cell
    }
}
