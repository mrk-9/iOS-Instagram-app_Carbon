//
//  AddReminderViewController.swift
//  Carbon
//
//  Created by Mobile on 9/18/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData

class AddReminderViewController: UIViewController {
    
    var carbonMedia: NSManagedObject?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var imvBackground: UIImageView!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var cancelBtnWidthConstraint: NSLayoutConstraint!
    
    // photo view
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var photoContainerViewHeightConstraint: NSLayoutConstraint!
    
    // watermarks
    @IBOutlet weak var watermark1View: UIView!
    @IBOutlet weak var watermark2View: UIView!
    @IBOutlet weak var watermark3View: UIView!
    @IBOutlet weak var watermark4View: UIView!
    
    @IBOutlet weak var lblWatermark1: UILabel!
    @IBOutlet weak var lblWatermark2: UILabel!
    @IBOutlet weak var lblWatermark3: UILabel!
    @IBOutlet weak var lblWatermark4: UILabel!
    
    @IBOutlet weak var watermark1WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark2WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark3WidthContraint: NSLayoutConstraint!
    @IBOutlet weak var watermark4WidthContraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(AddReminderViewController.tapOnMainView))
        touchView.addGestureRecognizer(gesture)

        placeWaterMark()
        loadPhoto()
        setWatermarkFont()
        setReminderDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 2
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOffset = CGSize(width: -2, height: -1)
        
        AnalyticsUtil.trackScreen(screenName: "Post Detail Reminder")
    }
    
    override func viewDidLayoutSubviews() {
        
        self.cancelBtnWidthConstraint.constant = self.btnCancel.intrinsicContentSize.width + 30
        
        // set Photo size
        let imageWidth = (carbonMedia?.value(forKey: "standardResolutionImageWidth") as! NSNumber).floatValue
        let imageHeight = (carbonMedia?.value(forKey: "standardResolutionImageHeight") as! NSNumber).floatValue
        photoContainerViewHeightConstraint.constant = photoContainerView.frame.size.width * CGFloat(imageHeight) / CGFloat(imageWidth)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tap Gesture
    func tapOnMainView() {
        _ = self.navigationController?.popViewController(animated: false)
    }

    // MARK: - Actions
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: false)
    }

    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func doneBtnTapped(_ sender: AnyObject) {
        
        if datePicker.date.isGreaterThanDate(dateToCompare: Date()) {
            carbonMedia?.setValue(NSNumber(value: Int16(1)), forKey: "mediaType")
            carbonMedia?.setValue(datePicker.date, forKey: "scheduledDateTime")
            
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            
            // check and authorize user notification
            if !UserDefaults.standard.bool(forKey: "notifAuthorized") {
                
                LocalNotificationsUtil.requestAuthorization()
                UserDefaults.standard.set(true, forKey: "notifAuthorized")
            } else {
                if !LocalNotificationsUtil.checkPushNotfication() {
                    let alertController = UIAlertController(title: NSLocalizedString("Push notifications not enabled", comment: ""), message: NSLocalizedString("Please review your settings and allow notifications for Carbon", comment: ""), preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: { (action) in
                        Util.openSettings()
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            LocalNotificationsUtil.removeLocalNotification(carbonMedia: carbonMedia!)
            LocalNotificationsUtil.addLocalNotification(carbonMedia: carbonMedia!)
            
            _ = self.navigationController?.popToRootViewController(animated: true)
            
            AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Added scheduled event", value: nil)
        }
    }
    
    // MARK: - Custom Functions
    
    func setReminderDate() {
        let mediaType = ((carbonMedia?.value(forKey: "mediaType") as! NSNumber).int16Value)
        if mediaType == 1 {
            let date = carbonMedia?.value(forKey: "scheduledDateTime") as! Date?
            self.datePicker.setDate(date!, animated: false)
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
    
    func loadPhoto() {
        imvBackground.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
        imvPhoto.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
    }
    
    func placeWaterMark() {
        // hide all watermarks
        watermark1View.isHidden = true
        watermark2View.isHidden = true
        watermark3View.isHidden = true
        watermark4View.isHidden = true
        
        let waterMarkType = ((carbonMedia?.value(forKey: "watermarkType") as! NSNumber).int64Value)
        switch waterMarkType {
        case 0:
            watermark1View.isHidden = false
            break
        case 1:
            watermark2View.isHidden = false
            break
        case 2:
            watermark3View.isHidden = false
            break
        case 3:
            watermark4View.isHidden = false
            break
        default: break
            
        }
    }
}
