

//
//  RideAutoConfirmationSettingViewController.swift
//  Quickride
//
//  Created by rakesh on 1/29/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation

class RideAutoConfirmationSettingViewController : UIViewController,SaveRidePreferencesReceiver{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var allOptionView: UIView!
    
    @IBOutlet weak var allOptionImageView: UIImageView!
    
    @IBOutlet weak var allOptionLbl: UILabel!
    
    @IBOutlet weak var anyVerifiedUsersOptionView: UIView!
    
    @IBOutlet weak var anyVerifiedUsersOptionImageView: UIImageView!
    
    @IBOutlet weak var anyVerifedUserOptionLbl: UILabel!
    
    @IBOutlet weak var favouritePartnersOptionView: UIView!
    
    @IBOutlet weak var favouritePartnersImageView: UIImageView!
    
    @IBOutlet weak var favouritePartnersOptionLbl: UILabel!
    
    @IBOutlet weak var  viewFavouritesLabel: UILabel!
    
    @IBOutlet weak var viewFavouritesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var offerRideMatchView: UIView!
    
    @IBOutlet weak var findRideMatchView: UIView!
    
    @IBOutlet weak var timeRangeMatchView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    
    @IBOutlet weak var timeRangeLabel: UILabel!
    
    @IBOutlet weak var offerRidePercentLabel: UILabel!
    
    @IBOutlet weak var findRideMatchPercentageLabel: UILabel!
    
    @IBOutlet weak var donotAllowViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var autoMatchEnableSwitch: UISwitch!
    
    @IBOutlet weak var matchAndDontMatchView: UIView!
    
    @IBOutlet weak var selectAndDisSelectImageView: UIImageView!
    
    @IBOutlet weak var disclaimerView: UIView!
    
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    @IBOutlet weak var disclaimerViewHeightConstraint: NSLayoutConstraint!
    
    var ridePreferences : RidePreferences?
    var isAutoConfirmSettingsChanged  = false
    
