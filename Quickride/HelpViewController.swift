
//
//  HelpViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 30/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI
import UIKit
import AVKit
import AVFoundation


class HelpViewController: HelpBaseViewController {

    @IBOutlet weak var helpTableView: UITableView!
    @IBOutlet weak var whatsNew: UIButton!
    @IBOutlet weak var emailWriteButton: UIButton!
    @IBOutlet weak var presentVersionInfoView: UIView!
    let FAQ_URL = "https://quickride.in/help.php"
    static let TERMSURL = "https://www.quickride.in/terms-and-conditions.php"
    let WHATS_NEW_URL = "https://www.quickride.in/new-features.php#ios"
    var helpSceneTitles : [String] = [String]()
    static let saturday : Int = 7
    static let sunday : Int = 1
    var blog : Blog?
    
    override func viewDidLoad()
    {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        helpTableView.register(UINib(nibName: "RectangleBlogTableViewCell", bundle: nil), forCellReuseIdentifier: "RectangleBlogTableViewCell")
        helpTableView.register(UINib(nibName: "HelpVideoDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpVideoDetailsTableViewCell")
        helpTableView.register(UINib(nibName: "HelpInformationTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpInformationTableViewCell")
        helpTableView.register(UINib(nibName: "CarpoolHelpVideoPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "CarpoolHelpVideoPlayerTableViewCell")
        



        let hour = NSCalendar.current.component(.hour, from: NSDate() as Date)
        let day = NSCalendar.current.component(.weekday, from: NSDate() as Date)
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if hour < Int(clientConfiguration.customerSupportAllowFromTime)! || hour >= Int(clientConfiguration.customerSupportAllowToTime)! || day == HelpViewController.saturday || day == HelpViewController.sunday
        {
            helpSceneTitles = Strings.help_scene_title_without_call
        }
        else
        {
            helpSceneTitles = Strings.help_scene_titles
        }
        whatsNew.setTitleColor(Colors.defaultTextColor, for: .normal)
        blog = HelpUtils.getRecentBlogToDisplay()
        helpTableView.reloadData()
        helpTableView.estimatedRowHeight = 250
        helpTableView.rowHeight = UITableView.automaticDimension
        helpTableView.delegate = self
        helpTableView.dataSource = self
        helpTableView.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        self.navigationController?.isNavigationBarHidden = true
    }
    func moveToOfferWebView(){
        if blog!.linkUrl != nil {
            let queryItems = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps = URLComponents(string :  blog!.linkUrl!)
            urlcomps?.queryItems = [queryItems]
            if urlcomps?.url != nil{
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: "Blog", url: urlcomps!.url!, actionComplitionHandler: nil)
                self.navigationController?.pushViewController(webViewController, animated: false)
            }else{
                UIApplication.shared.keyWindow?.makeToast(Strings.cant_open_this_web_page)
            }

        }
    }
    func moveToHelpVideos(){
        let helpVideosViewController = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "HelpVideosViewController") as! HelpVideosViewController
        self.navigationController?.pushViewController(helpVideosViewController, animated: false)
    }
    
    func toShowLegelView(){
        let legalViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LegalViewController") as! LegalViewController
        self.navigationController?.pushViewController(legalViewController, animated: false)
    }
    
    func toShowFeedbackView(){
        let feedViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as!  FeedbackViewController
        self.navigationController?.pushViewController(feedViewController, animated: false)
    }
    
    private func openVideoLink(identifier: String){

        let  automaticVideoPlayerViewController = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "AutomaticVideoPlayerViewController") as! AutomaticVideoPlayerViewController
        automaticVideoPlayerViewController.initializeDataBeforePresenting(id: identifier)
       self.navigationController?.pushViewController( automaticVideoPlayerViewController, animated: false)
    }
    
    

    

    func openFaQsPage(){
        let faqViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
        self.navigationController?.pushViewController(faqViewController, animated: false)
    }
 
    func termsAndCondPage(){
        AppDelegate.getAppDelegate().log.debug("")
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  HelpViewController.TERMSURL)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms, url: (urlcomps?.url!)!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }else{
           UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
   }

