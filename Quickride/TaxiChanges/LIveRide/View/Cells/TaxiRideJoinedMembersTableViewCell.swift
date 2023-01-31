//
//  TaxiRideJoinedMembersTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 26/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class TaxiRideJoinedMembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taxiPoolHeaderLabel: UILabel!
    @IBOutlet weak var otherPassengerCollectionView: UICollectionView!
    @IBOutlet weak var nextButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinedMemberSubtitleLabel: UILabel!
    @IBOutlet weak var nextStepBtn: UIButton!
    
    @IBOutlet weak var animationView: AnimatedControl!
    @IBOutlet weak var carpoolMatchesCountButton: UIButton!
    @IBOutlet weak var inviteView: UIView!
    
    private var viewModel = TaxiPoolLiveRideViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }
    
    func initialisationData(viewModel: TaxiPoolLiveRideViewModel) {
        self.viewModel = viewModel
        getOutgoingTaxipoolInvitations()
        setUpUIForTaxiPool()
        if let count = viewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count, count >= 2{
            inviteView.isHidden = true
        }else{
            showAnimation()
            inviteView.isHidden = false
        }
        otherPassengerCollectionView.reloadData()
    }
    
    private func registerCells() {
        otherPassengerCollectionView.register(UINib(nibName: "CoRidersTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(taxiInvitationReceived), name: .taxiInvitationReceived, object: nil)
    }
    
    private func showAnimation(){
        guard let taxiRidePassenger = viewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        animationView.isHidden = false
        animationView.animationView.animation = Animation.named("loader")
        animationView.animationView.play()
        animationView.animationView.loopMode = .loop
        MyActiveTaxiRideCache.getInstance().getCarpoolPassengerMatches(taxiRide: taxiRidePassenger, dataReceiver: self)
        
    }
    
    private func stopAnimationAndShowMatchesCount(){
        animationView.isHidden = true
        animationView.animationView.stop()
        if !viewModel.carpoolMatchesForTaxipool.isEmpty{
            carpoolMatchesCountButton.isHidden = false
            carpoolMatchesCountButton.setTitle(String(viewModel.carpoolMatchesForTaxipool.count), for: .normal)
        }else{
            carpoolMatchesCountButton.isHidden = true
        }
    }
    
    private func getOutgoingTaxipoolInvitations(){
        viewModel.taxipoolOutgoingInvitations = MyActiveTaxiRideCache.getInstance().getOutGoingTaxipoolInvites(taxiRideId: viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id ?? 0)
        otherPassengerCollectionView.reloadData()
    }
    
    @objc func taxiInvitationReceived(_ notification: Notification){
        getOutgoingTaxipoolInvitations()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if  let taxiRidePassengerDetails = viewModel.taxiRidePassengerDetails {
            let taxiPoolIntroduction = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiNextStepShowingViewController") as! TaxiNextStepShowingViewController
            taxiPoolIntroduction.prepareData(taxiRidePassengerDetails: taxiRidePassengerDetails)
            taxiPoolIntroduction.modalPresentationStyle = .overFullScreen
            parentViewController?.present(taxiPoolIntroduction, animated: false, completion: nil)
        }
    }
    
    private func setUpUIForTaxiPool() {
        guard let passengerGroup = viewModel.taxiRidePassengerDetails?.taxiRideGroup else { return }
        joinedMemberSubtitleLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        joinedMemberSubtitleLabel.textColor = UIColor.black.withAlphaComponent(1)
        if (passengerGroup.noOfPassengers ?? 0) < 2{
            taxiPoolHeaderLabel.text = updateTaxiPoolStatus()
            joinedMemberSubtitleLabel.text = String(format: Strings.more_seats_to_confirm_taxipool,arguments: ["1"])
            showNextStep(status: true)
        }else{
            if passengerGroup.driverName == "" || passengerGroup.driverName == nil {
                showNextStep(status: true)
                switch passengerGroup.status {
                case TaxiRideGroup.STATUS_ALLOTTED,TaxiRideGroup.STATUS_RE_ALLOTTED,TaxiRideGroup.STATUS_CONFIRMED:
                    taxiPoolHeaderLabel.text = updateTaxiPoolStatus()
                    joinedMemberSubtitleLabel.text = Strings.taxi_will_allot_prior
                default:
                    taxiPoolHeaderLabel.text = updateTaxiPoolStatus()
                    joinedMemberSubtitleLabel.text = Strings.taxi_will_allott_soon
                }
            }else{
                taxiPoolHeaderLabel.text = Strings.joined_members.capitalized
                joinedMemberSubtitleLabel.text = ""
                showNextStep(status: false)
            }
        }
    }
    
    private func updateTaxiPoolStatus() -> String {
        guard let passengerGroup = viewModel.taxiRidePassengerDetails?.taxiRideGroup else { return ""}
        switch passengerGroup.status {
        case TaxiRideGroup.STATUS_STARTED :
            return Strings.taxi_started + "!"
        case TaxiRideGroup.STATUS_DELAYED :
            return Strings.taxi_delayed + "!"
        case TaxiRideGroup.STATUS_OPEN, TaxiRideGroup.STATUS_FROZEN,TaxiRideGroup.BOOKING_STATUS_IN_PROGRESS :
            return Strings.joined_taxipool
        case TaxiRideGroup.STATUS_ALLOTTED,TaxiRideGroup.STATUS_RE_ALLOTTED,TaxiRideGroup.STATUS_CONFIRMED :
            return Strings.taxi_pool_confirm + "!"
        default:
            return Strings.joined_taxipool
        }
    }
    
    private func showNextStep(status: Bool) {
        if status {
            nextStepBtn.isHidden = false
        }else{
            nextStepBtn.isHidden = true
        }
    }
    
    @IBAction func matchesButtonTapped(_ sender: Any) {
        let taxipoolPassengersViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolPassengersViewController") as! TaxipoolPassengersViewController
        taxipoolPassengersViewController.initialiseMatches(taxiRide: viewModel.taxiRidePassengerDetails?.taxiRidePassenger)
        self.parentViewController?.navigationController?.pushViewController(taxipoolPassengersViewController, animated: false)
    }
}
//MARK: UICollectionViewDataSource
extension TaxiRideJoinedMembersTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{ // current user
            return 1
        }else if section == 1{ // joined members
            return viewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0
        }else if section == 2{ // invites
            return viewModel.taxipoolOutgoingInvitations.count
        }else{ // Empty user
            let count = (viewModel.taxiRidePassengerDetails?.otherPassengersInfo?.count ?? 0) + viewModel.taxipoolOutgoingInvitations.count
            if count < 2{
                return 2 - count
            }else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell", for: indexPath) as! CoRidersTaxiPoolCollectionViewCell
        if indexPath.section == 0{
            cell.initialiseCurrentUser()
        }else if indexPath.section == 1 && !(viewModel.taxiRidePassengerDetails?.otherPassengersInfo?.isEmpty ?? false){
            cell.initialiseCoRiderUserInfo(taxiRidePassengerBasicInfo: viewModel.taxiRidePassengerDetails?.otherPassengersInfo?[indexPath.row])
        }else if indexPath.section == 2 && !viewModel.taxipoolOutgoingInvitations.isEmpty{
            cell.initialiseTaxipoolInvite(taxiInvite: viewModel.taxipoolOutgoingInvitations[indexPath.row])
        }else{
            cell.initialiseEmptyUser()
        }
        return cell
    }
}
//MARK: UICollectionViewDataSource
extension TaxiRideJoinedMembersTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            moveToProfile(taxiRidePassengerBasicInfo: viewModel.taxiRidePassengerDetails?.otherPassengersInfo?[indexPath.row])
        }else if indexPath.section == 2{
            moveToInviteDetailView(taxiInvite: viewModel.taxipoolOutgoingInvitations[indexPath.row])
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    private func moveToProfile(taxiRidePassengerBasicInfo: TaxiRidePassengerBasicInfo?){
        guard let taxiPassengerInfo = taxiRidePassengerBasicInfo else { return }
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: taxiPassengerInfo.userId),isRiderProfile: UserRole.Passenger,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: 1, isSafeKeeper: true)
        self.parentViewController?.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
    
    private func moveToInviteDetailView(taxiInvite: TaxiPoolInvite){
        guard let taxiRidePassenger = viewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        if  taxiInvite.invitedRideId == 0 {
            let matchingTaxiPassenger =  createDefaultTaxiRidePassenger(taxiRideInvite: taxiInvite, taxiRidePassenger: taxiRidePassenger)
            navigateToTaxiPoolPassengerDetailsView(taxiRidePassenger: taxiRidePassenger, matchedUser: matchingTaxiPassenger)
            return
        }
        MyActiveTaxiRideCache.getInstance().getCarpoolMatchedUser(taxiRide: taxiRidePassenger, filterPassengerRideId: Double(taxiInvite.invitedRideId)) { [weak self] (matchingTaxipoolUser, responseObject, error) in
            if let matchedUser = matchingTaxipoolUser, let self = self{
                self.navigateToTaxiPoolPassengerDetailsView(taxiRidePassenger: taxiRidePassenger, matchedUser: matchedUser)
            }
        }
    }
    func navigateToTaxiPoolPassengerDetailsView(taxiRidePassenger: TaxiRidePassenger, matchedUser : MatchingTaxiPassenger){
        let taxiPoolPassengerDetailViewController  = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolPassengerDetailViewController") as! TaxiPoolPassengerDetailViewController
        taxiPoolPassengerDetailViewController.showTaxipoolPassengers(taxipoolMatches: [matchedUser], taxiRide: taxiRidePassenger, selectedIndex: 0)
        self.parentViewController?.navigationController?.pushViewController(taxiPoolPassengerDetailViewController, animated: false)
    }
    func  createDefaultTaxiRidePassenger(taxiRideInvite : TaxiPoolInvite, taxiRidePassenger: TaxiRidePassenger) -> MatchingTaxiPassenger {
        let matchingTaxiPassenger =  MatchingTaxiPassenger()
        matchingTaxiPassenger.userid = Double(taxiRideInvite.invitedUserId)
        matchingTaxiPassenger.invitationStatus = taxiRideInvite.status
        if taxiRideInvite.pickupTimeMs != 0 {
            let pickupTime = Double(taxiRideInvite.pickupTimeMs)
            matchingTaxiPassenger.startDate = pickupTime
            matchingTaxiPassenger.pickupTime =  pickupTime
        }
        matchingTaxiPassenger.fromLocationLatitude = taxiRideInvite.fromLat
        matchingTaxiPassenger.fromLocationLongitude = taxiRideInvite.fromLng
        matchingTaxiPassenger.pickupLocationLatitude = taxiRideInvite.fromLat
        matchingTaxiPassenger.pickupLocationLongitude = taxiRideInvite.fromLng
        matchingTaxiPassenger.dropLocationLatitude = taxiRideInvite.toLat
        matchingTaxiPassenger.dropLocationLongitude = taxiRideInvite.toLng
        matchingTaxiPassenger.toLocationLatitude = taxiRideInvite.toLat
        matchingTaxiPassenger.toLocationLongitude = taxiRideInvite.toLng
        matchingTaxiPassenger.taxiRoutePolyline = taxiRidePassenger.routePolyline
        matchingTaxiPassenger.routePolyline = taxiRideInvite.overviewPolyLine
        matchingTaxiPassenger.distance = taxiRideInvite.distance
        matchingTaxiPassenger.deviation = 0.0
        matchingTaxiPassenger.name = taxiRideInvite.invitedUserName
        matchingTaxiPassenger.gender = taxiRideInvite.invitedUserGender
        matchingTaxiPassenger.imageURI = taxiRideInvite.invitedUserImageURI
        if let userDataCache = UserDataCache.getInstance(), let userProfile = userDataCache.userProfile {
            matchingTaxiPassenger.profileVerificationData = userProfile.profileVerificationData
            matchingTaxiPassenger.companyName = userProfile.companyName
            matchingTaxiPassenger.rating = userProfile.rating
            matchingTaxiPassenger.noOfReviews = userProfile.noOfReviews
        }
        return matchingTaxiPassenger;
    }
}
//MARK: UICollectionViewDelegateFlowLayout
extension TaxiRideJoinedMembersTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 76)
    }
}

//MARK: CarpoolPassengerDataReceiver
extension TaxiRideJoinedMembersTableViewCell: CarpoolPassengerDataReceiver{
    func receivedCarpoolPassengerList(carpoolMatches: [MatchingTaxiPassenger]) {
        viewModel.carpoolMatchesForTaxipool = carpoolMatches
        stopAnimationAndShowMatchesCount()
    }
    
    func carpoolMatchesRetrivalFailed(responseObject: NSDictionary?, error: NSError?) {
        stopAnimationAndShowMatchesCount()
    }
}
