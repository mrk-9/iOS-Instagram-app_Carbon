//
//  LocalNotificationsUtil.swift
//  Carbon
//
//  Created by Mobile on 9/19/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

public class LocalNotificationsUtil: NSObject {
    
    public class func checkPushNotfication() -> Bool {
        let notificationtypes = UIApplication.shared.currentUserNotificationSettings?.types
        if notificationtypes == UIUserNotificationType(rawValue: 0) {
            return false
        } else {
            return true
        }
    }
    
    public class func requestAuthorization() {
        if #available(iOS 10.0, *) {
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            let userNotificationCenter = UNUserNotificationCenter.current()
            userNotificationCenter.removeAllDeliveredNotifications()
            userNotificationCenter.delegate = appDelegate
            userNotificationCenter.requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
                if error == nil {
                    NSLog("request authorization succeeded!")
                }
            }
        } else {
            // Register for notification: This will prompt for the user's consent to receive notifications from this app.
            let notificationSettings = UIUserNotificationSettings(types: [.alert,.sound,.badge], categories: nil)
            
            //*NOTE*
            // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)

        }
        
    }
    
    public class func addLocalNotification(carbonMedia: NSManagedObject) {
        
        let dateTime = carbonMedia.value(forKey: "scheduledDateTime") as! Date
        let id = carbonMedia.value(forKey: "id") as! String
        
        if #available(iOS 10.0, *) {
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("Reminder", comment: "")
            content.body = NSLocalizedString("Repost your instagram picture now.", comment: "")
            content.sound = UNNotificationSound.default()
            
            //Set the trigger of the notification -- here a timer.
            let interval = dateTime.timeIntervalSinceNow
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
            
        } else {
            let localNotification = UILocalNotification() // Creating an instance of the notification.
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = NSLocalizedString("Reminder", comment: "")
            } else {
                // Fallback on earlier versions
            }
            localNotification.alertBody = NSLocalizedString("Repost your instagram picture now.", comment: "")
            localNotification.fireDate = dateTime
            localNotification.timeZone = NSTimeZone.default
            localNotification.soundName = UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
            localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
            localNotification.userInfo = ["id": id]
            UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the notification.
        }
        
    }
    
    public class func removeLocalNotification(carbonMedia: NSManagedObject) {
        let id = carbonMedia.value(forKey: "id") as! String
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        } else {
            let app = UIApplication.shared
            for oneEvent in app.scheduledLocalNotifications! {
                let notification = oneEvent as UILocalNotification
                let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                let uid = userInfoCurrent["id"]! as! String
                if uid == id {
                    //Cancelling local notification
                    app.cancelLocalNotification(notification)
                    break;
                }
            }
        }
    }
}
