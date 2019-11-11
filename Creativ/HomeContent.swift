//
//  HomeContent.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 11/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

struct HomeContent {
    var cvImage: UIImage
    var cvName: String
    var cvCreated: String
    
    static func createHomeContent() -> [HomeContent] {
        
        let Content1 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "RobbyCV", cvCreated: "2019-11-01")
        let Content2 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "CaesarCV", cvCreated: "2019-11-01")
        let Content3 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "EvanCV", cvCreated: "2019-11-01")
        let Content4 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "OwenCV", cvCreated: "2019-11-01")
        let Content5 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "WillCV", cvCreated: "2019-11-01")
        let Content6 = HomeContent(cvImage: UIImage(named: "Content1")!, cvName: "AgnesCV", cvCreated: "2019-11-01")
        
        return [Content1, Content2, Content3, Content4, Content5, Content6]
    }
}
