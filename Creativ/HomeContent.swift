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
    var cvId: UUID
    var cvImage: UIImage
    var cvName: String
    var cvCreated: String
    
    static func createHomeContent() -> [HomeContent] {
        
        let content1 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "RobbyCV", cvCreated: "12-11-2019")
        let content2 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "CaesarCV", cvCreated: "12-11-2019")
        let content3 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "OwenCV", cvCreated: "12-11-2019")
        let content4 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "EvanCV", cvCreated: "12-11-2019")
        let content5 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "WillCV", cvCreated: "12-11-2019")
        let content6 = HomeContent(cvId: UUID(), cvImage: UIImage(named: "Content1")!, cvName: "AgnesCV", cvCreated: "12-11-2019")
    
        return [content1, content2, content3, content4, content5, content6]
    }
}
