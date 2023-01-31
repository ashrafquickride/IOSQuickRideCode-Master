//
//  JoinedRideParticipantCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import ObjectMapper

class JoinedRideParticipantCardTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var joinedMemebersCollectionViewForPassenger: UICollectionView!
    @IBOutlet weak var viewJoinedMembers: UIView!
    //MARK: TaxiPool
    @IBOutlet weak var taxiPoolJoinedMemberTitleLabel: UILabel!
    @IBOutlet weak var joinedMemberSubtitleLabel: UILabel!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var nextStepBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteTaxiView: UIView!
    @IBOutlet weak var inviteTaxiViewWidthConstarint: NSLayoutConstraint!
    @IBOutlet weak var numberOfAvailableLabel: UILabel!
    
    //MARK: Properties
    private var ride: Ride?
    private var riderRide : RiderRide?
    private var passengersInfo = [RideParticipant]()
    private var taxiShareRide: TaxiShareRide?
    private var taxiInvitedUserData = [TaxiInviteEntity]()
    
    //MARK: Initializer
    func initializeData(ride: Ride,riderRide : RiderRide?, passengersInfo: [RideParticipant],taxiShareRide: TaxiShareRide?) {
        self.ride = ride
        self.riderRide = riderRide
        self.passengersInfo = passengersInfo
        self.taxiShareRide = taxiShareRide
        setUpUI()
    }
    
    //MARK: Methods
    private func setUpUI() {
        joinedMemebersCollectionViewForPassenger.register(UINib(nibName: "JoinedMembersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "JoinedMembersCollectionViewCell")
        joinedMemebersCollectionViewForPassenger.register(UINib(nibName: "EmptyPassengerTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell")
        setUpUIForTaxiPool()
        joinedMemebersCollectionViewForPassenger.reloadData()
    }
    private func setUpUIForTaxiPool() {
        if taxiShareRide != nil {
            joinedMemberSubtitleLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            joinedMemberSubtitleLabel.textColor = UIColor.black.withAlphaComponent(1)
            if Int(taxiShareRide!.availableSeats!) != 0{
                taxiPoolJoinedMemberTitleLabel.text = updateTaxiPoolStatus() + "!"
                joinedMemberSubtitleLabel.text = String(format: Strings.more_seats_to_confirm_taxipool,arguments: [String(Int(taxiShareRide!.availableSeats!))])
                hideOrShowInviteBtn(status: true)
                showNextStep(status: true)
                MatchedPassengerTaxiCache.getInstance().getAllMatchedPassengers(ride: ride!) { [weak self] (responseData, error) in
                    if responseData != nil {
                        self?.numberOfAvailableLabel.isHidden = false
                        self?.numberOfAvailableLabel.text = "\(responseData?.count ?? 0)"
                    }
                }
                TaxiPoolInvitationCache.getInstance().getAllInvitesForRide(rideId: ride?.rideId ?? 0.0) { [weak self] (responseData, error) in
                    if responseData != nil{
                        self?.taxiInvitedUserData = responseData ?? []
                        self?.joinedMemebersCollectionViewForPassenger.reloadData()
                    }
                }
            }else{
                hideOrShowInviteBtn(status: false)
                if taxiShareRide?.driverName == "" || taxiShareRide?.driverName == nil {
                    showNextStep(status: true)
                    switch taxiShareRide?.status {
                    case TaxiShareRide.TAXI_SHARE_RIDE_ALLOTTED,TaxiShareRide.TAXI_SHARE_RIDE_RE_ALLOTTED,TaxiShareRide.TAXI_SHARE_RIDE_POOL_CONFIRMED:
                        taxiPoolJoinedMemberTitleLabel.text = Strings.taxi_will_allot_prior
                        joinedMemberSubtitleLabel.text = updateTaxiPoolStatus() + "!"
                    default:
                        taxiPoolJoinedMemberTitleLabel.text = updateTaxiPoolStatus() + "!"
                        joinedMemberSubtitleLabel.text = Strings.taxi_will_allott_soon
                    }
                }else{
                    taxiPoolJoinedMemberTitleLabel.text = ""
                    joinedMemberSubtitleLabel.font = UIFont(name: "Roboto-Medium", size: 14)
                    joinedMemberSubtitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
                    joinedMemberSubtitleLabel.text = Strings.joined_members.capitalized
                    showNextStep(status: false)
                }
            }
        }else{
            hideOrShowInviteBtn(status: false)
        }
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
    
    private func hideOrShowInviteBtn(status: Bool) {
        if status {//MARK: Show
            inviteTaxiView.isHidden = false
            inviteTaxiViewWidthConstarint.constant = 60
        } else {//MARK: Hide
            inviteTaxiView.isHidden = true
            inviteTaxiViewWidthConstarint.constant = 0
            taxiInvitedUserData = []
        }
    }
    
    private func showNextStep(status: Bool) {
        if status {
            nextStepBtn.isHidden = false
            nextStepBtnWidthConstraint.constant = 60
        }else{
            nextStepBtn.isHidden = true
            nextStepBtnWidthConstraint.constant = 0
        }
    }
    
    @IBAction func nextStepBtnPressed(_ sender: UIButton) {
        if let ride = ride , let taxiShareRide = taxiShareRide {
            let taxiPoolIntroduction = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiNextStepShowingViewController") as! TaxiNextStepShowingViewController
//            taxiPoolIntroduction.prepareData(ride: ride, taxiShareRide: taxiShareRide)
            taxiPoolIntroduction.modalPresentationStyle = .overFullScreen
            parentViewController?.present(taxiPoolIntroduction, animated: false, completion: nil)
        }
    }
    
    @IBAction func InviteBtnPressed(_ sender: UIButton) {
        let taxiPoolInvite = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteTaxiPoolViewController") as! InviteTaxiPoolViewController
        taxiPoolInvite.initisation(ride: ride, taxiShareRide: taxiShareRide)
        parentViewController?.navigationController?.pushViewController(taxiPoolInvite, animated: false)
    }
    
    func inviteUserTapped(sender: Int) {
        let invitation = taxiInvitedUserData[sender]
        guard let passengerRide = ride as? PassengerRide else {return}
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.getPotentialCoRiders(passengerRideId: passengerRide.rideId, taxiRideId: passengerRide.taxiRideId, filterPassengerRideId: invitation.invitedRideId ?? 0) { [weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if(responseObject == nil || responseObject!["result"] as! String == "FAILURE") {
                self?.getMatchedPassengerInvitesAndUpdate(id: invitation.id!)
            }else if responseObject!["result"] as! String == "SUCCESS"{
                guard let taxiShareRide = self?.taxiShareRide else { return }
                if  responseObject!["resultData"] as! [MatchedPassenger] == [] {
                    self?.getMatchedPassengerInvitesAndUpdate(id: invitation.id!)
                    return
                }
                let matchedPassenger = Mapper<MatchedPassenger>().mapArray(JSONObject: responseObject!["resultData"])!
                let taxiPoolInviteDetails = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolPassengerDetailsInviteViewController") as! TaxiPoolPassengerDetailsInviteViewController
                taxiPoolInviteDetails.dataBeforePresent(selectedIndex: 0, matchedPassengerRide: matchedPassenger , taxiShareRide: taxiShareRide, ride: self?.ride, allInvitedUsers: self?.taxiInvitedUserData)
                self?.parentViewController?.navigationController?.pushViewController(taxiPoolInviteDetails, animated: false)
            }
        }
    }
    
    private func getMatchedPassengerInvitesAndUpdate(id: String) {
        TaxiPoolInvitationCache.getInstance().removeAnInvitationFromLocal(rideId: self.ride?.rideId ?? 0, invitationId: id)
        self.taxiInvitedUserData.removeAll()
        self.taxiInvitedUserData = TaxiPoolInvitationCache.getInstance().totalInvitations[self.ride?.rideId ?? 0] ?? []
        self.joinedMemebersCollectionViewForPassenger.reloadData()
    }
}
// MARK: - Collection view delegate and data source
extension JoinedRideParticipantCardTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if taxiShareRide == nil {
            return 1
        }else{
            if taxiShareRide?.driverName != nil {
                return 1
            } else {
                return 2
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        switch section {
        case 0:
            if taxiShareRide == nil {
                return passengersInfo.count
            } else {
                return Int(taxiShareRide?.capacity ?? 0)
            }
        default:
            return taxiInvitedUserData.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section ==  0 {
            if indexPath.row < passengersInfo.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JoinedMembersCollectionViewCell", for: indexPath) as! JoinedMembersCollectionViewCell
                if passengersInfo.endIndex <= indexPath.row{
                    return cell
                }
                let rideParticipant : RideParticipant = passengersInfo[indexPath.item]
                cell.userId = rideParticipant.userId
                if StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId) == QRSessionManager.getInstance()?.getUserId() {
                    cell.labelName.text = "You"
                } else {
                    cell.labelName.text = rideParticipant.name?.capitalized
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
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell", for: indexPath) as! EmptyPassengerTaxiPoolCollectionViewCell
                cell.inviteStatusImage.isHidden = true
                cell.inviteNameLabel.isHidden = true
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell", for: indexPath) as! EmptyPassengerTaxiPoolCollectionViewCell
            cell.inviteStatusImage.isHidden = false
            cell.inviteNameLabel.isHidden = false
            cell.inviteNameLabel.text = taxiInvitedUserData[indexPath.item].invitedUserName
            cell.inviteStatusImage.image = UIImage(named: "invite_tick")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if passengersInfo.count <= indexPath.item{
                return
            }
            let rideParticipant = passengersInfo[indexPath.row]
            if rideParticipant.userId == ride?.userId{
                return
            }
            contactSelectedPassenger(rideParticipant: rideParticipant)
        }else{
            inviteUserTapped(sender: indexPath.item)
        }
    }
    func contactSelectedPassenger(rideParticipant : RideParticipant){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actions = LiveRideViewModelUtil.getApplicableActionOnPassengerSelection(rideParticipant: rideParticipant,riderRide: riderRide,currentUserRide: ride!)
        for action in actions {
            var style = UIAlertAction.Style.default
            if action == Strings.unjoin{
                style = .destructive
            }
            let expectedAction = UIAlertAction(title: action, style: style, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handleRideParticiapantAction(selectedType: alert.title!, rideParticipant: rideParticipant)
            })
            optionMenu.addAction(expectedAction)
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        parentViewController?.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    func handleRideParticiapantAction(selectedType: String,rideParticipant: RideParticipant){

        guard let viewController = parentViewController else {
            return
        }
        switch selectedType {
        case Strings.contact:
            LiveRideViewControllerUtils.showContactOptionView(ride: ride, rideParticipant: rideParticipant, viewController: viewController)
        case Strings.smsLabel:
            UserDataCache.getInstance()?.getContactNo(userId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), handler: { (contactNo) in
                LiveRideViewControllerUtils.sendSMS(phoneNumber: contactNo, message: "", viewController: viewController)
            })
        case Strings.profile:
            LiveRideViewControllerUtils.displayConnectedUserProfile(rideParticipant: rideParticipant, riderRide: riderRide,viewController : viewController)
        case Strings.ride_notes:
            MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideParticipant.rideNote, viewController: nil)
        default:
            break
        }
    }
    
}
