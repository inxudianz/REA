//
//  HomeNavigationViewController.swift
//  Creativ
//
//  Created by Evan Christian on 12/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit

class HomeNavigationViewController: UINavigationController {

    let customFont = CustomFont()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: customFont.getCustomFontType(type: .Bold, size: 17), .foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: customFont.getCustomFontType(type: .Bold, size: 34), .foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.init(hex: "#30669BFF")
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        // Do any additional setup after loading the view.
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
