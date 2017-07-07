//
//  EditWatermarkViewController.swift
//  Carbon
//
//  Created by Mobile on 9/17/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import CoreData

class EditWatermarkViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var carbonMedia: NSManagedObject?
    var fontNames : [String]!
    var tempWatermarkFontName: String?
    var tempWatermarkColor: UIColor?
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var lblEditPost: UILabel!
    @IBOutlet weak var tvCaption: UITextView!

    
    @IBOutlet weak var colorBubbleViewXPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var fontPickerView: UIPickerView!
    @IBOutlet weak var fontViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var colorSlider: ColorSlider!
    
    @IBOutlet weak var tfWatermark: UITextField!
    
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(EditWatermarkViewController.tapOnMainView))
        mainView.addGestureRecognizer(gesture)
        
        placeWaterMark()
        loadPhoto()
        
        loadAllFonts()
        
        tempWatermarkFontName = carbonMedia?.value(forKey: "watermarkFontName") as! String?
        tempWatermarkColor = Util.getColorFromData(carbonMedia?.value(forKey: "watermarkColor") as! NSData)
        tfWatermark.text = carbonMedia?.value(forKey: "watermarkCaption") as! String?
        setWatermarkFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set caption text
        let caption = carbonMedia?.value(forKey: "caption") as! NSString
        let username = carbonMedia?.value(forKey: "username") as! String?
        self.tvCaption.attributedText = Util.resolvedHashTagsString(caption, username: username!)
        
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 2
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOffset = CGSize(width: -2, height: -1)
        
        // add keyboard notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(EditWatermarkViewController.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        lblEditPost.sizeToFit()
        
        AnalyticsUtil.trackScreen(screenName: "Post Detail Watermark")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        colorSlider.addLayer()
    }
    
    override func viewDidLayoutSubviews() {
        tvCaption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        // set Photo size
        let imageWidth = (carbonMedia?.value(forKey: "standardResolutionImageWidth") as! NSNumber).floatValue
        let imageHeight = (carbonMedia?.value(forKey: "standardResolutionImageHeight") as! NSNumber).floatValue
        photoContainerViewHeightConstraint.constant = photoContainerView.frame.size.width * CGFloat(imageHeight) / CGFloat(imageWidth)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    let limitLength = 50
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    
    // MARK: - Keyboard show/hide functions
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue!
        let size = frame?.cgRectValue.size // keyboard's size
        
        // get duration of keyboard's slide-in animation
        let animationTime = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        // move up the text bar with animation
        self.fontViewHeightConstraint.constant = (size?.height)!;
        UIView.animate(withDuration: animationTime!) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Tap Gesture
    func tapOnMainView() {
        _ = self.navigationController?.popViewController(animated: false)
    }

    // MARK: - Actions
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func doneBtnTapped(_ sender: AnyObject) {
        carbonMedia?.setValue(tempWatermarkFontName, forKey: "watermarkFontName")
        
        var watermarkText = tfWatermark.text
        if watermarkText == "" {
            watermarkText = "Reposted with Carbon"
        }
        carbonMedia?.setValue(watermarkText, forKey: "watermarkCaption")
        carbonMedia?.setValue(Util.getDataFromColor(tempWatermarkColor!), forKey: "watermarkColor")
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
        _ = self.navigationController?.popViewController(animated: false)
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Watermark Edited", value: nil)
    }
    
    @IBAction func watermarkTextValueChanged(_ sender: AnyObject) {
        setWatermarkFont()
    }
    
    @IBAction func colorSliderValueChanged(_ sender: AnyObject) {
        tempWatermarkColor = UIColor(hue: CGFloat(colorSlider.value), saturation: 1, brightness: 1, alpha: 1)
        setWatermarkFont()
        
        colorPickerView.backgroundColor = tempWatermarkColor
        colorBubbleViewXPosConstraint.constant = CGFloat(130) * CGFloat(colorSlider.value)
    }
    
    @IBAction func customColorBtnTapped(_ sender: AnyObject) {
        tempWatermarkColor = sender.superview??.viewWithTag(10)?.backgroundColor
        setWatermarkFont()
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDatasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let fontName = fontNames[row]
        let font = UIFont(name: fontName, size: 18)
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = fontName
        pickerLabel.font = font
        pickerLabel.textAlignment = NSTextAlignment.left
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempWatermarkFontName = fontNames[row]
        setWatermarkFont()
    }
    
    // MARK: - Custom Functions
    func loadAllFonts() {
        fontNames = [String]()
        for familyName in UIFont.familyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            fontNames.append(contentsOf: names)
        }
    }
    
    func setWatermarkFont() {
        if tempWatermarkFontName == nil || tempWatermarkFontName == "" {
            tempWatermarkFontName = "OpenSans-Semibold"
        }
        if tempWatermarkColor == nil {
            tempWatermarkColor = UIColor.white
        }
        
        lblWatermark1.text = tfWatermark.text
        lblWatermark2.text = tfWatermark.text
        lblWatermark3.text = tfWatermark.text
        lblWatermark4.text = tfWatermark.text
        
        lblWatermark1.font = UIFont(name: tempWatermarkFontName!, size: 9.5)
        lblWatermark2.font = UIFont(name: tempWatermarkFontName!, size: 9.5)
        lblWatermark3.font = UIFont(name: tempWatermarkFontName!, size: 9.5)
        lblWatermark4.font = UIFont(name: tempWatermarkFontName!, size: 9.5)
        
        lblWatermark1.textColor = tempWatermarkColor
        lblWatermark2.textColor = tempWatermarkColor
        lblWatermark3.textColor = tempWatermarkColor
        lblWatermark4.textColor = tempWatermarkColor
        
        watermark1WidthContraint.constant = 41 + lblWatermark1.intrinsicContentSize.width
        watermark2WidthContraint.constant = 41 + lblWatermark2.intrinsicContentSize.width
        watermark3WidthContraint.constant = 41 + lblWatermark3.intrinsicContentSize.width
        watermark4WidthContraint.constant = 41 + lblWatermark4.intrinsicContentSize.width
        
        // get row of the current font
        var fontRow = -1
        for i in 0 ..< fontNames.count {
            if fontNames[i] == tempWatermarkFontName {
                fontRow = i
                break
            }
        }
        
        fontPickerView.selectRow(fontRow, inComponent: 0, animated: false)
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
