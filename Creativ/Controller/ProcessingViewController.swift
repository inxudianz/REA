//
//  ProcessingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class ProcessingViewController: UIViewController {

    @IBOutlet weak var mascotSpriteImage: UIImageView!
    @IBOutlet weak var bubbleMessage: UIView!
    
//    @IBOutlet weak var labelProcess1: UILabel!
//    @IBOutlet weak var labelProcess2: UILabel!
//    @IBOutlet weak var labelProcess3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setting up the image/sprite of Rena
        // mascotSpriteImage.image = UIImage(named: "")
        
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToOverview", sender: self)
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
