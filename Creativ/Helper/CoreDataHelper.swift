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

    func save<T>(model: T) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return print("Error : Could not get AppDelegate file!")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let resume = Resume(context: managedContext)
        resume.name = model.name
        resume.created = model.created
        resume.path = model.path
        
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
        
        let resumes = fetch(entityName: "Resume")
        
        for resume in resumes {
            if names.contains(resume.name) {
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
