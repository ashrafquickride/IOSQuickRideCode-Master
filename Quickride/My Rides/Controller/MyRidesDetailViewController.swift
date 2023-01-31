//
//  MyRidesDetailViewController.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI
import DropDown

protocol HomeOfficeLocationSavingDelegate: class {
    func navigateToRegularRideCreation()
}

class MyRidesDetailViewController: UIViewController, VehicleDetailsUpdateListener {
    func VehicleDetailsUpdated() {
        setVehicle()
    }


    //MARK: Outlets
    @IBOutlet weak var myRidesTableView: UITableView!
    @IBOutlet weak var rideHistoryButton: CustomUIButton!

    //MARK: Properties
    var vehicle :Vehicle?
    var taxiPoolCancelFeeWaived = false
    var isRecurringRideRequiredFrom: String?
    var overFlowMenuDropDown = DropDown()
    var rideEditDropDown = DropDown()
    var rideRepeatDropDown = DropDown()

    lazy var myRideDetailsViewModel: MyRidesDetailViewModel = {
        return MyRidesDetailViewModel()
    }()

    func setVehicleModelText(vehicleModel : String, vehicleCapacity: String, vehicleFare: String, image : UIImage){}

    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupUI()
        myRideDetailsViewModel.rideModelDelegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRideDetailsViewModel.addListner() //add listner - so that get ride details
        NotificationStore.getInstance().addNotificationListChangeListener(key: MyActiveRidesCache.MyRidesDetailViewController_key, listener: self)
        myRidesTableView.reloadData()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myRideDetailsViewModel.removeListner()
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideUpdateListener(key: MyActiveRidesCache.MyRidesDetailViewController_key)
        MyRegularRidesCache.singleInstance?.removeRideUpdateListenre(rideId: 0)
        NotificationStore.getInstance().removeListener(key: MyActiveRidesCache.MyRidesDetailViewController_key)
        self.navigationController?.isNavigationBarHidden = false
    }


    func setupUI() {
        ViewCustomizationUtils.addCornerRadiusToView(view: rideHistoryButton, cornerRadius: rideHistoryButton.frame.width / 2)
        myRidesTableView.register(UINib(nibName: "MyRidesDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRidesDetailTableViewCell")
        myRidesTableView.register(UINib(nibName: "MyRideVacationTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRideVacationTableViewCell")
        myRidesTableView.register(UINib(nibName: "AutoMatchTableViewCell", bundle: nil), forCellReuseIdentifier: "AutoMatchTableViewCell")
        myRidesTableView.register(UINib(nibName: "MyRidesRecurringTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRidesRecurringTableViewCell")
        myRidesTableView.register(UINib(nibName: "CreateRideTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateRideTableViewCell")
        myRidesTableView.register(UINib(nibName: "MyRideSectionHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRideSectionHeaderTableViewCell")
        myRidesTableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        myRidesTableView.rowHeight = UITableView.automaticDimension
    }
    
    
    private func setupOverFlowDropDownView(ride: Ride, rideParticipants: [RideParticipant],taxiShareRide: TaxiShareRide?,rideActionsMenuController: RideActionsMenuController, anchorView: AnchorView){
        overFlowMenuDropDown.anchorView = anchorView
        overFlowMenuDropDown.bottomOffset = CGPoint(x: -50, y: 0)
        overFlowMenuDropDown.topOffset = CGPoint(x: -50, y: 0)
        myRideDetailsViewModel.overFlowMenuActionsList.removeAll()
        if rideParticipants.count == 0 {
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.ride_edit_options)
        }
        myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.repeat_ride_options)
        let rideStatusObj = ride.prepareRideStatusObject()
        if rideStatusObj.isRescheduleAllowed() {
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.reschedule)
        }
        if rideStatusObj.rideType ==  Ride.RIDER_RIDE {
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.share_ride_invite)
        }
        if ride.rideType == Ride.RIDER_RIDE || (ride.rideType == Ride.PASSENGER_RIDE && (ride.status == Ride.RIDE_STATUS_SCHEDULED || ride.status == Ride.RIDE_STATUS_STARTED || ride.status == Ride.RIDE_STATUS_DELAYED)){
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.shareRidePath)
            
        }
        if rideStatusObj.isCancelRideAllowed(){
            if  let taxiShareRide = taxiShareRide {
                if taxiShareRide.taxiShareRidePassengerInfos?.count ?? 0 > 1{
                    taxiPoolCancelFeeWaived = true
                }
            }
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.cancel_ride)
        }
        overFlowMenuDropDown.dataSource = myRideDetailsViewModel.overFlowMenuActionsList
        overFlowMenuDropDown.textFont = UIFont(name: "HelveticaNeue", size: 14)!
        overFlowMenuDropDown.selectionAction = { [weak self] (index, item) in
            switch item {
            case Strings.ride_edit_options:
                self?.showRideEditDropDown(ride: ride, rideActionsMenuController: rideActionsMenuController, anchorView: anchorView)
            case Strings.repeat_ride_options:
                self?.showRepeatDropDown(rideActionsMenuController: rideActionsMenuController, anchorView: anchorView)
            case Strings.reschedule:
                rideActionsMenuController.rescheduleRide()
            case Strings.share_ride_invite:
                rideActionsMenuController.shareRideInSocialGroups()
            case Strings.shareRidePath:
                rideActionsMenuController.showShareOptions()
            case Strings.cancel_ride:
                rideActionsMenuController.cancelRide(rideParticipants: rideParticipants)
            default:
                break
            }
        }
        overFlowMenuDropDown.show()
    }
    
    private func showRideEditDropDown(ride: Ride,rideActionsMenuController: RideActionsMenuController, anchorView: AnchorView){
        rideEditDropDown.anchorView = anchorView
        rideEditDropDown.bottomOffset = CGPoint(x: -100, y: 0)
        rideEditDropDown.topOffset = CGPoint(x: -100, y: 0)
        rideEditDropDown.textFont = UIFont(name: "HelveticaNeue", size: 14)!
        myRideDetailsViewModel.overFlowMenuActionsList.removeAll()
        if ride.rideType == Ride.RIDER_RIDE{
            if ride.status != Ride.RIDE_STATUS_STARTED {
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.edit_ride)
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.edit_ride_notes)
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.change_role)
            } else {
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.edit_route)
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.ride_notes)
                myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.change_role)
            }
        } else if ride.rideType == Ride.PASSENGER_RIDE {
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.edit_ride)
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.edit_ride_notes)
            myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.change_role)
        }
        rideEditDropDown.dataSource = myRideDetailsViewModel.overFlowMenuActionsList
        rideEditDropDown.selectionAction = { [weak self] (index, item) in
            switch item {
            case Strings.edit_ride:
                rideActionsMenuController.handleEditRide()
            case Strings.edit_route:
                self?.myRideDetailsViewModel.handleEditRoute()
            case Strings.edit_ride_notes:
                rideActionsMenuController.handleRideNotesAction()
            case Strings.change_role:
                rideActionsMenuController.cancelCurrentRideAndCreateNewRideWithDifferentRole()
            default:
                break
            }
        }
        rideEditDropDown.show()
    }
    
    private func showRepeatDropDown(rideActionsMenuController: RideActionsMenuController, anchorView: AnchorView){
        myRideDetailsViewModel.overFlowMenuActionsList.removeAll()
        rideRepeatDropDown.anchorView = anchorView
        rideRepeatDropDown.bottomOffset = CGPoint(x: -100, y: 0)
        rideRepeatDropDown.topOffset = CGPoint(x: -100, y: 0)
        rideRepeatDropDown.textFont = UIFont(name: "HelveticaNeue", size: 14)!
        myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.repeat_once)
        myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.repeat_regular)
        myRideDetailsViewModel.overFlowMenuActionsList.append(Strings.return_ride)
        rideRepeatDropDown.dataSource = myRideDetailsViewModel.overFlowMenuActionsList
        rideRepeatDropDown.selectionAction = { (index, item) in
            switch item {
            case Strings.repeat_once:
                rideActionsMenuController.repeatRide()
            case Strings.repeat_regular:
                rideActionsMenuController.createRegularRide()
            case Strings.return_ride:
                rideActionsMenuController.createReturnRide()
            default:
                break
            }
        }
        rideRepeatDropDown.show()
    }
    

    //MARK: Actions

    @IBAction func rideHistoryBarButtonTapped(_ sender: UIButton) {
        presentHistoryViewController()
    }
    private func rideSetting() {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myridePreferencesViewController)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: true)
    }

    private func vacationSetting() {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VacationViewController")
        self.navigationController?.pushViewController(destViewController, animated: true)
    }
    @IBAction func backButtontapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
