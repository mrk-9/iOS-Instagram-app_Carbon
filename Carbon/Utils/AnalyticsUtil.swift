//
//  AnalyticsUtil.swift
//  Carbon
//
//  Created by Mobile on 9/21/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

// MARK: Analytics actions and categories
let ANALYTICS_CATEGORY_UI_ACTION = "ui_action"

let ANALYTICS_ACTION_UI_BUTTON_TAP = "button_tap"
let ANALYTICS_ACTION_APP_LAUNCH = "app_launch"

public class AnalyticsUtil: NSObject {
    public class func trackScreen(screenName: String?) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        tracker?.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }
    
    public class func trackEvent(category: String?, action: String?, label: String?, value: NSNumber?) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as [NSObject: AnyObject])
    }
}
