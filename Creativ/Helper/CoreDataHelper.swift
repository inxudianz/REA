//
//  CoreDataHelper.swift
//  Creativ
//
//  Created by William Inx on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import CoreData
import UIKit

class CoreDataHelper {
    
    func fetch<T>(entityName :String) -> [T] {
        var result:[T] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                print("Error : Could not open AppDelegate!")
                return result
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            result = try managedContext.fetch(request) as! [T]
            print("Success fetching data")
        }
        catch {
            print("Error : Failed when trying to fetch data")
        }
        
        return result
    }

    func saveResume(model: ResumeModel) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return print("Error : Could not get AppDelegate file!")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let resume = Resume(context: managedContext)
        resume.name = model.name
        resume.dateCreated = model.dateCreated
        resume.thumbnailImage = model.thumbnailImage
        
        let feedback = Feedback(context: managedContext)
        feedback.score = Int64(model.feedback.score)
        feedback.overview = model.feedback.overview
        
        let contents = model.feedback.contents
        
        var feedbackContents = [FeedbackContent(context: managedContext)]
        var feedbackDetails = [FeedbackContentDetail(context: managedContext)]
        for content in contents {
            let feedbackContent = FeedbackContent(context: managedContext)
            feedbackContent.type = content.type
            feedbackContent.score = Int64(content.score)
            feedbackContent.overview = content.overview
            
            feedbackContents.append(feedbackContent)
            
            let contentDetails = content.details
            
            for contentDetail in contentDetails {
                let feedbackDetail = FeedbackContentDetail(context: managedContext)
                feedbackDetail.overview = contentDetail.overview
                feedbackDetail.score = Int64(contentDetail.score)
                feedbackDetail.type = contentDetail.type
                
                feedbackDetails.append(feedbackDetail)
            }
            
        }
        
        do {
            try managedContext.save()
            print("Success saving data")
        }
        catch {
            print("Error : Saving data")
        }
    }
    
    func delete(names: [String]) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return print("Error : Could not get AppDelegate file!")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let resumes:[Resume] = fetch(entityName: "Resume")
        
        for resume in resumes {
            
            guard let name  = resume.name else {
                print("Error: Name data not found")
                return
            }
            
            if names.contains(name) {
                managedContext.delete(resume)
            }
        }
        
        do {
            try managedContext.save()
        }
        catch {
            print("Error : Failed to save managedContext")
        }
        
    }
}
