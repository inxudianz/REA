//
//  Brain.swift
//  Creativ
//
//  Created by Owen Prasetya on 14/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

enum GPAStatus {
    case notFound, outOfBound, inRange
}

class Brain {
    
    /* Array of action verbs necessary in a summary or when making experience description */
    let arrayActionVerb: [String] = ["Simplify", "Create", "Produce", "Achieve", "Improve", "Enhance", "Nurture", "Manage", "Maintain", "Develop", "Lead", "Assemble", "Build", "Ensure", "Help", "Engineer", "Design", "Construct", "Upgrade"]
    
    /* Function to check phone number regex */
    func isPhoneNumberRegexFound(text: String) -> Bool {
        return text.range(of: "^(\\+62[ ]?|0)8[0-9]{1,2}(([ ]|\\-)?[0-9]{3,4}){2}$", options: .regularExpression) != nil
    }
    
    /* Function to check e-mail regex */
    func isEmailRegexFound(text: String) -> Bool {
        return text.range(of: "^[a-z0-9]+@(gmail|yahoo|hotmail).co(m|.[a-z]{2})$", options: .regularExpression) != nil
    }
    
/*
    func isAddressRegexFound(text: String) -> Bool {
        return text.range(of: "^(Jl\\.|Jalan|Komp\\.|Komplek)[ ]*$", options: .regularExpression) != nil
    }
*/
    
    /* Function to check whether GPA is found, is lower or higher than the boundaries, or not found */
    func isRangeGPARegexFound(lowerBoundary: Int, upperBoundary: Int, text: String) -> GPAStatus {
        if text.range(of: "(^([3-4]{1}\\s)|([3]{1}[\\.|\\,]\\d{0,2}\\s))|[4][\\.|\\,][0]{0,2}\\s", options: .regularExpression) != nil {
            return GPAStatus.inRange
        }
        else if text.range(of: "(^([0-2|5-9]{1}\\s)|([0-2|4-9]{1}[\\.|\\,]\\d{0,2}\\s))", options: .regularExpression) != nil {
            return GPAStatus.outOfBound
        }
        else {
            return GPAStatus.notFound
        }
    }
    
    /* Struct */
    var summaryDictionary = Dictionary<String, Int>()
    var totalWordSummary = 0

    /* Function to check word frequency and what to do with it */
    func isWordFrequencyAppropriate(dictionary: [String: Int]) -> Bool {
        let dictionary = dictionary
        print(dictionary)
        
        for key in dictionary.keys {
            if Double(dictionary[key]!) / Double(totalWordSummary) > 0.05 {
                return false
            }
        }
        return true
    }

    /* Function for counting word frequency */
    func createWordDictionary(text: String) -> Dictionary<String, Int> {
        let words = text.components(separatedBy: NSCharacterSet.whitespaces)
        var wordDictionary = Dictionary<String, Int>()
        for word in words {
            if let count = wordDictionary[word] {
                // kalau wordnya udah ada, jumlahnya ditambah 1
                wordDictionary[word] = count + 1
            } else {
                // tambah word baru
                wordDictionary[word] = 1
            }
            // jumlah total semua word
            totalWordSummary += 1
        }
        return wordDictionary
    }
}
