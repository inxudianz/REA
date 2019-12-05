//
//  Brain.swift
//  Creativ
//
//  Created by Owen Prasetya on 14/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

enum GPAStatus {
    case notFound, outOfBound, inRange
}

class Brain {
    /* Array of action verbs necessary in a summary or when making experience description */
    let arrayActionVerb: [String] = ["Simplify", "Create", "Produce", "Achieve", "Improve", "Enhance", "Nurture", "Manage", "Maintain", "Develop", "Lead", "Assemble", "Build", "Ensure", "Help", "Engineer", "Design", "Construct", "Upgrade", "Reduce", "Prove", "Eliminate", "Attain", "Work"]
    
    let arrayRelatedSkills: [String] = ["JSON", "API", "Array", "Dictionary", "Set", "Git", "Github", "Core Data", "Human Interface Guidelines", "HIG", "MVVM", "MVC", "Swift", "Objective C", "Framework", "UIKit", "SwiftUI", "CoreML", "Machine Learning", "Design Pattern", "Artificial Intelligence", "Kotlin", "Java", "C", "C++", "MVP", "Cloud", "CloudKit", "UIKit", "PDFKit", "SpriteKit", "SceneKit", "Ruby", "Fortran", "HTML", "CSS", "Javascript"]
    
    let relevantWordDict: [String: String] = ["Simplify": "Action", "Create": "Action", "Produce": "Action", "Achieve": "Action", "Improve": "Action", "Enhance": "Action", "Nurture": "Action", "Manage": "Action", "Maintain": "Action", "Develop": "Action", "Lead": "Action", "Assemble": "Action", "Build": "Action", "Ensure": "Action", "Help": "Action", "Engineer": "Action", "Design": "Action", "Construct": "Action", "Upgrade": "Action", "Reduce": "Action", "Prove": "Action", "Eliminate": "Action", "Attain": "Action", "API": "Skill", "Array": "Skill", "Dictionary": "Skill", "Set": "Skill", "Git": "Skill", "Github": "Skill", "Core Data": "Skill", "Human Interface Guidelines": "Skill", "HIG": "Skill", "MVVM": "Skill", "MVC": "Skill", "Swift": "Skill", "Objective C": "Skill", "Framework": "Skill", "JSON": "Skill"]
    
    /* Function to check phone number regex */
    func isPhoneNumberRegexFound(text: String) -> Bool {
        return text.range(of: "\\+?(\\(?\\+?62\\)?[ ]?|0)8[0-9]{1,3}(([ ]|\\-)?[0-9]{3,4}){2}\\s", options: .regularExpression) != nil
    }
    
