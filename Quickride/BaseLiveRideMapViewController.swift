//
//  BaseLiveRideMapViewController.swift
//  Quickride
//
//  Created by KNM Rao on 17/05/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import ObjectMapper
import MessageUI
import ContactsUI
import AddressBookUI
import Lottie

public enum UserRole{
    case Passenger
    case Rider
    case RegularRider
    case RegularPassenger
    case None
}

protocol LiveRideDelegateForTaxiPool {
    func showCancelFeeWaiverView()
}
extension BaseLiveRideMapViewController {
    func showCancelFeeWaiverView(){}
}

class BaseLiveRideMapViewController: UIViewController, GMSMapViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource, MyRidesCacheListener, RideParticipantLocationListener,GroupChatMessageListener, RideUpdateListener ,RideActionComplete ,MFMessageComposeViewControllerDelegate,RideCancelDelegate,SelectContactDelegate,EmergencyInitiator,NotificationChangeListener,RideInvitationUpdateListener,MatchedUsersDataReceiver,PassengerPickupDelegate,RideObjectUdpateListener,RideActionDelegate,RouteSelectionDelegate{
   
    
    
    
    @IBOutlet weak var viewLeftNavigationItems: UIView!
    
    @IBOutlet weak var labelRideScheduledTime: UILabel!
    
    @IBOutlet weak var labelRideStatus: UILabel!
    
    @IBOutlet weak var viewNotification: UIView!
    
    @IBOutlet weak var buttonChat: CustomUIButton!
    
    @IBOutlet weak var buttonChatWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonMenu: CustomUIButton!
    
    @IBOutlet weak var buttonNoticicationIcon: CustomUIButton!
    
    @IBOutlet weak var buttonEmergency: UIButton!
    
    @IBOutlet weak var viewMapContainer: UIView!
    
    @IBOutlet weak var buttonCurrentLoc: UIButton!
    
    @IBOutlet weak var buttonGoogleMapNavigation: UIButton!
    
    @IBOutlet weak var viewFindMatchedRidersAfterJoin: UIView!
    
    @IBOutlet weak var buttonFindMatchedRiderAfterJoin: UIButton!
    
    @IBOutlet weak var viewUserDetail: UIView!
    
    @IBOutlet weak var userDetailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewFindMatchedUser: UIImageView!
    
    @IBOutlet weak var viewJoinedMembers: UIView!
    @IBOutlet weak var taxiWaitingForConfirmationView: UIStackView!
    
    @IBOutlet weak var labelRideActionTitle: UILabel!
    
    @IBOutlet weak var viewRideActionSlider: UIView!
    
    @IBOutlet weak var rideactionSlideViewHeightConstrints: NSLayoutConstraint!
    @IBOutlet weak var InviteMatchedUserViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelFindMatchedUser: UILabel!
    
    @IBOutlet weak var inviteMatchedUsersView: UIView!
    
    @IBOutlet weak var lockView: UIView!
    
    @IBOutlet weak var buttonPendingNotification: UIButton!
    
    @IBOutlet weak var labelInviteMatchedUsers: UILabel!
    
    @IBOutlet weak var viewWalkPath: UIView!
    
    @IBOutlet weak var viewWalkPathHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewWalkPathFomStartToPickUp: UIView!
    
    @IBOutlet weak var labelWalkPathDistanceFromStartToPickUp: UILabel!
    
    @IBOutlet weak var viewWalkPathFromDropToEnd: UIView!
    
    @IBOutlet weak var labelWalkPthDistanceFromDropToEnd: UILabel!
    
    @IBOutlet weak var imageViewWalkPathCarIcon: UIImageView!
    
    @IBOutlet weak var viewWalkPathWidthFromStartToPickUp: NSLayoutConstraint!
    
    @IBOutlet weak var viewWalkPathWidthFromDropToEnd: NSLayoutConstraint!
    
    @IBOutlet weak var passengersCollectionViewForRider: UICollectionView!
    
    @IBOutlet weak var noOfMatchesAvailable: UIButton!
    
    @IBOutlet weak var viewRideParticipant: UIView!
    
    @IBOutlet weak var riderDetailViewForPassenger: UIView!
    
    @IBOutlet weak var imageViewRider: UIImageView!
    
    @IBOutlet weak var labelRiderRideStatus: UILabel!
    //MARK: TaxiPOOL liveRide Changes
    
    @IBOutlet weak var taxiRideRiderHeaderLabel: UILabel!
    @IBOutlet weak var taxiRideRiderSubtitleLabel: UILabel!
    
    @IBOutlet weak var riderNameStackView: UIStackView!
    
    @IBOutlet weak var pickUpImageView: UIImageView!
    
    @IBOutlet weak var taxiPoolPriceShowingLabel: UILabel!
    
    @IBOutlet weak var labelRiderName: UILabel!
    
    @IBOutlet weak var labelVehicleName: UILabel!
    
    @IBOutlet weak var buttonFreezeUnfreeze: UIButton!
    
    @IBOutlet weak var viewNavigationBarItems: UIView!
    
    @IBOutlet weak var joinedMemebersCollectionViewForPassenger: UICollectionView!
    
    @IBOutlet weak var taxiPoolHeaderLabel: UILabel!
    
    @IBOutlet weak var joinedMemberSubtitleLabel: UILabel!
    
    @IBOutlet weak var joinedMemberViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewFirstRideCreatedInfo: UIView!
    
    @IBOutlet weak var labelFirstRideInfo1: UILabel!
    
    @IBOutlet weak var labelFirstRideInfo2: UILabel!
    
    @IBOutlet weak var passengerDetailViewForRider: UIView!
    
    @IBOutlet weak var pickupButton: UIButton!
    
    @IBOutlet weak var viewMoreHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelNextPickupOrRideStatus: UILabel!
    
    @IBOutlet weak var labelRideTakerDistanceToPickupPointOrRiderName: UILabel!
    
    @IBOutlet weak var buttonMore: UIButton!
    
    @IBOutlet weak var buttonContactPassenger: UIButton!
    
    @IBOutlet weak var viewMoreDetail: UIView!
    
    @IBOutlet weak var startRideAnimationView: LOTAnimatedControl!
    
    @IBOutlet weak var btnFreezeUnfreezeWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnCurrentLocTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var passengerDetailViewForRiderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapUtilitiesBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    @IBOutlet weak var viewSeperator: UIView!
    
    @IBOutlet weak var rideRequestAckView: UIView!
    
    @IBOutlet weak var rideRequestAckLabel: UILabel!
    
    @IBOutlet weak var viewJoinedPassengerTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewUnreadMsg: UIView!
    
    @IBOutlet weak var unreadChatCountLabel: UILabel!
    
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonRefresh: UIButton!
    
    @IBOutlet weak var firstRideAnimationView: LOTAnimatedControl!
    
    @IBOutlet weak var bottomDataView: UIView!
    
    @IBOutlet weak var topDataView: UIView!
    
    @IBOutlet weak var matchingOptionsLoadingAnimationView: LOTAnimatedControl!
    
    @IBOutlet weak var viewMapComponent: UIView!
    
    @IBOutlet weak var emergencyBtnTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelArrivalOrPickupTime: UILabel!
    
    @IBOutlet weak var viewArrivalOrPickupTime: UIView!
    
    @IBOutlet weak var viewArrivalOrPickupTimeTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var refreshButtonAnimationView: LOTAnimatedControl!
        
    @IBOutlet weak var tripInsuranceView: UIView!
    
    @IBOutlet weak var walkPathCenterXSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tripInsuranceViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftNavigationTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var riderCallButton: UIButton!
    
    @IBOutlet weak var riderChatButton: UIButton!
    
    @IBOutlet weak var rideModeratorButton: UIButton!
    
    @IBOutlet weak var pickupNoteOrVehicleDetailsLabel: MarqueeLabel!
    
    @IBOutlet weak var pickupNoteOrVehicleDetailsLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var batteryCriticallyLowBackgroundView: UIView!
    
    @IBOutlet weak var batteryCriticallyLowView: UIView!

    @IBOutlet weak var lowBatteryImageView: UIView!
    
    @IBOutlet weak var vehicleView: UIView!
    
    @IBOutlet weak var riderImageView: UIImageView!
    
    @IBOutlet weak var riderNameLabel: UILabel!
    
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    
    @IBOutlet weak var otpButton: UIButton!
    
    @IBOutlet weak var taxiPoolIconImageView: UIImageView!
    @IBOutlet weak var nextBtnForTaxiPool: UIButton!
    
    @IBOutlet weak var taxiWillAllocateView: UIView!
    
    @IBOutlet weak var riderDetailsHeightConstraint: NSLayoutConstraint!
    
    private var zoom = true
    private var rideActionLabelCenter : CGPoint = CGPoint(x:0,y: 0)
    private var startRideActionSlideArrowCenter : CGPoint = CGPoint(x:0,y: 0)
    weak var viewMap: GMSMapView!
    
    var riderRide : RiderRide?
    var rideObj:Ride?
    var delegate: LiveRideDelegateForTaxiPool?
    private var taxiShareRide: TaxiShareRide?
    private var rideParticipantsObject = [RideParticipant]()
    private var rideParticipantLocationObject = [RideParticipantLocation]()
    private var passengersInfo = [RideParticipant]()

    private var routeNavigationMarker: GMSMarker!
    private var locationUpdateMarker: GMSMarker!
    private var isRideDetailInfoRetrieved = false
    private var matchedUsers = [String : MatchedUser]()
    private var matchedUsersMarkers = [GMSMarker]()

    private var routePathPolyline : GMSPolyline?
    var riderRideId : Double? = 0
    var rideStatusObj : RideStatus?
    private var etaTime = 0
    private var nextPassengerPickupTime = 0
    private var etaError : ResponseError?
    private var rideCurrentLocation : CLLocationCoordinate2D?
    private var userId : Double?
    private var rideParticipantMarkers = [Double : RideParticipantElements]()
    private var dropMarkers = [GMSMarker]()
    private var pickUpMarkerImage : UIImage?
    private var pickupMarker: GMSMarker?
    
    let MIN_TIME_DIFF_CURRENT_LOCATION  = 10
    let MIN_TIME_DIFF_FOR_ETA  = 60
    var MAP_ZOOM :Float = 16

    private var timer : Timer?
    private var participantLocationListener : ParticipantLocationListener?
    private var outGoingRideInvites = [RideInvitation]()
    private var incomingRideInvites = [Double: RideInvitation]()
    var isFromRideCreation = false
    private var isFreezeRideRequired = false

    var inviteDialogue : InviteDialogue?
    var inviteStatusDialogue : InviteStatusDialogue?
    var inviteMultipleUsersViewController : InviteMultipleUsersViewController?
    var isFromSignupFlow = false
    private var isWalkPathViewHidden = true
    private var nextPassengerToPickupIndex: Int?
    private var rideTakerDistanceToPickUp: Double?
    private var isMapFullView: Bool?
    private var selectedPickupUserId = 0.0
    private var isParticipantMarkerLoaded = false
    private var policyUrl : String?
    private var insurancePoints : Double?
    private var isModerator = false
    private var warningAlert : WarningAlertView?
    private var taxiRideId: Double? = 0
    
    static var baseLiveRideMapViewController : BaseLiveRideMapViewController?
    static let liveRideMapViewControllerKey = "LiveRideMapViewController"
    static let LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS = 60.0
    static let slideThersoldPercentage : CGFloat = 0.8
    
