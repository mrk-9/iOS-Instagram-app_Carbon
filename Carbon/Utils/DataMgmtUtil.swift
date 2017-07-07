//
//  DataMgmtUtil.swift
//  Carbon
//
//  Created by Mobile on 9/15/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData

open class DataMgmtUtil: NSObject {
    open class func getAllMedia() -> [NSManagedObject] {
        // fetch carbon media list
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CarbonMedia")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [NSManagedObject]()
    }
    
    open class func getAllScheduledMedia() -> [NSManagedObject] {
        // fetch carbon media list
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CarbonMedia")
        fetchRequest.predicate = NSPredicate(format: "mediaType = 1")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [NSManagedObject]()
    }
    
    open class func getAllNewMedia() -> [NSManagedObject] {
        // fetch carbon media list
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CarbonMedia")
        fetchRequest.predicate = NSPredicate(format: "mediaType = 0")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [NSManagedObject]()
    }
    
    open class func getAllRepostedMedia() -> [NSManagedObject] {
        // fetch carbon media list
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CarbonMedia")
        fetchRequest.predicate = NSPredicate(format: "mediaType = 2")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [NSManagedObject]()
    }
    
    open class func findMedia(_ mediaId: String) -> NSManagedObject! {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CarbonMedia")
        fetchRequest.predicate = NSPredicate(format: "id = %@", mediaId)
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            if (results.count > 0) {
                return results[0] as! NSManagedObject
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
        
    }
    
    open class func deleteMedia(_ media: NSManagedObject!) {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.delete(media)
        
        appDelegate.saveContext()
    }
    
    open class func changeMedia(_ media: InstagramMedia) -> NSManagedObject! {
        let carbonMedia = findMedia(media.id)
        if carbonMedia == nil {
            return nil
        }
        
        //set data
        carbonMedia?.setValue(media.id, forKey: "id")
        carbonMedia?.setValue(NSNumber(value: Int64(media.commentCount)), forKey: "commentCount")
        carbonMedia?.setValue(NSNumber(value: Int64(media.likesCount)), forKey: "likesCount")
        carbonMedia?.setValue(media.standardResolutionImageURL.absoluteString, forKey: "standardResolutionImage")
        carbonMedia?.setValue(NSNumber(value: Float(media.standardResolutionImageFrameSize.width)), forKey: "standardResolutionImageWidth")
        carbonMedia?.setValue(NSNumber(value: Float(media.standardResolutionImageFrameSize.height)), forKey: "standardResolutionImageHeight")
        
        if (media.caption != nil) {
            let caption = String(format: "repostedwithcarbon @%@\n%@", media.user.username, (media.caption?.text)!)
            carbonMedia?.setValue(caption, forKey: "caption")
        }
        carbonMedia?.setValue(media.user.id, forKey: "userId")
        carbonMedia?.setValue(media.user.username, forKey: "username")
        carbonMedia?.setValue(media.user.profilePictureURL.absoluteString, forKey: "userProfilePicture")
        carbonMedia?.setValue(Date(), forKey: "dateTime")
        
        carbonMedia?.setValue("Reposted with Carbon", forKey: "watermarkCaption")
        carbonMedia?.setValue(Util.getDataFromColor(UIColor.white), forKey: "watermarkColor")
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
        return carbonMedia
    }
    
    open class func addMedia(_ media: InstagramMedia) -> NSManagedObject! {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "CarbonMedia",
                                                        in:managedContext)
        
        // check if new media
        if findMedia(media.id) != nil {
            return nil
        }
        
        let carbonMedia = NSManagedObject(entity: entity!,
                                          insertInto: managedContext)
        
        //set data
        carbonMedia.setValue(media.id, forKey: "id")
        carbonMedia.setValue(NSNumber(value: Int64(media.commentCount)), forKey: "commentCount")
        carbonMedia.setValue(NSNumber(value: Int64(media.likesCount)), forKey: "likesCount")
        carbonMedia.setValue(media.standardResolutionImageURL.absoluteString, forKey: "standardResolutionImage")
        carbonMedia.setValue(NSNumber(value: Float(media.standardResolutionImageFrameSize.width)), forKey: "standardResolutionImageWidth")
        carbonMedia.setValue(NSNumber(value: Float(media.standardResolutionImageFrameSize.height)), forKey: "standardResolutionImageHeight")
        
        if (media.caption != nil) {
            let caption = String(format: "repostedwithcarbon @%@\n%@", media.user.username, (media.caption?.text)!)
            carbonMedia.setValue(caption, forKey: "caption")
        }
        carbonMedia.setValue(media.user.id, forKey: "userId")
        carbonMedia.setValue(media.user.username, forKey: "username")
        carbonMedia.setValue(media.user.profilePictureURL.absoluteString, forKey: "userProfilePicture")
        carbonMedia.setValue(Date(), forKey: "dateTime")
        
        carbonMedia.setValue("Reposted with Carbon", forKey: "watermarkCaption")
        carbonMedia.setValue(Util.getDataFromColor(UIColor.white), forKey: "watermarkColor")
        
        appDelegate.saveContext()
        
        return carbonMedia
    }
}
