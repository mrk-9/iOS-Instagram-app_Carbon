//
//  EditPostViewController.swift
//  Carbon
//
//  Created by Mobile on 9/17/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData

class EditPostViewController: UIViewController, UITextViewDelegate {
    
    var carbonMedia: NSManagedObject?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tvCaption: UITextView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var imvProfilePicture: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLikesCount: UILabel!
    @IBOutlet weak var imvBackground: UIImageView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOffset = CGSize(width: -2, height: -1)
        
        setWatermarkFont()
        
        AnalyticsUtil.trackScreen(screenName: "Post Detail Edit")
    }
    
    override func viewDidLayoutSubviews() {
        tvCaption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Actions
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func doneBtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(tvCaption.text, forKey: "caption")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let caption = tvCaption.text as NSString
        let username = carbonMedia?.value(forKey: "username") as! String?
        self.tvCaption.attributedText = Util.resolvedHashTagsString(caption, username: username!)
    }

    // MARK: - Custom Functions
    func initView() {
        imvBackground.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
        imvPhoto.setImageWith(URL(string: carbonMedia?.value(forKey: "standardResolutionImage") as! String)!)
        imvProfilePicture.setImageWith(URL(string: carbonMedia?.value(forKey: "userProfilePicture") as! String)!)
        lblUsername.text = carbonMedia?.value(forKey: "username") as! String?
        lblDate.text = (carbonMedia?.value(forKey: "dateTime") as! Date?)?.timeShort
        lblLikesCount.text = String(format: NSLocalizedString("%d likes", comment: ""), ((carbonMedia?.value(forKey: "likesCount") as! NSNumber).int64Value))
        
        // set caption text
        let caption = carbonMedia?.value(forKey: "caption") as! NSString
        let username = carbonMedia?.value(forKey: "username") as! String?
        self.tvCaption.attributedText = Util.resolvedHashTagsString(caption, username: username!)
        
        placeWaterMark()
        
        tvCaption.becomeFirstResponder()
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
        
        lblWatermark1.font = UIFont(name: watermarkFontName!, size: 4.8)
        lblWatermark2.font = UIFont(name: watermarkFontName!, size: 4.8)
        lblWatermark3.font = UIFont(name: watermarkFontName!, size: 4.8)
        lblWatermark4.font = UIFont(name: watermarkFontName!, size: 4.8)
        
        lblWatermark1.textColor = watermarkColor
        lblWatermark2.textColor = watermarkColor
        lblWatermark3.textColor = watermarkColor
        lblWatermark4.textColor = watermarkColor
        
        watermark1WidthContraint.constant = 20.5 + lblWatermark1.intrinsicContentSize.width
        watermark2WidthContraint.constant = 20.5 + lblWatermark2.intrinsicContentSize.width
        watermark3WidthContraint.constant = 20.5 + lblWatermark3.intrinsicContentSize.width
        watermark4WidthContraint.constant = 20.5 + lblWatermark4.intrinsicContentSize.width
    }
}
