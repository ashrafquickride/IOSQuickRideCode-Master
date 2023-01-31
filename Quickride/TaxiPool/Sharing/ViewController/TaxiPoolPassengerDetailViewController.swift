//
//  TaxiPoolPassengerDetailViewController.swift
//  Quickride
//
//  Created by HK on 19/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
import GoogleMaps

class TaxiPoolPassengerDetailViewController: UIViewController,GMSMapViewDelegate{
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var cardView: QuickRideCardView!
    @IBOutlet weak var leftView: QuickRideCardView!
    @IBOutlet weak var rightView: QuickRideCardView!
    //User details
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var invitingImageView: UIImageView!
    @IBOutlet weak var inviteButtonView: UIView!
    @IBOutlet weak var callChatView: UIView!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var callButton: UIButton!
    
    private var viewModel = TaxiPoolPassengerDetailViewModel()
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    private var matchedUserMarker : GMSMarker!
    
    func showTaxipoolPassengers(taxipoolMatches: [MatchingTaxiPassenger],taxiRide: TaxiRidePassenger?,selectedIndex: Int){
        viewModel = TaxiPoolPassengerDetailViewModel(taxipoolMatches: taxipoolMatches, taxiRide: taxiRide,selectedIndex: selectedIndex)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 40)
        viewMap.delegate = self
        setUpUi()
        drawTaxipoolAndMatchedUserRoute()
        checkAndAddMatchViewSwipeGesture()
        handleCustomizationToInviteView()
    }
    
    private func setUpUi(){
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: viewModel.selecetdMatchedUser?.imageURI ?? "", gender: viewModel.selecetdMatchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = viewModel.selecetdMatchedUser?.name?.capitalized
        companyNameLabel.text = viewModel.selecetdMatchedUser?.companyName
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if (viewModel.selecetdMatchedUser?.rating)! > 0.0{
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(viewModel.selecetdMatchedUser?.rating ?? 0) + "(\(String(viewModel.selecetdMatchedUser?.noOfReviews ?? 0)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingShowingLabelHeightConstraints.constant = 15.0
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            starImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 8.0
            ratingLabel.layer.masksToBounds = true
        }
        verificationImage.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: viewModel.selecetdMatchedUser?.profileVerificationData)
        deviationLabel.text = TaxiUtils.getDistanceString(distance: viewModel.selecetdMatchedUser?.deviation ?? 0)
        if let pickupTime = viewModel.selecetdMatchedUser?.pickupTime, pickupTime < NSDate().getTimeStamp() {
            pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        }else{
            pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        }
        
        if let _ = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: viewModel.taxiRide?.id ?? 0, userId: viewModel.selecetdMatchedUser?.userid ?? 0){
            callChatView.isHidden = false
            inviteButtonView.isHidden = true
            checkCallOptionAvailability()
        }else{
            callChatView.isHidden = true
            inviteButtonView.isHidden = false
        }
    }
    
    private func drawTaxipoolAndMatchedUserRoute(){
        if viewMap == nil{
            return
        }
        viewMap.clear()
        drawTaxipoolRoute()
        drawMatchedUserRoute()
    }
    
    private func drawTaxipoolRoute(){
        if let taxiRide = viewModel.taxiRide {
            GoogleMapUtils.drawRoute(pathString: taxiRide.routePolyline ?? "", map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_5, tappable: false)
            let start = CLLocationCoordinate2D(latitude: taxiRide.startLat ?? 0,longitude: taxiRide.startLng ?? 0)
            let end =  CLLocationCoordinate2D(latitude: taxiRide.endLat ?? 0, longitude: taxiRide.endLng ?? 0)
            pickUpMarker?.map = nil
            pickUpMarker = nil
            pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: start, shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            dropMarker?.zIndex = 12
            dropMarker?.map = nil
            dropMarker = nil
            dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: end, shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
            dropMarker?.zIndex = 12
            if let routePolyline = taxiRide.routePolyline, viewMap != nil{
                GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
            }
        }
    }
    
    
    private func drawMatchedUserRoute(){
        if let matchedUser = viewModel.selecetdMatchedUser{
            GoogleMapUtils.drawRoute(pathString: matchedUser.taxiRoutePolyline ?? "", map: viewMap, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
            let pickup =  CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude ?? 0, longitude: matchedUser.pickupLocationLongitude ?? 0)
            matchedUserMarker?.map = nil
            matchedUserMarker = nil
            let participantPickUpImageView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
            participantPickUpImageView.initializeView(name: matchedUser.name ?? "", colorCode: UIColor(netHex: 0x656766))
            let icon = ViewCustomizationUtils.getImageFromView(view: participantPickUpImageView)
            matchedUserMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickup, shortIcon: icon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.4))
            matchedUserMarker.zIndex = 12
        }
    }
    
    func checkAndAddMatchViewSwipeGesture() {
        if viewModel.taxipoolMatches.count > 1 {
            cardView.isUserInteractionEnabled = true
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            leftSwipe.direction = .left
            cardView.addGestureRecognizer(leftSwipe)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            rightSwipe.direction = .right
            cardView.addGestureRecognizer(rightSwipe)
        }else{
            leftView.isHidden = true
            rightView.isHidden = true
        }
        if viewModel.selectedIndex == 0{
            leftView.isHidden = true
            
        }else{
            leftView.isHidden = false
        }
        if viewModel.selectedIndex == viewModel.taxipoolMatches.count - 1 {
            rightView.isHidden = true
        }else{
            rightView.isHidden = false
        }
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if viewModel.selectedIndex != viewModel.taxipoolMatches.count - 1{
                cardView.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
        }else if gesture.direction == .right {
            
            if viewModel.selectedIndex != 0 {
                cardView.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
        }
        if gesture.direction == .left {
            viewModel.selectedIndex += 1
            if viewModel.selectedIndex > viewModel.taxipoolMatches.count - 1 {
                viewModel.selectedIndex = viewModel.taxipoolMatches.count - 1
            }
        }else if gesture.direction == .right {
            viewModel.selectedIndex -= 1
            if viewModel.selectedIndex < 0 {
                viewModel.selectedIndex = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.viewModel.selecetdMatchedUser = self.viewModel.taxipoolMatches[self.viewModel.selectedIndex]
            self.drawTaxipoolAndMatchedUserRoute()
            self.setUpUi()
            self.checkAndAddMatchViewSwipeGesture()
        })
    }
    
    private func handleCustomizationToInviteView(){
        invitingImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        invitingImageView.isHidden = true
        invitingImageView.animationDuration = 0.3
    }
    
    private func startAnimation(){
        invitingImageView.isHidden = false
        invitingImageView.startAnimating()
        invitingImageView.isHidden = true
    }
    
    private func stopAnimation(){
        invitingImageView.isHidden = false
        invitingImageView.stopAnimating()
        invitingImageView.isHidden = false
    }
    
    func checkCallOptionAvailability(){
        if UserProfile.SUPPORT_CALL_ALWAYS == viewModel.selecetdMatchedUser?.callSupport && viewModel.selecetdMatchedUser?.enableChatAndCall == true {
            callButton.backgroundColor = UIColor(netHex: 0x2196F3)
        }else if viewModel.selecetdMatchedUser?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && viewModel.selecetdMatchedUser?.enableChatAndCall == true{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: viewModel.selecetdMatchedUser?.userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                callButton.backgroundColor = UIColor(netHex: 0x2196F3)
            }else{
                callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            }
        }else{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            guard let call_disaable_msg = viewModel.getErrorMessageForCall() else { return }
            UIApplication.shared.keyWindow?.makeToast( call_disaable_msg)
            return
        }
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: viewModel.selecetdMatchedUser?.userid), refId: "", name: viewModel.selecetdMatchedUser?.name ?? "", targetViewController: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        guard let userId = viewModel.selecetdMatchedUser?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            guard let invite = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: self.viewModel.taxiRide?.id ?? 0, userId: self.viewModel.selecetdMatchedUser?.userid ?? 0) else { return }
            self.viewModel.sendTaxiInvite(taxiInvite: invite) { responseObject, error in
                if responseObject == nil || error == nil{
                }else{
                }
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            guard let invite = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: self.viewModel.taxiRide?.id ?? 0, userId: self.viewModel.selecetdMatchedUser?.userid ?? 0) else { return }
            QuickRideProgressSpinner.startSpinner()
            self.viewModel.cancelCarpoolPassengerInvite(inviteId: invite.id ?? "") { responseObject, error in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject == nil && error == nil{
                    self.inviteButtonView.isHidden = false
                    self.callChatView.isHidden = true
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in}
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true)
    }
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        startAnimation()
        viewModel.sendInviteToCarpoolPassenger { [weak self]responseObject, error in
            self?.stopAnimation()
            if responseObject == nil && error == nil{
                self?.inviteButtonView.isHidden = true
                self?.callChatView.isHidden = false
                self?.checkCallOptionAvailability()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        guard let matchedUser = viewModel.selecetdMatchedUser else { return }
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.userid),isRiderProfile: UserRole.Passenger,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: 1, isSafeKeeper: matchedUser.hasSafeKeeperBadge)
        self.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
}
