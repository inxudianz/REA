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

enum ContentFound: String {
    case personalInfo
    case education
    case workExperience
    case organisationExperience
    case skills
    case summary
    case notFound
}

class Brain {
    /* Array of action verbs necessary in a summary or when making experience description */
    let arrayActionVerb: [String] = ["Simplify", "Create", "Produce", "Achieve", "Improve", "Enhance", "Nurture", "Manage", "Maintain", "Develop", "Lead", "Assemble", "Build", "Ensure", "Help", "Engineer", "Design", "Construct", "Upgrade", "Reduce", "Prove", "Eliminate", "Attain", "Work"]
    
    let arrayRelatedSkills: [String] = ["JSON", "API", "Array", "Dictionary", "Set", "Git", "Github", "Core Data", "Human Interface Guidelines", "HIG", "MVVM", "MVC", "Swift", "Objective C", "Framework", "UIKit", "SwiftUI", "CoreML", "Machine Learning", "Design Pattern", "Artificial Intelligence", "Kotlin", "Java", "C", "C++", "MVP", "Cloud", "CloudKit", "UIKit", "PDFKit", "SpriteKit", "SceneKit", "Ruby", "Fortran", "HTML", "CSS", "Javascript"]
    
    let relevantWordDict: [String: String] = ["Simplify": "Action", "Create": "Action", "Produce": "Action", "Achieve": "Action", "Improve": "Action", "Enhance": "Action", "Nurture": "Action", "Manage": "Action", "Maintain": "Action", "Develop": "Action", "Lead": "Action", "Assemble": "Action", "Build": "Action", "Ensure": "Action", "Help": "Action", "Engineer": "Action", "Design": "Action", "Construct": "Action", "Upgrade": "Action", "Reduce": "Action", "Prove": "Action", "Eliminate": "Action", "Attain": "Action", "API": "Skill", "Array": "Skill", "Dictionary": "Skill", "Set": "Skill", "Git": "Skill", "Github": "Skill", "Core Data": "Skill", "Human Interface Guidelines": "Skill", "HIG": "Skill", "MVVM": "Skill", "MVC": "Skill", "Swift": "Skill", "Objective C": "Skill", "Framework": "Skill", "JSON": "Skill"]
    
    /* Function to check phone number regex */
    func isPhoneNumberRegexFound(text: String) -> Bool {
        return text.range(of: "\\+?(\\(?\\+?62\\)?[ ]?|0)8[0-9]{1,3}(([ ]|\\-)?[0-9]{3,4}){2}", options: .regularExpression) != nil
    }
    
    /* Function to check e-mail regex */
    func isEmailRegexFound(text: String) -> Bool {
        return text.range(of: "[a-zA-Z0-9]+@(gmail|yahoo|hotmail|icloud).co(m|.[a-z]{2})", options: .regularExpression) != nil
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
    
    /* Nanti dibuat jadi struct */
    var summaryDictionary = Dictionary<String, Int>()
    var overusedWords:[String] = []
    var totalWordSummary = 0

    /* Function to check word frequency and what to do with it */
    func isWordFrequencyAppropriate(dictionary: [String: Int]) -> Bool {
        let dictionary = dictionary
        var isAppropriate:Bool = true
        
        for key in dictionary.keys {
            if Double(dictionary[key]!) / Double(totalWordSummary) > 0.2 {
                overusedWords.append(key)
                isAppropriate = false
            }
        }
        return isAppropriate
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
        let sortedText = yearOnly.sorted() { $0 > $1 }
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
        var isNameFound = false
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                if tag.rawValue == "PersonalName" {
                    isNameFound = true
                }
            }
        }
        return isNameFound
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
                    
                } else {
                    break
                }
                i += misspelledRange.location + misspelledRange.length

            }
            break
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    func checkContentFound(in key: String) -> ContentFound {
        let formattedKey = key.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        switch formattedKey {
        case "contact info", "contact", "personal information", "personal info":
            return ContentFound.personalInfo
        case "education", "academic history", "academic background", "education history":
            return ContentFound.education
        case "work experience", "work history", "working experience", "job history", "experience":
            return ContentFound.workExperience
        case let str where str.contains("organisation"), let str where str.contains("organization"), let str where str.elementsEqual("organisation experience"), let str where str.elementsEqual("organization experience"), let str where str.elementsEqual("organisational experience"), let str where str.elementsEqual("organizational experience"):
            return ContentFound.organisationExperience
        case let str where str.contains("skills"), let str where str.contains("skill"), let str where str.contains("expertise"), let str where str.contains("technical skills"):
            return ContentFound.skills
        case let str where str.contains("summary"), let str where str.contains("about me"), let str where str.contains("about"), let str where str.contains("personal profile"), let str where str.contains("profile"), let str where str.contains("in words"):
            return ContentFound.summary
        default:
            if personalNameEntityRecognitionFound(for: formattedKey) && formattedKey.count < 40 {
                return ContentFound.personalInfo
            }
            return ContentFound.notFound
        }
    }
    
    func isPersonalInfoFound(in key: String) -> Bool {
        if key.lowercased() == "contact info" || key.lowercased() == "contact" || key.lowercased() == "personal information" || key.lowercased() == "personal info" {
            return true
        }
        return false
    }

    func isEducationFound(in key: String) -> Bool {
        if key.lowercased() == "education" || key.lowercased() == "academic history" || key.lowercased() == "academic background" || key.lowercased() == "education history" {
            return true
        }
        return false
    }

    func isWorkExperienceFound(in key: String) -> Bool {
        if key.lowercased() == "work experience" || key.lowercased() == "work history" || key.lowercased() == "working experience" || key.lowercased() == "job history" || key.lowercased() == "experience" {
            return true
        }
        return false
    }

    func isOrganisationExperienceFound(in key: String) -> Bool {
        if key.lowercased() == "organisation experience" || key.lowercased() == "organisational experience" || key.lowercased() == "organization experience" || key.lowercased() == "organizational experience" || key.lowercased() == "organisation history" || key.lowercased() == "organization history" || key.lowercased().contains("organisation") || key.lowercased().contains("organization") {
            return true
        }
        return false
    }

    func isSkillsFound(in key: String) -> Bool {
        if key.lowercased().contains("skills") || key.lowercased().contains("skill") || key.lowercased().contains("expertise") || key.lowercased().contains("technical skills") || key.lowercased().contains("key skills") {
            return true
        }
        return false
    }

    func isSummaryFound(in key: String) -> Bool {
        if key.lowercased().contains("summary") || key.lowercased().contains("about me") || key.lowercased().contains("about") || key.lowercased().contains("personal profile") || key.lowercased().contains("profile") || key.lowercased().contains("in words") {
            return true
        }
        return false
    }
}
