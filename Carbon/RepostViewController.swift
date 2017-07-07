//
//  RepostViewController.swift
//  Carbon
//
//  Created by Mobile on 9/15/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData
import Photos

class RepostViewController: UIViewController {
    
    var carbonMedia: NSManagedObject?
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var lblCaptionNotes: UILabel!
    @IBOutlet weak var tvCaption: UITextView!
    
    @IBOutlet weak var lblEditPost: UILabel!
    @IBOutlet weak var lblEditWatermark: UILabel!
    
    @IBOutlet weak var imvBackground: UIImageView!
    
    // photo view
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var photoContainerViewHeightConstraint: NSLayoutConstraint!
    
    // watermarks
    @IBOutlet weak var watermark1View: UIView!
    @IBOutlet weak var watermark2View: UIView!
    @IBOutlet weak var watermark3View: UIView!
    @IBOutlet weak var watermark4View: UIView!
    
    @IBOutlet weak var btnWatermark1: UIButton!
    @IBOutlet weak var btnWatermark2: UIButton!
    @IBOutlet weak var btnWatermark3: UIButton!
    @IBOutlet weak var btnWatermark4: UIButton!
    @IBOutlet weak var btnWatermark5: UIButton!
    @IBOutlet weak var imvRemoveWatermark: UIImageView!
    @IBOutlet weak var imvEditWatermark: UIImageView!
    
    @IBOutlet weak var lblWatermark1: UILabel!
    @IBOutlet weak var lblWatermark2: UILabel!
    @IBOutlet weak var lblWatermark3: UILabel!
    @IBOutlet weak var lblWatermark4: UILabel!
    
    @IBOutlet weak var watermark1WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark2WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark3WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark4WidthContraint: NSLayoutConstraint!
    
    // schedule bar
    @IBOutlet weak var scheduleBar: UIView!
    @IBOutlet weak var lblScheduleDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placeWaterMark()
        loadPhoto()
        
