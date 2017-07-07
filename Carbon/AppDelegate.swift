//
//  AppDelegate.swift
//  Carbon
//
//  Created by Mobile on 9/13/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // authorize request for user notification
        if UserDefaults.standard.bool(forKey: "notifAuthorized") {
            LocalNotificationsUtil.requestAuthorization()
        }
        
        // process local notification
        if #available(iOS 10.0, *) {
            
        } else if let aLaunchOptions = launchOptions { // Checking if there are any launch options.
            // Check if there are any local notification objects.
            if let notification = (aLaunchOptions as NSDictionary).object(forKey: "UIApplicationLaunchOptionsLocalNotificationKey") as? UILocalNotification {
                // Handle the notification action on opening. Like updating a table or showing an alert.
                if #available(iOS 8.2, *) {
                    UIAlertView(title: notification.alertTitle, message: notification.alertBody, delegate: nil, cancelButtonTitle: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil)).show()
                } else {
                    UIAlertView(title: NSLocalizedString("Reminder", comment: ""), message: notification.alertBody, delegate: nil, cancelButtonTitle: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil)).show()
                }
            }
        }
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_APP_LAUNCH, label: "Regular Launch", value: nil)
        
        // one signal
        OneSignal.initWithLaunchOptions(launchOptions, appId: "6530db8f-090c-42ef-aaaa-36b6865ae37b", handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification?.payload.notificationID)")
            }, handleNotificationAction: { (result) in
                
                // This block gets called when the user reacts to a notification received
                let payload = result?.notification.payload
                var fullMessage = payload?.title
                
                //Try to fetch the action selected
                if let additionalData = payload?.additionalData, let actionSelected = additionalData["actionSelected"] as? String {
                    fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
                }
                print(fullMessage)
            }, settings: [kOSSettingsKeyAutoPrompt : false, kOSSettingsKeyInAppAlerts : false])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: Notification.Name(rawValue: "checkPasteboard"), object: self)
        if #available(iOS 10.0, *) {
            
        } else {
            if application.applicationIconBadgeNumber > 0 {
                application.applicationIconBadgeNumber = 0
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Point for handling the local notification when the app is open.
        // Showing reminder details in an alertview
        if #available(iOS 10.0, *) {
            
        } else if #available(iOS 8.2, *) {
            UIAlertView(title: notification.alertTitle, message: notification.alertBody, delegate: nil, cancelButtonTitle: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil)).show()
        } else {
            UIAlertView(title: NSLocalizedString("Reminder", comment: ""), message: notification.alertBody, delegate: nil, cancelButtonTitle: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil)).show()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        
        if application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background {
            AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_APP_LAUNCH, label: "Push Notification Launch", value: nil)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Anubix.Carbon" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Carbon", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true]
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        
        print("will present")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completionHandler([.alert, .sound, .badge])
    }
}