    func moveToReportIssuePage(){
        let supportViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SupportElementViewController") as! SupportElementViewController
        supportViewController.initializeDataBeforePresenting(name: Strings.report_issue)
        self.navigationController?.pushViewController(supportViewController, animated: false)
    }

    func moveTocallSupportPage(){
        let supportViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SupportElementViewController") as! SupportElementViewController
        supportViewController.initializeDataBeforePresenting(name: Strings.call_support)
        self.navigationController?.pushViewController(supportViewController, animated: false)
    }
    func moveToFeedback(){
        let feedbackViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(feedbackViewController, animated: false)
    }
    func callSupport()
    {
        AppDelegate.getAppDelegate().log.debug("")
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        AppUtilConnect.callSupportNumber(phoneNumber: "\(clientConfiguration.callQuickRideForSupport)".components(separatedBy: ".")[0], targetViewController: self)
    }

    @IBAction func whatsNewBtnTapped(_ sender: Any) {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  WHATS_NEW_URL)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.whatsnew, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }

    @IBAction func writeEmailToSupport(_ sender: Any) {
        HelpUtils.sendEmailToSupport(viewController: self, image: nil, listOfIssueTypes: Strings.list_of_issue_types)

    }


    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

}

extension HelpViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return CarpoolHelpVideoPlayerTableViewCell.CARPOOL_VIDEOS.count
        case 2:
            return 1
        case 3:
            return helpSceneTitles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        AppDelegate.getAppDelegate().log.debug("")
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RectangleBlogTableViewCell", for: indexPath) as! RectangleBlogTableViewCell
            if blog != nil{
                ImageCache.getInstance().getImageFromCache(imageUrl: blog!.blogImageUri!, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
                    cell.recentBlogImageView.image = image
                    cell.recentBlogImageView.layer.cornerRadius = 8
                    cell.recentBlogImageView.clipsToBounds = true
                })
                cell.labelBlogTitle.text = blog!.blogTitle
                return cell
            }
            else{
                tableView.rowHeight = 0
                return UITableViewCell()
            }
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolHelpVideoPlayerTableViewCell", for: indexPath) as! CarpoolHelpVideoPlayerTableViewCell
            cell.setTitleAndContentBasedOnCategory(value: indexPath.row)
            return cell
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HelpVideoDetailsTableViewCell", for: indexPath) as! HelpVideoDetailsTableViewCell
            cell.quickRideUseLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            return cell
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HelpInformationTableViewCell", for: indexPath) as! HelpInformationTableViewCell
            cell.title.text = helpSceneTitles[indexPath.row]
            cell.title.font =  UIFont(name: "HelveticaNeue-Bold", size: 16)
            return cell
        default :
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("\(indexPath)")
        
        let hour = NSCalendar.current.component(.hour, from: NSDate() as Date)
        let day = NSCalendar.current.component(.weekday, from: NSDate() as Date)
        
        switch indexPath.section{
        case 0:
            moveToOfferWebView()
        case 1:
            if indexPath.row == 0 {
                openVideoLink(identifier: CarpoolHelpVideoPlayerTableViewCell.CARPOOL_VIDEOS[indexPath.row])
                
            } else if indexPath.row == 1 {
                openVideoLink(identifier: CarpoolHelpVideoPlayerTableViewCell.CARPOOL_VIDEOS[indexPath.row])
                
            } else if indexPath.row == 2 {
                openVideoLink(identifier: CarpoolHelpVideoPlayerTableViewCell.CARPOOL_VIDEOS[indexPath.row])
            }
        case 2:
            moveToHelpVideos()
        case 3:
            if indexPath.row == 0 {
                openFaQsPage()
            }else if indexPath.row == 1 {
                moveToReportIssuePage()
            }else  if indexPath.row == 2 {
                termsAndCondPage()
            } else if indexPath.row == 3 {
                toShowLegelView()
            } else if indexPath.row == 4 {
                toShowFeedbackView()
                
            } else if indexPath.row == 5 {
                let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                if hour < Int(clientConfiguration.customerSupportAllowFromTime)! || hour >= Int(clientConfiguration.customerSupportAllowToTime)! || day == HelpViewController.saturday || day == HelpViewController.sunday
                {
                    termsAndCondPage()
                }
                else
                {
                    moveTocallSupportPage()
                }
                
            }
        default: break
        }
        
       tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }

}
