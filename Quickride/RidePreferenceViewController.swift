//
//  RidePreferenceViewController.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RidePreferenceViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var rideTakerRoleSelectionView: UIView!
    @IBOutlet weak var rideGiverRoleSelectionView: UIView!
    @IBOutlet weak var preferredRoleSelectionView: UIView!
    @IBOutlet weak var rideTakerRoleSelectedImageView: UIImageView!
    @IBOutlet weak var rideGiverRoleSelectedImageView: UIImageView!
    @IBOutlet weak var vehicleView: UIView!
    @IBOutlet weak var vehicleImageView: UIImageView!
    @IBOutlet weak var vehicleModelLabel: UILabel!
    @IBOutlet weak var vehicleRegistrationNumberLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tickMarkButton: UIButton!
    @IBOutlet weak var simplView: UIView!
    @IBOutlet weak var simplViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    //MARK: Properties
    private var preferredRole : String?
    private var ridePreferenceViewModel = RidePreferenceViewModel()
    
    func initialiseData(isFromSignUpFlow: Bool){
        ridePreferenceViewModel = RidePreferenceViewModel(isFromSignUpFlow: isFromSignUpFlow)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addGestureRecognizer()
        ridePreferenceViewModel.updateOrgEmail()
        ridePreferenceViewModel.checkSimplEligibilityForCurrentUser()
        if !ridePreferenceViewModel.isFromSignUpFlow {
            cancelButton.isHidden = false
            cancelButton.isUserInteractionEnabled = true
        }
        let userProfile = UserDataCache.getInstance()?.userProfile
        userNameLabel.text = "Hey " + (userProfile?.userName ?? "") + "!"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Methods
    private func addGestureRecognizer(){
        rideTakerRoleSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RidePreferenceViewController.rideTakerRoleSelected(_:))))
        rideGiverRoleSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RidePreferenceViewController.rideGiverRoleSelected(_:))))
    }
    
    private func setUpUI(){
      
        ViewCustomizationUtils.addCornerRadiusToView(view: rideTakerRoleSelectionView, cornerRadius: 20.0)
        ViewCustomizationUtils.addBorderToView(view: rideTakerRoleSelectionView, borderWidth: 1.0, color: UIColor(netHex: 0xebebeb))
        ViewCustomizationUtils.addCornerRadiusToView(view: rideGiverRoleSelectionView, cornerRadius: 20.0)
        ViewCustomizationUtils.addBorderToView(view: rideGiverRoleSelectionView, borderWidth: 1.0, color: UIColor(netHex: 0xebebeb))
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
        simplView.isHidden = true
        simplViewHeightConstraint.constant = 0
        if let userPreferredRole = SharedPreferenceHelper.getUserPreferredRole(){
           handleUIAfterPreferredRoleStepCompleted(preferredRole: userPreferredRole)
        }
    }
    
    
    private func handleUIAfterPreferredRoleStepCompleted(preferredRole : String){
        if SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS) != nil && SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS)!{

            if preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
                rideGiverRoleSelectedImageView.isHidden = false
                rideTakerRoleSelectedImageView.isHidden = true
                if UserDataCache.getInstance()?.vehicle != nil{
                  vehicleView.isHidden = false
                }else{
                  vehicleView.isHidden = true
                }
                getVehicleDetailsAndPopulateView()
            }else{
                rideGiverRoleSelectedImageView.isHidden = true
                rideTakerRoleSelectedImageView.isHidden = false
                vehicleView.isHidden = true
            }
        }else{

           rideGiverRoleSelectedImageView.isHidden = true
           rideTakerRoleSelectedImageView.isHidden = true
           vehicleView.isHidden = true
        }
    }
    @objc func rideTakerRoleSelected(_ sender : UITapGestureRecognizer){
        preferredRole = UserProfile.PREFERRED_ROLE_PASSENGER
        SharedPreferenceHelper.storeUserPreferredRole(preferredRole: preferredRole!)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS, value: true)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_SELECTED_ROLE, params: [
            "user_role" : preferredRole ?? "","UserId": QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        handleUIAfterPreferredRoleStepCompleted(preferredRole: preferredRole!)
        ridePreferenceViewModel.updateUserProfile(viewController: self, preferredRole: preferredRole!)
        if ridePreferenceViewModel.isEligiableForSimpl && ridePreferenceViewModel.isSimpleOfferPresent{
            simplView.isHidden = false
            simplViewHeightConstraint.constant = 140

        }else{
            simplView.isHidden = true

            simplViewHeightConstraint.constant = 0
               navigateToRecurringRideCreationVC()
        }
    }
    
   
    
    @objc func rideGiverRoleSelected(_ sender : UITapGestureRecognizer){
        simplView.isHidden = true
        simplViewHeightConstraint.constant = 0
        preferredRole = UserProfile.PREFERRED_ROLE_RIDER
        SharedPreferenceHelper.storeUserPreferredRole(preferredRole: preferredRole!)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS, value: true)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_SELECTED_ROLE, params: [
            "user_role" : preferredRole ?? "","UserId": QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        ridePreferenceViewModel.updateUserProfile(viewController: self, preferredRole: preferredRole!)
        handleUIAfterPreferredRoleStepCompleted(preferredRole: preferredRole!)
        navigateToAddVehicleVC()
     }
    
    func navigateToAddVehicleVC(){
        let vehicle = SharedPreferenceHelper.getVehicleObject()
        let addVehicleDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "AddVehicleDetailsViewController") as! AddVehicleDetailsViewController
        addVehicleDetailsViewController.initializeDataBeforePresentingView(presentedFromActivationView: true, rideConfigurationDelegate: nil, vehicle: vehicle, listener: nil)
        if !ridePreferenceViewModel.isFromSignUpFlow{
        addVehicleDetailsViewController.initialiseData(isFromSignUpFlow: false)
        }
        self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
       ViewControllerUtils.addSubView(viewControllerToDisplay: addVehicleDetailsViewController)
        addVehicleDetailsViewController.view!.layoutIfNeeded()
    }
    private func navigateToRecurringRideCreationVC(){
        let rideCreationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as!
            RideCreateViewController
        if !ridePreferenceViewModel.isFromSignUpFlow{
            rideCreationVC.initiliseData(isFromSignUpFlow: false)
        }
        self.navigationController?.pushViewController(rideCreationVC, animated: false)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
    }
    
    
    func getVehicleDetailsAndPopulateView(){
        if let vehicle = UserDataCache.getInstance()?.vehicle{
            if vehicle.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
                vehicleImageView.image = UIImage(named: "icon_hatchback")
            }else{
                vehicleImageView.image = UIImage(named: "icon_scooter")
            }
            vehicleModelLabel.text = vehicle.vehicleModel
            vehicleRegistrationNumberLabel.text = vehicle.registrationNumber
        }
    }

    
    //MARK: Action
    @IBAction func linkSimpleAsdefaultWallet(_ sender: Any) {
        if ridePreferenceViewModel.isUserSelectedSimpl{
            tickMarkButton.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
            ridePreferenceViewModel.isUserSelectedSimpl = false
        }else{
            tickMarkButton.setImage(UIImage(named: "insurance_tick"), for: .normal)
            ridePreferenceViewModel.isUserSelectedSimpl = true
        }
    }
    
    @IBAction func whatSimplClicked(_ sender: Any) {
        let infoDailogWithImage = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InfoDailogWithImage") as! InfoDailogWithImage
        infoDailogWithImage.initializeInfoDailog(image: UIImage(named: "simpl_logo_with_text") ?? UIImage(), message: Strings.whats_simpl_text)
        ViewControllerUtils.addSubView(viewControllerToDisplay: infoDailogWithImage)
    }
    
    @IBAction func termsAndConditionClicked(_ sender: Any) {
        let url = NSURL(string :  AppConfiguration.simpl_terms_url)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}


