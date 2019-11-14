//
//  Brain.swift
//  Creativ
//
//  Created by Owen Prasetya on 14/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

class Brain {
    
    let arrayActionVerb: [String] = ["Simplify", "Create", "Produce", "Achieve", "Improve", "Enhance", "Nurture", "Manage", "Maintain", "Develop", "Lead", "Assemble", "Build", "Ensure", "Help", "Engineer", "Design", "Construct", "Upgrade"]
    
    func isPhoneNumberRegexFound(text: String) -> Bool {
        return text.range(of: "^(\\+62[ ]?|0)8[0-9]{1,2}(([ ]|\\-)?[0-9]{3,4}){2}$", options: .regularExpression) != nil
    }
    
    func isEmailRegexFound(text: String) -> Bool {
        return text.range(of: "^[a-z0-9]+@(gmail|yahoo|hotmail).co(m|.[a-z]{2})$", options: .regularExpression) != nil
    }
    
}