        // add swipe Right gesture
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(RepostViewController.swipeRight))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
        
        let tapOutTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RepostViewController.editPostBtnTapped))
        self.tvCaption.addGestureRecognizer(tapOutTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check internet access
        let networkStatus = Reachability.forInternetConnection().currentReachabilityStatus()
        if (networkStatus == NotReachable) {
            let alertController = UIAlertController(title: NSLocalizedString("No Internet", comment: ""), message: NSLocalizedString("Please make sure you are connected to the internet", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        // set caption text
        let caption = carbonMedia?.value(forKey: "caption") as! NSString
        let username = carbonMedia?.value(forKey: "username") as! String?
        if caption.isEqual(to: "") {
            self.lblCaptionNotes.isHidden = false
        } else {
            self.lblCaptionNotes.isHidden = true
        }
        self.tvCaption.attributedText = Util.resolvedHashTagsString(caption, username: username!)
        
        setWatermarkFont()

        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 2
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOffset = CGSize(width: -2, height: -1)
        
        // check schedule bar
        let mediaType = ((carbonMedia?.value(forKey: "mediaType") as! NSNumber).int16Value)
        if mediaType == 1 {
            let dateTime = carbonMedia?.value(forKey: "scheduledDateTime") as! Date
            scheduleBar.isHidden = false
            lblScheduleDate.text = dateTime.timeString
            lblScheduleDate.sizeToFit()
        } else {
            scheduleBar.isHidden = true
        }
        
        lblEditPost.sizeToFit()
        lblEditWatermark.sizeToFit()
        
        //check IAP and locked
        if (IAPHelper.isPurchased(IAPKeyPack1)) {
            imvRemoveWatermark.isHidden = true
            imvEditWatermark.image = UIImage(named: "CarbonNextWatermark")
        } else {
            imvRemoveWatermark.isHidden = false
            imvEditWatermark.image = UIImage(named: "CarbonLocked")
        }
        
        AnalyticsUtil.trackScreen(screenName: "Post Detail")
    }
    
    override func viewDidLayoutSubviews() {
        tvCaption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        // set Photo size
        let imageWidth = (carbonMedia?.value(forKey: "standardResolutionImageWidth") as! NSNumber).floatValue
        let imageHeight = (carbonMedia?.value(forKey: "standardResolutionImageHeight") as! NSNumber).floatValue
        photoContainerViewHeightConstraint.constant = photoContainerView.frame.size.width * CGFloat(imageHeight) / CGFloat(imageWidth)
        
        self.tvCaption.setContentOffset(CGPoint.zero, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Gesture
    func swipeRight() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Actions
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func scheduleBtnTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "addReminder", sender: nil)
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Set Reminder", value: nil)
    }
    
    @IBAction func editPostBtnTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "editPost", sender: nil)
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Edit Post", value: nil)
    }
    
    @IBAction func editWatermarkBtnTapped(_ sender: AnyObject) {
        if !IAPHelper.isPurchased(IAPKeyPack1) {
            performSegue(withIdentifier: "upgrade", sender: nil)
        } else {
            performSegue(withIdentifier: "editWatermark", sender: nil)
        }
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Edit Watermark", value: nil)
    }
    
    @IBAction func repostBtnTapped(_ sender: AnyObject) {
        let imageWidth = (carbonMedia?.value(forKey: "standardResolutionImageWidth") as! NSNumber).floatValue
        let imageHeight = (carbonMedia?.value(forKey: "standardResolutionImageHeight") as! NSNumber).floatValue
        let imgPhoto = Util.getImageForView(photoContainerView, imageWidth: CGFloat(imageWidth), imageHeight: CGFloat(imageHeight))
        
        UIPasteboard.general.string = self.tvCaption.text
        
        if UserDefaults.standard.bool(forKey: "clipboardWarningNoNeed") {
            self.postImageToInstagram(image: imgPhoto)
        } else {
            let alertController = UIAlertController(title: nil, message: NSLocalizedString("Your text has been copied to the clipboard. Paste it in instagram", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: { (action) in
                self.postImageToInstagram(image: imgPhoto)
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't show this again", comment: ""), style: .cancel, handler: { (action) in
                
                UserDefaults.standard.set(true, forKey: "clipboardWarningNoNeed")
                UserDefaults.standard.synchronize()
                
                self.postImageToInstagram(image: imgPhoto)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
     
    }
    
    @IBAction func watermark1BtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(NSNumber(value: 0), forKey: "watermarkType")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        placeWaterMark()
    }
    
    @IBAction func watermark2BtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(NSNumber(value: 1), forKey: "watermarkType")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        placeWaterMark()
    }
    
    @IBAction func watermark3BtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(NSNumber(value: 2), forKey: "watermarkType")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        placeWaterMark()
    }
    
    @IBAction func watermark4BtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(NSNumber(value: 3), forKey: "watermarkType")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        placeWaterMark()
    }
    
    @IBAction func watermark5BtnTapped(_ sender: AnyObject) {
        if !IAPHelper.isPurchased(IAPKeyPack1) {
            performSegue(withIdentifier: "upgrade", sender: nil)
        } else {
            carbonMedia?.setValue(NSNumber(value: 4), forKey: "watermarkType")
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            placeWaterMark()
        }
}
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPost" {
            let vc = segue.destination as! EditPostViewController
            vc.carbonMedia = carbonMedia
        } else if segue.identifier == "editWatermark" {
            let vc = segue.destination as! EditWatermarkViewController
            vc.carbonMedia = carbonMedia
        } else if segue.identifier == "addReminder" {
            let vc = segue.destination as! AddReminderViewController
            vc.carbonMedia = carbonMedia
        }
    }
    
    // MARK: - Custom Functions
    func loadPhoto() {
        imvBackground.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
        imvPhoto.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Loading Instagram Picture", value: nil)
    }
    
    func placeWaterMark() {
        // hide all watermarks
        watermark1View.isHidden = true
        watermark2View.isHidden = true
        watermark3View.isHidden = true
        watermark4View.isHidden = true
        btnWatermark1.isSelected = false
        btnWatermark2.isSelected = false
        btnWatermark3.isSelected = false
        btnWatermark4.isSelected = false
        btnWatermark5.isSelected = false
        
        let waterMarkType = ((carbonMedia?.value(forKey: "watermarkType") as! NSNumber).int64Value)
        switch waterMarkType {
        case 0:
            watermark1View.isHidden = false
            btnWatermark1.isSelected = true
            break
        case 1:
            watermark2View.isHidden = false
            btnWatermark2.isSelected = true
            break
        case 2:
            watermark3View.isHidden = false
            btnWatermark3.isSelected = true
            break
        case 3:
            watermark4View.isHidden = false
            btnWatermark4.isSelected = true
            break
        case 4:
            btnWatermark5.isSelected = true
        default: break
            
        }
    }
    
    func setWatermarkFont() {
        var watermarkFontName = carbonMedia?.value(forKey: "watermarkFontName") as! String?
        let watermarkColor = Util.getColorFromData(carbonMedia?.value(forKey: "watermarkColor") as! NSData)
        let watermarkCaption = carbonMedia?.value(forKey: "watermarkCaption") as! String?
        
        if watermarkFontName == nil || watermarkFontName == "" {
            watermarkFontName = "OpenSans-Semibold"
        }
        
        lblWatermark1.text = watermarkCaption
        lblWatermark2.text = watermarkCaption
        lblWatermark3.text = watermarkCaption
        lblWatermark4.text = watermarkCaption
        
        lblWatermark1.font = UIFont(name: watermarkFontName!, size: 9.5)
        lblWatermark2.font = UIFont(name: watermarkFontName!, size: 9.5)
        lblWatermark3.font = UIFont(name: watermarkFontName!, size: 9.5)
        lblWatermark4.font = UIFont(name: watermarkFontName!, size: 9.5)
        
        lblWatermark1.textColor = watermarkColor
        lblWatermark2.textColor = watermarkColor
        lblWatermark3.textColor = watermarkColor
        lblWatermark4.textColor = watermarkColor
        
        watermark1WidthContraint.constant = 41 + lblWatermark1.intrinsicContentSize.width
        watermark2WidthContraint.constant = 41 + lblWatermark2.intrinsicContentSize.width
        watermark3WidthContraint.constant = 41 + lblWatermark3.intrinsicContentSize.width
        watermark4WidthContraint.constant = 41 + lblWatermark4.intrinsicContentSize.width
    }
    
    func postImageToInstagram(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(RepostViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error != nil {
            print(error)
        }
        
        let caption = self.tvCaption.text
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.firstObject {
            let localIdentifier = lastAsset.localIdentifier
            let u = "instagram://library?LocalIdentifier=" + localIdentifier + "&InstagramCaption=" + (caption?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
            let url = URL(string: u)!
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
                
                carbonMedia?.setValue(NSNumber(value: Int16(2)), forKey: "mediaType")
                carbonMedia?.setValue(Date(), forKey: "repostedDateTime")
                
                let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
                appDelegate.saveContext()
                
                LocalNotificationsUtil.removeLocalNotification(carbonMedia: carbonMedia!)
                scheduleBar.isHidden = true
                
                self.perform(#selector(RepostViewController.backBtnTapped(_:)), with: NSObject(), afterDelay: 0.3)
                
                AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "REPOST", value: nil)

            } else {
                let alertController = UIAlertController(title: NSLocalizedString("Instagram Not Found", comment: ""), message: NSLocalizedString("Please download the Instagram application from the Appstore", comment: ""), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: { (action) in
                    Util.goToAppStoreForInstagram()
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
}
