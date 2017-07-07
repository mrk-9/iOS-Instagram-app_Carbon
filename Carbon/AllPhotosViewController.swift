//
//  ViewController.swift
//  Carbon
//
//  Created by Mobile on 9/13/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import AFNetworking
import CoreData
import AVFoundation
import MBProgressHUD

class AllPhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var btnInfo: UIButton!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet weak var editBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoPlayerContainer: UIView!
    @IBOutlet weak var videoViewXPosConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var instagramEngine: InstagramEngine?
    
    var videoPlayer : AVPlayer! = nil
    var playeritem : AVPlayerItem! = nil
    var scheduledMediaList = [NSManagedObject]()
    var repostedMediaList = [NSManagedObject]()
    var newMediaList = [NSManagedObject]()
    var selectedIndexPaths = [IndexPath]()
    
    var isEditMode : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instagramEngine = InstagramEngine.shared()
        instagramEngine?.accessToken = "3929963884.feb0927.1095f2d780534e21aad9454d00ab9bff"
        NotificationCenter.default.addObserver(self, selector: #selector(AllPhotosViewController.checkPasteboard), name: NSNotification.Name(rawValue: "checkPasteboard"), object: nil)
        
        // Google analytics
        AnalyticsUtil.trackScreen(screenName: "Splash")
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_APP_LAUNCH, label: "Number of Reposts", value: NSNumber(value: DataMgmtUtil.getAllRepostedMedia().count))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.editBtnWidthConstraint.constant = self.btnEdit.intrinsicContentSize.width + 30
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
        
        // fetch carbon media list
        scheduledMediaList = DataMgmtUtil.getAllScheduledMedia()
        repostedMediaList = DataMgmtUtil.getAllRepostedMedia()
        newMediaList = DataMgmtUtil.getAllNewMedia()
        self.tableView.reloadData()
        
        checkPasteboard()
        
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // add tutorial video view
        if videoPlayer == nil {
            let videoURL = Bundle.main.url(forResource: "Carbon-iPhone-IntroRawCrop", withExtension: "mov")
            playeritem = AVPlayerItem(url: videoURL!)
            videoPlayer = AVPlayer(playerItem: playeritem)
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer.frame = self.videoPlayerContainer.bounds
            self.videoPlayerContainer.layer.addSublayer(playerLayer)
            
            NotificationCenter.default.addObserver(self, selector: #selector(AllPhotosViewController.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playeritem)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification
    func finishedPlaying(_ myNotification:NSNotification) {
        btnPlay.isHidden = false
        
        let stopedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stopedPlayerItem.seek(to: kCMTimeZero)
        
        // mark as played
        UserDefaults.standard.set(true, forKey: "played")
        UserDefaults.standard.synchronize()
        
        self.btnInstagram.isEnabled = true
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Video finished", value: nil)
    }
    
    // MARK: - Actions
    @IBAction func infoBtnTapped(_ sender: AnyObject) {
        showVideoPlayer(true)
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Info", value: nil)
    }
    
    @IBAction func editBtnTapped(_ sender: AnyObject) {
        if btnEdit.title(for: UIControlState.normal) == "" {
            hideVideoPlayer(true)
            return
        }
        
        if self.isEditMode {
            self.isEditMode = false
            self.btnDelete.isHidden = true
            self.btnInstagram.isHidden = false
            
            self.btnEdit.setTitle(NSLocalizedString("Edit", comment: ""), for: UIControlState.normal)
            self.btnInfo.isEnabled = true
        } else {
            self.isEditMode = true
            self.btnDelete.isHidden = false
            self.btnInstagram.isHidden = true
            self.btnDelete.setTitle(NSLocalizedString("DELETE", comment: ""), for: UIControlState.normal)
            self.btnDelete.isEnabled = false
            
            self.btnInfo.isEnabled = false
            self.btnEdit.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState.normal)
            self.selectedIndexPaths.removeAll()
        }
        
        // animate left or right
        let visibleCells = self.tableView.visibleCells
        for cell in visibleCells {
            if cell is MediaTableViewCell {
                let mediaCell = cell as! MediaTableViewCell
                UIView.animate(withDuration: 0.2, animations: {
                    if self.isEditMode {
                        mediaCell.startingXPosConstraint.constant = 0
                    } else {
                        mediaCell.startingXPosConstraint.constant = -54
                    }
                    mediaCell.contentView.layoutIfNeeded()
                })
                
                mediaCell.btnCheckbox.isSelected = false
            }
        }
    }
    
    @IBAction func videoPlayBtnTapped(_ sender: AnyObject) {
        videoPlayer.play()
        btnPlay.isHidden = true
        
        AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "Video started", value: nil)
    }
    
    @IBAction func goToInstagramBtnTapped(_ sender: AnyObject) {
        let instagramURL = URL(string: "instagram://app")
        if (UIApplication.shared.canOpenURL(instagramURL!)) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(instagramURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(instagramURL!)
            }
            
            AnalyticsUtil.trackEvent(category: ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "GO TO INSTAGRAM", value: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Instagram Not Found", comment: ""), message: NSLocalizedString("Please download the Instagram application from the Appstore", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: { (action) in
                Util.goToAppStoreForInstagram()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteBtnTapped(_ sender: AnyObject) {
        var deleteMediaList = [NSManagedObject]()
        
        for indexPath in selectedIndexPaths {
            let mediaList : [NSManagedObject]!
            if indexPath.section == 0 {
                mediaList = scheduledMediaList
            } else if indexPath.section == 1 {
                mediaList = newMediaList
            } else {
                mediaList = repostedMediaList
            }
            
            let carbonMedia = mediaList[indexPath.row]
            deleteMediaList.append(carbonMedia)
            
            LocalNotificationsUtil.removeLocalNotification(carbonMedia: carbonMedia)
            DataMgmtUtil.deleteMedia(carbonMedia)
        }
        
        for carbonMedia in deleteMediaList {
            var index = scheduledMediaList.index(of: carbonMedia)
            if (index != nil) {
                scheduledMediaList.remove(at: index!)
            }
            
            index = newMediaList.index(of: carbonMedia)
            if (index != nil) {
                newMediaList.remove(at: index!)
            }
            
            index = repostedMediaList.index(of: carbonMedia)
            if (index != nil) {
                repostedMediaList.remove(at: index!)
            }
        }
        
        self.tableView.deleteRows(at: selectedIndexPaths, with: UITableViewRowAnimation.left)
        selectedIndexPaths.removeAll()
        
        // refresh delete button
        self.btnDelete.setTitle(NSLocalizedString("DELETE", comment: ""), for: UIControlState.normal)
        self.btnDelete.isEnabled = false
        
        checkAndShowVideoPlayer()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if (scheduledMediaList.count > 0) {
                return NSLocalizedString("   Scheduled   ", comment: "")
            }
        } else if section == 1 {
            if (newMediaList.count > 0) {
                return NSLocalizedString("   Added   ", comment: "")
            }
        } else {
            if (repostedMediaList.count > 0) {
                return NSLocalizedString("   Reposted   ", comment: "")
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var mediaList : [NSManagedObject]
        if section == 0 {
            mediaList = scheduledMediaList
        } else if section == 1 {
            mediaList = newMediaList
        } else {
            mediaList = repostedMediaList
        }
        
        if mediaList.count > 0 {
            return 33
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var mediaList : [NSManagedObject]
        if section == 0 {
            mediaList = scheduledMediaList
        } else if section == 1 {
            mediaList = newMediaList
        } else {
            mediaList = repostedMediaList
        }
        
        if mediaList.count > 0 {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaSectionHeaderCell") as! MediaSectionHeaderTableViewCell
        
        cell.lblTitle.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        cell.lblTitle.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return scheduledMediaList.count
        } else if section == 1 {
            return newMediaList.count
        } else {
            return repostedMediaList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath) as! MediaTableViewCell
        
        var mediaList : [NSManagedObject]
        if indexPath.section == 0 {
            mediaList = scheduledMediaList
        } else if indexPath.section == 1 {
            mediaList = newMediaList
        } else {
            mediaList = repostedMediaList
        }
        let carbonMedia = mediaList[(indexPath as NSIndexPath).row]
        
        cell.imvThumbnail.setImageWith(URL(string: carbonMedia.value(forKey: "standardResolutionImage") as! String)!)
        cell.imvUserProfilePicture.setImageWith(URL(string: carbonMedia.value(forKey: "userProfilePicture") as! String)!)
        cell.lblUsername.text = carbonMedia.value(forKey: "username") as? String
        cell.lblLikesAndCommentCount.text = String(format: NSLocalizedString("%d likes  %d comments", comment: ""),
                                                   ((carbonMedia.value(forKey: "likesCount") as! NSNumber).int64Value),
                                                   ((carbonMedia.value(forKey: "commentCount") as! NSNumber).int64Value))
        
        // display date
        var dateTime : Date
        if indexPath.section == 0 {
            dateTime = carbonMedia.value(forKey: "scheduledDateTime") as! Date
        } else if indexPath.section == 1 {
            dateTime = carbonMedia.value(forKey: "dateTime") as! Date
        } else {
            dateTime = carbonMedia.value(forKey: "repostedDateTime") as! Date
        }
        
        if (indexPath.section == 0) {
            cell.lblDate.text = dateTime.timeString
        } else {
            cell.lblDate.text = dateTime.timeShort
        }
        
        // display media type image
        if indexPath.section == 0 {
            cell.imvType.image = UIImage(named: "CarbonClock")
            cell.lblDate.textColor = UIColor(red: 244.0/255.0, green: 48.0/255.0, blue: 109.0/255.0, alpha: 1)
        } else if indexPath.section == 1 {
            cell.imvType.image = UIImage(named: "CarbonDownloaded")
            cell.lblDate.textColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1)
        } else {
            cell.imvType.image = UIImage(named: "CarbonPosted")
            cell.lblDate.textColor = UIColor(red: 123.0/255.0, green: 197.0/255.0, blue: 41.0/255.0, alpha: 1)
        }
        
        if self.isEditMode {
            cell.startingXPosConstraint.constant = 0
        } else {
            cell.startingXPosConstraint.constant = -54
        }
        
        if selectedIndexPaths.contains(indexPath) {
            cell.btnCheckbox.isSelected = true
        } else {
            cell.btnCheckbox.isSelected = false
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !self.isEditMode {
            
            var mediaList : [NSManagedObject]
            if indexPath.section == 0 {
                mediaList = scheduledMediaList
            } else if indexPath.section == 1 {
                mediaList = newMediaList
            } else {
                mediaList = repostedMediaList
            }
            let carbonMedia = mediaList[(indexPath as NSIndexPath).row]
            performSegue(withIdentifier: "repost", sender: carbonMedia)
        } else {
            if selectedIndexPaths.contains(indexPath) {
                let index = selectedIndexPaths.index(of: indexPath)
                selectedIndexPaths.remove(at: index!)
            } else {
                selectedIndexPaths.append(indexPath)
            }
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            if selectedIndexPaths.count > 0 {
                self.btnDelete.setTitle(String(format: NSLocalizedString("DELETE %d", comment: ""), selectedIndexPaths.count), for: UIControlState.normal)
                self.btnDelete.isEnabled = true
            } else {
                self.btnDelete.setTitle(NSLocalizedString("DELETE", comment: ""), for: UIControlState.normal)
                self.btnDelete.isEnabled = false
            }
        }
    }

    // MARK: - NotificationCenter
    func checkPasteboard() {
        // check internet access
        let networkStatus = Reachability.forInternetConnection().currentReachabilityStatus()
        if (networkStatus == NotReachable) {
            let alertController = UIAlertController(title: NSLocalizedString("No Internet", comment: ""), message: NSLocalizedString("Please make sure you are connected to the internet", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        
        if let pbString = UIPasteboard.general.string {
            if pbString.hasPrefix("https://instagram.com/p/") || pbString.hasPrefix("https://www.instagram.com/p/") {
                
                self.getInstagramMediaInfo(pbString)
                
                UIPasteboard.general.setValue("", forPasteboardType: UIPasteboardName.general.rawValue)

                return
            }
        }
        
        checkAndShowVideoPlayer()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repost" {
            let vc = segue.destination as! RepostViewController
            vc.carbonMedia = sender as? NSManagedObject

        }
    }
    
    // MARK: - Custom Functions
    
    func checkAndShowVideoPlayer() {
        // play tutorial video if no media
        if scheduledMediaList.count == 0 && repostedMediaList.count == 0 && newMediaList.count == 0 {
            showVideoPlayer(false)
        } else {
            hideVideoPlayer(false)
        }
    }
    
    func saveMedia(_ media: InstagramMedia) {
        if DataMgmtUtil.findMedia(media.id) == nil {
            if let carbonMedia = DataMgmtUtil.addMedia(media) {
                newMediaList.append(carbonMedia)
                performSegue(withIdentifier: "repost", sender: carbonMedia)
            }
        } else {
            _ = DataMgmtUtil.changeMedia(media)
            self.tableView.reloadData()
        }
    }
    
    func showVideoPlayer(_ animate: Bool) {
        lblTitle.text = NSLocalizedString("Introduction", comment: "")
        
        // stop player
        if videoPlayer != nil {
            self.btnPlay.isHidden = false
            videoPlayer.pause()
            playeritem.seek(to: kCMTimeZero)
        }
        
        // check played
        if UserDefaults.standard.bool(forKey: "played") {
            btnInstagram.isEnabled = true
        } else {
            btnInstagram.isEnabled = false
        }
        self.btnDelete.isHidden = true
        self.btnInstagram.isHidden = false
        
        if scheduledMediaList.count == 0 && repostedMediaList.count == 0 && newMediaList.count == 0 {
            self.btnInfo.isHidden = true
            self.btnEdit.isHidden = true
        } else {
            self.btnInfo.isHidden = true
            self.btnEdit.isHidden = false
            self.btnEdit.setTitle("", for: UIControlState.normal)
            self.btnEdit.setImage(UIImage(named: "CarbonArrow"), for: UIControlState.normal)
        }
        
        // animate show video view
        UIView.animate(withDuration: animate ? 0.4 : 0, animations: {
            self.videoViewXPosConstraint.constant = 0
            self.view.layoutIfNeeded()
            }) { (done) in
                self.videoPlayBtnTapped(NSObject())
        }
        
        AnalyticsUtil.trackScreen(screenName: "Introduction")
    }
    
    func hideVideoPlayer(_ animate: Bool) {
        // animate hide video view
        UIView.animate(withDuration: animate ? 0.4 : 0) {
            self.videoViewXPosConstraint.constant = UIScreen.main.bounds.size.width
            self.view.layoutIfNeeded()
        }
        
        self.btnInfo.isHidden = false
        self.btnEdit.isHidden = false
        self.btnEdit.setTitle(NSLocalizedString(self.isEditMode ? "Done" : "Edit", comment: ""), for: UIControlState.normal)
        self.btnEdit.setImage(nil, for: UIControlState.normal)
        lblTitle.text = NSLocalizedString("All Photos", comment: "")
        
        if !self.isEditMode {
            self.btnDelete.isHidden = true
            self.btnInstagram.isHidden = false
        } else {
            self.btnDelete.isHidden = false
            self.btnInstagram.isHidden = true
        }
        
        // stop player
        if videoPlayer != nil {
            videoPlayer.pause()
            playeritem.seek(to: kCMTimeZero)
        }
        
        btnInstagram.isEnabled = true
        
        AnalyticsUtil.trackScreen(screenName: "Post Overview")
    }
    
    func getInstagramMediaInfo(_ urlString: String) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            var media: InstagramMedia! = nil
            if error == nil {
                
                var jsonString: String! = nil
                
                // get window.sharedData
                let string = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                let prefix = String("window._sharedData = ")
                let range1 = string?.range(of: prefix!)
                if range1 != nil {
                    let index = string?.index(range1!.lowerBound, offsetBy: (prefix?.characters.count)!)
                    let string1 = string?.substring(from: index!)
                    let range2 = string1?.range(of: ";</script>")
                    if range2 != nil {
                        jsonString = string1?.substring(to: (range2?.lowerBound)!)
                    }
                }
                
                // extact data
                if jsonString != nil && !jsonString.isEmpty {
                    media = InstagramMedia()
                    let sharedData = self.convertStringToDictionary(text: jsonString!)
                    let entryData = sharedData?["entry_data"] as! [String:AnyObject]
                    let postPage = entryData["PostPage"] as! [AnyObject]
                    let firstPost = postPage[0] as! [String:AnyObject]
                    let jsonMedia = firstPost["media"] as! [String:AnyObject]
                    
                    media.id = jsonMedia["id"] as! String
                    
                    let dimensions = jsonMedia["dimensions"] as! [String:AnyObject]
                    let width = dimensions["width"] as! CGFloat
                    let height = dimensions["height"] as! CGFloat
                    media.standardResolutionImageFrameSize = CGSize(width: width, height: height)
                    media.standardResolutionImageURL = URL(string: (jsonMedia["display_src"] as! String))!
                    
                    let comments = jsonMedia["comments"] as! [String:AnyObject]
                    let commentsCount = comments["count"] as! Int
                    media.commentCount = commentsCount
                    
                    let likes = jsonMedia["likes"] as! [String:AnyObject]
                    let likesCount = likes["count"] as! Int
                    media.likesCount = likesCount
                    
                    let user = InstagramUser()
                    let owner = jsonMedia["owner"] as! [String:AnyObject]
                    user.id = owner["id"] as! String
                    user.username = owner["username"] as! String
                    user.profilePictureURL = URL(string: (owner["profile_pic_url"] as! String))!
                    media.user = user;
                    
                    media.isVideo = jsonMedia["is_video"] as! Bool
                    
                    if jsonMedia["caption"] != nil {
                        let caption = InstagramComment()
                        caption.text = jsonMedia["caption"] as! String
                        media.caption = caption
                    }

                }
                
            } else {
                print(error)
            }
            
            self.performSelector(onMainThread: #selector(AllPhotosViewController.processMedia(_:)), with: media, waitUntilDone: true)
        }
        task.resume()
    }
    
    func processMedia(_ media: InstagramMedia!) {
        
        MBProgressHUD.hide(for: self.view, animated: true)
        
        if media != nil {
            if (!media.isVideo) {
                self.saveMedia(media)
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("Videos not supported", comment: ""), message: NSLocalizedString("We do not support video repost", comment: ""), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Photo could not be accessed", comment: ""), message: NSLocalizedString("The link you provided contains a photo that can not be reposted.", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "OK", value: "", table: nil), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        self.checkAndShowVideoPlayer()
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

