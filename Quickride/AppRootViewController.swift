//
//  AppRootViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 21/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import AVKit
import ObjectMapper

class AppRootViewController: UIViewController{
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    @IBOutlet var gTechLogo: UIImageView!
    
    @IBOutlet var poweredByLabel: UILabel!
    
    @IBOutlet var appIcon: UIImageView!
    
    @IBOutlet var splashScreenBackgroundImage: UIImageView!
    
    @IBOutlet var quickridelink: UILabel!
    
    @IBOutlet weak var appIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var appIconHeightConstraint: NSLayoutConstraint!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var initializationStarted = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        quickridelink.isHidden = true
        gTechLogo.isHidden = true
        poweredByLabel.isHidden = true
        appIcon.isHidden = false
        versionNumberLabel.isHidden = false
        splashScreenBackgroundImage.image = nil
        appIcon.image = UIImage(named: "splash_background")
        appIconWidthConstraint.constant = 250
        appIconHeightConstraint.constant = 300
        let lastDisplayedTime = SharedPreferenceHelper.getSplashVideoDisplayedTime()
        if lastDisplayedTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayedTime!) < 24*60{
            appIcon.isHidden = false
            appIcon.image = UIImage(named:"app_icon_with_label")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                self.checkSessionStatusAndNavigateToAppropriateView()
            })
        }else{
            loadVideo()
        }
        
        quickridelink.isHidden = true
        gTechLogo.isHidden = true
        poweredByLabel.isHidden = true
        versionNumberLabel.isHidden = false
        splashScreenBackgroundImage.image = UIImage(named: "splash_background")
        splashScreenBackgroundImage.isHidden = true
        appIconWidthConstraint.constant = 185
        appIconHeightConstraint.constant = 145
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumberLabel.text = Strings.version+" "+version
        }
        appDelegate.window!.rootViewController = self
        if #available(iOS 13.0, *) {
            if appDelegate.window!.responds(to: Selector("overrideUserInterfaceStyle")) {
                appDelegate.window!.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
        initializationStarted = true
        
    }
    private func loadVideo() {
        let path = Bundle.main.path(forResource: "IMG_0970", ofType: "mov")
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        }
        catch {
            AppDelegate.getAppDelegate().log.debug("\(error)")
        }
        appIcon.isHidden = true
        let player = AVPlayer(url: URL(fileURLWithPath: path!))
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        player.seek(to: .zero)
        player.play()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            self.checkSessionStatusAndNavigateToAppropriateView()
        })
        SharedPreferenceHelper.setSplashVideoDisplayedTime(time: NSDate())
        
    }
    
    func checkSessionStatusAndNavigateToAppropriateView(){
        AppDelegate.getAppDelegate().log.debug("checkSessionStatusAndNavigateToAppropriateView()")
        let userId = SharedPreferenceHelper.getLoggedInUserId()
        AppDelegate.getAppDelegate().log.debug("userId  : \(String(describing: userId))")
        
        if (userId == nil) {
            UserRestClient.getContactNoForDeviceId(deviceId: DeviceUniqueIDProxy().getDeviceUniqueId() ?? "", appName: AppConfiguration.APP_NAME) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                    UserDataCache.contactNo = responseObject!["resultData"] as? Double
                }
                self.checkViewControllerAndNavigate(viewController: self)
            }
           
        }
        else {
            // App re-open
            
            let appStartupHandler = AppStartupHandler(targetViewController: self,  notificationActionIdentifier : nil,isbackGroundStartUp: false, completionHandler: {(sessionComplete, sessionStop, sessionRestart) in
                
            })
            appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
        }
    }
    
    func checkViewControllerAndNavigate(viewController : UIViewController?)
    {
        var status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_FEATURE_SELECTION_DETAILS)
        if status != nil && status == false
        {
            let featureSelectionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FeatureSelectionViewController") as! FeatureSelectionViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : featureSelectionVC)
            return
         }
        
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS)
        if status != nil && status == false
        {
            let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePreferenceViewController") as! RidePreferenceViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : ridePreferencesViewController)
            return
        }
        
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO)
        if status != nil && status == false
        {
            let rideCreateViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : rideCreateViewController)
            return
        }
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD)
        if status != nil && status == false{
            let addProfilePictureViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProfilePictureViewController") as! AddProfilePictureViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : addProfilePictureViewController)
        }else{
           
            appDelegate.window?.rootViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "startcontroller")
            if let contactNo = UserDataCache.contactNo,contactNo != 0 {
                let signUpSecondPhaseVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignUpSecondPhaseViewController") as! SignUpSecondPhaseViewController
                AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : signUpSecondPhaseVC)
            }
        }
    }
}