    /* Function to check e-mail regex */
    func isEmailRegexFound(text: String) -> Bool {
        return text.range(of: "[a-z0-9]+@(gmail|yahoo|hotmail).co(m|.[a-z]{2})\\s", options: .regularExpression) != nil
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
    
    func isActionVerbAppropriate(text: String) -> Bool {
        // Check action verb usage
        var actionVerbCount = 0
        
        for word in arrayActionVerb {
            if text.contains(word) {
                actionVerbCount += 1
                if actionVerbCount >= 1 {
                    return true
                }
            }
        }
        return false
    }
    
    func isRelatedSkillsAppropriate(text: String) -> Bool {
        var relevantSkillsCount = 0
        
        for word in arrayRelatedSkills {
            if text.contains(word) {
                relevantSkillsCount += 1
                if relevantSkillsCount >= 1 {
                    return true
                }
            }
        }
        return false
    }
    
    /* Struct */
    var summaryDictionary = Dictionary<String, Int>()
    var totalWordSummary = 0

    /* Function to check word frequency and what to do with it */
    func isWordFrequencyAppropriate(dictionary: [String: Int]) -> Bool {
        let dictionary = dictionary
        //print(dictionary)
        
        for key in dictionary.keys {
            if Double(dictionary[key]!) / Double(totalWordSummary) > 0.2 {
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
    
    func getYear(for text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "(present|now|(\\-|\\-|s\\/d|~|until)[ ]?[0-9]{2,4})", options: .caseInsensitive)
            return regex.matches(in: text, options: .reportCompletion, range: NSRange(location: 0, length: text.count)).map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func isChronological(text: [String]) -> Bool {
        var yearOnly: [String] = []
        for year in text {
            if year.range(of: "present|now", options: .regularExpression) == nil {
                yearOnly.append(year.components(separatedBy: CharacterSet(charactersIn: "\n - until s/d")).last!)
            } else {
                yearOnly.append(year)
            }
        }
        
        print("Chrono: \(text)")
        print("CHRONOLOGY: \(yearOnly)")
        let sortedText = yearOnly.sorted() { $0 > $1 }
        print("Sorted: \(sortedText)")
        if (yearOnly != sortedText && yearOnly.count > 1) || yearOnly.count == 0 {
            return false
        }
        return true
    }
    
    let tagger = NSLinguisticTagger(tagSchemes:[.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]

    func personalNameEntityRecognitionFound(for text: String) -> Bool {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        var isPersonalNameFound: Bool = false
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                print("\(name): \(tag.rawValue)")
                if tag.rawValue == "PersonalName" {
                    isPersonalNameFound = true
                }
            }
        }
        return isPersonalNameFound
    }
    
    func lemmatization(for text: String) -> String {
        tagger.string = text
        var lemmatized : String = ""
        let range = NSRange(location:0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, stop in
            if let lemma = tag?.rawValue {
                lemmatized = lemma
            }
        }
        return lemmatized
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        for word in arrayRelatedSkills {
            UITextChecker.learnWord(word)
        }
        
        for var i in 0 ..< word.utf16.count {
            var lastIndex = 0
            
            while true {
                let textChecker = UITextChecker()
                let misspelledRange =
                    textChecker.rangeOfMisspelledWord(in: word,
                                                      range: NSRange(0..<word.utf16.count),
                                                      startingAt: lastIndex,
                                                      wrap: false,
                                                      language: "en_US")
                
                if misspelledRange.location != NSNotFound,
                    let firstGuess = textChecker.guesses(forWordRange: misspelledRange,
                                                         in: word,
                                                         language: "en_US")?.first
                {
                    lastIndex = (misspelledRange.location + misspelledRange.length)
                    print("First guess: \(firstGuess)")
                    print("\(misspelledRange.length) sama \(misspelledRange.location)")
                    
                } else {
                    print("Not found")
                    break
                }
                i += misspelledRange.location + misspelledRange.length

            }
            break
        }
        
        return misspelledRange.location == NSNotFound
    }
}

//isReal(word: String)
//
//                for var i in 0 ..< quote.utf16.count {
//        var lastIndex = 0
//
//                while true {
//                    let textChecker = UITextChecker()
//                    let misspelledRange =
//                        textChecker.rangeOfMisspelledWord(in: quote,
//                                                          range: NSRange(0..<quote.utf16.count),
//                                                          startingAt: lastIndex,
//                                                          wrap: false,
//                                                          language: "en_US")
//
//                    if misspelledRange.location != NSNotFound,
//                        let firstGuess = textChecker.guesses(forWordRange: misspelledRange,
//                                                             in: quote,
//                                                             language: "en_US")?.first
//                    {
//                        lastIndex = (misspelledRange.location + misspelledRange.length)
//                        print("First guess: \(firstGuess)")
//                        print("\(misspelledRange.length) sama \(misspelledRange.location)")
//                        } else {
//                            print("Not found")
//                            break
//                        }
//                }
//                for (index,element) in quote.enumerated() {
//
//                }
//         First guess: hipster
//                        print(i)
//                        i += misspelledRange.location + misspelledRange.length
//
//                }

class BrainResult {
    var BrainResult: [String] = []
    
}
