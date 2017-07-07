//
//  Util.swift
//  Carbon
//
//  Created by Mobile on 9/16/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

public class Util: NSObject {
    public class func getImageForView(_ view: UIView, imageWidth: CGFloat, imageHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0);
        view.drawHierarchy(in: CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: imageWidth, height: imageHeight)), afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        return image
    }

    public class func getColorFromData(_ data: NSData) -> UIColor {
        return NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! UIColor
    }
    
    public class func getDataFromColor(_ color: UIColor) -> NSData {
        return NSKeyedArchiver.archivedData(withRootObject: color) as NSData
    }
    
    public class func openSettings() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    public class func goToAppStoreForInstagram() {
        let instagramAppStoreURL = URL(string: "https://itunes.apple.com/us/app/instagram/id389801252?mt=8")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(instagramAppStoreURL!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(instagramAppStoreURL!)
        }
    }
    
    public class func resolvedHashTagsString(_ caption: NSString, username: String) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!,
            NSForegroundColorAttributeName : UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1)] as [String : Any]
        let attrString = NSMutableAttributedString(string: caption as String, attributes: attributes)
        
        do {
            // Find all the hashtags in our string
            let regex = try NSRegularExpression(pattern: "(?:\\s|^)(#(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b", options: NSRegularExpression.Options.anchorsMatchLines)
            let results = regex.matches(in: caption as String,
                                        options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, caption.length))
            let array = results.map { caption.substring(with: $0.range) }
            
            for hashtag in array {
                // get range of the hashtag in the main string
                let range = (attrString.string as NSString).range(of: hashtag)
                // add a colour to the hashtag
                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 213.0/255.0, green: 53.0/255.0, blue: 146.0/255.0, alpha: 1), range: range)
            }
        }
        catch {
            
        }
        
        // color the first sentence
        let firstSentence = String(format: "repostedwithcarbon @%@", username)
        let range = caption.range(of: firstSentence)
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 213.0/255.0, green: 53.0/255.0, blue: 146.0/255.0, alpha: 1), range: range)
        
        return attrString
    }
}