//MARK: MyRidesDetailViewController
extension MyRidesDetailViewController {



    func presentCreateRideViewController() {
        self.navigationController?.popViewController(animated: false)
    }

    func presentHistoryViewController() {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let historyVC = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.rideHistoryViewController) as! RideHistoryViewController
        self.navigationController?.pushViewController(historyVC, animated: true)
    }



    func setVehicle(){
        var vehicleModel = ""
        var vehicleModelImage :UIImage?

        if vehicle?.registrationNumber == nil || vehicle!.registrationNumber.isEmpty{
            vehicleModel = self.vehicle?.vehicleModel ?? ""
        }else{

            vehicleModel = self.vehicle?.registrationNumber ?? ""
            vehicleModel = String(vehicleModel.suffix(4))
        }
        var vehicleFare = ""
        if let fare = vehicle?.fare{
            vehicleFare = String(format: Strings.points_per_km, arguments: [String(fare)])
        }
        var vehicleCapacity = ""
        if vehicle?.vehicleType == Vehicle.VEHICLE_TYPE_CAR,let capacity = vehicle?.capacity{
            vehicleModelImage = UIImage(named: "vehicle_type_car_grey")
            vehicleCapacity = String(format: Strings.multi_seat, arguments: [String(capacity)])
        }else{
            vehicleModelImage = UIImage(named: "vehicle_type_bike_grey")
        }
        setVehicleModelText(vehicleModel: vehicleModel, vehicleCapacity: vehicleCapacity, vehicleFare: vehicleFare, image: vehicleModelImage!)
    }

    func presentInviteAndMatchContactsViewController(ride: Ride) {
        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: ride, isFromCanceRide: false, isFromRideCreation: false)
        self.navigationController?.pushViewController(sendInviteBaseViewController, animated: false)
    }
    //Show alert for share ride path

}
//MARK: UITableViewDataSource
extension MyRidesDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activeRideSection = myRideDetailsViewModel.activeRidesHashTable
        switch section {
        case 0:
            var rows = 1
            if let vacation = UserDataCache.getInstance()?.getLoggedInUserVacation(), vacation.fromDate != nil, vacation.toDate != nil{
                rows += 1
            }
            return rows
        case 1: // create ride cell
            if activeRideSection.count == 0{
                return 1
            }
            return 0
        case 2: // upcoming ride header table view cell
            if activeRideSection.count > 0 {
                return 1
            }
            return 0
        case 3: // todays ride
            return activeRideSection[MyRidesDetailViewModel.TODAYS_RIDES]?.count ?? 0
        case 4: // other than todays ride
            return activeRideSection[MyRidesDetailViewModel.NOT_TODAYS_RIDES]?.count ?? 0
        case 5:
            return 1
        case 6:
            return 2
        default :
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyRideVacationTableViewCell", for: indexPath) as! MyRideVacationTableViewCell

                cell.setUpUI(vacation: (UserDataCache.getInstance()!.getLoggedInUserVacation())!) {
                    self.myRidesTableView.reloadData()
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyRidesRecurringTableViewCell", for: indexPath) as! MyRidesRecurringTableViewCell
                cell.delegate = self
                cell.configureRideCollectionView(regularRide: myRideDetailsViewModel.regularRides)
                return cell
            }
        case 1:
            let createRideCell = tableView.dequeueReusableCell(withIdentifier: "CreateRideTableViewCell", for: indexPath) as! CreateRideTableViewCell
            createRideCell.setUpUI(data: false)
            createRideCell.delegate = self
            return createRideCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyRideSectionHeaderTableViewCell", for: indexPath) as! MyRideSectionHeaderTableViewCell
            cell.delegate = self
            cell.configureUI(totalNumberOfActiveRides: ((myRideDetailsViewModel.activeRidesHashTable[MyRidesDetailViewModel.TODAYS_RIDES]?.count ?? 0) + (myRideDetailsViewModel.activeRidesHashTable[MyRidesDetailViewModel.NOT_TODAYS_RIDES]?.count ?? 0)), todayActiveRides: (myRideDetailsViewModel.activeRidesHashTable[MyRidesDetailViewModel.TODAYS_RIDES]?.count ?? 0))
            return cell
        case 3:
            let activeRideSection = myRideDetailsViewModel.activeRidesHashTable
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyRidesDetailTableViewCell", for: indexPath) as! MyRidesDetailTableViewCell
            cell.delegate = self
            let rides: [Ride] =  activeRideSection[MyRidesDetailViewModel.TODAYS_RIDES] ?? []
            cell.overflowButton.tag = indexPath.row
            cell.cellIndexPath = indexPath
            cell.configureView(ride: rides[indexPath.row])
            cell.configureMatchingListForMyRides(ride:  rides[indexPath.row], section: indexPath.section, row: indexPath.row,viewController: self)
            if (rides.count - 1) == indexPath.row {
                cell.seperatorView.isHidden = false
            }else {
                cell.seperatorView.isHidden = true
            }
            return cell
        case 4:
            let activeRideSection = myRideDetailsViewModel.activeRidesHashTable
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyRidesDetailTableViewCell", for: indexPath) as! MyRidesDetailTableViewCell
            cell.delegate = self
            let rides: [Ride] =  activeRideSection[MyRidesDetailViewModel.NOT_TODAYS_RIDES] ?? []
            cell.overflowButton.tag = indexPath.row
            cell.cellIndexPath = indexPath
            cell.configureView(ride: rides[indexPath.row])
            cell.configureMatchingListForMyRides(ride:  rides[indexPath.row], section: indexPath.section, row: indexPath.row,viewController: self)
            if (rides.count - 1) == indexPath.row {
                cell.seperatorView.isHidden = false
            }else {
                cell.seperatorView.isHidden = true
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoMatchTableViewCell", for: indexPath) as! AutoMatchTableViewCell
            cell.setUpUI()
            cell.delegate = self
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
            cell.setUpUI(indexPath: indexPath.row)
            return cell
        default :
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDelegate
extension MyRidesDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 6 {
            if indexPath.row == 0 {
                rideSetting()
            }else if indexPath.row == 1{
                vacationSetting()
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: MyRidesDetailViewModelDelegate
extension MyRidesDetailViewController: MyRidesDetailViewModelDelegate {

    func receiveActiveRide() {
        myRidesTableView.reloadData()
    }

    func receiveErrorForMyRides(responseError: ResponseError?, responseObject: NSDictionary?,error : NSError?) {
        if let responseError = responseError {
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self, handler: nil)
        } else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    func checkVehicalDetails(){
        let currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        if currentUserVehicle?.vehicleId == 0 || currentUserVehicle?.registrationNumber.isEmpty == true {
            let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
            vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: nil, listener: self)
            self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
        }
    }


    func toCreateRecurringRide(ride: Ride){
        let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RecurringRideViewController") as! RecurringRideViewController
        recurringRideViewController.initializeDataBeforePresentingView(ride: ride, isFromRecurringRideCreation: false)
        self.navigationController?.pushViewController(recurringRideViewController, animated: false)

    }
}
//MARK: MyRidesRecurringTableViewCellDelegate
extension MyRidesDetailViewController: MyRidesRecurringTableViewCellDelegate {

    func createRecurringRide(isRecurringRideRequiredFrom: String?) {

        if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
            let regularRideCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
            regularRideCreationViewController.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
            regularRideCreationViewController.initializeView(createRideAsRecuringRide: false, ride: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: regularRideCreationViewController, animated: true)
        } else {
            self.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
            let destViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
            destViewController.initializeView(myRideDeleagte: self)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: true)
        }
    }

    func showRecurringRideScreen(for ride: Ride) {

        if ride.rideType == "RegularRider" {
            let currentUserVehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
            if currentUserVehicle?.vehicleId == 0 || currentUserVehicle?.registrationNumber.isEmpty == true {
                self.checkVehicalDetails()
            } else {
                toCreateRecurringRide(ride: ride)
            }

        } else {

            toCreateRecurringRide(ride: ride)
        }
    }

    func reloadRegularRideCell() {
        myRidesTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

//MARK: MyRidesDetailTableViewCellDelegate
extension MyRidesDetailViewController: MyRidesDetailTableViewCellDelegate {

    func cellButtonTapped(ride: Ride?, indexPath: IndexPath) {
        if myRideDetailsViewModel.activeRidesHashTable.count == 0 {
            presentCreateRideViewController()
        } else {
            var isRequiredToShowRelayRide = ""
            if ride?.rideType == Ride.PASSENGER_RIDE,let relayRide = (ride as? PassengerRide)?.relayLeg{
                if relayRide == RelayRideMatch.RELAY_LEG_ONE{
                    isRequiredToShowRelayRide = RelayRideMatch.SHOW_FIRST_RELAY_RIDE
                }else if relayRide == RelayRideMatch.RELAY_LEG_TWO{
                    isRequiredToShowRelayRide = RelayRideMatch.SHOW_SECOND_RELAY_RIDE
                }
            }
            var alternateRide: Ride?
            if !isRequiredToShowRelayRide.isEmpty{
                alternateRide = MyActiveRidesCache.getRidesCacheInstance()?.getOtherChildRelayRide(ride: ride as? PassengerRide)
            }
            let firstRide: Ride?
            let secondRide: Ride?
            if isRequiredToShowRelayRide == RelayRideMatch.SHOW_FIRST_RELAY_RIDE{
                firstRide = ride
                secondRide = alternateRide
            }else if isRequiredToShowRelayRide == RelayRideMatch.SHOW_SECOND_RELAY_RIDE{
                firstRide = alternateRide
                secondRide = ride
            }else{
                firstRide = ride
                secondRide = nil
            }
            let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
            mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: firstRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false, relaySecondLegRide: secondRide,requiredToShowRelayRide: isRequiredToShowRelayRide)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
        }
    }

    func matchUserProfileButtonTapped(ride: Ride) {
        presentInviteAndMatchContactsViewController(ride: ride)
    }

    func receivePendingInvitation() {
        myRidesTableView.reloadData()
    }

    func createRideButtonTap() {
        presentCreateRideViewController()
    }

    func rideEditButtonTapped(ride: Ride?, rideParticipants: [RideParticipant], senderTag: Int,taxiShareRide: TaxiShareRide?,dropDownView: AnchorView?) {
        guard let dropDownView = dropDownView, let ride = ride else { return }
        let rideActionsMenuController = RideActionsMenuController(ride: ride, isFromRideView: true, viewController: self, rideUpdateListener: myRideDetailsViewModel, delegate: myRideDetailsViewModel)
        setupOverFlowDropDownView(ride: ride, rideParticipants: rideParticipants, taxiShareRide: taxiShareRide, rideActionsMenuController: rideActionsMenuController ,anchorView: dropDownView)
    }
}
//MARK: MyRidesAutoMatchTableViewCellDelegate
extension MyRidesDetailViewController: AutoMatchTableViewCellDelegate {


    func updateAndSaveAutoMatchPreference(status: Bool,preference: RidePreferences) {
        let preference = myRideDetailsViewModel.getRidePreference()
        preference.autoConfirmEnabled = status
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: preference, viewController: self, receiver: self).saveRidePreferences()
    }

    func autoMatchSettingTapped() {
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: myRideDetailsViewModel.getRidePreference())
        self.navigationController?.pushViewController(rideAutoConfirmationSettingViewController, animated: false)
    }

}
//MARK: CreateRideTableViewCellDelegate and cancelRide
extension MyRidesDetailViewController: CreateRideTableViewCellDelegate,RideCancelDelegate {
    func rideCancelled() {
        if taxiPoolCancelFeeWaived {
            // showCancelFeeWaiverView()
            taxiPoolCancelFeeWaived = false
        }
    }

    func createRideButtonTapped() {
        presentCreateRideViewController()
    }
}


//MARK: MyRideSectionHeaderTableViewCellDelegate
extension MyRidesDetailViewController: MyRideSectionHeaderTableViewCellDelegate {
    func loadCreateRideView() {
        presentCreateRideViewController()
    }
}
//MARK: SaveRidePreferencesReceiver
extension MyRidesDetailViewController: SaveRidePreferencesReceiver {
    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }

    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
    }
}

//MARK: NotificationChangeListener
extension MyRidesDetailViewController: NotificationChangeListener {

    func handleNotificationListChange() {
        myRidesTableView.reloadData()
    }
}

//MARK: HomeOfficeSavingDelegate
extension MyRidesDetailViewController: HomeOfficeLocationSavingDelegate {

    func navigateToRegularRideCreation() {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.regularRideCreationViewController) as! RegularRideCreationViewController
        destViewController.isRecurringRideRequiredFrom = isRecurringRideRequiredFrom
        destViewController.initializeView(createRideAsRecuringRide: false, ride: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: true)
    }
}