    static let passengerIcon = ImageUtils.RBResizeImage(image: UIImage(named: "passenger_marker")!, targetSize: CGSize(width: 20, height: 20))
    static let carIcon = ImageUtils.RBResizeImage(image: UIImage(named: "car_marker")!, targetSize: CGSize(width: 20, height: 20))
    let bikeIcon = ImageUtils.RBResizeImage(image: UIImage(named: "bike_marker")!, targetSize: CGSize(width: 25, height: 25))
    
    
    func initializeDataBeforePresenting(riderRideId : Double?,rideObj : Ride?,isFromRideCreation : Bool, isFreezeRideRequired : Bool, isFromSignupFlow: Bool){
        self.riderRideId = riderRideId
        self.isFreezeRideRequired = isFreezeRideRequired
        self.isFromSignupFlow = isFromSignupFlow
        self.rideObj = rideObj
        self.isFromRideCreation = isFromRideCreation
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        riderDetailViewForPassenger.isHidden = true
        viewJoinedMembers.isHidden = true
        viewFindMatchedRidersAfterJoin.isHidden = true
        noOfMatchesAvailable.isHidden = true
        viewRideParticipant.isHidden = true
        joinedMemebersCollectionViewForPassenger.register(UINib(nibName: "EmptyPassengerTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell")
        
        if ViewCustomizationUtils.hasTopNotch{
            leftNavigationTopConstraint.constant = 40
        }
        self.displayFirstRideCreationView()
        if BaseLiveRideMapViewController.baseLiveRideMapViewController != nil{
            BaseLiveRideMapViewController.baseLiveRideMapViewController?.removeListeners()
            BaseLiveRideMapViewController.baseLiveRideMapViewController = nil
        }
        BaseLiveRideMapViewController.baseLiveRideMapViewController = self
        self.viewMap = QRMapView.getQRMapView(mapViewContainer: viewMapContainer)
        self.viewMap.padding = getUIEdgeInsetsBasedOnRideConstraint(top: 100, left: 20, bottom: 40, right: 20)
        self.viewMap.setMinZoom(2.0, maxZoom: 18)
        viewLeftNavigationItems.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LiveRideMapViewController.backButtonClicked(_:))))
        viewRideActionSlider.isUserInteractionEnabled = true
        viewRideActionSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.rideActionSliderViewTapped(_:))))
        labelRideActionTitle.isUserInteractionEnabled = true
        
        viewMoreDetail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.viewMoreDetailTapped(_:))))
        progressSpinner.hidesWhenStopped = true
        initializeDataAndValidate()
        
        let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
        if emergencyContactNo == nil || emergencyContactNo!.isEmpty
        {
            AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
        }
        if AppDelegate.getAppDelegate().getEmergencyInitializer() != nil{
            buttonEmergency.setImage(UIImage(named: "emergency_pressed"), for: UIControl.State.normal)
        }
        RideViewUtils.displaySubscriptionDialogueBasedOnStatus()
        tripInsuranceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.insuranceViewTapped(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(rideObj == nil){
            return
        }
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil {
            goBackToCallingViewController()
            return
        }
        myActiveRidesCache!.addRideUpdateListener(listener: self,key: MyActiveRidesCache.LiveRideMapViewController_key)
        myActiveRidesCache?.delegateForTaxiPool = self
        RideInviteCache.getInstance().addRideInviteStatusListener(rideInvitationUpdateListener: self)
        NotificationStore.getInstance().addNotificationListChangeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey, listener: self)
        if rideObj?.rideType == Ride.RIDER_RIDE {
            NotificationCenter.default.addObserver(self, selector: #selector(checkLocationUpdateStatusAndDisplayAlert), name: .locationUpdateSatatus, object: nil)
            checkLocationUpdateStatusAndDisplayAlert()
        }
        if rideObj?.status == Ride.RIDE_STATUS_STARTED{
            FaceBookEventsLoggingUtils.logViewedContentEvent(contentType: "", contentData: "LiveRideScreen", contentId: "", currency: "", price: 0)
        }
        viewWalkPath.isHidden = true
        self.viewWalkPathHeightConstraint.constant = 0
        if rideObj?.rideType == Ride.RIDER_RIDE{
            imageViewFindMatchedUser.image = UIImage(named: "find_matched_ridetakers_gray")
            labelInviteMatchedUsers.text = Strings.invite
        }
        else{
            imageViewFindMatchedUser.image = UIImage(named: "find_matched_riders_gray")
            labelInviteMatchedUsers.text = Strings.find_rider
        }
        refreshMapWithNewData()
        handleNotificationCountAndDisplay()
        if self.navigationController != nil{
            AppDelegate.getAppDelegate().log.debug("navigation bar displayed")
            self.navigationController!.isNavigationBarHidden = false
        }
        
        displayFirstRideCreationView()
        if self.rideObj != nil && Ride.RIDER_RIDE == self.rideObj!.rideType && self.rideStatusObj != nil && self.riderRide != nil && RideViewUtils.isPassengerAdditionAllowed(currentRideStatus: self.rideStatusObj!, associatedRiderRide: self.riderRide!)
        {
            self.getMatchingPassengersCountAndDisplay()
        }
        if self.rideObj != nil && Ride.PASSENGER_RIDE == self.rideObj!.rideType && Ride.RIDE_STATUS_REQUESTED == self.rideObj!.status{
            self.getMatchingRidersCountAndDisplay()
        }
        if riderRideId != 0 {
            RidesGroupChatCache.getInstance()?.addRideGroupChatListener(rideId: riderRideId!, listener: self)
            checkNewMessage()
        }
        validateAndGetRideInvites()
        LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
        if inviteDialogue != nil
        {
            inviteDialogue!.displayView()
        }
        else if inviteStatusDialogue != nil
        {
            inviteStatusDialogue!.displayView()
        }
        else if inviteMultipleUsersViewController != nil{
            inviteMultipleUsersViewController!.displayView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        buttonCurrentLoc.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonCurrentLoc.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonGoogleMapNavigation.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonGoogleMapNavigation.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonFreezeUnfreeze.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonFreezeUnfreeze.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        buttonRefresh.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldButton(_:)), for: UIControl.Event.touchDown)
        buttonRefresh.addTarget(self, action:#selector(BaseLiveRideMapViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        ViewCustomizationUtils.addBorderToView(view: buttonPendingNotification, borderWidth: 2.0, color: UIColor.white)
        ViewCustomizationUtils.addBorderToView(view: noOfMatchesAvailable, borderWidth: 2.0, color: UIColor.white)
        viewUserDetail.addShadow()
        riderDetailViewForPassenger.addShadow()
        viewJoinedMembers.addShadow()
        viewFindMatchedRidersAfterJoin.addShadow()
        viewRideActionSlider.addShadow()
        viewArrivalOrPickupTime.addShadow()
        passengerDetailViewForRider.addShadow()
        viewSeperator.dropShadow(color: UIColor.lightGray, opacity: 0.3, offSet: CGSize(width: -1, height: 1), radius: 1, scale: true, cornerRadius: 0)
        ViewCustomizationUtils.addCornerRadiusToView(view: riderDetailViewForPassenger, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: viewJoinedMembers, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: viewFindMatchedRidersAfterJoin, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: passengerDetailViewForRider, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: viewUserDetail, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: viewRideActionSlider, cornerRadius: 10.0)
        buttonMenu.changeBackgroundColorBasedOnSelection()
        buttonChat.changeBackgroundColorBasedOnSelection()
        buttonNoticicationIcon.changeBackgroundColorBasedOnSelection()
        ViewCustomizationUtils.addCornerRadiusToView(view: tripInsuranceView, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: tripInsuranceView, borderWidth: 1.0, color: UIColor(netHex: 0x007AFF))
            showGreetingBasedOnCriteria()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if inviteDialogue != nil {
            self.inviteDialogue?.removeSuperView()
        }
        if inviteStatusDialogue != nil {
            self.inviteStatusDialogue?.removeSuperView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func HoldButton(_ sender: UIButton){
        sender.backgroundColor = UIColor.lightGray
    }
    
    @objc func HoldRelease(_ sender: UIButton){
        sender.backgroundColor = UIColor.white
    }
    
    func handleVisibilityForFreezeIcon(){
        if rideObj?.rideType == Ride.RIDER_RIDE{
            let freezeRide = (self.rideObj as! RiderRide).freezeRide
            
            if freezeRide{
                self.buttonFreezeUnfreeze.isHidden = false
                btnFreezeUnfreezeWidthConstraint.constant = 40
                btnCurrentLocTrailingConstraint.constant = 20
                inviteMatchedUsersView.isHidden = true
                lockView.isHidden = false
                self.buttonFreezeUnfreeze.setImage(UIImage(named: "Unlock"), for: .normal)
            }else{
                inviteMatchedUsersView.isHidden = false
                lockView.isHidden = true
                if rideObj != nil && rideObj!.rideType == Ride.RIDER_RIDE && (rideObj as! RiderRide).vehicleType == Vehicle.VEHICLE_TYPE_CAR  && rideParticipantsObject.count > 2{
                    self.buttonFreezeUnfreeze.isHidden = false
                    btnFreezeUnfreezeWidthConstraint.constant = 40
                    btnCurrentLocTrailingConstraint.constant = 20
                    self.buttonFreezeUnfreeze.setImage(UIImage(named: "freeze_lock"), for: .normal)
                    
                }else{
                    btnFreezeUnfreezeWidthConstraint.constant = 0
                    btnCurrentLocTrailingConstraint.constant = 0
                    self.buttonFreezeUnfreeze.isHidden = true
                }
            }
        } else {
            inviteMatchedUsersView.isHidden = false
            lockView.isHidden = true
            self.buttonFreezeUnfreeze.isHidden = true
            btnFreezeUnfreezeWidthConstraint.constant = 0
            btnCurrentLocTrailingConstraint.constant = 0
        }
    }
    
    func handleNotificationCountAndDisplay(){
        let pendingNotificationCount =  NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0{
            buttonPendingNotification.isHidden = false
            buttonPendingNotification.setTitle(String(pendingNotificationCount), for: .normal)
        }else{
            buttonPendingNotification.isHidden = true
        }
        let notificationsMap = NotificationStore.getInstance().getAllNotifications()
        if notificationsMap.isEmpty{
            viewNotification.isHidden = true
        }
        else{
            viewNotification.isHidden = false
        }
    }
    
    @IBAction func notificationIconTapped(_ sender: Any) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }
    
    @objc func rideActionSliderViewTapped(_ gesture : UITapGestureRecognizer){
        UIApplication.shared.keyWindow?.makeToast(message: Strings.rideview_swipe_arrow_LeftToRight, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
    }
    
    @objc func rideActionSliderSlided(_ gesture : UIPanGestureRecognizer){
        
        if (gesture.state == UIGestureRecognizer.State.began) {
            rideActionLabelCenter = gesture.view!.center
            startRideActionSlideArrowCenter = startRideAnimationView.center
        } else if (gesture.state == UIGestureRecognizer.State.changed) {
            let translate = gesture.translation(in: gesture.view)
            gesture.view!.center = CGPoint(x: rideActionLabelCenter.x + translate.x, y: rideActionLabelCenter.y)
            startRideAnimationView.center = CGPoint(x: startRideActionSlideArrowCenter.x + translate.x, y: startRideActionSlideArrowCenter.y)
            if startRideAnimationView.center.x > self.viewRideActionSlider.frame.width{
                startRideAnimationView.center.x = self.viewRideActionSlider.frame.width - 20
                gesture.view!.center.x = startRideAnimationView.center.x - 70
            }
            if gesture.view!.center.x < self.viewRideActionSlider.frame.origin.x{
                gesture.view!.center.x = self.viewRideActionSlider.frame.origin.x + 30
                startRideAnimationView.center.x = gesture.view!.center.x + 70
                
            }
        } else if (gesture.state == UIGestureRecognizer.State.ended ) {
            
            if startRideAnimationView.center.x > self.viewRideActionSlider.frame.width*BaseLiveRideMapViewController.slideThersoldPercentage{
                gesture.view!.center = self.rideActionLabelCenter
                performRideAction(rideAction: labelRideActionTitle.text)
            }
            startRideAnimationView.center = startRideActionSlideArrowCenter
            labelRideActionTitle.center = rideActionLabelCenter
        }
    }
    
    func performRideAction(rideAction: String?){
        AppDelegate.getAppDelegate().log.debug("performRideAction()")
        if rideObj == nil{
            return
        }
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(message: Strings.DATA_CONNECTION_NOT_AVAILABLE, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
            return
        }
        if rideAction == Strings.start_action_caps
        {
            
            if DateUtils.isTargetTimeWithInBoundary(startTime: rideObj!.startTime, boundaryInMins: 60) == false{
                UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_not_qualified_to_start, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
                return
            }
            
            RideManagementUtils.startRiderRide(rideId: self.rideObj!.rideId, rideComplteAction: self, viewController: self)
        }
        else if rideAction == Strings.checkin_action_caps || rideAction == Strings.pre_checkin_action_caps
        {
            if DateUtils.isTargetTimeWithInBoundary(startTime: (rideObj as! PassengerRide).pickupTime, boundaryInMins: 60) == false{
                UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_not_qualified_to_start, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
                return
            }
            RideManagementUtils.startPassengerRide(passengerRideId: self.rideObj!.rideId, riderRideId: (self.rideObj as! PassengerRide).riderRideId, rideCompleteAction: self, viewController: self)
        }
        else if rideAction == Strings.stop_action_caps
        {
            
            let passengerToPickup = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerToPickUp(riderRideId: riderRideId!)
            if passengerToPickup == nil || passengerToPickup!.isEmpty{
                
                RideManagementUtils.completeRiderRide(riderRideId: self.rideObj!.rideId, targetViewController: self,rideActionCompletionDelegate: self)
            }else{
                let passengerPickUpViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "PassengersToPickupViewController") as! PassengersToPickupViewController
                passengerPickUpViewController.initializeDataBeforePresenting(riderRideId: rideObj!.rideId,  ride: rideObj, passengerToBePickup: passengerToPickup!, passengerPickupDelegate: self)
                self.view.addSubview(passengerPickUpViewController.view)
                self.addChild(passengerPickUpViewController)
                passengerPickUpViewController.view.layoutIfNeeded()
            }
            
            
        }
        else if rideAction == Strings.checkout_action_caps
        {
            completePassengerRide()
        }
        
    }
    
    func completePassengerRide() {
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
        let passengerRide = rideObj as! PassengerRide
        if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0  {
            RideManagementUtils.completePassengerRide(riderRideId: (self.rideObj as! PassengerRide).riderRideId, passengerRideId: self.rideObj!.rideId, userId: self.rideObj!.userId, targetViewController: self,rideCompletionActionDelegate: self)
        } else {
            
            let rideStatus : RideStatus = RideStatus(rideId: rideObj!.rideId, userId: rideObj!.userId, status: Ride.RIDE_STATUS_COMPLETED, rideType: Ride.PASSENGER_RIDE,joinedRideId:riderRideId, joinedRideStatus: nil)
            MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
            ClearRideDataAsync().clearRideData(rideStatus: rideStatus)
            RideManagementUtils.getPassengerBill(riderRideId: passengerRide.taxiRideId!, passengerRideId: rideObj!.rideId, userId: rideObj!.userId, targetViewController: self, rideCompletionActionDelegate: self)
            
        }
    }
    
    func continueRefreshAction() {
        if rideObj?.rideType == Ride.PASSENGER_RIDE {
            if (rideObj as! PassengerRide).riderRideId == 0{
                let syncPassengerActiveRideTask = SyncPassengerActiveRideTask(userId: rideObj!.userId, rideId: rideObj!.rideId , status: rideObj!.status, passengerActiveRideReceive: { (passengerRide) in
                    if passengerRide != nil
                    {
                        self.syncPassengerData(passengerRide : passengerRide!)
                    }
                    self.refreshButtonAnimationView.isHidden = true
                    self.refreshButtonAnimationView.animationView.stop()
                })
                syncPassengerActiveRideTask.getPassengerRide()
            }else{
                MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoFromServer(riderRideId: (rideObj as! PassengerRide).riderRideId, myRidesCacheListener: self)
            }
        }else{
            MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoFromServer(riderRideId: rideObj!.rideId, myRidesCacheListener: self)
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        refreshButtonAnimationView.isHidden = false
        refreshButtonAnimationView.animationView.setAnimation(named: "loading_refresh")
        refreshButtonAnimationView.animationView.play()
        refreshButtonAnimationView.animationView.loopAnimation = true
        QRReachability.isInternetAvailable { (isConnectedToNetwork) in
            if !isConnectedToNetwork{
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                self.refreshButtonAnimationView.isHidden = true
                self.refreshButtonAnimationView.animationView.stop()
            }else{
                if self.rideObj == nil{
                    self.refreshButtonAnimationView.isHidden = true
                    self.refreshButtonAnimationView.animationView.stop()
                    return
                }
                self.continueRefreshAction()
                
            }
        }
        
    }
    
    func syncPassengerData( passengerRide: PassengerRide)
    {
        if passengerRide.riderRideId != 0{
            let newRideStatus = RideStatus(passengerRide: passengerRide)
            MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: newRideStatus)
        }
        
    }
    
    func displayNoConnectionDialogue(){
        InternetTrackerUtils().checkInternetAvailability(viewController: self) { (value) in
            if value{
                self.viewWalkPath.isHidden = true
                self.viewWalkPathHeightConstraint.constant = 0
            }
            else{
                if self.rideObj?.rideType == Ride.PASSENGER_RIDE && (self.rideObj?.status == Ride.RIDE_STATUS_SCHEDULED || self.rideObj?.status == Ride.RIDE_STATUS_STARTED || self.rideObj?.status == Ride.RIDE_STATUS_DELAYED) && !self.isWalkPathViewHidden{
                    if self.isMapFullView == nil || !self.isMapFullView!{
                        self.viewWalkPath.isHidden = false
                    }
                    self.viewWalkPathHeightConstraint.constant = 40
                }
                else{
                    self.viewWalkPath.isHidden = true
                    self.viewWalkPathHeightConstraint.constant = 0
                }
            }
        }
    }
    
    func displayFirstRideCreationView(){
        if self.isFromSignupFlow {
            self.viewFirstRideCreatedInfo.isHidden = false
            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0x00b557)
            self.labelFirstRideInfo1.text = "Cool! You have created your first ride"
            self.labelFirstRideInfo2.text = "Finding rides for you..."
            firstRideAnimationView.animationView.setAnimation(named: "signup_like")
            firstRideAnimationView.animationView.play()
            firstRideAnimationView.animationView.loopAnimation = true
            self.riderDetailViewForPassenger.isHidden = true
            self.viewUserDetail.isHidden = true
            self.buttonGoogleMapNavigation.isHidden = true
            self.buttonEmergency.isHidden = true
            self.buttonFreezeUnfreeze.isHidden = true
            self.viewNavigationBarItems.isHidden = true
            self.viewMoreDetail.isHidden = true
            self.buttonRefresh.isHidden = true
        }
        else{
            self.unhidingOfUtilities()
            displayNoConnectionDialogue()
        }
    }
    func unhidingOfUtilities(){
        self.isFromSignupFlow = false
        firstRideAnimationView.animationView.stop()
        self.viewFirstRideCreatedInfo.isHidden = true
        self.buttonGoogleMapNavigation.isHidden = false
        self.viewNavigationBarItems.isHidden = false
        self.viewMoreDetail.isHidden = false
        self.viewUserDetail.isHidden = false
        self.buttonRefresh.isHidden = false
        if rideObj?.rideType == Ride.RIDER_RIDE{
            viewRideActionSlider.isHidden = false
        }
    }
    
    func initializeDataAndValidate(){
        AppDelegate.getAppDelegate().log.debug("initializeDataAndValidate()")
        if riderRideId == 0{
            if rideObj?.rideType == Ride.RIDER_RIDE {
                riderRideId = rideObj?.rideId
            } else if rideObj?.rideType == Ride.PASSENGER_RIDE {
                let passengerRide = rideObj as! PassengerRide
                if !isTaxiRide(ride: passengerRide){
                    riderRideId = passengerRide.riderRideId
                } else {
                    taxiRideId = passengerRide.taxiRideId
                }
            }
        }else {
            if RideViewUtils.isRideClosed(riderRideId: riderRideId!){
                displayRideClosedDialogue()
                return
            }
        }
        
        self.getInputData()
    }
    
   private func isTaxiRide(ride: PassengerRide) -> Bool {
        if ride.taxiRideId == 0 || ride.taxiRideId == nil {
            return false
        } else {
            taxiRideId = ride.taxiRideId
            return true
        }
    }

    func goBackToCallingViewController(){
        AppDelegate.getAppDelegate().log.debug("goBackToCallingViewController()")
        let myActiveRidesCache : MyActiveRidesCache? =  MyActiveRidesCache.singleCacheInstance
        if myActiveRidesCache != nil{
            myActiveRidesCache!.removeRideUpdateListener(key: MyActiveRidesCache.LiveRideMapViewController_key)
        }
        RideInviteCache.getInstance().removeRideInviteStatusListener()
        NotificationStore.getInstance().removeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
        removeListeners()
        clearAllDetails()
        if (self.navigationController != nil) {
            self.navigationController!.popViewController(animated: false)
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
        BaseLiveRideMapViewController.baseLiveRideMapViewController = nil
    }
    func clearAllDetails()
    {
        clearRoute()
        viewMap?.delegate = nil
        AppDelegate.appDelegate?.log.debug("routeNavigationMarker set to nil")
        riderRide = nil
        startRideAnimationView.animationView.stop()
    }
    func getInputData(){
        AppDelegate.getAppDelegate().log.debug("getInputData()")
        self.userId = Double((QRSessionManager.getInstance()?.getUserId())!)
        if riderRideId == 0 {
            if taxiRideId != 0{
                handleScheduleRide()
            } else {
                handleRequestedRide()
            }
        }else{
            handleScheduleRide()
        }
    }
    
    func handleEditRoute(){
        if rideObj == nil{
            return
        }
        let duration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: rideObj!.expectedEndTime, time2: rideObj!.startTime)
        let rideRoute = RideRoute(routeId: rideObj!.routeId!,overviewPolyline : rideObj!.routePathPolyline,distance :rideObj!.distance!,duration : Double(duration), waypoints : rideObj!.waypoints)
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: rideObj!, rideRoute:rideRoute , routeSelectionDelegate: self)
        self.navigationController?.pushViewController(routeSelectionViewController, animated: false)
    }
    
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.updateRideRoute(rideId: rideObj!.rideId, rideType: rideObj!.rideType!, rideRoute: route, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let updatedRoute = Mapper<RideRoute>().map(JSONString: responseObject!["resultData"] as! String)
                
                if updatedRoute != nil{
                    MyActiveRidesCache.getRidesCacheInstance()?.updateRideRoute(rideRoute: updatedRoute!, rideId: self.rideObj!.rideId, rideType: self.rideObj!.rideType!)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self,handler: nil)
            }
        }
    }
    
    func handleRequestedRide(){
        AppDelegate.getAppDelegate().log.debug("handleRequestedRide()")
        let passengerRideId = rideObj?.rideId
        rideObj =  MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: passengerRideId!)
        self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
        progressSpinner.isHidden = true
        progressSpinner.stopAnimating()
        if(rideObj == nil){
            goBackToCallingViewController()
        }else{
            handleRequestedRideIfAvailable()
        }
    }
    func handleRequestedRideIfAvailable(){
        syncRideInvitesOfRide()
        self.rideStatusObj = rideObj!.prepareRideStatusObject()
        rideStatusObj?.status = Ride.RIDE_STATUS_REQUESTED
        riderRide = nil
        receivePassengerDetailInfo()
        validateAndGetRideInvites()
        handleVisibilityForFreezeIcon()
    }
    
    private func handleScheduleRide(){
        if taxiRideId == 0{
        MyActiveRidesCache.singleCacheInstance?.getRideDetailInfo(riderRideId: self.riderRideId!, myRidesCacheListener: self)
        
        participantLocationListener = ParticipantLocationListener()
        participantLocationListener!.subscribeToLocationUpdatesForRide(rideId: riderRideId!)
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        if(isRideDetailInfoRetrieved == false){
            let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoInOffline(riderRideId: riderRideId!)
            updateRideViewMapWithRideData(rideDetailInfo: rideDetailInfo)
            progressSpinner.isHidden = false
            progressSpinner.startAnimating()
            validateAndGetRideInvites()
            }
        } else {
            QuickRideProgressSpinner.startSpinner()
            MyActiveRidesCache.singleCacheInstance?.getTaxiDetailInfo(taxiRideId: taxiRideId!, passengerRideId: rideObj?.rideId ?? 0, myRidesCacheListener: self)
        }
    }

    @objc func checkLocationUpdateStatusAndDisplayAlert() {
        DispatchQueue.main.async {
            let locationStatus = LocationChangeListener.getInstance().currentLocationUpdateStatus
            if locationStatus == LocationStatus.LocationDenied {
                self.displayWarningAlert(backGroundColor: UIColor.red, warningIncon: UIImage(named: "location_off_icon") ?? UIImage(), warningTitle: Strings.location_service_off_title, warningMessage: Strings.location_service_off_msg, actionMessage: Strings.go_to_settings)
            } else if locationStatus == LocationStatus.BatteryCriticallyLow {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = false
                self.batteryCriticallyLowView.isHidden = false
                ViewCustomizationUtils.addCornerRadiusToView(view: self.lowBatteryImageView, cornerRadius: self.lowBatteryImageView.frame.height / 2)
                ViewCustomizationUtils.addCornerRadiusToView(view: self.batteryCriticallyLowView, cornerRadius: 8.0)
            } else if locationStatus == LocationStatus.BatteryLow {
                self.displayWarningAlert(backGroundColor: UIColor(netHex: 0xE7782F), warningIncon: UIImage(named: "battery_low_warning") ?? UIImage(), warningTitle: Strings.phone_battery_low_title, warningMessage: Strings.phone_battery_low_msg, actionMessage: nil)
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            } else if locationStatus == LocationStatus.BatteryOk {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            } else {
                self.warningAlert?.removeFromSuperview()
                self.batteryCriticallyLowBackgroundView.isHidden = true
                self.batteryCriticallyLowView.isHidden = true
            }
        }
    }
    
    private func displayWarningAlert(backGroundColor : UIColor,warningIncon : UIImage,warningTitle : String? ,warningMessage : String?, actionMessage: String?) {
        self.warningAlert?.removeFromSuperview()
        self.batteryCriticallyLowBackgroundView.isHidden = true
        self.batteryCriticallyLowView.isHidden = true
        warningAlert = Bundle.main.loadNibNamed("WarningAlertView", owner: self, options: nil)?[0] as? WarningAlertView
        warningAlert!.frame = CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: 88)
        warningAlert!.initializeViews(backGroundColor: backGroundColor, warningIncon: warningIncon, warningTitle: warningTitle, warningMessage: warningMessage, actionMessage: actionMessage, handler: { (action) in
            if action == Strings.go_to_settings {
                if let settingsUrl = NSURL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl as URL) {
                    UIApplication.shared.open(settingsUrl as URL, options: [:], completionHandler: nil)
                }
            }
        })
        view.addSubview(warningAlert!)
        view!.layoutIfNeeded()
    }
    
    private func receivePassengerDetailInfo()
    {
        self.rideParticipantsObject.removeAll()
        self.loadParticipantImages()
        self.rideParticipantLocationObject.removeAll()
        self.updateRideViewControlsAsPerStatus()
        self.displayRideScheduledTime()
        self.displayRideStatusAndFareDetailsToUser(status: Ride.RIDE_STATUS_REQUESTED)
        getMatchingRidersCountAndDisplay()
        
        refreshMapWithNewData()
    }
    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) {
        QuickRideProgressSpinner.stopSpinner()
        if rideDetailInfo.offlineData{
            isRideDetailInfoRetrieved = true
            progressSpinner.isHidden = false
            progressSpinner.startAnimating()
        }
        else{
            isRideDetailInfoRetrieved = true
            progressSpinner.isHidden = true
            progressSpinner.stopAnimating()
        }
        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()
        if rideDetailInfo.rideParticipants != nil && !rideDetailInfo.rideParticipants!.isEmpty{
            let userId = Double(QRSessionManager.getInstance()!.getUserId())
            let currentRideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: userId!, rideParticipants: rideDetailInfo.rideParticipants)
            if currentRideParticipant == nil{
                self.displayRideClosedDialogue()
                return
            }else if currentRideParticipant != nil && Ride.RIDE_STATUS_COMPLETED == currentRideParticipant?.status{
                self.rideObj = rideDetailInfo.currentUserRide
                if taxiRideId == 0{
                self.riderRide = rideDetailInfo.riderRide
                } else {
                    self.taxiShareRide = rideDetailInfo.taxiShareRide
                }
                if rideObj!.rideType == Ride.PASSENGER_RIDE{
                    completePassengerRide()
                    return
                }
            }
        }
        
        updateRideViewMapWithRideData(rideDetailInfo: rideDetailInfo)
        MyActiveRidesCache.singleCacheInstance?.addRideUpdateListener(listener: self,key: MyActiveRidesCache.LiveRideMapViewController_key)
        RideInviteCache.getInstance().addRideInviteStatusListener(rideInvitationUpdateListener: self)
        if !rideDetailInfo.offlineData{
            if rideDetailInfo.rideParticipantLocations != nil && !rideDetailInfo.rideParticipantLocations!.isEmpty{
                self.isParticipantMarkerLoaded = true
                self.rideParticipantLocationObject = rideDetailInfo.rideParticipantLocations!
                self.loadRideParticipantMarkers()
            }else{
            MyActiveRidesCache.getRidesCacheInstance()?.getRideParticipantLocationAndRefresh(riderRideId: rideDetailInfo.riderRideId!, handler: { (participantLocations) in
                self.isParticipantMarkerLoaded = true
                    if participantLocations != nil{
                        self.rideParticipantLocationObject = participantLocations!
                    }
                    self.loadRideParticipantMarkers()
                })
            }
            startTimer()
        }
        if isFreezeRideRequired
        {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.freeze_ride_alert_title, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self) { (result) in
                if result == Strings.yes_caps{
                    self.handleFreeze(freezeRide: true, rideDetailInfo : rideDetailInfo)
                }
                
            }
            self.isFreezeRideRequired = false
        }
    }
    
    private func handleTaxiPoolUIWithData() {
        
        if rideParticipantsObject.isEmpty || rideObj == nil{
            return
        }
        viewUserDetail.isHidden = true
        if isMapFullView == nil || !isMapFullView!{
            mapUtilitiesBottomSpaceConstraint.constant = 140
        }
        self.riderDetailViewForPassenger.isHidden = false
        self.viewJoinedMembers.isHidden = false
        passengersInfo = RideViewUtils.getPasengersInfo(rideParticipants: rideParticipantsObject)
        viewMoreDetail.isHidden = true
        viewMoreHeightConstraint.constant = 0
        viewRideActionSlider.isHidden = true
        taxiWillAllocateView.isHidden = false
        taxiPoolIconImageView.isHidden = false
        joinedMemebersCollectionViewForPassenger.delegate = self
        joinedMemebersCollectionViewForPassenger.dataSource = self
        joinedMemebersCollectionViewForPassenger.isHidden = false
        joinedMemebersCollectionViewForPassenger.reloadData()
        joinedMemberViewHeightConstraint.constant = 105
        
        joinedMemberSubtitleLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        joinedMemberSubtitleLabel.textColor = UIColor.black.withAlphaComponent(1)
        rideModeratorButton.isHidden = true
        riderCallButton.isHidden = true
        riderChatButton.isHidden = true
        taxiRideRiderHeaderLabel.text = Strings.taxi_details.capitalized
        taxiRideRiderHeaderLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        taxiRideRiderHeaderLabel.font = UIFont(name: "Roboto-Medium", size: 16)
        
        imageViewRider.image = UIImage(named: "taxi_car_icon")
        labelRiderRideStatus.font = UIFont(name: "Roboto-Bold", size: 16)
        labelRiderRideStatus.textColor = .black
        labelRiderRideStatus.text = taxiShareRide?.shareType
        pickUpImageView.isHidden = false
        let pickUptime = getPickUPTime(taxiShareRide: taxiShareRide!)
        let addedTimeRangeTime = DateUtils.addMinutesToTimeStamp(time: pickUptime, minutesToAdd: ConfigurationCache.getObjectClientConfiguration().taxiPickUpTimeRangeInMins)
        labelRiderName.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickUptime, timeFormat: DateUtils.TIME_FORMAT_hh_mm)! + "-" + DateUtils.getTimeStringFromTimeInMillis(timeStamp: addedTimeRangeTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        taxiPoolPriceShowingLabel.isHidden = false
        taxiPoolPriceShowingLabel.text = getPriceOfTaxi()
        nextBtnForTaxiPool.isHidden = false
        
        if Int(taxiShareRide!.availableSeats!) != 0{
            taxiPoolHeaderLabel.text = updateTaxiPoolStatus() + "!"
            joinedMemberSubtitleLabel.text = String(format: Strings.more_seats_to_confirm_taxipool,arguments: [String(Int(taxiShareRide!.availableSeats!))])
        }else{
            
            if taxiShareRide?.driverName != nil && taxiShareRide?.driverName != "" {
                
                taxiRideRiderHeaderLabel.text = updateTaxiPoolStatus() + "!"
                taxiRideRiderHeaderLabel.textColor = UIColor.black
                taxiRideRiderHeaderLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                let pickupTime = getPickUPTime(taxiShareRide: taxiShareRide!)
                joinedMemberSubtitleLabel.text = "Your pickup will be at " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
                joinedMemberViewHeightConstraint.constant = 85
                taxiWaitingForConfirmationView.isHidden = true
                rideactionSlideViewHeightConstrints.constant = 0
                riderDetailsHeightConstraint.constant = 110
                taxiPoolPriceShowingLabel.isHidden = true
                labelRiderRideStatus.text = taxiShareRide?.driverName
                pickUpImageView.isHidden  = true
                labelRiderName.text  = "\(taxiShareRide?.vehicleModel ?? "") - \(taxiShareRide?.vehicleNumber ?? "")"
                labelRiderName.textColor = UIColor.black.withAlphaComponent(0.8)
                labelRiderName.font = UIFont(name: "Roboto-Regular", size: 12)
                
                labelVehicleName.font = UIFont(name: "Roboto-Medium", size: 12)
                labelVehicleName.textColor = .black
                labelVehicleName.text = "\(taxiShareRide?.shareType ?? "")-" + getPriceOfTaxi()
                if taxiShareRide?.driverImageURI == "" ||  taxiShareRide?.driverImageURI == nil {
                    imageViewRider.image = UIImage(named: "default_taxi_driver")
                }else{
                    ImageCache.getInstance().setImageToView(imageView: imageViewRider, imageUrl: taxiShareRide?.driverImageURI, gender: "U",imageSize: ImageCache.DIMENTION_SMALL)
                }
                viewRideActionSlider.isHidden = true
                riderCallButton.isHidden = false
            }else{
                taxiPoolHeaderLabel.text = ""
                joinedMemberSubtitleLabel.text = updateTaxiPoolStatus() + "!"
            }
        }
    }
    
    @IBAction func nextStepBtnPressed(_ sender: UIButton) {
         let taxiPoolIntroduction = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolIntroductionViewController") as! TaxiPoolIntroductionViewController
        taxiPoolIntroduction.initialisationBeforeShowing(ride: rideObj, taxiSharedRide: taxiShareRide, delegate: nil)
             self.navigationController?.pushViewController(taxiPoolIntroduction, animated: false)
    }
    
    private func getPickUPTime(taxiShareRide: TaxiShareRide) -> Double{
        for data in taxiShareRide.taxiShareRidePassengerInfos ?? [] {
            if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0"){
                return data.pickUpTime ?? 0
            }
        }
        return 0
    }
    
     private func updateTaxiPoolStatus() -> String {
         if let taxiShareRide = taxiShareRide {
             switch taxiShareRide.status {
             case TaxiShareRide.TAXI_SHARE_RIDE_STARTED :
                 return Strings.taxi_started
             case TaxiShareRide.TAXI_SHARE_RIDE_DELAYED :
                 return Strings.taxi_delayed
             case TaxiShareRide.TAXI_SHARE_RIDE_BOOKING_IN_PROGRESS, TaxiShareRide.TAXI_SHARE_RIDE_SUCCESSFUL_BOOKING,TaxiShareRide.TAXI_SHARE_RIDE_POOL_IN_PROGRESS :
                 return Strings.joined_taxipool
             case TaxiShareRide.TAXI_SHARE_RIDE_ALLOTTED,TaxiShareRide.TAXI_SHARE_RIDE_RE_ALLOTTED,TaxiShareRide.TAXI_SHARE_RIDE_POOL_CONFIRMED :
                 return Strings.taxi_pool_confirm
             case TaxiShareRide.TAXI_SHARE_RIDE_ARRIVED :
                 return Strings.taxi_arrived
             default:
                 return Strings.joined_taxipool
             }
         }else { return "" }
     }
    
    private func getPriceOfTaxi() -> String {
        for data in taxiShareRide?.taxiShareRidePassengerInfos ?? [] {
            if data.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0"){
                    return "\(Int(data.initialFare ?? 0)) Pts"
            }
        }
         return ""
    }

    func handleFreeze(freezeRide : Bool, rideDetailInfo : RideDetailInfo)
    {
        QuickRideProgressSpinner.startSpinner()
        RiderRideRestClient.freezeRide(rideId: rideDetailInfo.riderRide!.rideId, freezeRide: freezeRide, targetViewController: nil, complitionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                MyRidesPersistenceHelper.updateRiderRide(riderRide: self.rideObj as! RiderRide)
                NotificationStore.getInstance().removeInvitationWithGroupNameAndGroupValue(groupName: UserNotification.NOT_GRP_RIDER_RIDE, groupValue: StringUtils.getStringFromDouble(decimalNumber : rideDetailInfo.riderRide!.rideId))
                let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideDetailInfo.riderRide!.rideId)
                if riderRide != nil{
                    riderRide!.freezeRide = true
                    MyActiveRidesCache.getRidesCacheInstance()?.activeRiderRides![riderRide!.rideId] = riderRide
                }
                UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_freezed, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
                self.handleFreezeRide(freezeRide : true)
                
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil,handler: nil)
            }
        })
    }
    
    func handleFreezeRide(freezeRide : Bool)
    {
        
        if !freezeRide
        {
            inviteMatchedUsersView.isHidden = false
            lockView.isHidden = true
            if rideObj != nil && rideObj!.rideType == Ride.RIDER_RIDE && (rideObj as! RiderRide).vehicleType == Vehicle.VEHICLE_TYPE_CAR && rideParticipantsObject.count > 2{
                self.buttonFreezeUnfreeze.isHidden = false
                btnFreezeUnfreezeWidthConstraint.constant = 40
                btnCurrentLocTrailingConstraint.constant = 20
                self.buttonFreezeUnfreeze.setImage(UIImage(named: "freeze_lock"), for: .normal)
                
            }else{
                btnFreezeUnfreezeWidthConstraint.constant = 0
                btnCurrentLocTrailingConstraint.constant = 0
                self.buttonFreezeUnfreeze.isHidden = true
            }
        }
        else
        {
            inviteMatchedUsersView.isHidden = true
            lockView.isHidden = false
            self.buttonFreezeUnfreeze.isHidden = false
            btnFreezeUnfreezeWidthConstraint.constant = 40
            btnCurrentLocTrailingConstraint.constant = 20
            self.buttonFreezeUnfreeze.setImage(UIImage(named: "Unlock"), for: .normal)
        }
    }
    
    func getNextPassengerToPickup() -> RideParticipant?{
        if rideParticipantsObject.isEmpty{
            return nil
        }
        var nextPassengerToPickup : RideParticipant?
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider || (Ride.RIDE_STATUS_SCHEDULED != rideParticipant.status && Ride.RIDE_STATUS_DELAYED != rideParticipant.status)
            {
                continue
            }
            if (nextPassengerToPickup == nil) || (Double(nextPassengerToPickup!.pickUpTime!) > Double(rideParticipant.pickUpTime!)){
                nextPassengerToPickup = rideParticipant
            }
        }
        return nextPassengerToPickup
    }
    
    @objc func vehicleNumberTapped(_ sender: UITapGestureRecognizer){
        
        if riderRide == nil{
            return
        }
        let vehicle = Vehicle(ownerId:riderRide!.userId,vehicleModel: riderRide!.vehicleModel,vehicleType: riderRide!.vehicleType,registrationNumber: riderRide!.vehicleNumber,capacity: riderRide!.capacity,fare: riderRide!.farePerKm,makeAndCategory: riderRide!.makeAndCategory,additionalFacilities: riderRide!.additionalFacilities,riderHasHelmet : riderRide!.riderHasHelmet)
        
        vehicle.imageURI = riderRide!.vehicleImageURI
        let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
        vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: vehicle)
        self.navigationController?.pushViewController(vehicleDisplayViewController, animated: false)
        
    }
    
    
    func refreshMapWithNewData()
    {
        viewMap.delegate = self
        self.viewMap.clear()
        routeNavigationMarker?.map = nil
        routeNavigationMarker = nil
        clearLocationUpdateMarker()
        AppDelegate.appDelegate?.log.debug("routeNavigationMarker set to nil")
        self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
        viewMap.isMyLocationEnabled = false
        if(rideObj!.rideType == Ride.PASSENGER_RIDE && rideObj!.status == Ride.RIDE_STATUS_REQUESTED ){
            drawRoutePathAndAddMarkersForRequestedRide()
        }else{
            drawRoutePathAndAddMarkersForScheduledRide()
        }
        perform(#selector(BaseLiveRideMapViewController.fitToScreenAfterDelay), with: self, afterDelay: 0.5)
        viewMap.isTrafficEnabled = false
        if taxiRideId == 0 {
            checkAndShowRideModerationIcon()
        }
    }
    
    private func showGreetingBasedOnCriteria(){
        if taxiRideId != 0 {
            return
        }
        if UserDataCache.getInstance() == nil {
            return
        }
        var type : String?
        if rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.status  == Ride.RIDE_STATUS_SCHEDULED {
            if !UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.WELCOME_GREETING) && (SharedPreferenceHelper.getRideId() == nil || SharedPreferenceHelper.getRideId() != rideObj!.rideId){
                type = Strings.welcome
            }
        }else if rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.status == Ride.RIDE_STATUS_STARTED {
            if !UserDataCache.getInstance()!.getEntityDisplayStatus(key: UserDataCache.THANKYOU_GREETING) && (SharedPreferenceHelper.getRiderRideId() == nil || SharedPreferenceHelper.getRiderRideId() != riderRide?.rideId){
                type = Strings.thank_you_greeting
            }
        }
        
        if type != nil, let greetingDetails = UserCoreDataHelper.getGreetingDetails(type: type!), greetingDetails.displayedCount < 3{
            if type == Strings.welcome{
                SharedPreferenceHelper.storeRideId(rideId: rideObj!.rideId)
                UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.WELCOME_GREETING, status: true)
            } else if type == Strings.thank_you_greeting{
                SharedPreferenceHelper.storeRiderRideId(riderRideId: riderRide?.rideId)
                UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.THANKYOU_GREETING, status: true)
            }
            greetingDetails.displayedCount += 1
            UserCoreDataHelper.saveGreetingDetails(greetingDetails: [greetingDetails])
            if let gifImageURL = greetingDetails.gifImageUrl{
                let greetingDisplayView = GreetingDisplayView.loadFromNibNamed(nibNamed: "GreetingDisplayView",bundle: nil) as! GreetingDisplayView
                DispatchQueue.main.async {
                    ImageCache.getInstance().getGifImageFromCache(gifUrl: gifImageURL) { (image) in
                        if image != nil {
                            let yPosition: CGFloat?
                            if self.isMapFullView != nil && self.isMapFullView!{
                                yPosition = 10
                            } else {
                                yPosition = self.viewWalkPath.frame.origin.y
                            }
                            greetingDisplayView.initializeViews(greetingDetails: greetingDetails, image: image, x: 0, y: yPosition!,viewController: self) {
                                greetingDetails.displayedCount = 3
                                UserCoreDataHelper.saveGreetingDetails(greetingDetails: [greetingDetails])
                            }
                        }
                    }
                }
            }
        }
    }
    @objc func fitToScreenAfterDelay(){
        if rideObj == nil{
            return
        }
        if !zoom {
            let uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 20, left: 20, bottom: 220, right: 40)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: rideObj!.routePathPolyline)!)
            delay(seconds: 0.5) {
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            }
            return
        }
        if rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.status != Ride.RIDE_STATUS_REQUESTED && riderRide?.status == Ride.RIDE_STATUS_STARTED{
            zoomAndShowPassengerRoutePath()
        }
        else if rideObj?.rideType == Ride.RIDER_RIDE && rideObj?.status == Ride.RIDE_STATUS_STARTED{
            zoomAndShowRiderRoutePath()
        }
        else{
            showEntireRoutePath()
        }
    }
    
    func showEntireRoutePath(){
        if isMapFullView == nil || isMapFullView!{
            let uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 20, left: 20, bottom: 220, right: 40)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: rideObj!.routePathPolyline)!)
            delay(seconds: 0.5) {
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            }
        }
    }
    func zoomAndShowPassengerRoutePath(){
        if rideObj == nil || riderRide == nil{
            return
        }
        var startLat = riderRide!.startLatitude
        var startLong = riderRide!.startLongitude
        if rideCurrentLocation != nil {
            startLat = rideCurrentLocation!.latitude
            startLong = rideCurrentLocation!.longitude
        }
        var endLat = (self.rideObj as! PassengerRide).pickupLatitude
        var endLong = (self.rideObj as! PassengerRide).pickupLongitude
        if rideObj!.status == Ride.RIDE_STATUS_STARTED || (etaError != nil && etaError!.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR){
            endLat = (self.rideObj as! PassengerRide).dropLatitude
            endLong = (self.rideObj as! PassengerRide).dropLongitude
        }
        if startLat <= 0 || startLong <= 0 || endLat <= 0 || endLong <= 0{
            showEntireRoutePath()
        }else{
            var uiEdgeInsets: UIEdgeInsets?
            if isMapFullView == true{
                uiEdgeInsets = getUIEdgeInsetsForFullMapView()
            }
            else{
                let deviceWidth = UIScreen.main.bounds.size.width
                if deviceWidth <= 320{
                    uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 60, left: 20, bottom: 260, right: 60)
                }
                else{
                    uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 60, left: 20, bottom: 300, right: 60)
                }
            }
            let routePathToNextPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat, startLong: startLong, endLat: endLat, endLong: endLong, viewMap: viewMap)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToNextPickUP)!)
            delay(seconds: 0.5) {
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets!))
            }
            AppDelegate.getAppDelegate().log.debug("Current zoom level \(self.viewMap.camera.zoom)")
        }
    }
    
    func zoomAndShowRiderRoutePath(){
        let nextPickUpPassenger = RideViewUtils.getRideParticipantObjForParticipantId(participantId: selectedPickupUserId, rideParticipants: rideParticipantsObject)
        if rideObj == nil{
            return
        }
        var startLat = rideObj!.startLatitude
        var startLong = rideObj!.startLongitude
        if rideCurrentLocation != nil {
            startLat = rideCurrentLocation!.latitude
            startLong = rideCurrentLocation!.longitude
        }
        var endLat = rideObj!.endLatitude
        var endLong = rideObj!.endLongitude
        if nextPickUpPassenger != nil && (etaError == nil || etaError!.errorCode != ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR){
            endLat = nextPickUpPassenger!.startPoint!.latitude
            endLong = nextPickUpPassenger!.startPoint!.longitude
        }
        if startLat <= 0 || startLong <= 0 || endLat! <= 0 || endLong! <= 0{
            showEntireRoutePath()
        }else{
            var uiEdgeInsets: UIEdgeInsets?
            if isMapFullView == true{
                uiEdgeInsets = getUIEdgeInsetsForFullMapView()
            }
            else{
                let deviceWidth = UIScreen.main.bounds.size.width
                if deviceWidth <= 320{
                    uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 60, left: 20, bottom: 260, right: 60)
                }
                else{
                    uiEdgeInsets = getUIEdgeInsetsBasedOnRideConstraint(top: 60, left: 20, bottom: 300, right: 60)
                }
            }
            let routePathToNextPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat, startLong: startLong, endLat: endLat!, endLong: endLong!, viewMap: viewMap)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToNextPickUP)!)
            delay(seconds: 0.5) {
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets!))
            }
        }
    }
    
    func drawRoutePathAndAddMarkersForRequestedRide(){
        AppDelegate.getAppDelegate().log.debug("drawRoutePathAndAddMarkersForRequestedRide()")
        if rideObj == nil{
            return
        }
        let start = CLLocationCoordinate2D(latitude: rideObj!.startLatitude, longitude: rideObj!.startLongitude)
        let end = CLLocationCoordinate2D(latitude: (rideObj?.endLatitude)!, longitude: (rideObj?.endLongitude)!)
        routePathPolyline = GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start,end : end,route: (rideObj?.routePathPolyline)!, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_5)
    }
    
    func drawRoutePathAndAddMarkersForScheduledRide()
    {
        AppDelegate.getAppDelegate().log.debug("drawRoutePathAndAddMarkersForScheduledRide()")
        loadParticipantImages()

        if Ride.PASSENGER_RIDE == rideObj?.rideType {
        
            let passengerRide = rideObj as! PassengerRide
            if passengerRide.taxiRideId != nil && taxiShareRide != nil {
                GoogleMapUtils.drawPassengerPathWithDrop(riderRoutePolyline: taxiShareRide?.routePathPolyline ?? "", passengerRide: passengerRide, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_7)
                return
        }

            if riderRide != nil {
                if isModerator {
                    isWalkPathViewHidden = true
                    viewWalkPath.isHidden = true
                    self.viewWalkPathHeightConstraint.constant = 0
                    let start = CLLocationCoordinate2D(latitude: riderRide!.startLatitude, longitude: riderRide!.startLongitude)
                    let end = CLLocationCoordinate2D(latitude: riderRide!.endLatitude!, longitude: riderRide!.endLongitude!)
                    routePathPolyline = GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start, end: end, route: (riderRide?.routePathPolyline)!, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_7)
                    handleETAToRider()
                } else {
                    let passengerRide = rideObj as! PassengerRide
                    routePathPolyline = GoogleMapUtils.drawPassengerPathFromPickToDrop(riderRoutePolyline: riderRide!.routePathPolyline,passengerRide: passengerRide, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_7)
                    showPassengerPickUpMarker(passengerRide: passengerRide)
                    GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: passengerRide.rideId, useCase: "iOS.App.Passenger.WalkRoute.RideView", riderRoutePolyline: riderRide!.routePathPolyline,passengerRoutePolyline:passengerRide.routePathPolyline,passengerStart: CLLocation(latitude: passengerRide.startLatitude, longitude: passengerRide.startLongitude),passengerEnd: CLLocation(latitude: passengerRide.endLatitude!, longitude: passengerRide.endLongitude!), pickup: CLLocation(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude), drop: CLLocation(latitude: passengerRide.dropLatitude, longitude: passengerRide.dropLongitude), passengerRideDistance: passengerRide.distance!, map: viewMap, colorCode: UIColor(netHex:0x2F77F2), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
                        self.initializeWalkPathView(distance: cumalativeDistance!)
                    })
                    handleETAToPassenger()
                }
            }
        }else{
            let start = CLLocationCoordinate2D(latitude: (rideObj?.startLatitude)!, longitude: (rideObj?.startLongitude)!)
            let end = CLLocationCoordinate2D(latitude: (rideObj?.endLatitude)!, longitude: (rideObj?.endLongitude)!)
            routePathPolyline = GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start, end: end, route: (rideObj?.routePathPolyline)!, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_7)
            handleETAToRider()
        }
        if isParticipantMarkerLoaded{
            loadRideParticipantMarkers()
        }
    }
    
    private func showPassengerPickUpMarker(passengerRide: PassengerRide) {
        if passengerRide.status == Ride.RIDE_STATUS_STARTED {
            pickupMarker?.map = nil
            pickupMarker = nil
            addPickupMarker(passengerRide: passengerRide)
        } else {
            addPickupMarker(passengerRide: passengerRide)
        }
    }
    
    private func addPickupMarker(passengerRide: PassengerRide) {
        let pickup = CLLocationCoordinate2D(latitude:passengerRide.pickupLatitude,longitude: passengerRide.pickupLongitude)
        let pickupView = UIView.loadFromNibNamed(nibNamed: "ConfirmPickUpView") as! ConfirmPickUpView
        if passengerRide.status == Ride.RIDE_STATUS_STARTED {
            pickupView.initializeDataAndViews(confirmPickupType: ConfirmPickupType.None)
        } else if passengerRide.pickupNote != nil && !passengerRide.pickupNote!.isEmpty {
            pickupView.initializeDataAndViews(confirmPickupType: ConfirmPickupType.Edit)
        } else {
            pickupView.initializeDataAndViews(confirmPickupType: ConfirmPickupType.Add)
        }
        let icon = ViewCustomizationUtils.getImageFromView(view: pickupView)
        pickupMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickup, shortIcon: icon, tappable: true)
        pickupMarker!.groundAnchor = CGPoint(x: 0.9 , y: 0.7)
        pickupMarker!.zIndex = 14
    }
    
    func initializeWalkPathView(distance : CummulativeTravelDistance){
        
        
        if distance.passengerStartToPickup > 0.01 && distance.passengerDropToEnd > 0.01{
            isWalkPathViewHidden = false
            if isMapFullView == nil || !isMapFullView!{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFomStartToPickUp.isHidden = false
            viewWalkPathWidthFromStartToPickUp.constant = 100
            labelWalkPathDistanceFromStartToPickUp.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerStartToPickup)
            setTintedIconToWalkPathView()
            viewWalkPathFromDropToEnd.isHidden = false
            viewWalkPathWidthFromDropToEnd.constant = 100
            labelWalkPthDistanceFromDropToEnd.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerDropToEnd)
            setWalkPathCenterXConstraint(value: -135)
           
        }else if distance.passengerStartToPickup > 0.01{
            isWalkPathViewHidden = false
            if isMapFullView == nil || !isMapFullView!{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFomStartToPickUp.isHidden = false
            viewWalkPathWidthFromStartToPickUp.constant = 100
            setTintedIconToWalkPathView()
            labelWalkPathDistanceFromStartToPickUp.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerStartToPickup)
            
            viewWalkPathFromDropToEnd.isHidden = true
            viewWalkPathWidthFromDropToEnd.constant = 0
            setWalkPathCenterXConstraint(value: -80)
        }else if distance.passengerDropToEnd > 0.01{
            isWalkPathViewHidden = false
            if isMapFullView == nil || !isMapFullView!{
                viewWalkPath.isHidden = false
            }
            self.viewWalkPathHeightConstraint.constant = 40
            viewWalkPathFromDropToEnd.isHidden = false
            viewWalkPathWidthFromDropToEnd.constant = 100
            setTintedIconToWalkPathView()
            labelWalkPthDistanceFromDropToEnd.text = CummulativeTravelDistance.getReadableDistance(distance: distance.passengerDropToEnd)
            viewWalkPathFomStartToPickUp.isHidden = true
            viewWalkPathWidthFromStartToPickUp.constant = 0
            setWalkPathCenterXConstraint(value: -80)
            
        }else{
            if tripInsuranceView.isHidden{
                isWalkPathViewHidden = true
                viewWalkPath.isHidden = true
                self.viewWalkPathHeightConstraint.constant = 0
            }else{
                isWalkPathViewHidden = false
                viewWalkPath.isHidden = false
                self.viewWalkPathHeightConstraint.constant = 40
                walkPathCenterXSpaceConstraint.constant = -100
            }
            viewWalkPathFomStartToPickUp.isHidden = true
            viewWalkPathWidthFromStartToPickUp.constant = 0
            viewWalkPathFromDropToEnd.isHidden = true
            viewWalkPathWidthFromDropToEnd.constant = 0
            imageViewWalkPathCarIcon.isHidden = true
        }
    }
    
    func setWalkPathCenterXConstraint(value : CGFloat){
        if tripInsuranceView.isHidden{
            walkPathCenterXSpaceConstraint.constant = -60
        }else{
            walkPathCenterXSpaceConstraint.constant = value
        }
    }
    
    func setTintedIconToWalkPathView(){
        
        imageViewWalkPathCarIcon.isHidden = false
        
        if riderRide?.vehicleType ==  Vehicle.VEHICLE_TYPE_BIKE{
            imageViewWalkPathCarIcon.image = UIImage(named : "motorbike")
        }else{
            imageViewWalkPathCarIcon.image = UIImage(named : "car_new")
        }
    }
    
    func handleETAToPassenger(){
        if riderRide == nil{
            return
        }
        let riderParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: riderRide!.userId, rideParticipantLocations: self.rideParticipantLocationObject)
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: riderRide!.userId, rideParticipants: self.rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        if riderParticipantLocation != nil{
            checkAndDisplayETAForPassenger(rideParticipantLocation: riderParticipantLocation)
        }
        else if Ride.RIDE_STATUS_SCHEDULED == rideParticipant!.status || Ride.RIDE_STATUS_DELAYED == rideParticipant!.status{
            
            let riderStartLocation = RideParticipantLocation(rideId: riderRide!.rideId,userId:  riderRide!.userId, latitude: riderRide!.startLatitude, longitude: riderRide!.startLongitude, bearing: 0,participantETAInfos: nil)
            riderStartLocation.lastUpdateTime = NSDate().timeIntervalSince1970*1000
            checkAndDisplayETAForPassenger(rideParticipantLocation: riderStartLocation)

        }
    }
    
    func handleETAToRider(){
        if riderRide == nil{
            return
        }
        let riderParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: riderRide!.userId, rideParticipantLocations: self.rideParticipantLocationObject)
        
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: riderRide!.userId, rideParticipants: self.rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        if riderParticipantLocation != nil{
        checkAndDisplayETAForRider(riderLocation: riderParticipantLocation!)
        }
        else if Ride.RIDE_STATUS_SCHEDULED == rideParticipant!.status || Ride.RIDE_STATUS_DELAYED == rideParticipant!.status{
            
            let riderStartLocation = RideParticipantLocation(rideId: riderRide!.rideId,userId:  riderRide!.userId, latitude: riderRide!.startLatitude, longitude: riderRide!.startLongitude, bearing: 0,participantETAInfos: nil)
            riderStartLocation.lastUpdateTime = NSDate().timeIntervalSince1970*1000
            checkAndDisplayETAForRider(riderLocation: riderStartLocation)
        }
    }

    func checkAndReturnEndRideMessage() -> NSAttributedString?{
        if passengersInfo.isEmpty && incomingRideInvites.isEmpty && outGoingRideInvites.isEmpty && rideParticipantsObject.count > 1{
            labelFindMatchedUser.text = Strings.end_ride_message
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.4
            let attributedString = NSMutableAttributedString(string: labelFindMatchedUser.text!)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            return attributedString
        }
        return nil
    }
    
    func loadParticipantImages(){
        if taxiRideId != 0 {
            handleTaxiPoolUIWithData()
            return
        }else{
            if rideObj?.rideType == Ride.PASSENGER_RIDE && (rideObj?.status != Ride.RIDE_STATUS_REQUESTED) && !isModerator {
                displayRiderInfoToPassenger()
            }
            else{
                if rideObj?.rideType == Ride.PASSENGER_RIDE && !isModerator{
                    viewRideActionSlider.isHidden = true
                    InviteMatchedUserViewBottomConstraint.constant = 20
                    userDetailViewHeightConstraint.constant = 120
                    if isMapFullView == nil || !isMapFullView!{
                        mapUtilitiesBottomSpaceConstraint.constant = 0
                    }
                }
                else{
                    viewRideActionSlider.isHidden = false
                    InviteMatchedUserViewBottomConstraint.constant = 60
                    userDetailViewHeightConstraint.constant = 150
                    if isMapFullView == nil || !isMapFullView! {
                        if passengerDetailViewForRider.isHidden {
                            mapUtilitiesBottomSpaceConstraint.constant = 20
                        } else {
                            mapUtilitiesBottomSpaceConstraint.constant = 90
                        }
                    }
                }
                if isFromSignupFlow{
                    if rideObj?.rideType == Ride.RIDER_RIDE{
                        viewRideActionSlider.isHidden = true
                    }
                    viewUserDetail.isHidden = true
                }
                else{
                    viewUserDetail.isHidden = false
                }
                viewFindMatchedRidersAfterJoin.isHidden = true
                self.riderDetailViewForPassenger.isHidden = true
                self.viewJoinedMembers.isHidden = true
                passengersCollectionViewForRider.delegate = nil
                passengersCollectionViewForRider.dataSource = nil
                passengersInfo = RideViewUtils.getPasengersInfo(rideParticipants: rideParticipantsObject)
                if rideObj?.rideType == Ride.PASSENGER_RIDE && isModerator, let rider = RideViewUtils.getRiderFromRideParticipant(rideParticipants: rideParticipantsObject)  {
                    passengersInfo.insert(rider, at: 0)
                    //Set Data of rider on full mapview
                    setRiderDetailOnFullMapView(rideParticipant: rider)
                }
                if passengersInfo.isEmpty && incomingRideInvites.isEmpty && outGoingRideInvites.isEmpty{
                    labelFindMatchedUser.isHidden = false
                    viewRideParticipant.isHidden = true
                    if let message = checkAndReturnEndRideMessage(){
                        labelFindMatchedUser.attributedText = message
                    }
                }
                else{
                    labelFindMatchedUser.isHidden = true
                    viewRideParticipant.isHidden = false
                }
                passengersCollectionViewForRider.delegate = self
                passengersCollectionViewForRider.dataSource = self
                passengersCollectionViewForRider.isHidden = false
                passengersCollectionViewForRider.reloadData()
            }
        }
    }
    private func setRiderDetailOnFullMapView(rideParticipant: RideParticipant) {
        if riderRide != nil && riderRide!.vehicleNumber != nil{
            self.labelVehicleName.isHidden = false
            if riderRide!.makeAndCategory == nil || riderRide!.makeAndCategory!.isEmpty{
                vehicleNumberLabel.text = riderRide!.vehicleNumber!.uppercased()
            }
            else{
                vehicleNumberLabel.text = riderRide!.vehicleNumber!.uppercased() + " " + riderRide!.makeAndCategory!.capitalizingFirstLetter()
            }
        }
        riderNameLabel.text = rideParticipant.name?.capitalized
        ImageCache.getInstance().setImageToView(imageView: riderImageView, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)
        vehicleNumberLabel.isUserInteractionEnabled = true
        vehicleNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.vehicleNameTapped(_:))))
    }
    func getMatchingRidersCountAndDisplay(){
        labelFindMatchedUser.isHidden = false
        labelFindMatchedUser.text = "Finding riders in your route..."

        if rideObj == nil || rideObj!.isKind(of: RiderRide().classForCoder) || (rideObj as! PassengerRide).riderRideId != 0 || rideObj?.status == Ride.RIDE_STATUS_STARTED {
            return
        }
        matchingOptionsLoadingAnimationView.isHidden = false
        matchingOptionsLoadingAnimationView.animationView.setAnimation(named: "loader")
        matchingOptionsLoadingAnimationView.animationView.play()
        matchingOptionsLoadingAnimationView.animationView.loopAnimation = true
        noOfMatchesAvailable.isHidden = true
        MatchedUsersCache.getInstance().getAllMatchedRiders(ride: rideObj!, rideRoute: nil, overviewPolyline: rideObj?.routePathPolyline, noOfSeats: (rideObj as! PassengerRide).noOfSeats, viewController: self, requestSeqId: 1,displaySpinner: false, dataReceiver: self)
    }
    func getMatchingPassengersCountAndDisplay(){
        matchingOptionsLoadingAnimationView.isHidden = false
        matchingOptionsLoadingAnimationView.animationView.setAnimation(named: "loader")
        matchingOptionsLoadingAnimationView.animationView.play()
        matchingOptionsLoadingAnimationView.animationView.loopAnimation = true
        labelFindMatchedUser.isHidden = false
        noOfMatchesAvailable.isHidden = true
        if let message = checkAndReturnEndRideMessage(){
            labelFindMatchedUser.attributedText = message
        }
        else{
            labelFindMatchedUser.text = "Finding ride takers in your route..."
        }
        if isFromRideCreation {
            viewRideActionSlider.isHidden = true
            InviteMatchedUserViewBottomConstraint.constant = 20
            userDetailViewHeightConstraint.constant = 120
        }
        else{
            viewRideActionSlider.isHidden = false
            InviteMatchedUserViewBottomConstraint.constant = 60
            userDetailViewHeightConstraint.constant = 150
        }
        
        MatchedUsersCache.getInstance().getAllMatchedPassengers(ride: rideObj!, rideRoute: nil, overviewPolyline: rideObj?.routePathPolyline, capacity: (rideObj as! RiderRide).availableSeats, fare: (rideObj as! RiderRide).farePerKm, viewController: self, requestSeqId: 1, displaySpinner: false,dataReceiver: self)
    }
    
    func receiveMatchedRidersList( requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int)
    {
        if taxiRideId != 0 {
            return
        }
        matchingOptionsLoadingAnimationView.isHidden = true
        matchingOptionsLoadingAnimationView.animationView.stop()
        if viewRideParticipant.isHidden{
            labelFindMatchedUser.isHidden = false
        }
        else{
            labelFindMatchedUser.isHidden = true
        }
        if rideObj == nil{
            return
        }
        if matchedRiders.isEmpty == true{
            self.unhidingOfUtilities()
            handleMatchedRidersCountFailureScenario(recieveMatchedUserFailed: false)
        }else{
            if self.isFromSignupFlow{
                self.changeLabelTextAndImage(matchedUserCount: matchedRiders.count)
            }
            else{
                if isFromRideCreation {
                    movetoInviteViewController(UITapGestureRecognizer(target: self, action: #selector(LiveRideMapViewController.movetoInviteViewController(_:))))
                    isFromRideCreation = false
                }else{
                    labelFindMatchedUser.text = "Yay! \nFound \(matchedRiders.count) riders to join your ride."
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 2
                    paragraphStyle.lineHeightMultiple = 1.4
                    let attributedString = NSMutableAttributedString(string: labelFindMatchedUser.text!)
                    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                    noOfMatchesAvailable.isHidden = false
                    labelFindMatchedUser.attributedText = attributedString
                    imageViewFindMatchedUser.image = UIImage(named: "find_matched_riders_black")
                    labelInviteMatchedUsers.textColor = UIColor.black
                    if currentMatchBucket != MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH{
                        noOfMatchesAvailable.setTitle(String(matchedRiders.count) + "+", for: .normal)
                    }else{
                        noOfMatchesAvailable.setTitle(String(matchedRiders.count), for: .normal)
                    }
                }
            }
        }
    }
    
    func receiveMatchedPassengersList( requestSeqId : Int, matchedPassengers : [MatchedPassenger], currentMatchBucket: Int) {
        if taxiRideId != 0 {
            return
        }
        matchingOptionsLoadingAnimationView.isHidden = true
        matchingOptionsLoadingAnimationView.animationView.stop()
        if viewRideParticipant.isHidden{
            labelFindMatchedUser.isHidden = false
        }
        else{
            labelFindMatchedUser.isHidden = true
        }
        if matchedPassengers.isEmpty {
            self.unhidingOfUtilities()
            handleMatchedPassengersCountFailureScenario(recieveMatchedUserFailed: false)
        }else{
            if self.isFromSignupFlow{
                self.changeLabelTextAndImage(matchedUserCount: matchedPassengers.count)
            }
            else{
                
                if isFromRideCreation {
                    isFromRideCreation = false
                    movetoInviteViewController(UITapGestureRecognizer(target: self, action: #selector(LiveRideMapViewController.movetoInviteViewController(_:))))
                }else{
                    noOfMatchesAvailable.isHidden = false
                    if let message = checkAndReturnEndRideMessage(){
                        labelFindMatchedUser.attributedText = message
                    }
                    else{
                        labelFindMatchedUser.text = "Yay! \nFound \(matchedPassengers.count) ride takers to join your ride"
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 2
                        paragraphStyle.lineHeightMultiple = 1.4
                        let attributedString = NSMutableAttributedString(string: labelFindMatchedUser.text!)
                        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                        labelFindMatchedUser.attributedText = attributedString
                    }
                    imageViewFindMatchedUser.image = UIImage(named: "find_matched_ridetakers_black")
                    labelInviteMatchedUsers.textColor = UIColor.black
                    if currentMatchBucket != MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH{
                        noOfMatchesAvailable.setTitle(String(matchedPassengers.count) + "+", for: .normal)
                    }else{
                        noOfMatchesAvailable.setTitle(String(matchedPassengers.count) , for: .normal)
                    }
                }
            }
        }
        
    }
    
    func matchingRidersRetrievalFailed(requestSeqId :Int,responseObject : NSDictionary?,error :NSError?) {
        handleMatchedRidersCountFailureScenario(recieveMatchedUserFailed: true)
    }
    
    func matchingPassengersRetrievalFailed( requestSeqId : Int,responseObject : NSDictionary?,error :NSError?) {
        handleMatchedPassengersCountFailureScenario(recieveMatchedUserFailed: true)
    }
    func handleMatchedRidersCountFailureScenario(recieveMatchedUserFailed : Bool){
        matchingOptionsLoadingAnimationView.isHidden = true
        matchingOptionsLoadingAnimationView.animationView.stop()
        noOfMatchesAvailable.isHidden = true
        guard let ride = rideObj else { return }
        if ride.rideType == Ride.PASSENGER_RIDE{
            if recieveMatchedUserFailed == true{
                displayMatchedUserRetrievalFailure()
            }else{
                displayNoMatchingOptions(message: Strings.zero_matching_options_for_ridetaker)
            }
        }else{
            labelFindMatchedUser.isHidden = true
        }
    }
    func handleMatchedPassengersCountFailureScenario(recieveMatchedUserFailed : Bool){
        noOfMatchesAvailable.isHidden = true
        matchingOptionsLoadingAnimationView.isHidden = true
        matchingOptionsLoadingAnimationView.animationView.stop()
        guard let ride = rideObj else { return }
        
        if ride.rideType == Ride.RIDER_RIDE{
            if recieveMatchedUserFailed == true{
                displayMatchedUserRetrievalFailure()
            }else{
                var message = Strings.zero_matching_options_for_rider
                if checkAndReturnEndRideMessage() != nil{
                    message = Strings.end_ride_message
                }
                displayNoMatchingOptions(message: message)
            }
        }else{
            labelFindMatchedUser.isHidden = true
        }
    }
    
    @objc func moveToInviteByContact(_ gesture :UITapGestureRecognizer){
        moveToInvite(isFromContacts: true)
    }
    func changeLabelTextAndImage(matchedUserCount: Int){
        firstRideAnimationView.animationView.stop()
        firstRideAnimationView.animationView.setAnimation(named: "signup_star")
        UIView.transition(with: firstRideAnimationView.animationView,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.firstRideAnimationView.animationView.play()
                            self.firstRideAnimationView.animationView.loopAnimation = true
        }, completion: nil)
        UIView.transition(with: viewFirstRideCreatedInfo,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.viewFirstRideCreatedInfo.backgroundColor = UIColor(netHex: 0xd64361)
        }, completion: nil)
        UIView.transition(with: labelFirstRideInfo1,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.labelFirstRideInfo1.text = "Awesome! Found " + "\(matchedUserCount)" + " rides"
        }, completion: nil)
        UIView.transition(with: labelFirstRideInfo2,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.labelFirstRideInfo2.text = "Redirecting there..."
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.isFromSignupFlow = false
            self.firstRideAnimationView.animationView.stop()
            self.moveToInvite(isFromContacts: false)
        }
    }
    
    func loadRideParticipantMarkers()
    {
        for rideParticipant in rideParticipantsObject{
            checkParticipantStatusAndDisplayMarker(rideParticipant: rideParticipant)
        }
        handleETAToPassenger()
        handleETAToRider()
    }
    
    func displayRideStatusAndFareDetailsToUser(status : String){
        if rideObj == nil{
            return
        }
        let fare = getFareDetails()
        if fare > 0{
            self.labelRideStatus.text = RideViewUtils().getRideStatusAsTitle(status: status,rideType: rideObj!.rideType!) + " | " + StringUtils.getStringFromDouble(decimalNumber: fare) + " Pts"
        }
        else{
            self.labelRideStatus.text = RideViewUtils().getRideStatusAsTitle(status: status,rideType: rideObj!.rideType!)
        }
    }
    
    func getFareDetails() -> Double{
        
        if let passengerRide = rideObj as? PassengerRide{
            if passengerRide.status == Ride.RIDE_STATUS_REQUESTED {
                return 0
            }
            if passengerRide.newFare > -1{
                return passengerRide.newFare
            }else{
                return passengerRide.points
            }
        }else{
            return 0
        }
    }
    
    func displayRideScheduledTime(){
        self.labelRideScheduledTime.text = RideViewUtils.getRideStartTime(ride: rideObj!,format: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa)
    }
    
    
    private func updateRideViewControlsAsPerStatus(){
        if !isFromSignupFlow {
            if rideParticipantsObject.count > 1{
                self.buttonChat.isHidden = false
                buttonChatWidthConstraint.constant = 45
                
            }else{
                self.buttonChat.isHidden = true
                buttonChatWidthConstraint.constant = 0
            }
        }
        enableControlsAsPerStatus()
        handleVisibilityOfInsuranceView()
    }
    
    private func enableControlsAsPerStatus(){
        if taxiRideId != 0 {
            return
        }
        if self.rideStatusObj!.isStartRideAllowed(){
            enableStartButton()
        }else if self.rideStatusObj!.isCheckInRideAllowed(){
            enableCheckinOrPreCheckinButton()
            
        }else if self.rideStatusObj!.isStopRideAllowed(){
            enableStopButton()
            
        }else if self.rideStatusObj!.isCheckOutRideAllowed(){
            
            enableCheckoutButton()
            
        }
        handleEmergencyButtonVisibility()
        
    }
    func handleEmergencyButtonVisibility(){
        if rideObj?.status == Ride.RIDE_STATUS_STARTED{
            buttonEmergency.isHidden = false
        }else{
            buttonEmergency.isHidden = true
        }
    }
    func enableStartButton(){
        startRideAnimationView.animationView.setAnimation(named: "slider")
        startRideAnimationView.animationView.play()
        startRideAnimationView.animationView.loopAnimation = true
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0x00B557)
        self.labelRideActionTitle.text = Strings.start_action_caps
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.rideActionSliderSlided(_:))))
        self.labelRideActionTitle.isUserInteractionEnabled = true
    }
    
    func enableCheckinOrPreCheckinButton(){
        self.labelRideActionTitle.isUserInteractionEnabled = true
        startRideAnimationView.animationView.setAnimation(named: "slider")
        startRideAnimationView.animationView.play()
        startRideAnimationView.animationView.loopAnimation = true
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0x00B557)
        if riderRide != nil && riderRide!.status == Ride.RIDE_STATUS_STARTED{
            labelRideActionTitle.text = Strings.checkin_action_caps
        }else{
            labelRideActionTitle.text = Strings.pre_checkin_action_caps
        }
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.rideActionSliderSlided(_:))))
    }
    
    func enableStopButton(){
        if startRideAnimationView.animationView.isAnimationPlaying == false{
            startRideAnimationView.animationView.setAnimation(named: "slider")
            startRideAnimationView.animationView.play()
            startRideAnimationView.animationView.loopAnimation = true
        }
        viewRideActionSlider.backgroundColor = UIColor(netHex: 0xB50000)
        self.labelRideActionTitle.text = Strings.stop_action_caps
        self.labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.rideActionSliderSlided(_:))))
        self.labelRideActionTitle.isUserInteractionEnabled = true
    }
    
    func enableCheckoutButton(){
        if startRideAnimationView.animationView.isAnimationPlaying == false{
            startRideAnimationView.animationView.setAnimation(named: "slider")
            startRideAnimationView.animationView.play()
            startRideAnimationView.animationView.loopAnimation = true
        }
        self.viewRideActionSlider.backgroundColor = UIColor(netHex: 0xB50000)
        self.labelRideActionTitle.text = Strings.checkout_action_caps
        labelRideActionTitle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.rideActionSliderSlided(_:))))
        labelRideActionTitle.isUserInteractionEnabled = true
        self.labelRideActionTitle.isHidden = false
    }
    
    var closedDialogueDisplayed = false
    func displayRideClosedDialogue(){
        AppDelegate.getAppDelegate().log.debug("displayRideClosedDialogue")
        if closedDialogueDisplayed{
            return
        }
        closedDialogueDisplayed = true
        MessageDisplay.displayAlert( messageString: "Oops ! This ride is already closed", viewController: self,  handler: { (result) -> Void in
            if result == Strings.ok_caps {
                self.goBackToCallingViewController()
                self.closedDialogueDisplayed = false
            }
        })
    }
    func updateRideViewMapWithRideData(rideDetailInfo : RideDetailInfo?){
        
        self.rideObj = rideDetailInfo!.currentUserRide
        if taxiRideId == 0 {
            self.riderRide = rideDetailInfo!.riderRide
            if self.rideObj == nil || (riderRide != nil && RideViewUtils.isRideClosed(riderRideId: riderRide!.rideId)){
                
                self.displayRideClosedDialogue()
                return
            }
        } else {
           self.taxiShareRide = rideDetailInfo!.taxiShareRide
        }
        
        if rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.status == Ride.RIDE_STATUS_COMPLETED{
            completePassengerRide()
            return
        }
        self.rideParticipantsObject = rideDetailInfo!.rideParticipants!
        self.rideStatusObj = rideObj?.prepareRideStatusObject()
        
        if taxiRideId == 0 {
        self.rideStatusObj?.joinedRideStatus = riderRide?.status
        }else{
         self.rideStatusObj?.joinedRideStatus = taxiShareRide?.status
        }
        if rideDetailInfo!.offlineData && rideDetailInfo!.rideParticipantLocations != nil{
            self.rideParticipantLocationObject = rideDetailInfo!.rideParticipantLocations!
        }
        self.updateRideViewControlsAsPerStatus()
        
        initializeRideCurrentLocation(rideDetailInfo: rideDetailInfo)

        displayRideScheduledTime()
        handleVisibilityForFreezeIcon()
        addPassengerAdditionControlToView()
        MyActiveRidesCache.getRidesCacheInstance()!.addRideLocationChangeListener(rideParticipantLocationListener: self)
        
    
        displayRideStatusAndFareDetailsToUser(status: self.rideObj!.status)
        refreshMapWithNewData()
        syncRideInvitesOfRide()
        checkNewMessage()
    }

    private func checkAndShowRideModerationIcon() {
        if rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.status == Ride.RIDE_STATUS_REQUESTED {
            rideModeratorButton.isHidden = true
            return
        }
        rideModeratorButton.isHidden = false
        var rideParticipantAsRider: RideParticipant?
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider {
                rideParticipantAsRider = rideParticipant
                break
            }
        }
        if let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() {
            if ridePreference.rideModerationEnabled {
                rideModeratorButton.backgroundColor = UIColor(netHex: 0xFD5D5D)
                rideModeratorButton.setImage(UIImage(named: "moderator_icon_red"), for: .normal)
            } else {
                rideModeratorButton.backgroundColor = UIColor.white
                rideModeratorButton.setImage(UIImage(named: "moderator_icon_gray"), for: .normal)
            }
        } else {
            rideModeratorButton.backgroundColor = UIColor.white
            rideModeratorButton.setImage(UIImage(named: "moderator_icon_gray"), for: .normal)
        }
        if rideParticipantAsRider != nil && !rideParticipantAsRider!.rideModerationEnabled && rideObj?.rideType == Ride.PASSENGER_RIDE {
            rideModeratorButton.backgroundColor = UIColor.white
            rideModeratorButton.setImage(UIImage(named: "moderator_icon_gray"), for: .normal)
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker == pickupMarker {
            navigateToWhyConfirmGuidelinesView()
        }
        if marker.title == nil || marker.title!.isEmpty == true{
            return nil
        }

        if marker == self.routeNavigationMarker{
            let customInfoWindowView = UIView.loadFromNibNamed(nibNamed: "CustomInfoWindowView") as! CustomInfoWindowView
            customInfoWindowView.initializeView(title: marker.title!)
            return customInfoWindowView
        }
        if Double(marker.title!) != nil{
            let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: Double(marker.title!)!, rideParticipants: rideParticipantsObject)
            if rideParticipant != nil{
                let customInfoWindowView = UIView.loadFromNibNamed(nibNamed: "CustomInfoWindowView") as! CustomInfoWindowView
                customInfoWindowView.initializeView(title: rideParticipant!.name!)
                return customInfoWindowView
            }
        }
        let matchedUser = matchedUsers[marker.title!]
        if matchedUser != nil{
            let markerView = NearByOptionView.loadFromNibNamed(nibNamed: "NearByOptionView",bundle: nil) as? NearByOptionView
            markerView?.initialiseDataAndViews(matchedUser: matchedUser!)
            return markerView
        }
        
        return nil
    }
    private func navigateToWhyConfirmGuidelinesView() {
        let status = SharedPreferenceHelper.getDisplayStatusForWhyConfirmPickup()
        if status == nil || !status! {
            let qrPledgeVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickridePledgeViewController") as! QuickridePledgeViewController
            qrPledgeVC.initializeDataBeforePresenting(titles: Strings.confirm_pickup_titles, messages: Strings.confirm_pickup_messages, images: Strings.confirm_pickup_images, actionName: Strings.confirm_caps, heading: Strings.confirm_pickup_heading) { [weak self] () in
                guard let self = `self` else { return }
                SharedPreferenceHelper.setDisplayStatusForWhyConfirmPickup(status: true)
                self.moveToEditPickupView()
            }
             ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: qrPledgeVC, animated: false)
        } else {
            self.moveToEditPickupView()
        }
       
    }
    
    private func moveToEditPickupView() {
        if rideObj == nil || rideObj!.isKind(of: RiderRide.self) || riderRide == nil {
            return
        }
        let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickupDropEditViewController") as! PickupDropEditViewController
        let passengerRide = rideObj as! PassengerRide
        pickUpDropViewController.initializeDataBeforePresenting(matchedUser: MatchedRider(passengerRide: passengerRide),riderRoutePolyline: riderRide!.routePathPolyline,riderRideType: Ride.RIDER_RIDE, delegate: self,passengerRideId: rideObj!.rideId,riderRideId: passengerRide.riderRideId,passengerId: rideObj?.userId,riderId: passengerRide.riderId,noOfSeats: passengerRide.noOfSeats,isFromEditPickup: true, note: passengerRide.pickupNote)
        self.navigationController?.pushViewController(pickUpDropViewController, animated: false)
    }
    func addPassengerAdditionControlToView(){}
    
    
    func initializeRideCurrentLocation(rideDetailInfo : RideDetailInfo?){
        let timeNow = DateUtils.getCurrentTimeInMillis()
        if rideDetailInfo?.rideCurrentLocation != nil && rideDetailInfo?.rideLocationUpdateTime != nil && (DateUtils.getDifferenceBetweenTwoDatesInMins(time1: timeNow, time2: rideDetailInfo?.rideLocationUpdateTime) < MIN_TIME_DIFF_CURRENT_LOCATION){
            let latLongOnRoute = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: CLLocationCoordinate2D(latitude: Double((rideDetailInfo?.rideCurrentLocation?.latitude)!), longitude: Double((rideDetailInfo?.rideCurrentLocation!.longitude)!)), routePath: rideObj!.routePathPolyline)
            self.rideCurrentLocation = latLongOnRoute
            return
        }
        
        LocationUpdationServiceClient.getRiderCurrentLocation(riderRideId: StringUtils.getStringFromDouble(decimalNumber: self.riderRideId), targetViewController: self) { (responseObject, error) -> Void in
            if responseObject != nil{
                if responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                    let latLong = Mapper<RideParticipantLocation>().map(JSONObject: responseObject!["resultData"])!
                    let latLongOnRoute = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: CLLocationCoordinate2D(latitude: latLong.latitude!, longitude: latLong.longitude!), routePath: self.rideObj!.routePathPolyline)
                    self.rideCurrentLocation?.latitude = latLongOnRoute.latitude
                    self.rideCurrentLocation?.longitude = latLongOnRoute.longitude
                    
                }
            }
        }
    }

    func checkNewMessage(){
        let unreadCount = MessageUtils.getUnreadCountOfChat()
        if unreadCount > 0{
            viewUnreadMsg.isHidden = false
            unreadChatCountLabel.text = String(unreadCount)
        }else{
            viewUnreadMsg.isHidden = true
        }
    }
    
    func newChatMessageRecieved(newMessage : GroupChatMessage){
        moveToGroupChatView()
    }
    func chatMessagesInitializedFromSever(){
        
    }
    func handleException(){
        
    }
    
    func clearRoute() {
        if rideParticipantMarkers.count > 0 {
            for rideParticipantElement in rideParticipantMarkers.values {
                AppDelegate.getAppDelegate().log.debug("removeMarker: \(String(describing: userId))")
                rideParticipantElement.removeRideParticipantElement()
            }
            rideParticipantMarkers.removeAll()
        }
        if self.viewMap != nil{
            viewMap.clear()
        }
        routeNavigationMarker?.map = nil
        routeNavigationMarker = nil
        pickupMarker?.map = nil
        pickupMarker = nil
        clearLocationUpdateMarker()
        AppDelegate.appDelegate?.log.debug("routeNavigationMarker set to nil")
    }
    
    
    // MARK: - Collection view delegate and data source
    func numberOfSections() -> Int{
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count = 0
        if section == 0{
            if taxiShareRide == nil {
                count = passengersInfo.count
        } else {
            count = Int(taxiShareRide?.capacity ?? 0)
        }
            
        }else if section == 1{
            count = outGoingRideInvites.count
        }else if section == 2{
            count = incomingRideInvites.count
        }else {
            count = 0
        }
        if count != 0{
            labelFindMatchedUser.isHidden = true
        }
        return count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func initializeIncomingAndOutGoingInvites(indexPath: IndexPath, cell: RiderAndPassengerCollectionViewCell, rideInvitation: RideInvitation, isIncomingInvite: Bool) {
        guard let ride = rideObj else { return }
        if ride.rideType == Ride.PASSENGER_RIDE && !isModerator{
            cell.userId = rideInvitation.riderId!
            cell.imgProfilePic.image = nil
            cell.lblName.text = nil
            cell.noSeatsLabel.isHidden = true
            
            
            let userBasicInfo = RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation.riderId!)
            if userBasicInfo == nil{
                RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation.riderId!, handler: { (userBasicInfo,responseError,error) in
                    if userBasicInfo != nil{
                        self.passengersCollectionViewForRider.reloadData()
                    }
                })
                
            }else{
                self.setInvitedUserImage(invitedUser: userBasicInfo!, rideInvitation: rideInvitation,isIncomingInvite: isIncomingInvite, cell: cell)
            }
            
        }else{
            cell.userId = rideInvitation.passengerId!
            cell.imgProfilePic.image = nil
            cell.lblName.text = nil
            cell.noSeatsLabel.isHidden = true
            
            
            let userBasicInfo = RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation.passengerId!)
            if userBasicInfo == nil{
                RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation.passengerId!, handler: { (userBasicInfo,responseError,error) in
                    if userBasicInfo != nil{
                        self.passengersCollectionViewForRider.reloadData()
                    }
                })
                
            }else{
                self.setInvitedUserImage(invitedUser: userBasicInfo!, rideInvitation: rideInvitation,isIncomingInvite: isIncomingInvite, cell: cell)
                if rideInvitation.noOfSeats! > 1{
                    cell.noSeatsLabel.isHidden = false
                    cell.noSeatsLabel.text = "+\(String(rideInvitation.noOfSeats!-1))"
                }else{
                    cell.noSeatsLabel.isHidden = true
                }
            }
        }
    }
    
    func initializeRideParticipantProfile(indexPath: IndexPath, cell: RiderAndPassengerCollectionViewCell, passengersInfo: [RideParticipant]) {
        let rideParticipant : RideParticipant = passengersInfo[indexPath.item]
        cell.userId = rideParticipant.userId
        cell.status = rideParticipant.status
        cell.lblName.text = rideParticipant.name?.capitalizingFirstLetter()
        cell.incomingInvitationIcon.isHidden = true
        cell.invitationStatusIcon.isHidden = true
        cell.imgProfilePic.alpha = 1.0
        if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: rideObj, userProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) && (nextPassengerToPickupIndex == nil || nextPassengerToPickupIndex == indexPath.row) && !passengerDetailViewForRider.isHidden {
            cell.otpRequiredStartView.isHidden = false
        } else {
            cell.otpRequiredStartView.isHidden = true
        }
        if !rideParticipant.rider, rideParticipant.noOfSeats > 1{
            cell.noSeatsLabel.isHidden = false
            cell.noSeatsLabel.text = "+\(String(rideParticipant.noOfSeats-1))"
        }else{
            cell.noSeatsLabel.isHidden = true
        }
        ImageCache.getInstance().setImageToView(imageView: cell.imgProfilePic, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        if rideParticipant.rideModerationEnabled, rideParticipant.status == Ride.RIDE_STATUS_STARTED, !rideParticipant.rider {
            cell.moderatorImageView.isHidden = false
        } else {
            cell.moderatorImageView.isHidden = true
        }
        cell.awakeFromNib()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == passengersCollectionViewForRider{
            
            
            let cell : RiderAndPassengerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RiderAndPassengerCollectionViewCell
            if indexPath.section == 0{
                if passengersInfo.endIndex <= indexPath.row{
                    return cell
                }
                if passengersInfo.isEmpty{
                    labelFindMatchedUser.isHidden = false
                    viewRideParticipant.isHidden = true
                }
                else{
                    labelFindMatchedUser.isHidden = true
                    viewRideParticipant.isHidden = false
                    initializeRideParticipantProfile(indexPath: indexPath, cell: cell, passengersInfo: passengersInfo)
                }
            }else {
                cell.otpRequiredStartView.isHidden = true
                labelFindMatchedUser.isHidden = true
                cell.moderatorImageView.isHidden = true
                viewRideParticipant.isHidden = false
                var rideInvitation : RideInvitation?
                var isIncomingInvite = false
                if indexPath.section == 1{
                    if outGoingRideInvites.endIndex <= indexPath.row{
                        return cell
                    }
                    rideInvitation = outGoingRideInvites[indexPath.item]
                    isIncomingInvite = false
                }else{
                    let invites  = Array(incomingRideInvites.values)
                    if invites.endIndex <= indexPath.row{
                        return cell
                    }
                    rideInvitation = invites[indexPath.item]
                    isIncomingInvite = true
                }
                initializeIncomingAndOutGoingInvites(indexPath: indexPath, cell: cell, rideInvitation: rideInvitation!, isIncomingInvite: isIncomingInvite)
            }
            return cell
        }
        else{
            if indexPath.row < passengersInfo.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! JoinedRideParticipantCollectionViewCell
                if indexPath.section == 0{
                    if passengersInfo.endIndex <= indexPath.row{
                        return cell
                    }
                    let rideParticipant : RideParticipant = passengersInfo[indexPath.item]
                    cell.userId = rideParticipant.userId
                    if StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId) == QRSessionManager.getInstance()?.getUserId() {
                        cell.labelName.text = "You"
                    } else {
                        cell.labelName.text = rideParticipant.name?.capitalizingFirstLetter()
                    }
                    cell.invitationStatusIcon.isHidden = true
                    cell.status = rideParticipant.status
                    if rideParticipant.noOfSeats > 1{
                        cell.labelNoOfSeats.isHidden = false
                        cell.labelNoOfSeats.text = "+\(String(rideParticipant.noOfSeats-1))"
                    }else{
                        cell.labelNoOfSeats.isHidden = true
                    }
                    //Setting user image
                    ImageCache.getInstance().setImageToView(imageView: cell.imageViewProfilePic, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                    cell.awakeFromNib()
                }else{
                    var rideInvitation : RideInvitation?
                    if outGoingRideInvites.endIndex <= indexPath.row{
                        return cell
                    }
                    rideInvitation = outGoingRideInvites[indexPath.item]
                    cell.userId = rideInvitation!.riderId!
                    cell.labelName.text = nil
                    cell.imageViewProfilePic.image = nil
                    if rideInvitation!.noOfSeats! > 1{
                        cell.labelNoOfSeats.isHidden = false
                        cell.labelNoOfSeats.text = "+\(String(rideInvitation!.noOfSeats!-1))"
                    }else{
                        cell.labelNoOfSeats.isHidden = true
                    }
                    let userBasicInfo = RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation!.riderId!)
                    if userBasicInfo == nil{
                        RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvitation!.riderId!, handler: { (userBasicInfo,responseError,error) in
                            if userBasicInfo != nil{
                                self.joinedMemebersCollectionViewForPassenger.reloadData()
                            }
                        })
                        
                    }else{
                        cell.invitationStatusIcon.isHidden = false
                        ImageCache.getInstance().setImageToView(imageView: cell.imageViewProfilePic, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                        cell.labelName.text = userBasicInfo?.name?.capitalizingFirstLetter()
                        setImageViewBasedOnInvitationStatus(imageView: cell.invitationStatusIcon, status :rideInvitation!.invitationStatus!)
                    }
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell", for: indexPath) as! EmptyPassengerTaxiPoolCollectionViewCell
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == passengersCollectionViewForRider{
            let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! RiderAndPassengerCollectionViewCell
            if indexPath.section == 0{
                if (rideObj?.status == Ride.RIDE_STATUS_STARTED && passengersInfo[indexPath.row].status != Ride.RIDE_STATUS_STARTED){
                    selectedPickupUserId = passengersInfo[indexPath.row].userId
                    downArrowImageView.image = downArrowImageView.image?.withRenderingMode(.alwaysTemplate)
                    downArrowImageView.tintColor = UIColor(netHex: 0xeedb5c)
                    self.passengerDetailViewForRider.backgroundColor = UIColor(netHex: 0xeedb5c)
                    pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
                    self.viewArrivalOrPickupTime.isHidden = true
                    handleETAToRider()
                    nextPassengerToPickupIndex = indexPath.row
                    showPassengerInfoOfNextPickUp(passengerInfo: passengersInfo[indexPath.row])
                } else if isModerator && passengersInfo[indexPath.row].rider {
                    nextPassengerToPickupIndex = indexPath.row
                    showRiderInfoToModerator(rideParticipant: passengersInfo[indexPath.row])
                }
                else{
                    hidePassengerPickupInfoView()
                    contactSelectedUser(phoneNumber: cell.userId!)
                }
            }else if indexPath.section == 1{
                if self.outGoingRideInvites.count <= indexPath.item{
                    return
                }
                displayOutgoingInvitation(userId: cell.userId!, indexPath: indexPath)
                
            }else if indexPath.section == 2{
                if self.incomingRideInvites.count <= indexPath.item{
                    return
                }
                displayInviteDailogueOrMultiAcceptDailogue(indexPath: indexPath)
            }
        }
        else{
            if indexPath.row < passengersInfo.count {
                let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! JoinedRideParticipantCollectionViewCell
                if indexPath.section == 0{
                    contactSelectedUser(phoneNumber: cell.userId!)
                }
                else{
                    if self.outGoingRideInvites.count <= indexPath.item{
                        return
                    }
                    displayOutgoingInvitation(userId: cell.userId!, indexPath: indexPath)
                }
                
            }else{
                return
            }
        }
    }
    
    func displayOutgoingInvitation(userId: Double, indexPath: IndexPath){
        QuickRideProgressSpinner.startSpinner()
        RideInviteCache.getInstance().getUserBasicInfo(userId: userId, handler: {  (userBasicInfo,responseError,error) in
            QuickRideProgressSpinner.stopSpinner()
            if userBasicInfo == nil {
                return
            }
            let rideInvitation = self.outGoingRideInvites[indexPath.item]
            let viewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteStatusDialogue") as! InviteStatusDialogue
            self.inviteStatusDialogue = viewController
            viewController.initializeDataAndPresent(invitedUser: userBasicInfo!, currentUserRide: self.rideObj!,rideInvitation: rideInvitation, liveRideViewController: self, inviteStatusDialogueActionHandler :
                { (invitationStatus) in
                    if invitationStatus == nil
                    {
                        self.inviteStatusDialogue = nil
                    }
                    else
                    {
                        if self.rideObj == nil {
                            return
                        }
                        self.validateAndGetRideInvites()
                    }
            })
            viewController.displayView()
        })
    }
    
    func displayInviteDailogueOrMultiAcceptDailogue(indexPath: IndexPath){
        let invites = Array(incomingRideInvites.values)
        if invites.count > 2 && (rideObj?.rideType == Ride.RIDER_RIDE || isModerator) {
            if rideObj == nil{
                return
            }
            let selectedRideInvitation = invites[indexPath.item]
            let viewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteMultipleUsersViewController") as! InviteMultipleUsersViewController
            self.inviteMultipleUsersViewController = viewController
            viewController.initializeDataBeforePresenting(riderRideId: riderRideId, rideInvites: invites, currentUserRide: rideObj!,selectedRideInvitation:selectedRideInvitation,liveRideViewController: self, isModerator: isModerator, dismissHandler: {
                self.inviteMultipleUsersViewController = nil
            })
            viewController.displayView()
        }else{
            let rideInvitation = invites[indexPath.item]
            let viewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteDialogue") as! InviteDialogue
            self.inviteDialogue = viewController
            viewController.initializeDataAndPresent(rideInvitation: rideInvitation, currentUserRide: rideObj!, liveRideViewController: self, isModerator: isModerator, dismissHandler: {
                self.inviteDialogue = nil
            })
            viewController.displayView()
        }
    }
    
    func setInvitedUserImage(invitedUser : UserBasicInfo, rideInvitation : RideInvitation,isIncomingInvite : Bool,cell: RiderAndPassengerCollectionViewCell){
        AppDelegate.getAppDelegate().log.debug(rideInvitation.toJSONString())
        RideViewUtils.setBorderToUserImageBasedOnStatus(image: cell.imgProfilePic, status: Ride.RIDE_STATUS_REQUESTED)
        ImageCache.getInstance().setImageToView(imageView: cell.imgProfilePic, imageUrl: invitedUser.imageURI, gender: invitedUser.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        cell.awakeFromNib()
        if  isIncomingInvite{
            cell.invitationStatusIcon.isHidden = true
            cell.incomingInvitationIcon.isHidden = false
        }else{
            cell.invitationStatusIcon.isHidden = false
            cell.incomingInvitationIcon.isHidden = true
            setImageViewBasedOnInvitationStatus(imageView: cell.invitationStatusIcon, status :rideInvitation.invitationStatus!)
        }
        
        cell.lblName.text = invitedUser.name?.capitalizingFirstLetter()
        cell.imgProfilePic.alpha = 0.5
    }
    
    func displayRiderInfoToPassenger(){
        if rideParticipantsObject.isEmpty || rideObj == nil{
            return
        }
        viewRideActionSlider.isHidden = false
        viewUserDetail.isHidden = true
        if isMapFullView == nil || !isMapFullView!{
            mapUtilitiesBottomSpaceConstraint.constant = 110
        }
        self.riderDetailViewForPassenger.isHidden = false
        self.viewJoinedMembers.isHidden = false
        joinedMemebersCollectionViewForPassenger.delegate = nil
        joinedMemebersCollectionViewForPassenger.dataSource = nil
        passengersInfo = RideViewUtils.getPasengersInfo(rideParticipants: rideParticipantsObject)
        joinedMemebersCollectionViewForPassenger.delegate = self
        joinedMemebersCollectionViewForPassenger.dataSource = self
        joinedMemebersCollectionViewForPassenger.isHidden = false
        joinedMemebersCollectionViewForPassenger.reloadData()
        if rideObj?.status == Ride.RIDE_STATUS_STARTED{
            viewFindMatchedRidersAfterJoin.isHidden = true
            viewJoinedPassengerTrailingConstraint.constant = 0
        }
        else{
            viewFindMatchedRidersAfterJoin.isHidden = false
            viewJoinedPassengerTrailingConstraint.constant = -80
        }
        buttonFindMatchedRiderAfterJoin.setImage(UIImage(named: "icon_rider_active"), for: .normal)
        imageViewRider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.riderImageClicked(_:))))
        labelVehicleName.isUserInteractionEnabled = true
        labelVehicleName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.vehicleNameTapped(_:))))
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider == true{
                if let pickupOTP = UserDataCache.getInstance()?.getUser()?.pickupOTP {
                    handlePickuOTPShowing(pickupOTP: pickupOTP, rideParticipant: rideParticipant)
                } else {
                    getUserWithPickupOTPAndRefresh(rideParticipant: rideParticipant)
                }
                labelRiderName.text = rideParticipant.name
                setArrivalTimeOfRiderToPickup(rideParticipant: rideParticipant)
                if rideParticipant.enableChatAndCall{
                    if rideParticipant.callSupport == UserProfile.SUPPORT_CALL_NEVER{
                       riderCallButton.backgroundColor = UIColor(netHex: 0xcad2de)
                    }else{
                       riderCallButton.backgroundColor = UIColor(netHex: 0x2196f3)
                    }
                    riderChatButton.backgroundColor = UIColor(netHex: 0x19ac4a)
                }else{
                    riderCallButton.backgroundColor = UIColor(netHex: 0xcad2de)
                    riderChatButton.backgroundColor = UIColor(netHex: 0xcad2de)
                }
                if riderRide != nil && riderRide!.vehicleNumber != nil{
                    self.labelVehicleName.isHidden = false
                    if riderRide!.makeAndCategory == nil || riderRide!.makeAndCategory!.isEmpty{
                        self.labelVehicleName.text = riderRide!.vehicleNumber!.uppercased()
                        //Set Data of rider on full mapview
                        vehicleNumberLabel.text = riderRide!.vehicleNumber!.uppercased()
                    }
                    else{
                        self.labelVehicleName.text = riderRide!.vehicleNumber!.uppercased() + " " + riderRide!.makeAndCategory!.capitalizingFirstLetter()
                        //Set Data of rider on full mapview
                        vehicleNumberLabel.text = riderRide!.vehicleNumber!.uppercased() + " " + riderRide!.makeAndCategory!.capitalizingFirstLetter()
                    }
                }
                else{
                    self.labelVehicleName.isHidden = true
                }
                ImageCache.getInstance().setImageToView(imageView: self.imageViewRider, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                //Set Data of rider on full mapview
                riderNameLabel.text = rideParticipant.name?.capitalized
                ImageCache.getInstance().setImageToView(imageView: riderImageView, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)
                vehicleNumberLabel.isUserInteractionEnabled = true
                vehicleNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.vehicleNameTapped(_:))))
                break
            }
        }
    }
       
    private func getUserWithPickupOTPAndRefresh(rideParticipant: RideParticipant) {
        UserRestClient.getUserWithPickupOTP(userId: QRSessionManager.getInstance()?.getUserId(), uiViewController: self) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if let user = Mapper<User>().map(JSONObject: responseObject!["resultData"]) {
                    UserDataCache.getInstance()?.storeUserDynamicChanges(user: user)
                    self.handlePickuOTPShowing(pickupOTP: user.pickupOTP, rideParticipant: rideParticipant)
                }
            }
        }
    }
    
    private func getRiderUserProfileAndShowOTP(otp: String, rideParticipant: RideParticipant) {
        UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), targetViewController: self, completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) -> Void in
            if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: self.rideObj, userProfile: otherUserInfo?.userProfile) {
                self.otpButton.isHidden = false
                self.otpButton.setTitle("OTP \(otp)", for: .normal)
            } else {
                self.otpButton.isHidden = true
            }
        })
    }
    
    private func handlePickuOTPShowing(pickupOTP: String?, rideParticipant: RideParticipant) {
        if let otp = pickupOTP {
            getRiderUserProfileAndShowOTP(otp: otp, rideParticipant: rideParticipant)
        } else {
            otpButton.isHidden = true
        }
    }

    private func checkAndDisplayPickupButtonGuideLineScreen() {
        if !SharedPreferenceHelper.getPickupButtonGuideDisplayView() {
            SharedPreferenceHelper.setPickupButtonGuideDisplayView(status: true)
            let pickupButtonGuideViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickupButtonGuideViewController") as! PickupButtonGuideViewController
            self.view.addSubview(pickupButtonGuideViewController.view)
            self.addChild(pickupButtonGuideViewController)
            pickupButtonGuideViewController.view.layoutIfNeeded()
        }
    }
    
    func setArrivalTimeOfRiderToPickup(rideParticipant: RideParticipant){
        if isMapFullView == nil || !isMapFullView!{
            self.viewArrivalOrPickupTime.isHidden = true
        }
        else{
            self.viewArrivalOrPickupTime.isHidden = false
        }
        if etaError != nil && etaError!.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR{
            self.labelRiderRideStatus.textColor = UIColor(netHex: 0xB50000)
            self.labelArrivalOrPickupTime.textColor = UIColor(netHex: 0xB50000)
            self.labelRiderRideStatus.text = Strings.rider_crossed_pickup
            self.labelArrivalOrPickupTime.text = Strings.rider_crossed_pickup
        }
        else{
            self.labelRiderRideStatus.textColor = UIColor(netHex: 0x00B557)
            self.labelArrivalOrPickupTime.textColor = UIColor.black
	    
            self.labelRiderRideStatus.text = rideParticipant.status.uppercased()
            self.labelArrivalOrPickupTime.text = rideParticipant.status.uppercased()
        }
    }

    func showRiderInfoToModerator(rideParticipant: RideParticipant){
        labelNextPickupOrRideStatus.textColor = UIColor(netHex: 0x00B557)
        labelNextPickupOrRideStatus.text = rideParticipant.status.uppercased()
        labelRideTakerDistanceToPickupPointOrRiderName.isHidden = false
        labelRideTakerDistanceToPickupPointOrRiderName.text = rideParticipant.name?.capitalizingFirstLetter()
        downArrowImageView.image = downArrowImageView.image?.withRenderingMode(.alwaysTemplate)
        downArrowImageView.tintColor = UIColor.white
        passengerDetailViewForRider.isHidden = false
        passengerDetailViewForRider.backgroundColor = UIColor.white
        pickupButton.isHidden = true
        pickupNoteOrVehicleDetailsLabel.textColor = UIColor(netHex: 0x007AFF)
        downArrowImageView.frame.origin.x = 37
        if riderRide != nil && riderRide!.vehicleNumber != nil{
            passengerDetailViewForRiderHeightConstraint.constant = 75
            pickupNoteOrVehicleDetailsLabelHeightConstraint.constant = 25
            pickupNoteOrVehicleDetailsLabel.isHidden = false
            pickupNoteOrVehicleDetailsLabel.isUserInteractionEnabled = true
            pickupNoteOrVehicleDetailsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.vehicleNameTapped(_:))))
            if riderRide!.makeAndCategory == nil || riderRide!.makeAndCategory!.isEmpty{
                pickupNoteOrVehicleDetailsLabel.text = riderRide!.vehicleNumber!.uppercased()
            }
            else{
                pickupNoteOrVehicleDetailsLabel.text = riderRide!.vehicleNumber!.uppercased() + " " + riderRide!.makeAndCategory!.uppercased()
            }
        } else {
            passengerDetailViewForRiderHeightConstraint.constant = 60
            pickupNoteOrVehicleDetailsLabelHeightConstraint.constant = 0
            pickupNoteOrVehicleDetailsLabel.isHidden = true
        }
        if isMapFullView == nil || !isMapFullView!{
            mapUtilitiesBottomSpaceConstraint.constant = passengerDetailViewForRiderHeightConstraint.constant + 10
        }
        if checkAndEnableCallOption(callSupport: rideParticipant.callSupport) && rideParticipant.enableChatAndCall{
            buttonContactPassenger.isHidden = false
        }
        else{
            buttonContactPassenger.isHidden = true
        }
    }
    
    func showPassengerInfoOfNextPickUp(passengerInfo: RideParticipant){
        
        let attributes = passengersCollectionViewForRider.layoutAttributesForItem(at: IndexPath(item: nextPassengerToPickupIndex!, section: 0))
        let cellRect = attributes?.frame
        let cellFrameInSuperview = passengersCollectionViewForRider.convert(cellRect ?? CGRect.zero, to: passengersCollectionViewForRider.superview)
        if cellFrameInSuperview.origin.x == 0.0{
            downArrowImageView.frame.origin.x = 37
        }
        else{
            downArrowImageView.frame.origin.x = 0.0
            downArrowImageView.frame.origin.x = cellFrameInSuperview.origin.x + 42
        }
        if passengersCollectionViewForRider.contentSize.width != 0 && downArrowImageView.frame.origin.x + 50 >= passengersCollectionViewForRider.contentSize.width{
            passengersCollectionViewForRider.scrollToItem(at: IndexPath(item: nextPassengerToPickupIndex!, section: 0), at: .right, animated: false)
        }
        passengerDetailViewForRider.isHidden = false
        pickupButton.isHidden  = false
        checkAndDisplayPickupButtonGuideLineScreen()
        labelNextPickupOrRideStatus.textColor = UIColor.black
        pickupNoteOrVehicleDetailsLabel.isUserInteractionEnabled = false
        if passengerInfo.pickupNote != nil {
            passengerDetailViewForRiderHeightConstraint.constant = 75
            pickupNoteOrVehicleDetailsLabelHeightConstraint.constant = 25
            pickupNoteOrVehicleDetailsLabel.isHidden = false
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
            pickupNoteOrVehicleDetailsLabel.text = passengerInfo.pickupNote
            pickupNoteOrVehicleDetailsLabel.type = .continuous
            pickupNoteOrVehicleDetailsLabel.speed = .duration(13)
        } else {
            passengerDetailViewForRiderHeightConstraint.constant = 60
            pickupNoteOrVehicleDetailsLabelHeightConstraint.constant = 0
            pickupNoteOrVehicleDetailsLabel.isHidden = true
        }
        if isMapFullView == nil || !isMapFullView!{
            mapUtilitiesBottomSpaceConstraint.constant = passengerDetailViewForRiderHeightConstraint.constant + 10
        }
        buttonContactPassenger.isHidden = false
        if checkAndEnableCallOption(callSupport: passengerInfo.callSupport) && passengerInfo.enableChatAndCall{
            buttonContactPassenger.isHidden = false
        }
        else{
            buttonContactPassenger.isHidden = true
        }
        var nextPickupIndex = nextPassengerToPickupIndex
        if isModerator {
            nextPickupIndex = nextPickupIndex! - 1
        }
        var otpRequired = ""
        if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: passengerInfo, ride: rideObj, userProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
            otpRequired = " - OTP REQUIRED"
        }
        switch nextPickupIndex {
        case 0:
            labelNextPickupOrRideStatus.text = "FIRST PICKUP" + otpRequired
        case 1:
            labelNextPickupOrRideStatus.text = "SECOND PICKUP" + otpRequired
        case 2:
            labelNextPickupOrRideStatus.text = "THIRD PICKUP" + otpRequired
        case 3:
            labelNextPickupOrRideStatus.text = "FOURTH PICKUP" + otpRequired
        case 4:
            labelNextPickupOrRideStatus.text = "FIFTH PICKUP" + otpRequired
        case 6:
            labelNextPickupOrRideStatus.text = "SIXTH PICKUP" + otpRequired
        default:
            labelNextPickupOrRideStatus.text = "OTHER PICKUP" + otpRequired
        }
    }
    
    @objc func viewMoreDetailTapped(_ sender: UITapGestureRecognizer){
        guard let ride = rideObj else { return }
        let moreDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideRequestsAndRideInvitesViewController") as! MoreDetailViewController
        moreDetailsViewController.initializeView(rideObj: ride)
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(moreDetailsViewController, animated: false)
    }
    
    func contactSelectedUser(phoneNumber : Double){
        if phoneNumber == rideObj?.userId{
            return
        }
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: phoneNumber, rideParticipants: rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        
        var selectionTypes = [String]()

        if clientConfiguration!.enableNmberMasking{
            selectionTypes = [Strings.contact,
                              Strings.route,
                              Strings.droppedOff,
                              Strings.profile,
                              Strings.ride_notes,
                              String(format: Strings.rate_user, arguments: [rideParticipant!.name ?? ""]),
                              Strings.unjoin]
        }else{
            selectionTypes = [Strings.contact,
                              Strings.smsLabel,
                              Strings.route,
                              Strings.droppedOff,
                              Strings.profile,
                              Strings.ride_notes,
                              String(format: Strings.rate_user, arguments: [rideParticipant!.name ?? ""]),
                              Strings.unjoin]
         }
        for i in 0...selectionTypes.count-1{
            
            let title = selectionTypes[i]
            if title == Strings.unjoin{
                if (Ride.RIDE_STATUS_STARTED == rideParticipant!.status && rideParticipant?.rider == false) || (rideParticipant?.rider == false && rideObj?.rideType == Ride.PASSENGER_RIDE){
                    continue
                }
            }

            if title == Strings.droppedOff {
                if rideObj?.rideType == Ride.PASSENGER_RIDE{
                    continue
                }
                if rideParticipant?.rider == true{
                    continue
                }else if riderRide?.status != Ride.RIDE_STATUS_STARTED{
                    continue
                }else if rideParticipant?.status != Ride.RIDE_STATUS_STARTED{
                    continue
                }
            }
            if title == Strings.contact {
                if !rideParticipant!.enableChatAndCall || (rideParticipant?.status == Ride.RIDE_STATUS_STARTED && rideObj?.status == Ride.RIDE_STATUS_STARTED) || (riderRide?.status == Ride.RIDE_STATUS_STARTED && rideObj?.rideType == Ride.RIDER_RIDE) {
                    continue
                }
            }
            if title == Strings.smsLabel{
                if !rideParticipant!.enableChatAndCall || (rideParticipant?.status == Ride.RIDE_STATUS_STARTED && rideObj?.status == Ride.RIDE_STATUS_STARTED){
                    continue
                }
            }
            if title == Strings.route && rideObj?.rideType != Ride.RIDER_RIDE{
                continue
            }
            
            if title == Strings.ride_notes && (rideParticipant!.rideNote == nil || rideParticipant!.rideNote!.isEmpty)
            {
                continue
            }
            
            if title == Strings.unjoin{
                let expectedAction = UIAlertAction(title: selectionTypes[i], style: .destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.handleRideParticiapantAction(selectedType: selectionTypes[i], phoneNumber: phoneNumber, rideParticipant: rideParticipant!)
                })
                optionMenu.addAction(expectedAction)
            }else{
                let expectedAction = UIAlertAction(title: selectionTypes[i], style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.handleRideParticiapantAction(selectedType: selectionTypes[i], phoneNumber: phoneNumber, rideParticipant: rideParticipant!)
                })
                optionMenu.addAction(expectedAction)
            }
        }
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    func handleRideParticiapantAction(selectedType : String,phoneNumber : Double,rideParticipant : RideParticipant){
        
        switch selectedType {
        case Strings.droppedOff:
            self.updatePassengerStatusByRider(rideParticipant: rideParticipant, status: Ride.RIDE_STATUS_COMPLETED, riderRideId: self.riderRideId!)
        case Strings.contact:
            checkAnyModeratorPresentAndShowContactOption(rideParticipant: rideParticipant)
        case Strings.smsLabel:
            if rideParticipant.contactNo == nil || rideParticipant.contactNo!.isEmpty{
                UserDataCache.getInstance()?.getContactNo(userId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), handler: { (contactNo) in
                    rideParticipant.contactNo = contactNo
                    self.message(phoneNumber: contactNo, message: "")
                })
            }else{
                message(phoneNumber: rideParticipant.contactNo, message: "")
            }
        case Strings.profile:
            self.displayConnectedUserProfile(phoneNumber: phoneNumber)
        case Strings.unjoin:
            RideViewUtils.removeRideParticipant(effectingUserId: phoneNumber, unjoiningUserId:self.userId! , rideParticipants: self.rideParticipantsObject, riderRideId: self.riderRideId!, ride: rideObj, viewController: self, completionHandler: {
                self.displayNoConnectionDialogue()
            })
        case Strings.route:
            self.moveToSelectedUserRouteView(phoneNumber: phoneNumber)
        case Strings.ride_notes:
            MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideParticipant.rideNote, viewController: nil)
        case String(format: Strings.rate_user, arguments: [rideParticipant.name ?? ""]):
            let viewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
            viewController.initializeDataAndPresent(name: rideParticipant.name ?? "",imageURI: rideParticipant.imageURI,gender: rideParticipant.gender ?? "U",userId: phoneNumber, rideId: rideParticipant.riderRideId)
            self.navigationController?.view.addSubview(viewController.view)
            self.navigationController?.addChild(viewController)
        default:
            break
        }
    }
    
    private func showOTPToPickupView(rideParticipant: RideParticipant, riderRideId: Double) {
        let otpToPickupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPToPickupViewController") as! OTPToPickupViewController
        otpToPickupViewController.initializeData(rideParticipant: rideParticipant, riderRideId: riderRideId, isFromMultiPickup: false, passengerPickupDelegate: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: otpToPickupViewController)
    }
    
    private func updatePassengerRideStatus(rideParticipant: RideParticipant, status : String, riderRideId: Double) {
        QuickRideProgressSpinner.startSpinner()
        PassengerRideServiceClient.updatePassengerRideStatus(passengerRideId: rideParticipant.rideId, joinedRiderRideId:riderRideId, passengerId: rideParticipant.userId, status: status,fromRider: true, otp: nil, viewController: self, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if status == Ride.RIDE_STATUS_COMPLETED{
                    self.rideRequestAckLabel.text = Strings.checked_out_passenger
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        self.rideRequestAckView.isHidden = true
                    })
                }
            } else if responseObject != nil && responseObject!["result"] as? String == "FAILURE" {
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                if responseError?.errorCode == RideValidationUtils.RIDER_PICKED_UP_ERROR{
                    MessageDisplay.displayInfoViewAlert(title: "", message: String(format: Strings.rider_picked_up_error, arguments: [rideParticipant.name!,rideParticipant.name!]), infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
                    }
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func updatePassengerStatusByRider(rideParticipant: RideParticipant, status: String, riderRideId: Double){
        if status == Ride.RIDE_STATUS_STARTED && RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: rideObj, userProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
            showOTPToPickupView(rideParticipant: rideParticipant, riderRideId: riderRideId)
        } else {
            updatePassengerRideStatus(rideParticipant: rideParticipant, status: status, riderRideId: riderRideId)
        }
    }

    func moveToSelectedUserRouteView(phoneNumber : Double){
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: phoneNumber, rideParticipants: self.rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        let rideRouteDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePathDisplayViewController") as! RidePathDisplayViewController
        rideRouteDisplayViewController.initializeDataBeforePresenting(currentUserRidePath: rideObj?.routePathPolyline, joinedUserRidePath: nil, currentUserRideType: rideObj!.rideType!, currentUserRideId: rideObj!.rideId, joinedUserRideId: rideParticipant!.rideId, pickUp: CLLocationCoordinate2D(latitude: rideParticipant!.startPoint!.latitude, longitude: rideParticipant!.startPoint!.longitude),drop: CLLocationCoordinate2D(latitude: rideParticipant!.endPoint!.latitude, longitude: rideParticipant!.endPoint!.longitude), points: rideParticipant!.points!)
        self.present(rideRouteDisplayViewController, animated: false, completion: nil)
    }
    func displayConnectedUserProfile(phoneNumber : Double){
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: phoneNumber, rideParticipants: self.rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        
        let vc  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        
        
        
        if rideParticipant!.rider {
            if riderRide == nil{
                return
            }
            let vehicle = Vehicle(ownerId:riderRide!.userId,vehicleModel: riderRide!.vehicleModel,vehicleType: riderRide!.vehicleType,registrationNumber: riderRide!.vehicleNumber,capacity: riderRide!.capacity,fare: riderRide!.farePerKm,makeAndCategory: riderRide!.makeAndCategory,additionalFacilities: riderRide!.additionalFacilities,riderHasHelmet : riderRide!.riderHasHelmet)
            vehicle.imageURI = riderRide!.vehicleImageURI
            
            vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber : phoneNumber),isRiderProfile: UserRole.Rider,rideVehicle: vehicle, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: rideParticipant!.rideNote, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
            
            self.navigationController?.pushViewController(vc, animated: false)
        }else{
            vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber : phoneNumber),isRiderProfile: UserRole.Passenger,rideVehicle: nil, userSelectionDelegate: nil, displayAction: false,isFromRideDetailView : false, rideNotes: rideParticipant!.rideNote, matchedRiderOnTimeCompliance: nil, noOfSeats: rideParticipant!.noOfSeats, isSafeKeeper: false)
            
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
    func handleChatWithConnectedUser(rideParticipant:RideParticipant){
        guard let contactNoStr = rideParticipant.contactNo, let ride = rideObj, let rideType = ride.rideType else { return }
        AppUtilConnect.callNumber(phoneNumber: contactNoStr,receiverId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), refId: rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId), name: rideParticipant.name ?? "", targetViewController: self)
    }
    
    func message(phoneNumber:String?, message : String){
        
        let messageViewConrtoller = MFMessageComposeViewController()
        
        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            if phoneNumber != nil{
                messageViewConrtoller.recipients = [phoneNumber!]
            }
            messageViewConrtoller.messageComposeDelegate = self
            self.present(messageViewConrtoller, animated: false, completion: nil)
            
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: false, completion: nil)
    }
    // MARK: - IBActions
    
    @IBAction func rideOptionsButtonClick(_ sender: Any) {
        if rideObj == nil{
            return
        }
        let ride : Ride?
        if rideObj?.rideType == Ride.RIDER_RIDE{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideObj!.rideId)
        }else{
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideObj!.rideId)
        }
        if ride == nil
        {
            return
        }
        let rideActionsMenuController = RideActionsMenuController(ride: ride!,isFromRideView :true,viewController: self,rideUpdateListener: self,riderRide: riderRide, delegate: self)
        let rideStatusObj = rideObj!.prepareRideStatusObject()
        
        if rideObj!.rideType == Ride.RIDER_RIDE{
            
            if rideObj!.status != Ride.RIDE_STATUS_STARTED{
                rideActionsMenuController.editGroupAlertAction()
            }else{
                rideActionsMenuController.editGroupAlertActionAfterRideStarted()
            }
        }else if rideObj!.rideType == Ride.PASSENGER_RIDE{
            rideActionsMenuController.editGroupAlertActionForPassenger()
        }
        rideActionsMenuController.repeatGroupAction()
        
        if rideStatusObj.isRescheduleAllowed(){
            rideActionsMenuController.createRideRescheduleUIAlertAction()
        }
        if ride?.rideType == Ride.RIDER_RIDE || (ride?.rideType == Ride.PASSENGER_RIDE && (ride?.status == Ride.RIDE_STATUS_SCHEDULED || ride?.status == Ride.RIDE_STATUS_STARTED || ride?.status == Ride.RIDE_STATUS_DELAYED)){
            rideActionsMenuController.createShareRidePathUIAlertAction()
        }
        if rideObj!.rideType == Ride.PASSENGER_RIDE && rideObj!.status == Ride.RIDE_STATUS_REQUESTED{
            
            rideActionsMenuController.createRideCancellationUIAlertAction(rideParticipants: rideParticipantsObject, rideCancelDelegate: self)
            
        }else if rideStatusObj.isCancelRideAllowed(){
            
            
            rideActionsMenuController.createRideCancellationUIAlertAction(rideParticipants: rideParticipantsObject, rideCancelDelegate: self)
        }
        rideActionsMenuController.showAlertController()
    }
    
    func createObjectfromJSON(dictionary:NSDictionary) -> NSArray?{
        if (dictionary.value(forKey: "resultData") as! NSArray).count > 0
        {
            let result:NSArray = dictionary.value(forKey: "resultData") as! NSArray
            print(result[0])
            return result
        }
        return nil
    }
    
    
    @IBAction func moveToCurrentPath(_ sender: Any) {
        if rideObj == nil{
            return
        }
        zoom = false
        fitToScreenAfterDelay()
    }
    
    @IBAction func findMatchedRidersAfterJoin(_ sender: Any) {
        moveToInvite(isFromContacts: false)
    }
    
    @objc func movetoInviteViewController(_ gesture :UITapGestureRecognizer){
        moveToInvite(isFromContacts: false)
    }
    func moveToInvite(isFromContacts: Bool){
        if rideObj == nil{
            return
        }
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(message: Strings.DATA_CONNECTION_NOT_AVAILABLE, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-180))
            return
        }
        
        let inviteMatchedUsersAndContactsViewController : InviteMatchedUsersAndContactsViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteMatchedUsersAndContactsViewController") as! InviteMatchedUsersAndContactsViewController
        inviteMatchedUsersAndContactsViewController.initializeDataBeforePresenting(scheduleRide: rideObj!, isFromGroups: false, isFromContacts: isFromContacts,isFromCanceRide: false, isFromRideCreation: isFromRideCreation)
        self.navigationController?.pushViewController(inviteMatchedUsersAndContactsViewController, animated: false)
    }
    
    func receiveClosedRides(closedRiderRides: [Double : RiderRide], closedPassengerRides: [Double : PassengerRide]) {}
    
    func receivedActiveRides(activeRiderRides closedRiderRides: [Double : RiderRide], activePassengerRides closedPassengerRides: [Double : PassengerRide]) {}
    func receiveActiveRegularRides(regularRiderRides: [Double : RegularRiderRide], regularPassengerRides: [Double : RegularPassengerRide]) {}
    
    
    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {
        isRideDetailInfoRetrieved = true
        progressSpinner.isHidden = true
        progressSpinner.stopAnimating()
        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()
        if responseError != nil{
            MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self, handler: { (result) in
                self.goBackToCallingViewController()
                return
            })
            
        }else if error != nil{
            ErrorProcessUtils.handleError(error: error, viewController: self, completion: { (UIAlertAction) in
                self.goBackToCallingViewController()
                return
            })
        }
        
    }
    
    func receiveRideParticipantLocation(rideParticipantLocation: RideParticipantLocation) {
        if self.viewMap == nil {return}
        if self.riderRide == nil || rideParticipantLocation.rideId == nil {return}
        if self.riderRide!.rideId != rideParticipantLocation.rideId {return}
        participantLocationChanged(rideParticipantLocation: rideParticipantLocation)
    }
    
    
    func participantLocationChanged(rideParticipantLocation: RideParticipantLocation){
        
        if(rideParticipantLocation.userId == riderRide?.userId){
            handleRiderRideLocationChange(rideParticipantLocation: rideParticipantLocation)
        }else{
            handlePassengerLocationChange(rideParticipantChangedLocation: rideParticipantLocation)
        }
    }
    
    func handlePassengerLocationChange( rideParticipantChangedLocation:RideParticipantLocation){
        let rideParticipant:RideParticipant? = RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideParticipantChangedLocation.userId!,rideParticipants: rideParticipantsObject)
        if rideParticipant == nil || rideParticipant?.status == Ride.RIDE_STATUS_STARTED {
            AppDelegate.getAppDelegate().log.error("Could not process due to rideParticipant :\(String(describing: rideParticipant)),rideParticipantStatus : \(String(describing: rideParticipant?.status))")
            return
        }
        let participantElement = rideParticipantMarkers[rideParticipantChangedLocation.userId!]
        if (participantElement?.pickupMarker == nil) {
            AppDelegate.getAppDelegate().log.error("Could not process due to participantMarker is nil)")
            return
        }
        let newLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: rideParticipantChangedLocation.latitude!, longitude: rideParticipantChangedLocation.longitude!)
        participantElement?.pickupMarker!.position = newLocation

    }
    fileprivate func getETAForParticipant(riderParticipantLocation : RideParticipantLocation,participantId : Double) -> ParticipantETAInfo?{
        if let participantETAInfos = riderParticipantLocation.participantETAInfos{
            for participantETAInfo in participantETAInfos {
                if participantETAInfo.participantId == participantId{
                    return participantETAInfo
                }
            }
        }
        return nil
    }
    func checkAndDisplayETAForPassenger(rideParticipantLocation : RideParticipantLocation?) {
        if rideParticipantLocation == nil || rideObj == nil || rideObj?.rideType == Ride.RIDER_RIDE || rideObj?.status == Ride.RIDE_STATUS_STARTED || riderRide == nil || riderRideId == nil{
            AppDelegate.getAppDelegate().log.error("rideObj :\(String(describing: rideObj)), riderRide : \(String(describing: riderRide))")
            self.clearLocationUpdateMarker()
            return
        }
        if let participantETAInfo = getETAForParticipant(riderParticipantLocation: rideParticipantLocation!, participantId: rideObj!.userId){
            let routeMetrics = RouteMetrics()
            routeMetrics.fromLat = rideParticipantLocation!.latitude!
            routeMetrics.fromLng = rideParticipantLocation!.longitude!
            routeMetrics.toLat = participantETAInfo.destinationLatitude
            routeMetrics.toLng = participantETAInfo.destinationLongitude
            routeMetrics.error = participantETAInfo.error
            routeMetrics.journeyDurationInTraffic = participantETAInfo.durationInTraffic
            routeMetrics.journeyDuration = participantETAInfo.duration
            routeMetrics.routeDistance = participantETAInfo.routeDistance
            routeMetrics.creationTime = rideParticipantLocation!.lastUpdateTime ?? NSDate().getTimeStamp()
            receiveETAForPassenger(routeMetrics: routeMetrics)
        }
        
    }
    
    func checkAndDisplayETAForRider(riderLocation : RideParticipantLocation){

        if rideObj == nil || (rideObj?.rideType == Ride.PASSENGER_RIDE && !isModerator) || riderRide == nil || riderRideId == nil {
            return
        }
        if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: riderRide!.startTime, time2: NSDate().timeIntervalSince1970*1000) >  MIN_TIME_DIFF_FOR_ETA{
            return
        }
        
        let nextPickup = RideViewUtils.getNextPassengerToPickup(rideParticipants: passengersInfo)
        
        if selectedPickupUserId != 0 && rideObj?.status == Ride.RIDE_STATUS_STARTED {
            let selectedPassenger = RideViewUtils.getRideParticipantObjForParticipantId(participantId: selectedPickupUserId, rideParticipants: rideParticipantsObject)
            if selectedPassenger != nil && selectedPassenger!.status != Ride.RIDE_STATUS_STARTED{
                if let passengerETAInfo = self.getETAForParticipant(riderParticipantLocation: riderLocation, participantId: selectedPickupUserId){
                    let nextPickupRouteMetrics = RouteMetrics()
                    nextPickupRouteMetrics.fromLat = riderLocation.latitude!
                    nextPickupRouteMetrics.fromLng = riderLocation.longitude!
                    nextPickupRouteMetrics.toLat = passengerETAInfo.destinationLatitude
                    nextPickupRouteMetrics.toLng = passengerETAInfo.destinationLongitude
                    nextPickupRouteMetrics.error = passengerETAInfo.error
                    nextPickupRouteMetrics.routeDistance = passengerETAInfo.routeDistance
                    nextPickupRouteMetrics.journeyDuration = passengerETAInfo.duration
                    nextPickupRouteMetrics.journeyDurationInTraffic = passengerETAInfo.durationInTraffic
                    nextPickupRouteMetrics.creationTime = riderLocation.lastUpdateTime ?? NSDate().getTimeStamp()
                    self.receiveETAForSelectedParticipant(routeMetrics: nextPickupRouteMetrics, passengerInfo: selectedPassenger, selectedIndex: nextPassengerToPickupIndex ?? 0)
                }
            }
            else{
                hidePassengerPickupInfoView()
            }
            return
        }else if nextPickup != nil && nextPickup!.0 != nil && nextPickup!.1 != nil && rideObj?.status == Ride.RIDE_STATUS_STARTED {
            if nextPickup!.1!.status != Ride.RIDE_STATUS_STARTED, let passengerETAInfo = getETAForParticipant(riderParticipantLocation: riderLocation, participantId: nextPickup!.1!.userId) {
                let nextPickupRouteMetrics = RouteMetrics()
                nextPickupRouteMetrics.fromLat = riderLocation.latitude!
                nextPickupRouteMetrics.fromLng = riderLocation.longitude!
                nextPickupRouteMetrics.toLat = passengerETAInfo.destinationLatitude
                nextPickupRouteMetrics.toLng = passengerETAInfo.destinationLongitude
                nextPickupRouteMetrics.error = passengerETAInfo.error
                nextPickupRouteMetrics.routeDistance = passengerETAInfo.routeDistance
                nextPickupRouteMetrics.journeyDuration = passengerETAInfo.duration
                nextPickupRouteMetrics.journeyDurationInTraffic = passengerETAInfo.durationInTraffic
                nextPickupRouteMetrics.creationTime = riderLocation.lastUpdateTime ?? NSDate().getTimeStamp()
                receiveETAForSelectedParticipant(routeMetrics: nextPickupRouteMetrics, passengerInfo: nextPickup!.1!, selectedIndex: nextPickup!.0!)
            } else {
                self.viewArrivalOrPickupTime.isHidden = true
                hidePassengerPickupInfoView()
            }
        }
        else{
            if isModerator {
                self.viewArrivalOrPickupTime.isHidden = true
                return
            }
            if let passengerETAInfo = getETAForParticipant(riderParticipantLocation: riderLocation, participantId: rideObj!.userId) {
                let riderRouteMetrics = RouteMetrics()
                riderRouteMetrics.fromLat = riderLocation.latitude!
                riderRouteMetrics.fromLng = riderLocation.longitude!
                riderRouteMetrics.toLat = passengerETAInfo.destinationLatitude
                riderRouteMetrics.toLng = passengerETAInfo.destinationLongitude
                riderRouteMetrics.error = passengerETAInfo.error
                riderRouteMetrics.routeDistance = passengerETAInfo.routeDistance
                riderRouteMetrics.journeyDuration = passengerETAInfo.duration
                riderRouteMetrics.journeyDurationInTraffic = passengerETAInfo.durationInTraffic
                riderRouteMetrics.creationTime = riderLocation.lastUpdateTime ?? NSDate().getTimeStamp()
                receiveETAForRider(routeMetrics: riderRouteMetrics)
            }
        }
    }

    func receiveETAForRider(routeMetrics : RouteMetrics) {
        etaError = nil
        if rideObj?.rideType == Ride.PASSENGER_RIDE {
            viewArrivalOrPickupTime.isHidden = true
            labelArrivalOrPickupTime.text = nil
            return
        }
        DispatchQueue.main.async {
            if self.riderRide == nil || self.rideObj == nil{
                return
            }
            self.etaTime = routeMetrics.journeyDurationInTraffic
            if self.etaTime <= 0{
                self.etaTime = 1
            }
            self.labelArrivalOrPickupTime.textColor = UIColor.black
            if self.isMapFullView == nil || !self.isMapFullView!{
                self.viewArrivalOrPickupTimeTopSpaceConstraint.constant = 70
            }
            else{
                self.viewArrivalOrPickupTimeTopSpaceConstraint.constant = 20
            }
            self.viewArrivalOrPickupTime.isHidden = false
            self.labelArrivalOrPickupTime.text = "ETA \(String(self.etaTime)) min"
        }
    }
    
    func receiveETAForPassenger(routeMetrics: RouteMetrics) {

        if let error = routeMetrics.error, error.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR{
            etaError = error
            if self.isMapFullView == nil || !self.isMapFullView!{
                self.viewArrivalOrPickupTime.isHidden = true
            }
            else{
                self.viewArrivalOrPickupTime.isHidden = false
            }
            self.labelRiderRideStatus.textColor = UIColor(netHex: 0xB50000)
            self.labelRiderRideStatus.text = Strings.rider_crossed_pickup
            self.labelArrivalOrPickupTime.textColor = UIColor(netHex: 0xB50000)
            self.labelArrivalOrPickupTime.text = Strings.rider_crossed_pickup
            self.zoomAndShowPassengerRoutePath()
            self.setLocationDetailsMarkerAtLocation(routeMetrics: routeMetrics, passengerRide: self.rideObj as! PassengerRide)
        } else {
            etaError = nil
            DispatchQueue.main.async{
                if self.rideObj == nil || self.riderRide == nil || !self.rideObj!.isKind(of: PassengerRide.self) || self.rideObj!.status == Ride.RIDE_STATUS_STARTED{
                    return
                }
                self.etaTime = routeMetrics.journeyDurationInTraffic
                if self.etaTime <= 0{
                    self.etaTime = 1
                }
                self.setLocationDetailsMarkerAtLocation(routeMetrics: routeMetrics, passengerRide: self.rideObj as! PassengerRide)
                let startTime = self.calculatePickupTimeBasedOnETA()
                for rideParticipant in self.rideParticipantsObject{
                    if rideParticipant.rider {
                        self.setArrivalTimeOfRiderToPickup(rideParticipant: rideParticipant)
                    }
                }
                self.labelRideScheduledTime.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: startTime/1000), format : DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aa)
            }
        }
    }
    func calculatePickupTimeBasedOnETA() -> Double{
        return  NSDate().timeIntervalSince1970*1000 + (Double(self.etaTime)*60*1000)
    }
    
    func receiveETAForSelectedParticipant(routeMetrics: RouteMetrics?, passengerInfo: RideParticipant?, selectedIndex: Int) {
        if riderRide == nil || rideObj == nil || passengerInfo == nil {
            return
        }
        if let error = routeMetrics!.error, error.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR{
            etaError = error
        } else {
            etaError = nil
        }
        if(routeMetrics == nil) {
            self.nextPassengerPickupTime = 0
            self.selectedPickupUserId = 0
        }else{
            self.nextPassengerPickupTime = routeMetrics!.journeyDurationInTraffic
            if self.nextPassengerPickupTime <= 0{
                self.nextPassengerPickupTime = 1
            }
            self.selectedPickupUserId = passengerInfo!.userId
        }
        if routeMetrics != nil && routeMetrics!.routeDistance > 0{
            self.rideTakerDistanceToPickUp = routeMetrics!.routeDistance
        }
        if etaError != nil && etaError!.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR {
            nextPassengerToPickupIndex = selectedIndex
            showPassengerInfoOfNextPickUp(passengerInfo: passengerInfo!)
            self.labelRideTakerDistanceToPickupPointOrRiderName.isHidden = false
            self.labelRideTakerDistanceToPickupPointOrRiderName.text = Strings.pickup_point_crossed
            downArrowImageView.image = downArrowImageView.image?.withRenderingMode(.alwaysTemplate)
            downArrowImageView.tintColor = UIColor(netHex: 0xF9A825)
            self.passengerDetailViewForRider.backgroundColor = UIColor(netHex: 0xF9A825)
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
            if isMapFullView == nil || !isMapFullView!{
                self.viewArrivalOrPickupTime.isHidden = true
            }
            else{
                self.viewArrivalOrPickupTime.isHidden = false
            }
            self.labelArrivalOrPickupTime.text = Strings.pickup_point_crossed
            self.labelArrivalOrPickupTime.textColor = UIColor(netHex: 0xF9A825)
            self.nextPassengerPickupTime = 0
        } else {
            nextPassengerToPickupIndex = selectedIndex
            downArrowImageView.image = downArrowImageView.image?.withRenderingMode(.alwaysTemplate)
            downArrowImageView.tintColor = UIColor(netHex: 0xeedb5c)
            self.passengerDetailViewForRider.backgroundColor = UIColor(netHex: 0xeedb5c)
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
            showPassengerInfoOfNextPickUp(passengerInfo: passengerInfo!)
            self.showPickUpDistanceWithMins(passengerInfo: passengerInfo!)
            self.zoomAndShowRiderRoutePath()
        }
    }

    func showPickUpDistanceWithMins(passengerInfo: RideParticipant){
        self.viewArrivalOrPickupTime.isHidden = true
        if nextPassengerToPickupIndex == nil || nextPassengerToPickupIndex! >= passengersInfo.count{
            labelRideTakerDistanceToPickupPointOrRiderName.isHidden = true
            labelRideTakerDistanceToPickupPointOrRiderName.text = nil
            return
        }
        var desc = ""
        if self.rideTakerDistanceToPickUp != nil && self.rideTakerDistanceToPickUp! > 0{
            desc = CummulativeTravelDistance.getReadableDistance(distanceInMeters: self.rideTakerDistanceToPickUp!)
        }
        if nextPassengerPickupTime > 0{
            if isMapFullView == nil || !isMapFullView!{
                self.viewArrivalOrPickupTime.isHidden = true
            }
            else{
                self.viewArrivalOrPickupTime.isHidden = false
            }
            self.labelArrivalOrPickupTime.textColor = UIColor.black
            self.labelArrivalOrPickupTime.text = "Pickup \(passengerInfo.name!) in " + String(nextPassengerPickupTime) + " min"
            if desc.isEmpty {
                desc = String(nextPassengerPickupTime) + "min away"
            } else {
                desc = desc + ", " + String(nextPassengerPickupTime) + "min away"
            }
        }
        if desc.isEmpty == false {
            labelRideTakerDistanceToPickupPointOrRiderName.isHidden = false
            labelRideTakerDistanceToPickupPointOrRiderName.text = desc
        }
        else{
            labelRideTakerDistanceToPickupPointOrRiderName.isHidden = true
            labelRideTakerDistanceToPickupPointOrRiderName.text = nil
        }
    }

    func hidePassengerPickupInfoView() {
        if nextPassengerToPickupIndex == 0 && isModerator && !passengerDetailViewForRider.isHidden {
            return
        }
        passengerDetailViewForRider.isHidden = true
        if isMapFullView == nil || !isMapFullView!{
            mapUtilitiesBottomSpaceConstraint.constant = 20
        }
    }
    
    func getTimeToStartRide()->Int{
        if riderRide == nil{
            return 0
        }
        let duration = DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: riderRide!.startTime, time2: NSDate().timeIntervalSince1970*1000)
        if(duration > 0){
            return duration
        }else {
            return  0
        }
    }

    func handleRiderRideLocationChange(rideParticipantLocation : RideParticipantLocation){

        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideParticipantLocation.userId!, rideParticipants : rideParticipantsObject)
        if rideParticipant == nil {
            return
        }
        if riderRide == nil{
            return
        }
        let newLocation : CLLocationCoordinate2D  = CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!)
        let latLongOnRoute = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: newLocation, routePath: rideObj!.routePathPolyline)
        if(rideCurrentLocation == nil) {rideCurrentLocation = latLongOnRoute}
        checkAndDisplayETAForPassenger(rideParticipantLocation: rideParticipantLocation)
        checkAndDisplayETAForRider(riderLocation: rideParticipantLocation)
        self.displayRiderMarkerAtCurrentLocation(rideParticipantLocation: rideParticipantLocation, newLocation: latLongOnRoute,lastLocation : self.rideCurrentLocation!, rideParticipant: rideParticipant!)
    }
    
    func participantStatusUpdated(rideStatus: RideStatus){
        AppDelegate.getAppDelegate().log.debug("participantStatusUpdated :\(rideStatus)")
        self.refreshButtonAnimationView.isHidden = true
        self.refreshButtonAnimationView.animationView.stop()
        if rideObj == nil {
            return
        }
        if self.rideStatusObj == nil {
            return
        }
        if !RideViewUtils.isStatusUpdateForCurrentRide(newRideStatus: rideStatus, currentParticipantRide : rideObj , associatedRiderRide : riderRide){
            return
        }
        if RideViewUtils.isRedundantStatusUpdate(newRideStatus: rideStatus, currentRideStatus: self.rideStatusObj!){
            return
        }
        if(Ride.RIDER_RIDE == rideStatus.rideType){
            handleRiderStatusChange(rideStatus: rideStatus)
        }else{
            handlePassengerStatusChange(rideStatus: rideStatus)
        }
        
    }
    
    func participantRideRescheduled(rideStatus: RideStatus) {
        if rideObj == nil{
            return
        }
        var updatedRide : Ride?
        if rideObj?.rideType == Ride.RIDER_RIDE{
            updatedRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideObj!.rideId)
        }else if rideObj?.rideType == Ride.PASSENGER_RIDE{
            updatedRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideObj!.rideId)
        }
        if updatedRide == nil{
            return
        }
        
        displayRideScheduledTime()
        
        if rideStatus.rideType == Ride.RIDER_RIDE{
            loadParticipantImages()
            loadRideParticipantMarkers()
        }
        if rideObj != nil && Ride.RIDER_RIDE == rideObj!.rideType && rideStatusObj != nil && riderRide != nil && RideViewUtils.isPassengerAdditionAllowed(currentRideStatus: rideStatusObj!, associatedRiderRide: riderRide!)
        {
            getMatchingPassengersCountAndDisplay()
        }
        if rideObj != nil && Ride.PASSENGER_RIDE == rideObj!.rideType && Ride.RIDE_STATUS_REQUESTED == rideObj!.status{
            getMatchingRidersCountAndDisplay()
        }
        displayRideStatusAndFareDetailsToUser(status: Ride.RIDE_STATUS_SCHEDULED)
        if Ride.PASSENGER_RIDE == rideObj?.rideType{
            if self.riderRide != nil {
                handleETAToPassenger()
            }
        }else{
            if self.riderRide != nil{
                handleETAToRider()
            }
        }

    }

    func checkAndDisplayRiderMarker(userId : Double){
        AppDelegate.getAppDelegate().log.debug("userId: \(userId),LocationObjects:\(self.rideParticipantLocationObject.count)")
        var rideParticipantLocation  = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: userId, rideParticipantLocations: self.rideParticipantLocationObject)
        let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: userId, rideParticipants : rideParticipantsObject)
        if rideParticipant == nil{
            return
        }
        if rideParticipantLocation == nil {
            AppDelegate.getAppDelegate().log.debug("rideParticipantLocation is nil")
            rideParticipantLocation = RideParticipantLocation(rideId : riderRideId!, userId : userId, latitude : rideParticipant!.startPoint!.latitude, longitude : rideParticipant!.startPoint!.longitude, bearing : 0,participantETAInfos: nil)
        }
        let rideLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: rideParticipantLocation!.latitude!, longitude: rideParticipantLocation!.longitude!)
        let latLongOnRoute = LocationClientUtils.getNearestLatLongFromThePath(checkLatLng: rideLocation, routePath: rideObj!.routePathPolyline)
        displayRiderMarkerAtCurrentLocation(rideParticipantLocation: rideParticipantLocation!, newLocation: latLongOnRoute,lastLocation: latLongOnRoute, rideParticipant: rideParticipant!)
    }


    func displayRiderMarkerAtCurrentLocation(rideParticipantLocation: RideParticipantLocation, newLocation : CLLocationCoordinate2D,lastLocation : CLLocationCoordinate2D, rideParticipant: RideParticipant){
        
        if self.riderRide == nil || self.viewMap.delegate == nil || routePathPolyline == nil || rideObj == nil {
            return
        }
        if rideParticipant.status == Ride.RIDE_STATUS_STARTED || NSDate().getTimeStamp() > riderRide!.startTime {
            handleVehicleLocationChange(rideParticipantLocation: rideParticipantLocation, rideParticipant: rideParticipant, newLocation: newLocation)
        } else {
            setRiderImageAtLocation(rideParticipantLocation: rideParticipantLocation, rideParticipant: rideParticipant, newLocation: newLocation)
        }
    }
    
    func setRiderImageAtLocation(rideParticipantLocation : RideParticipantLocation, rideParticipant: RideParticipant, newLocation: CLLocationCoordinate2D) {
        if routeNavigationMarker == nil {
            routeNavigationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!))
        }
        routeNavigationMarker.map = viewMap
        routeNavigationMarker.zIndex = 15
        routeNavigationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        routeNavigationMarker.isFlat = true
        routeNavigationMarker.isTappable = true
        setRiderImage(rideParticipant: rideParticipant)
        updateVehicleOrRiderImageBasedOnLocation(newLocation: newLocation)
    }
    
    func handleVehicleLocationChange(rideParticipantLocation : RideParticipantLocation, rideParticipant: RideParticipant, newLocation: CLLocationCoordinate2D) {
        if routeNavigationMarker == nil {
            routeNavigationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!))
        }
        routeNavigationMarker.map = viewMap
        routeNavigationMarker.zIndex = 15
        routeNavigationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        routeNavigationMarker.isFlat = true
        routeNavigationMarker.isTappable = true
        if rideParticipantLocation.bearing != nil && rideParticipantLocation.bearing != 0{
            routeNavigationMarker.rotation = rideParticipantLocation.bearing!
        }
        setVehicleImage()
        updateVehicleOrRiderImageBasedOnLocation(newLocation: newLocation)
    }
    
    func setRiderImage(rideParticipant: RideParticipant) {
        ImageCache.getInstance().setImagetoMarker(imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender ?? "U", marker: routeNavigationMarker, isCircularImageRequired: true, imageSize: ImageCache.DIMENTION_SMALL)
    }
    
    func setVehicleImage() {
        var vehicleImage : UIImage?
        if Vehicle.VEHICLE_TYPE_BIKE == riderRide!.vehicleType {
            vehicleImage = UIImage(named: "bike_top")
            routeNavigationMarker.icon = vehicleImage!
        } else {
            vehicleImage = UIImage(named: "new_car")
            routeNavigationMarker.icon = ImageUtils.RBResizeImage(image: vehicleImage!, targetSize: CGSize(width: 55,height: 55))
        }
    }
    
    func updateVehicleOrRiderImageBasedOnLocation(newLocation: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({[weak self] () -> Void in
            guard let routeNavigationMarker = self?.routeNavigationMarker else { return }
            routeNavigationMarker.position = newLocation
        })
        CATransaction.commit()
        rideCurrentLocation = newLocation
        if rideObj?.rideType == Ride.PASSENGER_RIDE{
            zoomAndShowPassengerRoutePath()
        }
        else if rideObj?.rideType == Ride.RIDER_RIDE{
            zoomAndShowRiderRoutePath()
        }
    }
    
    private func setLocationDetailsMarkerAtLocation(routeMetrics: RouteMetrics, passengerRide: PassengerRide) {
        clearLocationUpdateMarker()
        let riderLocationDetailsInfoWindow = UIView.loadFromNibNamed(nibNamed: "RiderLocationDetails") as! RiderLocationDetails
        riderLocationDetailsInfoWindow.setETAInfo(routeMetrics: routeMetrics)
        let icon = ViewCustomizationUtils.getImageFromView(view: riderLocationDetailsInfoWindow)
        locationUpdateMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: passengerRide.pickupLatitude, longitude: passengerRide.pickupLongitude), shortIcon: icon, tappable: true, anchor: CGPoint(x: 0.0, y: -0.1))
        let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: routeMetrics.creationTime)
        locationUpdateMarker.title = String(timeDifferenceInSeconds)
        locationUpdateMarker.zIndex = 10
        locationUpdateMarker.isFlat = true
    }
    
    private func clearLocationUpdateMarker() {
        if locationUpdateMarker == nil {
            return
        }
        locationUpdateMarker.map = nil
        locationUpdateMarker = nil
    }
    
    func removeMarker(userId : Double){
        if let rideParticipantElement = self.rideParticipantMarkers[userId]{
            AppDelegate.getAppDelegate().log.debug("removeMarker: \(userId)")
            rideParticipantElement.removeRideParticipantElement()
        }
    }
    
    func onParticipantActionComplete(rideStatus : String){
        QuickRideProgressSpinner.stopSpinner()
        if self.rideObj == nil {return}
        self.rideStatusObj = self.rideObj?.prepareRideStatusObject()
        self.updateRideViewControlsAsPerStatus()
        self.loadParticipantImages()
        self.displayRideStatusAndFareDetailsToUser(status: rideStatus)
        addPassengerAdditionControlToView()
        
        
        if Ride.RIDE_STATUS_STARTED == rideStatus{
            self.checkAndDisplayRiderMarker(userId: self.userId!)
            if rideObj?.rideType == Ride.RIDER_RIDE{
                handleETAToRider()
            } else {
                syncRideInvitesOfRide()
                showGreetingBasedOnCriteria()
                clearLocationUpdateMarker()
                showPassengerPickUpMarker(passengerRide: rideObj as! PassengerRide)
            }
        }
        self.removeMarker(userId: self.userId!)
        
    }
    func removeListeners() {
        
        if riderRideId != 0{
            RidesGroupChatCache.getInstance()?.removeRideGroupChatListener(rideId: riderRideId!)
        }
        if participantLocationListener != nil{
            participantLocationListener!.unSubscribeToLocationUpdatesForRide(rideId: riderRideId!)
            UIApplication.shared.isIdleTimerDisabled = false
            
            
        }
        cancelTimer()
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideLocationChangeListener(rideParticipantLocationListener: self)
    }
    
    func startTimer(){
        if riderRide == nil && taxiShareRide == nil{
            return
        }
        var startTime: Double = 0.0
        if riderRide != nil {
         startTime = riderRide!.startTime
        } else {
            startTime = taxiShareRide?.actualStartTime ?? 0.0
        }
        let diff =  DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: startTime, time2: NSDate().getTimeStamp())
        if diff >= 60 {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BaseLiveRideMapViewController.refreshLocation), userInfo: nil, repeats: true)

    }
    func cancelTimer(){
        timer?.invalidate()
    }
    
    @objc func refreshLocation() {
        if taxiShareRide != nil && rideObj != nil && BaseLiveRideMapViewController.baseLiveRideMapViewController == self {
            let rideParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: taxiShareRide!.id, rideParticipantLocations: rideParticipantLocationObject)
            let participantMarkerUpdateTask = ParticipantMarkerUpdateTask(rideParticipantLocation: rideParticipantLocation, currentParticipantRide: rideObj!)
            participantMarkerUpdateTask.pullLatestLocationUpdatesBasedOnExpiry()
            
        } else {
            if riderRide == nil || rideObj == nil || BaseLiveRideMapViewController.baseLiveRideMapViewController != self{
                return
            }
            let rideParticipantLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: riderRide!.userId, rideParticipantLocations: rideParticipantLocationObject)
            
            let participantMarkerUpdateTask = ParticipantMarkerUpdateTask(rideParticipantLocation: rideParticipantLocation, currentParticipantRide: rideObj!)
            participantMarkerUpdateTask.pullLatestLocationUpdatesBasedOnExpiry()
        }
    }
    
    func handleRiderStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleRiderStatusChange")
        let newRideStatus : String = rideStatus.status!
        rideStatusObj?.joinedRideStatus = newRideStatus
        if Ride.RIDE_STATUS_STARTED == newRideStatus{
            enableControlsAsPerStatus()
            self.checkAndDisplayRiderMarker(userId: rideStatus.userId)
            loadParticipantImages()
            self.removeMarker(userId: rideStatus.userId)
            if rideStatus.userId == self.userId{
                self.onParticipantActionComplete(rideStatus: newRideStatus)
                
            }
            
        } else if Ride.RIDE_STATUS_DELAYED == newRideStatus {
            self.checkAndDisplayRiderMarker(userId: rideStatus.userId)
            loadParticipantImages()
        } else if Ride.RIDE_STATUS_CANCELLED == newRideStatus {
            if self.rideObj?.rideType == Ride.PASSENGER_RIDE{
                handleRequestedRide()
                return
            }else{
                goBackToCallingViewController()
                if taxiShareRide?.taxiShareRidePassengerInfos?.count ?? 0 > 1 {
                    delegate?.showCancelFeeWaiverView()
                }
            }
        }else if Ride.RIDE_STATUS_COMPLETED == newRideStatus {
            loadParticipantImages()
            
            if rideObj?.rideType == Ride.PASSENGER_RIDE {
                
                if rideObj?.status == Ride.RIDE_STATUS_STARTED || rideObj?.status == Ride.RIDE_STATUS_COMPLETED{
                    completePassengerRide()
                }else if rideObj?.status == Ride.RIDE_STATUS_SCHEDULED{
                    goBackToCallingViewController()
                }
            }
        }
        displayRideStatusAndFareDetailsToUser(status: newRideStatus)
    }
    
    func checkParticipantStatusAndDisplayMarker(rideParticipant : RideParticipant){
        AppDelegate.getAppDelegate().log.debug("checkParticipantStatusAndDisplayMarker- Status:\(rideParticipant.status) and userid:\(rideParticipant.userId)")
        if rideParticipant.status == Ride.RIDE_STATUS_COMPLETED{
            return
        }
        if (Ride.RIDE_STATUS_SCHEDULED == rideParticipant.status || Ride.RIDE_STATUS_DELAYED == rideParticipant.status || Ride.RIDE_STATUS_STARTED == rideParticipant.status)  && rideParticipant.rider {
            checkAndDisplayRiderMarker(userId: rideParticipant.userId)
            return
        }
        
        if rideParticipant.userId == rideObj!.userId {
            viewMap.isMyLocationEnabled = false
            return
        }
        guard let startPoint =  rideParticipant.startPoint else{
            return
        }
        if Ride.RIDE_STATUS_STARTED == rideParticipant.status && isModerator {
            return
        }
        var participantMarkerElement = rideParticipantMarkers[rideParticipant.userId]
        if participantMarkerElement == nil{
            participantMarkerElement = RideParticipantElements()
        }
        AppDelegate.getAppDelegate().log.debug("checkParticipantStatusAndDisplayMarker - userid:\(rideParticipant.userId)")
        participantMarkerElement!.createOrUpdateRideParticipantElement(viewMap: viewMap, startPoint: startPoint, rideParticipant: rideParticipant, rideParticipantLocationObject: rideParticipantLocationObject, rideObj: self.rideObj)
        rideParticipantMarkers[rideParticipant.userId] = participantMarkerElement
    }
    
    func handlePassengerStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handlePassengerStatusChange")
        let newRideStatus : String = rideStatus.status!
        
        if Ride.RIDE_STATUS_SCHEDULED == newRideStatus{
            if rideStatus.userId == self.userId{
                
                incomingRideInvites.removeAll()
                outGoingRideInvites.removeAll()
                self.riderRideId = rideStatus.joinedRideId
                if self.riderRideId != 0 {
                    handleScheduleRide()
                }
                return
            }
            rideParticipantsObject =  MyActiveRidesCache.getRidesCacheInstance()!.getRideParicipants(riderRideId: riderRideId!)
            self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
            let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideStatus.userId, rideParticipants: rideParticipantsObject)
            if rideParticipant != nil {
                rideParticipantsObject.append(rideParticipant!)
                checkParticipantStatusAndDisplayMarker(rideParticipant: rideParticipant!)
                loadParticipantImages()
            }
            addPassengerAdditionControlToView()
            
        } else if Ride.RIDE_STATUS_STARTED == newRideStatus{
            rideParticipantsObject =  MyActiveRidesCache.getRidesCacheInstance()!.getRideParicipants(riderRideId: riderRideId!)
            self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
            self.etaError = nil
            selectedPickupUserId = 0
            hidePassengerPickupInfoView()
            loadParticipantImages()
            self.removeMarker(userId: rideStatus.userId)
            if rideStatus.userId == userId{
                onParticipantActionComplete(rideStatus: newRideStatus)
            }
            let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideStatus.userId, rideParticipants: rideParticipantsObject)
            if rideParticipant != nil {
                checkParticipantStatusAndDisplayMarker(rideParticipant: rideParticipant!)
            }
            handleETAToRider()
        } else if Ride.RIDE_STATUS_COMPLETED == newRideStatus || Ride.RIDE_STATUS_CANCELLED == newRideStatus{
            rideParticipantsObject = MyActiveRidesCache.singleCacheInstance!.getRideParicipants(riderRideId: riderRideId!)
            self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
            selectedPickupUserId = 0
            hidePassengerPickupInfoView()
            loadParticipantImages()
            addPassengerAdditionControlToView()
            self.removeMarker(userId: rideStatus.userId)
            if Ride.RIDE_STATUS_CANCELLED == newRideStatus && rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.rideId == rideStatus.rideId{
                goBackToCallingViewController()
            }
            if Ride.RIDE_STATUS_COMPLETED == newRideStatus && rideObj?.rideType == Ride.PASSENGER_RIDE && rideObj?.rideId == rideStatus.rideId{
                MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
            }
            handleETAToRider()
        } else if Ride.RIDE_STATUS_DELAYED == rideStatus.status{
            loadParticipantImages()
        }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
            if self.rideObj?.rideType == Ride.RIDER_RIDE{
                rideParticipantsObject = MyActiveRidesCache.singleCacheInstance!.getRideParicipants(riderRideId: riderRideId!)
                enableControlsAsPerStatus()
                selectedPickupUserId = 0
                loadParticipantImages()
                removeMarker(userId: rideStatus.userId)
                handleETAToRider()
                addPassengerAdditionControlToView()
            } else if rideStatus.userId == self.userId{
                handleRequestedRide()
            } else {
                rideParticipantsObject = MyActiveRidesCache.singleCacheInstance!.getRideParicipants(riderRideId: riderRideId!)
                self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
                loadParticipantImages()
                addPassengerAdditionControlToView()
                removeMarker(userId: rideStatus.userId)
            }
            hidePassengerPickupInfoView()
        }
    }
    
    func rideActionCompleted(status: String) {
        
        if rideObj == nil{ return}
        if status == Ride.RIDE_STATUS_STARTED{
            
            if(Ride.RIDER_RIDE == rideObj?.rideType){
                checkAndDisplayRiderMarker(userId: userId!)
                handleETAToRider()
            }
            self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: rideObj, rideParticipantObjects: rideParticipantsObject)
            self.etaError = nil
            rideStatusObj = rideObj?.prepareRideStatusObject()
            addPassengerAdditionControlToView()
            updateRideViewControlsAsPerStatus()
            displayRideStatusAndFareDetailsToUser(status: status)
            loadParticipantImages()
            removeMarker(userId: userId!)
            syncRideInvitesOfRide()
            showGreetingBasedOnCriteria()
            if Ride.PASSENGER_RIDE == rideObj?.rideType {
                showPassengerPickUpMarker(passengerRide: rideObj as! PassengerRide)
                clearLocationUpdateMarker()
            }
        }else if status == Ride.RIDE_STATUS_COMPLETED{
            let myActiveRidesCache : MyActiveRidesCache? =  MyActiveRidesCache.singleCacheInstance
            if myActiveRidesCache != nil{
                myActiveRidesCache!.removeRideUpdateListener(key: MyActiveRidesCache.LiveRideMapViewController_key)
            }
            NotificationStore.getInstance().removeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
            removeListeners()
        }
    }
    
    func rideActionFailed(status: String, error : ResponseError?) {
        AppDelegate.getAppDelegate().log.debug("Ride action for \(status) failed due to : \(String(describing: error))")
    }
    
    @objc func backButtonClicked(_ gesture: UITapGestureRecognizer) {
        goBackToCallingViewController()
    }
    
    @IBAction func chatButtonClicked(_ sender: UIButton) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.centralChatViewController)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: centralChatViewController, animated: false)
    }
    
    @objc func riderImageClicked(_ gesture: UITapGestureRecognizer) {
        if Ride.RIDE_STATUS_REQUESTED == rideObj?.status{
            return
        }
        if riderRide != nil{
            contactSelectedUser(phoneNumber: riderRide!.userId)
        }
    }
    
    @objc func vehicleNameTapped(_ gesture: UITapGestureRecognizer) {
        if riderRide == nil{
            return
        }
        let vehicle = Vehicle(ownerId:riderRide!.userId,vehicleModel: riderRide!.vehicleModel,vehicleType: riderRide!.vehicleType,registrationNumber: riderRide!.vehicleNumber,capacity: riderRide!.capacity,fare: riderRide!.farePerKm,makeAndCategory: riderRide!.makeAndCategory,additionalFacilities: riderRide!.additionalFacilities,riderHasHelmet : riderRide!.riderHasHelmet)
        
        vehicle.imageURI = riderRide!.vehicleImageURI
        let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
        vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: vehicle)
        self.navigationController?.pushViewController(vehicleDisplayViewController, animated: false)
    }
    
    func moveToGroupChatView(){
        guard let currentRiderRideId = riderRideId else { return }
        let destViewController:GroupChatViewController  = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
        destViewController.initailizeGroupChatView(riderRideID: currentRiderRideId)
        if RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller != nil{
            RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller?.dismiss(animated: false, completion: {
                DispatchQueue.main.async(){
                    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                    RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
                }
            })
        }else{
            DispatchQueue.main.async(){
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
            }
        }
        
        
        
    }
    func rideCancelled() {

        ContainerTabBarViewController.indexToSelect = 0
        self.navigationController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.fromPopRooController = true
    }
    
    @IBAction func emergencyButtonClicked(_ sender: Any) {
        
        let emergencyInitializer = AppDelegate.getAppDelegate().getEmergencyInitializer()
        if emergencyInitializer == nil{
            
            displayConfirmationDialog()
        }else {
            UIApplication.shared.keyWindow?.makeToast(message: Strings.emerg_initiated_already, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
        }
        
    }
    
    func displayConfirmationDialog(){
        MessageDisplay.displayErrorAlertWithAction(title: Strings.want_to_start_emergency, isDismissViewRequired : false, message1: Strings.emergency_initiation_msg, message2: nil, positiveActnTitle: Strings.confirm_caps, negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.confirm_caps == result{
                self.checkForTheEmergencyContact()
            }
        })
    }
    func checkForTheEmergencyContact(){
        let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
        if emergencyContactNo == nil || emergencyContactNo!.isEmpty {
            
            self.navigateToEmergencyContactSelection()
        }
        else{
            self.initiateEmergency()
        }
    }
    func navigateToEmergencyContactSelection(){
        let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
        selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
        self.present(selectContactViewController, animated: false, completion: nil)
    }
    func selectedContact(contact: Contact) {
        
        let emergencyContact = EmergencyContactUtils.getEmergencyContactNumberWithName(contact: contact)
        UserDataCache.getInstance()?.updateUserProfileWithTheEmergencyContact(emergencyContact: emergencyContact,viewController : self)
        initiateEmergency()
    }
    
    func initiateEmergency(){
        
        AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: self)
        buttonEmergency.setImage(UIImage(named: "emergency_pressed"), for: UIControl.State.normal)
        let emergencyService =  EmergencyService(viewController: self)
        let shareRidePath = ShareRidePath(viewController: self, rideId: StringUtils.getStringFromDouble(decimalNumber : riderRideId!), userId: StringUtils.getStringFromDouble (decimalNumber : rideObj!.userId))
        shareRidePath.prepareRideTrackCoreURL { (url) in
            emergencyService.startEmergency(urlToBeAttended: url)
        }
        UIApplication.shared.keyWindow?.makeToast(message: Strings.emerg_initiated, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
    }
    func emergencyCompleted() {
        buttonEmergency.setImage(UIImage(named: "sos_ride_view"), for: UIControl.State.normal)
        AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
    }
    func syncRideInvitesOfRide(){
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil || rideObj == nil || rideObj!.rideType == nil{
            return
        }
        let lastSyncedTime :NSDate?
        var rideId: Double?
        var rideType: String?
        if isModerator {
            rideId = riderRide?.rideId
            rideType = riderRide?.rideType
            lastSyncedTime = myActiveRidesCache!.getRiderRideLastSyncedTime(rideId: rideId ?? 0)
        } else {
            rideId = rideObj!.rideId
            rideType = rideObj!.rideType
            if Ride.RIDER_RIDE == rideObj?.rideType{
                lastSyncedTime = myActiveRidesCache!.getRiderRideLastSyncedTime(rideId: rideId ?? 0)
            }else
            {
                lastSyncedTime = myActiveRidesCache!.getPassengerRideLastSyncedTime(rideId: rideId ?? 0)
            }
        }
        if let rideId = rideId, let rideType = rideType {
            let syncRideInvites = RideInvitationsSyncOfRide(rideId: rideId, rideType: rideType, lastSyncedTime: lastSyncedTime, viewController: self, handler: nil)
            syncRideInvites.syncRideInvitations()
        }
    }
    
    func validateAndGetRideInvites(){
        
        if rideObj == nil{
            return
        }
        getIncomingInivtesForTheRide()
        getOutGoingInvitesForRide()
        loadParticipantImages()
    }
    func getIncomingInivtesForTheRide(){
        
        let notificationStore = NotificationStore.getInstance()
        var invites = [RideInvitation]()
        var rideId: Double?
        var rideType: String?
        if isModerator {
            rideId = riderRide?.rideId
            rideType = riderRide?.rideType
        } else {
            if (Ride.PASSENGER_RIDE == rideObj!.rideType! && Ride.RIDE_STATUS_REQUESTED != self.rideObj!.status) || (Ride.RIDER_RIDE == rideObj!.rideType! && riderRide != nil && (riderRide?.availableSeats)! <= 0) {
                self.incomingRideInvites.removeAll()
                return
            }
            rideId = rideObj!.rideId
            rideType = rideObj!.rideType
        }
        if let rideId = rideId, let rideType = rideType {
            invites.append(contentsOf: notificationStore.getReceivedInvitationsForRide(rideId: rideId, rideType: rideType))
            let fromCache  = RideInviteCache.getInstance().getReceivedInvitationsOfRide(rideId: rideId, rideType: rideType)
            for invite in fromCache{
                invites.append(invite)
            }
            incomingRideInvites.removeAll()
            for rideInvite in invites{
                if  checkWhetherThisInviteISAlreadyPartOfRide(rideInvite: rideInvite) == false && checkForDuplicateIncomingInvite(rideInvite: rideInvite) == false && rideInvite.rideInvitationId != nil {
                    incomingRideInvites[rideInvite.rideInvitationId!] = rideInvite
                }
            }
        }
}
    
    func getOutGoingInvitesForRide(){
        if isModerator {
            outGoingRideInvites.removeAll()
            return
        }
        if let rideId = rideObj?.rideId, let rideType = rideObj?.rideType {
            let outGoingInvites = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId, rideType: rideType)

            outGoingRideInvites.removeAll()

            for invite in outGoingInvites{
                if checkWhetherThisInviteISAlreadyPartOfRide(rideInvite: invite) == false && checkForDuplicateOutGoingInvite(rideInvite: invite) == false {
                    outGoingRideInvites.append(invite)
                }
            }
        }
    }
    func checkWhetherThisInviteISAlreadyPartOfRide(rideInvite : RideInvitation) -> Bool{
        if rideObj!.rideType! == Ride.RIDER_RIDE || isModerator {
            let rideParticipant =  RideViewUtils.getRideParticipantObjForParticipantId(participantId: rideInvite.passengerId!, rideParticipants: rideParticipantsObject)
            if rideParticipant != nil{
                RideInviteCache.getInstance().removeInvitation(rideInvite: rideInvite)
                return true
            }
        }
        return false
    }
    func handleNotificationListChange(){
        handleNotificationCountAndDisplay()
    }
    
    func checkForDuplicateOutGoingInvite(rideInvite:RideInvitation) -> Bool{
        if rideObj!.rideType! == Ride.RIDER_RIDE{
            for outGoingInvite in outGoingRideInvites{
                if outGoingInvite.passenegerRideId == rideInvite.passenegerRideId && outGoingInvite.passengerId == rideInvite.passengerId{
                    RideInviteCache.getInstance().removeInvitation(rideInvite: rideInvite)
                    return true
                }
            }
        }else{
            for outGoingInvite in outGoingRideInvites{
                if outGoingInvite.rideId == rideInvite.rideId && outGoingInvite.riderId == rideInvite.riderId{
                    RideInviteCache.getInstance().removeInvitation(rideInvite: rideInvite)
                    return true
                }
            }
        }
        return false
    }
    func checkForDuplicateIncomingInvite(rideInvite:RideInvitation) -> Bool{
        if rideObj!.rideType! == Ride.RIDER_RIDE || isModerator{
            for incomingInvite in incomingRideInvites{
                if incomingInvite.1.passenegerRideId == rideInvite.passenegerRideId{
                    RideInviteCache.getInstance().removeInvitation(rideInvite: rideInvite)
                    return true
                }
            }
        }else{
            for incomingInvite in incomingRideInvites{
                if incomingInvite.1.rideId == rideInvite.rideId{
                    RideInviteCache.getInstance().removeInvitation(rideInvite: rideInvite)
                    return true
                }
            }
        }
        return false
    }
    func checkWhetherRideInvitesToBeLoaded()-> Bool{
        return (Ride.PASSENGER_RIDE == rideObj!.rideType! && Ride.RIDE_STATUS_REQUESTED == rideObj!.status)
            || (Ride.RIDER_RIDE == rideObj!.rideType! && riderRide != nil && (riderRide?.availableSeats)! > 0)
    }
    
    
    func setImageViewBasedOnInvitationStatus( imageView : UIImageView, status : String){
        AppDelegate.getAppDelegate().log.debug(status)
        switch status {
        case RideInvitation.RIDE_INVITATION_STATUS_RECEIVED:
            imageView.image = UIImage(named:"delivered_icon")
        case RideInvitation.RIDE_INVITATION_STATUS_NEW:
            imageView.image = UIImage(named:"sent_icon")
        case RideInvitation.RIDE_INVITATION_STATUS_FAILED:
            imageView.image = UIImage(named:"error_icon")
        case RideInvitation.RIDE_INVITATION_STATUS_READ:
            imageView.image = UIImage(named:"double_tick_green")
        default:
            break
        }
    }
    
    func rideInvitationStatusUpdated(invitationStatus: RideInviteStatus)
    {
        if rideObj == nil {
            return
        }
        validateAndGetRideInvites()
    }
    func updateStatusOfRideInvite( status : RideInviteStatus){
        
        for rideInvitation in outGoingRideInvites{
            if rideInvitation.rideInvitationId == status.invitationId{
                rideInvitation.invitationStatus = status.invitationStatus
            }
        }
    }
    func passengerPickedUp(riderRideId :Double){
        QuickRideProgressSpinner.startSpinner()
        
        RideManagementUtils.completeRiderRide(riderRideId: riderRideId, targetViewController: self,rideActionCompletionDelegate: self)
    }
    func displayAvailableOptionsOnScreen(matchedUsers :[MatchedUser]){
        AppDelegate.getAppDelegate().log.debug("displayAvailableOptionsOnScreen()")
        for marker in matchedUsersMarkers{
            marker.map = nil
        }
        self.matchedUsersMarkers.removeAll()
        self.matchedUsers.removeAll()
        for matchOption in matchedUsers{
            self.matchedUsers[matchOption.uniqueID!] = matchOption
            let marker = GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: matchOption.pickupLocationLatitude!,longitude: matchOption.pickupLocationLongitude!), shortIcon: getMarkerIconBasedOnType(matchedUser: matchOption),tappable: true)
            if matchOption.rideid == 0{
                marker.opacity = 0.6
            }else{
                marker.opacity = 1
            }
            marker.title = matchOption.uniqueID
            matchedUsersMarkers.append(marker)
        }
    }
    func getMarkerIconBasedOnType(matchedUser : MatchedUser) -> UIImage{
        if matchedUser.userRole == MatchedUser.PASSENGER{
            return BaseLiveRideMapViewController.passengerIcon
        }
        if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            return bikeIcon
        }else{
            return BaseLiveRideMapViewController.carIcon
        }
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let uniqueId = marker.title
        if uniqueId == nil || uniqueId!.isEmpty{
            return
        }
        
        let matchedUser = matchedUsers[uniqueId!]
        if matchedUser == nil {
            return
        }
        moveToMatchedUserRouteView(matchedUsers: [matchedUser!])

    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == locationUpdateMarker {
            if let titleInString = marker.title, let title = Int(titleInString), title > 120 {
                MessageDisplay.displayInfoViewAlert(title: Strings.low_network, message: Strings.low_network_msg, infoImage: UIImage(named: "wifi_img"), imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil,buttonTitle: Strings.got_it_caps) {
                }
            } else {
                mapView.selectedMarker = nil
            }
        } else {
            mapView.selectedMarker = marker
        }
        return true
    }
    
    private func moveToMatchedUserRouteView(matchedUsers: [MatchedUser]) {
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController

        mainContentVC.initializeData(ride: rideObj!, matchedUserList: matchedUsers, viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil)
        let drawerContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedViewController") as! RideDetailedViewController
        drawerContentVC.initializeData(ride: rideObj!, matchedUserList: matchedUsers, viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil, matchedUserDataChangeDelagate: mainContentVC.self)
        ViewControllerUtils.addPulleyViewController(mainContentViewController: mainContentVC, drawerContentViewController: drawerContentVC, currentViewController: self)

    }
    
    func rideUpdated(ride : Ride){
        self.rideObj = ride
        isRideDetailInfoRetrieved = false
        initializeDataAndValidate()
        handleVisibilityForFreezeIcon()
    }
    func participantUpdated(rideParticipant : RideParticipant){
        if riderRideId == rideParticipant.riderRideId{
            if let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(){
                rideParticipantsObject = myActiveRidesCache.getRideParicipants(riderRideId: riderRideId!)
                refreshMapWithNewData()
            }
        }
    }
    
    func displayNoMatchingOptions(message: String){
        AppDelegate.getAppDelegate().log.debug("")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x2196F3), textSize: 14), range: (message as NSString).range(of: Strings.invite_by_contacts))
        labelFindMatchedUser.attributedText = attributedString
        labelFindMatchedUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.moveToInviteByContact(_:))))
    }
    
    func displayMatchedUserRetrievalFailure(){
        AppDelegate.getAppDelegate().log.debug("displayToastForMatchedUserRecieveFailure()")
        if let message = checkAndReturnEndRideMessage(){
            labelFindMatchedUser.attributedText = message
        }
        else{
            let message = Strings.matching_options_retrieval_failure
            let attributedString = NSMutableAttributedString(string: message)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.4
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x2196F3), textSize: 14), range: (message as NSString).range(of: Strings.invite_by_contacts))
            labelFindMatchedUser.attributedText = attributedString
        }
        
        labelFindMatchedUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseLiveRideMapViewController.moveToInviteByContact(_:))))
        
    }
    
    func rideArchived(ride: Ride) {
        
    }
    
    @IBAction func navigationButtonTappped(_ sender: Any) {
        if rideObj == nil || rideStatusObj == nil{
            return
        }
        var endPoint = String(rideObj!.endLatitude!.roundToPlaces(places: 5))+","+String(rideObj!.endLongitude!.roundToPlaces(places: 5))
        var mode = "driving"
        var wayPointsString: String?
        var wayPoints = [String]()
        let startPoint: String?
        if rideCurrentLocation == nil{
            startPoint = String(rideObj!.startLatitude.roundToPlaces(places: 5))+","+String(rideObj!.startLongitude.roundToPlaces(places: 5))
        }
        else{
            startPoint = String(rideCurrentLocation!.latitude.roundToPlaces(places: 5))+","+String(rideCurrentLocation!.longitude.roundToPlaces(places: 5))
        }
        if rideStatusObj!.isStartRideAllowed() || rideStatusObj!.isStopRideAllowed() || isModerator {
            endPoint = String(rideObj!.endLatitude!.roundToPlaces(places: 5))+","+String(rideObj!.endLongitude!.roundToPlaces(places: 5))
            mode = "driving"
            let passengers = RideViewUtils.getPassengersYetToPickupInOrder(rideParticipants: rideParticipantsObject)
            var wayPoint: String?
            for passenger in passengers {
                wayPoint = String(passenger.startPoint!.latitude.roundToPlaces(places: 5)) + "," + String(passenger.startPoint!.longitude.roundToPlaces(places: 5))
                if wayPoints.contains(wayPoint!) || startPoint == wayPoint {
                    continue
                }
                wayPoints.append(wayPoint!)
            }
            if !wayPoints.isEmpty {
                wayPointsString = "&waypoints=" + wayPoints.joined(separator: "|")
            }
        } else if rideStatusObj!.isCheckInRideAllowed() || rideStatusObj!.isDelayedCheckinAllowed(){

            endPoint = String((rideObj as! PassengerRide).pickupLatitude.roundToPlaces(places: 5))+","+String((rideObj as! PassengerRide).pickupLongitude.roundToPlaces(places: 5))
            mode = "walking"
        }else if rideStatusObj!.isCheckOutRideAllowed(){
            endPoint = String((rideObj as! PassengerRide).dropLatitude.roundToPlaces(places: 5))+","+String((rideObj as! PassengerRide).dropLongitude.roundToPlaces(places: 5))
            
            mode = "driving"
        }
        var urlString = "https://www.google.com/maps/dir/?api=1&origin=" + startPoint! + "&destination=" + endPoint + "&travelmode=" + mode + "&dir_action=navigate"
        if wayPointsString != nil {
            urlString += wayPointsString!
        }
        if let enodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: enodedUrlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast(message: "Can't open Google maps in this device.", duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
        }
    }
    
    @IBAction func freezeUnfreezeIconClicked(_ sender: Any) {
        
        if rideObj as? RiderRide != nil{
            if !(self.rideObj as! RiderRide).freezeRide{
                self.displayFreezeRideAlert()
            }else{
                self.handleUnFreezeRide(freezeRide: false)
            }
        }
    }
    
    func handleUnFreezeRide(freezeRide : Bool)
    {
        QuickRideProgressSpinner.startSpinner()
        RiderRideRestClient.freezeRide(rideId: self.rideObj!.rideId, freezeRide: freezeRide, targetViewController: self, complitionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                (self.rideObj as! RiderRide).freezeRide = freezeRide
                MyRidesPersistenceHelper.updateRiderRide(riderRide: (self.rideObj as! RiderRide))
                UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_unfreezed, duration: 3.0, position: CGPoint(x: (self.view.frame.size.width)/2, y: (self.view.frame.size.height)-200))
                self.handleFreezeRide(freezeRide: freezeRide)
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func displayFreezeRideAlert(){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.freeze_ride_alert, message2: nil, positiveActnTitle: Strings.confirm_caps, negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if result == Strings.confirm_caps{
                QuickRideProgressSpinner.startSpinner()
                RiderRideRestClient.freezeRide(rideId: self.rideObj!.rideId, freezeRide: true, targetViewController: self, complitionHandler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        (self.rideObj as! RiderRide).freezeRide = true
                        UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_freezed, duration: 3.0, position: CGPoint(x: (self.view.frame.size.width)/2, y: (self.view.frame.size.height)-200))
                        self.handleFreezeRide(freezeRide: true)
                    }
                    else {
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                })
            }
        })
    }
    
    func refreshRideView(){
        if rideObj == nil{
            return
        }
        if rideObj?.rideType == Ride.RIDER_RIDE{
            var riderRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: rideObj!.rideId)
            if riderRide != nil{
                let rideStatus = RideStatus(rideId : riderRide!.rideId, userId : riderRide!.userId, status : riderRide!.status, rideType : Ride.RIDER_RIDE)
                participantStatusUpdated(rideStatus: rideStatus)
            }else{
                riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideObj!.rideId)
                if riderRide != nil {
                    let rideStatus = RideStatus(rideId : riderRide!.rideId, userId : riderRide!.userId, status : riderRide!.status, rideType : Ride.RIDER_RIDE)
                    participantStatusUpdated(rideStatus: rideStatus)
                    handleFreezeRide(freezeRide: riderRide!.freezeRide)
                }
            }
        }else if rideObj?.rideType == Ride.PASSENGER_RIDE{
            var passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideObj!.rideId)
            if passengerRide != nil{
                let rideStatus = RideStatus(rideId : passengerRide!.rideId, userId : passengerRide!.userId, status : passengerRide!.status, rideType : Ride.PASSENGER_RIDE)
                rideStatus.joinedRideId = passengerRide!.riderRideId
                participantStatusUpdated(rideStatus: rideStatus)
            }else{
                passengerRide = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: rideObj!.rideId)
                if passengerRide != nil {
                    let rideStatus = RideStatus(rideId : passengerRide!.rideId, userId : passengerRide!.userId, status : passengerRide!.status, rideType : Ride.PASSENGER_RIDE)
                    rideStatus.joinedRideId = passengerRide!.riderRideId
                    participantStatusUpdated(rideStatus: rideStatus)
                }
            }
        }
    }
    
    func handleUnfreezeRide() {
        handleFreezeRide(freezeRide: false)
    }
    
    @IBAction func conatactToPassengerButtonTapped(_ sender: AnyObject) {
        if nextPassengerToPickupIndex == nil || nextPassengerToPickupIndex! >= passengersInfo.count{
            return
        }
        guard let contactNo = passengersInfo[nextPassengerToPickupIndex!].contactNo, let ride = rideObj, let rideType = ride.rideType,let cantactName = passengersInfo[nextPassengerToPickupIndex!].name else { return }
        AppUtilConnect.callNumber(phoneNumber: contactNo, receiverId:  StringUtils.getStringFromDouble(decimalNumber: passengersInfo[nextPassengerToPickupIndex!].userId),refId: rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId), name: cantactName, targetViewController: self)

    }

    @IBAction func callToRiderButtonTapped(_ sender: AnyObject) {
        if taxiShareRide != nil {
            guard let contactNumber = taxiShareRide?.driverContactNumber else {
               UIApplication.shared.keyWindow?.makeToast(message: "Contact Number Not found")
                return
            }
            AppUtilConnect.dialNumber(phoneNumber: contactNumber, viewController: self)
        }else {
            if let callDisableMsg = getErrorMessageForCall(){
                UIApplication.shared.keyWindow?.makeToast(message: callDisableMsg)
                return
            }
            for rideParticipant in rideParticipantsObject{
                if rideParticipant.rider == true{
                    checkAnyModeratorPresentAndShowCallOption(rideParticipant: rideParticipant)
                }
            }
        }
    }
    
    @IBAction func chatToRiderButtonTapped(_ sender: AnyObject) {
        if let chatDisableMsg = getErroMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast(message: chatDisableMsg)
            return
        }
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider{
                guard let contactNoStr = rideParticipant.contactNo, let contactNo = Double(contactNoStr),  let name = rideParticipant.name, let callSupport = rideParticipant.callSupport else { return }
                let userBasicInfo = UserBasicInfo(userId : rideParticipant.userId, gender : rideParticipant.gender,userName : name, imageUri: rideParticipant.imageURI, callSupport : callSupport,contactNo: contactNo)
                var isRideStarted = false
                if rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
                    isRideStarted = true
                }else{
                    isRideStarted = false
                }
                let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
                viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : userBasicInfo, isRideStarted: isRideStarted, listener: nil)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: viewController, animated: false)
            }
        }
    }
    private func getErrorMessageForCall() -> String?{
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider == true{
                if rideParticipant.enableChatAndCall{
                    if rideParticipant.callSupport == UserProfile.SUPPORT_CALL_NEVER{
                       return Strings.no_call_please_msg
                    }
                }else{
                    return Strings.chat_and_call_disable_msg
                }
            }
        }
        return nil
    }
    
    private func getErroMessageForChat() -> String?{
       for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider == true{
                if !rideParticipant.enableChatAndCall{
                    return Strings.chat_and_call_disable_msg
                }
            }
        }
        return nil
    }

    private func checkAnyModeratorPresentAndShowCallOption(rideParticipant: RideParticipant) {
        if rideParticipant.rideModerationEnabled && rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipantsObject.count > 2 {
            var rideModerators = [RideParticipant]()
            for rideParticipant in rideParticipantsObject {
                if rideParticipant.rideModerationEnabled && !rideParticipant.rider && rideParticipant.userId != userId {
                    rideModerators.append(rideParticipant)
                }
            }
            if rideModerators.isEmpty {
                callToRider(rideParticipant: rideParticipant)
            } else {
                showModeratorContactOptionView(rideParticipant: rideParticipant, rideModerator: rideModerators)
            }
        } else {
            callToRider(rideParticipant: rideParticipant)
        }
    }
    
    private func callToRider(rideParticipant: RideParticipant) {
        guard let contactNoStr = rideParticipant.contactNo, let ride = rideObj, let rideType = ride.rideType else { return }
        AppUtilConnect.callNumber(phoneNumber: contactNoStr,receiverId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), refId: rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId), name: rideParticipant.name ?? "", targetViewController: self)
    }
    
    private func checkAnyModeratorPresentAndShowContactOption(rideParticipant: RideParticipant) {
        if rideParticipant.rideModerationEnabled && rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipantsObject.count > 2 {
            var rideModerators = [RideParticipant]()
            for rideParticipant in rideParticipantsObject {
                if rideParticipant.rideModerationEnabled && !rideParticipant.rider && rideParticipant.userId != userId {
                    rideModerators.append(rideParticipant)
                }
            }
            if rideModerators.isEmpty {
                showContactOptionView(rideParticipant: rideParticipant)
            } else {
                showModeratorContactOptionView(rideParticipant: rideParticipant, rideModerator: rideModerators)
            }
        } else {
            showContactOptionView(rideParticipant: rideParticipant)
        }
    }
    
    private func showContactOptionView(rideParticipant: RideParticipant) {
        guard let contactNoStr = rideParticipant.contactNo, let contactNo = Double(contactNoStr),  let name = rideParticipant.name, let callSupport = rideParticipant.callSupport else { return }
        let userBasicInfo = UserBasicInfo(userId : rideParticipant.userId, gender : rideParticipant.gender,userName : name, imageUri: rideParticipant.imageURI, callSupport : callSupport,contactNo: contactNo)
        let isRideStarted : Bool?
        if rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
            isRideStarted = true
        }else{
            isRideStarted = false
        }
        let viewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ContactOptionsDialouge") as! ContactOptionsDialouge
        viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : userBasicInfo,supportCall: UserProfile.isCallSupportAfterJoined(callSupport: rideParticipant.callSupport!, enableChatAndCall: rideParticipant.enableChatAndCall), delegate: nil, isRideStarted: isRideStarted!, dismissDelegate: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: viewController)
    }
    
    private func showModeratorContactOptionView(rideParticipant: RideParticipant, rideModerator: [RideParticipant]) {
        let contactModeratorViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ContactModeratorViewController") as! ContactModeratorViewController
        contactModeratorViewController.initialiseView(rideStatusText: labelRiderRideStatus.text, rideParticipant: rideParticipant, riderRideId: riderRideId!, rideModerators: rideModerator, rideType: rideObj!.rideType!)
        ViewControllerUtils.addSubView(viewControllerToDisplay: contactModeratorViewController)
    }
    
    @IBAction func riderViewMoreButtonTapped(_ sender: Any) {
        if nextPassengerToPickupIndex == nil || nextPassengerToPickupIndex! >= passengersInfo.count{
            return
        }
        contactSelectedUser(phoneNumber: passengersInfo[nextPassengerToPickupIndex!].userId)
    }
    
    func checkAndEnableCallOption(callSupport : String?) -> Bool
    {
        if UserProfile.SUPPORT_CALL_NEVER == callSupport
        {
            return false
        }
        else{
            return true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        MAP_ZOOM = position.zoom
    }
    
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            if isFromSignupFlow{
                buttonCurrentLoc.isHidden = true
            }
            else{
                buttonCurrentLoc.isHidden = false
            }
        }
        else{
            buttonCurrentLoc.isHidden = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if isMapFullView == nil{
            isMapFullView = false
        }
        if !isMapFullView!{
            isMapFullView = true
            hideInfoCardViews()
        }
        else{
            isMapFullView = false
            showInfoCardViews()
        }
    }
    
    func showInfoCardViews(){
        let animation2 = CATransition()
        animation2.type = .push
        animation2.subtype = .fromTop
        animation2.duration = 0.5
        bottomDataView.layer.add(animation2, forKey: nil)
        bottomDataView.isHidden = false
        let animation3 = CATransition()
        animation3.type = .push
        animation3.subtype = .fromTop
        animation3.duration = 0.5
        viewMapComponent.layer.add(animation3, forKey: nil)
        let animation4 = CATransition()
        animation4.type = .push
        animation4.subtype = .fromBottom
        animation4.duration = 0.5
        topDataView.layer.add(animation4, forKey: nil)
        self.topDataView.isHidden = false
        let animation5 = CATransition()
        animation5.type = .push
        animation5.subtype = .fromBottom
        animation5.duration = 0.5
        buttonEmergency.layer.add(animation5, forKey: nil)
        emergencyBtnTopSpaceConstraint.constant = 10
        viewArrivalOrPickupTime.isHidden = true
        vehicleView.isHidden = true
        if rideObj?.rideType == Ride.RIDER_RIDE && self.etaTime > 0{
            self.viewArrivalOrPickupTimeTopSpaceConstraint.constant = 70
            self.viewArrivalOrPickupTime.isHidden = false
            self.labelArrivalOrPickupTime.text = "ETA \(String(self.etaTime)) min"
        }
        if rideObj?.rideType == Ride.PASSENGER_RIDE && (rideObj?.status != Ride.RIDE_STATUS_REQUESTED){
            if taxiRideId != 0{
                mapUtilitiesBottomSpaceConstraint.constant = 140
            } else {
            mapUtilitiesBottomSpaceConstraint.constant = 110
            }
        }else{
            if rideObj?.rideType == Ride.PASSENGER_RIDE{
                mapUtilitiesBottomSpaceConstraint.constant = 0
            }
            else{
                mapUtilitiesBottomSpaceConstraint.constant = 20
            }

        }
        if isModerator {
             mapUtilitiesBottomSpaceConstraint.constant = 20
        }
        if !passengerDetailViewForRider.isHidden {
            mapUtilitiesBottomSpaceConstraint.constant = 90
        }
        self.viewMap.padding = getUIEdgeInsetsBasedOnRideConstraint(top: 100, left: 20, bottom:80, right: 20)
        for subView in  self.view.subviews{
            if let greetingView = subView as? GreetingDisplayView{
                UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                               animations: {
                                greetingView.frame.origin.y -= greetingView.bounds.width
                }, completion: {(_ completed: Bool) -> Void in
                    greetingView.removeFromSuperview()
                })
            }
            if let rideModeratorTipView = subView as? RideModeratorTipView {
                rideModeratorTipView.removeFromSuperview()
            }
        }
    }
    
    func hideInfoCardViews(){
        let animation1 = CATransition()
        animation1.type = .push
        animation1.subtype = .fromBottom
        animation1.duration = 0.5
        bottomDataView.layer.add(animation1, forKey: nil)
        self.bottomDataView.isHidden = true
        let animation2 = CATransition()
        animation2.type = .push
        animation2.subtype = .fromBottom
        animation2.duration = 0.5
        viewMapComponent.layer.add(animation2, forKey: nil)
        let animation3 = CATransition()
        animation3.type = .push
        animation3.subtype = .fromTop
        animation3.duration = 0.5
        topDataView.layer.add(animation3, forKey: nil)
        self.topDataView.isHidden = true
        let animation5 = CATransition()
        animation5.type = .push
        animation5.subtype = .fromTop
        animation5.duration = 0.5
        buttonEmergency.layer.add(animation5, forKey: nil)
        emergencyBtnTopSpaceConstraint.constant = -40
        if labelArrivalOrPickupTime.text != nil && !labelArrivalOrPickupTime.text!.isEmpty{
            self.viewArrivalOrPickupTimeTopSpaceConstraint.constant = 20
            viewArrivalOrPickupTime.isHidden = false
        }
        else{
            viewArrivalOrPickupTime.isHidden = true
        }
        self.viewMap.padding = self.getUIEdgeInsetsForFullMapView()
        for subView in  self.view.subviews{
            if let greetingView = subView as? GreetingDisplayView{
                UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                               animations: {
                                greetingView.frame.origin.y -= greetingView.bounds.width
                }, completion: {(_ completed: Bool) -> Void in
                    greetingView.removeFromSuperview()
                })
            }
            if let rideModeratorTipView = subView as? RideModeratorTipView {
                rideModeratorTipView.removeFromSuperview()
            }
        }
        if rideObj?.rideType == Ride.PASSENGER_RIDE && riderRide != nil {
            vehicleView.isHidden = false
            mapUtilitiesBottomSpaceConstraint.constant = -80
        } else {
            vehicleView.isHidden = true
            mapUtilitiesBottomSpaceConstraint.constant = -150
        }
    }

    func getUIEdgeInsetsBasedOnRideConstraint(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIEdgeInsets{
        var uiEdgeInsets : UIEdgeInsets?
        if let rideType = rideObj?.rideType, rideType == Ride.PASSENGER_RIDE, (Ride.RIDE_STATUS_SCHEDULED == rideObj?.status || Ride.RIDE_STATUS_DELAYED == rideObj?.status) {
            uiEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: 60)
        } else {
            uiEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        return uiEdgeInsets!
    }
    func getUIEdgeInsetsForFullMapView() -> UIEdgeInsets{
        if let rideType = rideObj?.rideType, rideType == Ride.PASSENGER_RIDE, (Ride.RIDE_STATUS_SCHEDULED == rideObj?.status || Ride.RIDE_STATUS_DELAYED == rideObj?.status) {
            return UIEdgeInsets(top: 60, left: 20, bottom: 80, right: 60)
        } else {
            return UIEdgeInsets(top: 60, left: 20, bottom: 80, right: 40)
        }
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let time = DispatchTime(uptimeNanoseconds: UInt64(10.0*Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: time) {
            completion()
        }
    }
    func handleVisibilityOfInsuranceView(){
        if self.rideObj != nil && !self.rideParticipantsObject.isEmpty{
            if let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: self.rideObj!.userId, rideParticipants: rideParticipantsObject){
                if rideParticipant.insurancePoints != 0{
                    tripInsuranceView.isHidden = false
                    viewWalkPath.isHidden = false
                    viewWalkPathHeightConstraint.constant = 40
                    self.policyUrl = rideParticipant.insurancePolicyUrl
                    self.insurancePoints = rideParticipant.insurancePoints
                }else{
                    tripInsuranceView.isHidden = true
		    walkPathCenterXSpaceConstraint.constant = -60
                }
            }
        }else{
          viewWalkPath.isHidden = true
          viewWalkPathHeightConstraint.constant = 0
        }
    }
    
    @objc func insuranceViewTapped(_ gesture : UITapGestureRecognizer){
        let rideLevelInsuranceViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideLevelInsuranceViewController") as! RideLevelInsuranceViewController

        rideLevelInsuranceViewController.initializeDataBeforePresenting(policyUrl: policyUrl, passengerRideId: self.rideObj!.rideId, riderId: nil, rideId: nil, isInsuranceClaimed: false, insurancePoints: self.insurancePoints, dismissHandler: { [weak self] in
            self?.handleVisibilityOfInsuranceView()
        })
        self.navigationController?.view.addSubview(rideLevelInsuranceViewController.view)
        self.navigationController?.addChild(rideLevelInsuranceViewController)
    }
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {  }
    
    @IBAction func moderaterIconTapped(_ sender: UIButton) {
        if rideObj == nil {
            return
        }
        var rideParticipantAsRider: RideParticipant?
        for rideParticipant in rideParticipantsObject{
            if rideParticipant.rider {
                rideParticipantAsRider = rideParticipant
                break
            }
        }
        var message: String?
        if rideParticipantAsRider != nil && !rideParticipantAsRider!.rideModerationEnabled && rideObj?.rideType == Ride.PASSENGER_RIDE {
            message = Strings.rider_disabled_ride_moderation
        }
        if message != nil {
            let moderatorTipView = RideModeratorTipView.loadFromNibNamed(nibNamed: "RideModeratorTipView", bundle: nil) as! RideModeratorTipView
            moderatorTipView.initializeData(message: message!, firstAction: Strings.okay, secondAction: Strings.know_more, x: self.rideModeratorButton.frame.origin.x, y: self.rideModeratorButton.frame.origin.y - 90, viewController: self) { (action) in
                if action == Strings.know_more {
                    self.moveToModerationInfoView()
                }
            }
        } else {
            moveToModerationInfoView()
        }
    }
    
    private func moveToModerationInfoView() {
        let rideModerationInfoVC = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideModerationInfoViewController") as! RideModerationInfoViewController
        
        var message: String?
        var subTitle: String?
        var titles: [String]?
        var subTitles: [String]?
        var infoImages: [UIImage]?
        if rideObj?.rideType == Ride.RIDER_RIDE {
            message = Strings.ride_moderation_title_for_rider
            titles = Strings.ride_moderation_info_titles_for_rider
            subTitles = Strings.ride_moderation_info_sub_titles_for_rider
            infoImages = Strings.ride_moderation_info_images_for_rider
            subTitle = Strings.ride_moderation_sub_title_for_rider
        } else {
            message = Strings.ride_moderation_title_for_ride_taker
            titles = Strings.ride_moderation_info_titles_for_ride_taker
            subTitles = Strings.ride_moderation_info_sub_titles_for_ride_taker
            infoImages = Strings.ride_moderation_info_images_ride_takers
            subTitle = Strings.ride_moderation_sub_title_for_ride_taker
        }
        rideModerationInfoVC.initialiseView(titleMessage: message!, subTitle: subTitle, infoImages: infoImages!, infoTitles: titles!, infoSubTitles: subTitles!, ridePreferenceReceiver: self)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideModerationInfoVC)
    }

    @IBAction func pickupButtonTapped(_ sender: UIButton) {
        if nextPassengerToPickupIndex == nil || nextPassengerToPickupIndex! >= passengersInfo.count{
            return
        }
        updatePassengerStatusByRider(rideParticipant: passengersInfo[nextPassengerToPickupIndex!], status: Ride.RIDE_STATUS_STARTED, riderRideId: riderRideId!)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseLiveRideMapViewController: PickUpAndDropSelectionDelegate {
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?) {
        if rideObj != nil && rideObj!.isKind(of: PassengerRide.self) {
            let updatedPassengerRide = (rideObj as! PassengerRide).copy() as! PassengerRide
            updatedPassengerRide.points = matchedUser.points!
            updatedPassengerRide.newFare = matchedUser.newFare
            updatedPassengerRide.pickupAddress = matchedUser.pickupLocationAddress!
            updatedPassengerRide.pickupLatitude = matchedUser.pickupLocationLatitude!
            updatedPassengerRide.pickupLongitude = matchedUser.pickupLocationLongitude!
            updatedPassengerRide.overLappingDistance = matchedUser.distance!
            updatedPassengerRide.pickupTime = matchedUser.pickupTime!
            updatedPassengerRide.dropAddress = matchedUser.dropLocationAddress!
            updatedPassengerRide.dropLatitude = matchedUser.dropLocationLatitude!
            updatedPassengerRide.dropLongitude = matchedUser.dropLocationLongitude!
            updatedPassengerRide.dropTime = matchedUser.dropTime!
            updatedPassengerRide.overLappingDistance = matchedUser.distance!
            if let preferredPickupDrop = userPreferredPickupDrop {
                updatedPassengerRide.pickupNote = preferredPickupDrop.note
                updateUserPreferredPickupDrop(userPreferredPickupDrop: preferredPickupDrop)
            }
            var pickupLatitude,pickupLongitude,pickupTime,dropLatitude,dropLongitude,dropTime : Double?
            var pickupAddress,dropAddress : String?
            let existingPassengerRide = (rideObj as! PassengerRide)
            if existingPassengerRide.pickupLatitude != updatedPassengerRide.pickupLatitude && existingPassengerRide.pickupLongitude != updatedPassengerRide.pickupLongitude{
                pickupAddress = updatedPassengerRide.pickupAddress
                pickupLatitude = updatedPassengerRide.pickupLatitude
                pickupLongitude = updatedPassengerRide.pickupLongitude
                pickupTime = updatedPassengerRide.pickupTime
            }
            if existingPassengerRide.dropLatitude != updatedPassengerRide.dropLatitude && existingPassengerRide.dropLongitude != updatedPassengerRide.dropLongitude{
                dropAddress = updatedPassengerRide.dropAddress
                dropLatitude = updatedPassengerRide.dropLatitude
                dropLongitude = updatedPassengerRide.dropLongitude
                dropTime = updatedPassengerRide.dropTime
            }
            QuickRideProgressSpinner.startSpinner()
            PassengerRideServiceClient.updatePassengerRide(rideId: updatedPassengerRide.rideId, startAddress: updatedPassengerRide.startAddress, startLatitude: updatedPassengerRide.startLatitude, startLongitude: updatedPassengerRide.startLongitude, endAddress: updatedPassengerRide.endAddress, endLatitude: updatedPassengerRide.endLatitude!, endLongitude: updatedPassengerRide.endLongitude!, startTime: updatedPassengerRide.startTime, noOfSeats: updatedPassengerRide.noOfSeats, route: nil, pickupAddress: pickupAddress,pickupLatitude: pickupLatitude,pickupLongitude: pickupLongitude,dropAddress: dropAddress,dropLatitude: dropLatitude,dropLongitude: dropLongitude,pickupTime: pickupTime,dropTime: dropTime,points : updatedPassengerRide.points,overlapDistance: updatedPassengerRide.overLappingDistance, allowRideMatchToJoinedGroups: updatedPassengerRide.allowRideMatchToJoinedGroups, showMeToJoinedGroups: updatedPassengerRide.showMeToJoinedGroups, pickupNote: updatedPassengerRide.pickupNote,viewController: self, completionHandler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let passenegerRideUpdate = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                    if passenegerRideUpdate != nil
                    {
                        MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: passenegerRideUpdate!)
                        self.rideUpdated(ride: passenegerRideUpdate!)
                    }
                } else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    
                }
            })
        }
    }
    
    private func updateUserPreferredPickupDrop(userPreferredPickupDrop: UserPreferredPickupDrop) {
        UserRestClient.saveOrUpdateUserPreferredPickupDrop(userId: QRSessionManager.getInstance()?.getUserId(), userPreferredPickupDropJsonString: userPreferredPickupDrop.toJSONString(), viewContrller: self) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userPreferredPickupDrop = Mapper<UserPreferredPickupDrop>().map(JSONObject: responseObject!["resultData"]) {
                    UserDataCache.getInstance()?.storeUserPreferredPickupDrops(userPreferredPickupDrop: userPreferredPickupDrop)
                    UIApplication.shared.keyWindow?.makeToast(message: Strings.pickup_point_updated_successfully, duration: 2.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2))
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
}

extension BaseLiveRideMapViewController: SaveRidePreferencesReceiver {
    func ridePreferencesSaved() {
        refreshMapWithNewData()
    }
}
//MARK: TaxiPOOL delegate For Featching rideDetail Info
extension BaseLiveRideMapViewController: TaxiPoolDetailsUpdateDelegate {
    func fetchNewRideDetailInfoTaxiPool() {
       MyActiveRidesCache.singleCacheInstance?.taxiPoolRideDetailInfoFromServer(taxiRideId: taxiRideId!, passengerRideId: rideObj?.rideId ?? 0, myRidesCacheListener: self)
    }
}
