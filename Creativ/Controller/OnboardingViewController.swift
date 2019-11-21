//
//  OnboardingViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    let customFont = CustomFont()
    
    @IBOutlet weak var onboardingTitle1: UILabel! {
        didSet {
            onboardingTitle1.font = customFont.getCustomFontType(type: .Bold, size: 16)
        }
    }
    @IBOutlet weak var onboardingLabel1: UILabel! {
        didSet {
            onboardingLabel1.font = customFont.getCustomFontType(type: .Regular, size: 14)
        }
    }
    @IBOutlet weak var onboardingTitle2: UILabel! {
        didSet {
            onboardingTitle2.font = customFont.getCustomFontType(type: .Bold, size: 16)
        }
    }
    @IBOutlet weak var onboardingLabel2: UILabel! {
        didSet {
            onboardingLabel2.font = customFont.getCustomFontType(type: .Regular, size: 14)
        }
    }
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.layer.cornerRadius = continueButton.frame.height/5
            continueButton.titleLabel?.font = customFont.getCustomFontType(type: .Bold, size: 17)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueButton(_ sender: Any) {
        performSegue(withIdentifier: "goToHome", sender: self)
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