     func initializeViews(ridePreferences : RidePreferences){
            self.ridePreferences = ridePreferences
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.ridePreferences != nil{
            self.ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
            SetUpUI()
        }else{
            self.navigationController?.popViewController(animated: false)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func SetUpUI() {       
        ViewCustomizationUtils.addCornerRadiusToView(view: circleView, cornerRadius: 20)
        allOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allViewTapped(_:))))
        anyVerifiedUsersOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(anyVerifiedUsersViewTapped(_:))))
        favouritePartnersOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoritePartnersViewTapped(_:))))
        viewFavouritesLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewFavoritePartnersTapped(_:))))
        offerRideMatchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(offerRideMatchViewTapped(_:))))
        findRideMatchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(findRideMatchViewTapped(_:))))
        timeRangeMatchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timeRangeMatchViewTapped(_:))))
        matchAndDontMatchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(specificPartnerViewTapped)))
        allOptionImageView.image = allOptionImageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        anyVerifiedUsersOptionImageView.image = anyVerifiedUsersOptionImageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        favouritePartnersImageView.image = favouritePartnersImageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        ViewCustomizationUtils.addCornerRadiusToView(view: allOptionView, cornerRadius: 10)
        ViewCustomizationUtils.addCornerRadiusToView(view: anyVerifiedUsersOptionView, cornerRadius: 10)
        ViewCustomizationUtils.addCornerRadiusToView(view: favouritePartnersOptionView, cornerRadius: 10)
        offerRidePercentLabel.text = String(ridePreferences!.autoConfirmRideMatchPercentageAsRider) + "%"
        findRideMatchPercentageLabel.text = String(ridePreferences!.autoConfirmRideMatchPercentageAsPassenger) + "%"
        timeRangeLabel.text = String(ridePreferences!.autoConfirmRideMatchTimeThreshold) + " Mins"
        if ridePreferences!.autoConfirmEnabled{
            autoMatchEnableSwitch.setOn(true, animated: false)
            infoView.isHidden  = false
            setAutoConfirmValueBasedOnSelection(AutoConfirm: ridePreferences?.autoconfirm ?? "")
            checkSpecificPartnerEnabledOrNot()
        }else{
            autoMatchEnableSwitch.setOn(false, animated: false)
            infoView.isHidden  = true
        }
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
            disclaimerView.isHidden = false
            disclaimerViewHeightConstraint.constant = 70
            disclaimerLabel.text = Strings.upi_disclaimer
        }
    }
    
    private func setAutoConfirmValueBasedOnSelection(AutoConfirm: String){
        switch AutoConfirm{
        case RidePreferences.AUTO_CONFIRM_ALL:
            allOptionTapped()
        case RidePreferences.AUTO_CONFIRM_VERIFIED:
            verifiedUsersOptionTapped()
        case RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS:
            favoritePartnersOptionTapped()
        default:
            break
        }
    }
    @objc private func allViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        ridePreferences!.autoconfirm = RidePreferences.AUTO_CONFIRM_ALL
        isAutoConfirmSettingsChanged = true
        allOptionTapped()
    }
    
    private func allOptionTapped(){
        // select
        ViewCustomizationUtils.addBorderToView(view: allOptionView, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        allOptionLbl.textColor = UIColor(netHex: 0x007AFF)
        allOptionImageView.tintColor = UIColor(netHex: 0x007AFF)
        
        //unselect
        ViewCustomizationUtils.addBorderToView(view: anyVerifiedUsersOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        anyVerifedUserOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        anyVerifiedUsersOptionImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
        ViewCustomizationUtils.addBorderToView(view: favouritePartnersOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        favouritePartnersOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        favouritePartnersImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @objc private func anyVerifiedUsersViewTapped(_ gestureRecognizer: UITapGestureRecognizer){
        ridePreferences!.autoconfirm = RidePreferences.AUTO_CONFIRM_VERIFIED
        isAutoConfirmSettingsChanged = true
        verifiedUsersOptionTapped()
    }
    
    private func verifiedUsersOptionTapped(){
        // select
        ViewCustomizationUtils.addBorderToView(view: anyVerifiedUsersOptionView, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        anyVerifedUserOptionLbl.textColor = UIColor(netHex: 0x007AFF)
        anyVerifiedUsersOptionImageView.tintColor = UIColor(netHex: 0x007AFF)
        
        //unselect
        ViewCustomizationUtils.addBorderToView(view: allOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        allOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        allOptionImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
        ViewCustomizationUtils.addBorderToView(view: favouritePartnersOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        favouritePartnersOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        favouritePartnersImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @objc private func favoritePartnersViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        ridePreferences!.autoconfirm = RidePreferences.AUTO_CONFIRM_FAVORITE_PARTNERS
        isAutoConfirmSettingsChanged = true
        favoritePartnersOptionTapped()
    }
    
    private func favoritePartnersOptionTapped(){
        // select
        ViewCustomizationUtils.addBorderToView(view: favouritePartnersOptionView, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        favouritePartnersOptionLbl.textColor = UIColor(netHex: 0x007AFF)
        favouritePartnersImageView.tintColor = UIColor(netHex: 0x007AFF).withAlphaComponent(1)
        
        //unselect
        ViewCustomizationUtils.addBorderToView(view: anyVerifiedUsersOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        allOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        allOptionImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
        ViewCustomizationUtils.addBorderToView(view: allOptionView, borderWidth: 1, color: UIColor(netHex: 0xEFEFEF))
        anyVerifedUserOptionLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        anyVerifiedUsersOptionImageView.tintColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @objc func  viewFavoritePartnersTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let specificFavouriteUsersViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SpecificFavouriteUsersViewController") as! SpecificFavouriteUsersViewController
        specificFavouriteUsersViewController.ridePreferences = self.ridePreferences
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: specificFavouriteUsersViewController, animated: false)
    }
    @objc func offerRideMatchViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentValue = Int(self.offerRidePercentLabel.text!) ?? ridePreferences!.autoConfirmRideMatchPercentageAsRider
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: Strings.offer_ride_match, firstValue: 50,lastValue: 100, minValue: 50,currentValue: currentValue) { (value) in
                self.offerRidePercentLabel.text = "\(value)" + "%"
                self.ridePreferences?.autoConfirmRideMatchPercentageAsRider = value
                self.isAutoConfirmSettingsChanged = true
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
    @objc func findRideMatchViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentValue = Int(self.findRideMatchPercentageLabel.text!) ?? ridePreferences!.autoConfirmRideMatchPercentageAsPassenger
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: Strings.find_ride_match, firstValue: 50,lastValue: 100, minValue:50, currentValue: currentValue) { (value) in
                self.ridePreferences?.autoConfirmRideMatchPercentageAsPassenger = value
                self.findRideMatchPercentageLabel.text = "\(value)" + "%"
                self.isAutoConfirmSettingsChanged = true
           
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
    @objc func timeRangeMatchViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentValue = Int(self.timeRangeLabel.text!) ?? self.ridePreferences!.autoConfirmRideMatchTimeThreshold
        
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: Strings.time_match, firstValue: 0,lastValue: 30, minValue: 5, currentValue: currentValue) { (value) in
            
            if value < 5 {
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: ["5"]),duration: 2.0, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                self.timeRangeLabel.text = String(self.ridePreferences!.autoConfirmRideMatchTimeThreshold) + " Mins"
            }else{
                self.ridePreferences?.autoConfirmRideMatchTimeThreshold = value
                self.timeRangeLabel.text = "\(value) Mins"
                self.isAutoConfirmSettingsChanged = true
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        if isAutoConfirmSettingsChanged{
            QuickRideProgressSpinner.startSpinner()
            SaveRidePreferencesTask(ridePreferences: ridePreferences!, viewController: self, receiver: self).saveRidePreferences()
        }else{
            closeViewController()
        }
    }

    @objc func specificPartnerViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if ridePreferences!.autoConfirmPartnerEnabled{
            selectAndDisSelectImageView.image = UIImage(named: "insurance_tick_disabled")
            viewFavouritesHeightConstraint.constant = 0
            ridePreferences?.autoConfirmPartnerEnabled = false
        }else{
            selectAndDisSelectImageView.image = UIImage(named: "insurance_tick")
            viewFavouritesHeightConstraint.constant = 20
            ridePreferences?.autoConfirmPartnerEnabled = true
        }
        isAutoConfirmSettingsChanged = true
    }
    private func checkSpecificPartnerEnabledOrNot(){
       if ridePreferences!.autoConfirmPartnerEnabled{
        selectAndDisSelectImageView.image = UIImage(named: "insurance_tick")
        viewFavouritesHeightConstraint.constant = 20
       }else{
        selectAndDisSelectImageView.image = UIImage(named: "insurance_tick_disabled")
        viewFavouritesHeightConstraint.constant = 0
        }
    }
    
    @IBAction func AutoMatchSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            infoView.isHidden = false
            ridePreferences?.autoConfirmEnabled = true
            SetUpUI()
        } else {
            infoView.isHidden = true
            ridePreferences?.autoConfirmEnabled = false
        }
        isAutoConfirmSettingsChanged = true
    }
    
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        closeViewController()
    }
    
    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }
    
    func closeViewController(){
        if self.navigationController != nil{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.dismiss(animated: false, completion: nil)
        }
    }
}
