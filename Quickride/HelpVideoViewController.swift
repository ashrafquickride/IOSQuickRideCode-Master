//
//  HelpVideosViewController.swift
//  Quickride
//
//  Created by KNM Rao on 07/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class HelpVideosViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    static let QUICKRIDE_GENERAL_VIDEO_ID="vqYw1MRuHR0"
    static let OFFER_RIDE_VIDEO_ID="IDwmVTXUQB8"
    static let MANAGING_OFFER_RIDE_VIDEO_ID="4Op4usDYXAQ"
    static let FIND_RIDE_VIDEO_ID="_cd41ANzSmw"
    static let MANAGE_FIND_RIDE_VIDEO_ID="RnBL9a8cBYA"
    static let CUSTOMIZE_QUICK_RIDE_ACCOUNT_VIDEO_ID="rjw_UnWniaU"
    static let REDEEM_VIDEO_ID="u1Hyo7pVLso"
    static let CREATING_REGULAR_RIDES_VIDEO_ID="3xHZsltDG9U"
    static let CUSTOMIZING_ROUTE_VIDEO_ID="hu_W5HLUDv0"
  
    static let youtube_url = "https://www.youtube.com/embed/"
    var fromActivation = false
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var helpVideosTableView: UITableView!
    
    override func viewDidLoad() {
        helpVideosTableView.register(UINib(nibName: "HelpVideoSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpVideoSectionTableViewCell")
        helpVideosTableView.delegate = self
        helpVideosTableView.dataSource = self
        helpVideosTableView.estimatedRowHeight = 63
        helpVideosTableView.rowHeight = UITableView.automaticDimension
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = false
        if fromActivation
        {
            nextButton.isHidden = false
            backButton.isHidden = true
        }
        else
        {
            nextButton.isHidden = true
            backButton.isHidden = false
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        helpVideosTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Strings.help_video_titles.count
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "HelpVideoSectionTableViewCell", for: indexPath) as! HelpVideoSectionTableViewCell

        if Strings.help_video_titles.endIndex <= indexPath.row{
            return cell
        }
       cell.title.text = Strings.help_video_titles[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openVideo(identifier: HelpVideosViewController.QUICKRIDE_GENERAL_VIDEO_ID)
            break
        case 1:
            openVideo(identifier: HelpVideosViewController.OFFER_RIDE_VIDEO_ID)
            break
        case 2:
            openVideo(identifier: HelpVideosViewController.MANAGING_OFFER_RIDE_VIDEO_ID)
            break
        case 3:
            openVideo(identifier: HelpVideosViewController.FIND_RIDE_VIDEO_ID)
            break
        case 4:
            openVideo(identifier: HelpVideosViewController.MANAGE_FIND_RIDE_VIDEO_ID)
            break
        case 5:
            openVideo(identifier: HelpVideosViewController.CUSTOMIZE_QUICK_RIDE_ACCOUNT_VIDEO_ID)
        case 6:
            openVideo(identifier: HelpVideosViewController.CREATING_REGULAR_RIDES_VIDEO_ID)
            
        case 7:
            openVideo(identifier: HelpVideosViewController.CUSTOMIZING_ROUTE_VIDEO_ID)
        case 8:
            openVideo(identifier: HelpVideosViewController.REDEEM_VIDEO_ID)
        default:
            break
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    func openVideo(identifier : String){
        AppDelegate.getAppDelegate().log.debug("openVideo() \(identifier)")
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HELP_VIDEOS_CHECKED, params: [
            "time of click" : DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa) ?? "",
            "userId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        let url = URL(string: HelpVideosViewController.youtube_url+identifier+"?autoplay=1")
        let videoPlayerViewController = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
        videoPlayerViewController.initializeDataBeforePresenting(url: url!)
        self.navigationController?.view.addSubview(videoPlayerViewController.view)
        self.navigationController?.addChild(videoPlayerViewController)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        AppStartUpUtils.checkViewControllerAndNavigate(viewController: self)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if fromActivation{
            ContainerTabBarViewController.indexToSelect = 1
            self.navigationController?.popToRootViewController(animated: false)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
        
    }
}
