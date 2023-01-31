//
//  TaxiPoolRideDetailViewController.swift
//  Quickride
//
//  Created by Ashutos on 5/17/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import ObjectMapper
import FloatingPanel

protocol TaxiPoolRideDetailViewControllerDelegate {
    func selectedIndexChanged(selectedIndex: Int)
}

class TaxiPoolRideDetailViewController: UIViewController {
    
    @IBOutlet weak var taxiRideDetailsTableView: UITableView!
    
    private var taxiPoolDetailViewModel = TaxiPoolRideDetailsViewModel()
    private var joinFlowUI: NewJoinShimmerViewController?
    private var backGroundView: UIView?
    var delegate: TaxiPoolRideDetailViewControllerDelegate?
    private var drawerState = FloatingPanelPosition.half
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        taxiRideDetailsTableView.estimatedRowHeight = 240
        taxiRideDetailsTableView.rowHeight = UITableView.automaticDimension
        taxiRideDetailsTableView.reloadData()
        if taxiPoolDetailViewModel.analyticNotificationHandlerModel != nil || taxiPoolDetailViewModel.taxiInviteEntity != nil {
            taxiRideDetailsTableView.backgroundColor = .white
            taxiPoolDetailViewModel.getTaxiRideDetails(completionHandler: {[weak self] result in
                self?.taxiRideDetailsTableView.reloadData()
            })
        }
    }
    
    func getDataForTheSharedTaxi(selectedIndex: Int?, matchedShareTaxis: [MatchedShareTaxi]?,ride: Ride?, delegate: TaxiPoolRideDetailViewControllerDelegate?,analyticNotificationHandlerModel: AnalyticNotificationHandlerModel?,taxiInviteData: TaxiInviteEntity?) {
        taxiPoolDetailViewModel.initliseData(selectedIndex: selectedIndex, matchedShareTaxi: matchedShareTaxis, ride: ride, analyticNotificationHandlerModel: analyticNotificationHandlerModel,taxiInviteEntity: taxiInviteData)
        self.delegate = delegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func registerCells() {
        taxiRideDetailsTableView.register(UINib(nibName: "TaxiPoolDetailCardTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolDetailCardTableViewCell")
        taxiRideDetailsTableView.register(UINib(nibName: "CoRidersTaxiDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "CoRidersTaxiDetailsTableViewCell")
        taxiRideDetailsTableView.register(UINib(nibName: "TaxiPoolVehicleDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolVehicleDetailsTableViewCell")
    }
}

extension TaxiPoolRideDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if taxiPoolDetailViewModel.analyticNotificationHandlerModel != nil {
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
            if taxiPoolDetailViewModel.analyticNotificationHandlerModel == nil {
                if taxiPoolDetailViewModel.taxiInviteEntity != nil {
                  return 1
                }
                return 0
            }else{
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPoolDetailCardTableViewCell", for: indexPath) as! TaxiPoolDetailCardTableViewCell
            if taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                cell.updateUI(data: nil, analyticsData: taxiPoolDetailViewModel.analyticNotificationHandlerModel,inviteData: taxiPoolDetailViewModel.taxiInviteEntity)
            } else {
                cell.updateUI(data: taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex], analyticsData: nil, inviteData: taxiPoolDetailViewModel.taxiInviteEntity)
                checkAndAddRideDetailViewSwipeGesture(cell: cell)
            }
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoRidersTaxiDetailsTableViewCell", for: indexPath) as! CoRidersTaxiDetailsTableViewCell
            if taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                cell.getDataAndUpdate(data: nil , potenTialCoRide: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.limitedUserProfile, taxiInviteData: taxiPoolDetailViewModel.taxiInviteEntity)
            } else {
                cell.getDataAndUpdate(data: taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex].taxiShareRidePassengerInfos , potenTialCoRide: nil, taxiInviteData: taxiPoolDetailViewModel.taxiInviteEntity)
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPoolVehicleDetailsTableViewCell", for: indexPath) as! TaxiPoolVehicleDetailsTableViewCell
            return cell
        }
    }
}

//MARK: DetailCardDelegate
extension TaxiPoolRideDetailViewController: TaxiPoolDetailCardTableViewCellDelegate {
    func joinInvitePressed() {
        addJoinViewAsSubView()
        self.joinTaxiPool()
    }
    
    func rejectInvitePressed() {
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.rejectInvite(inviteId: taxiPoolDetailViewModel.taxiInviteEntity?.id ?? "") {[weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject?["result"] as? String == "SUCCESS"{
                TaxiPoolInvitationCache.getInstance().removeAnInvitationFromLocal(rideId: self?.taxiPoolDetailViewModel.ride?.rideId ?? 0, invitationId: self?.taxiPoolDetailViewModel.taxiInviteEntity?.id ?? "")
                self?.removeJoinViewFromSuperView()
             }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error,viewController: nil, handler: nil)
            }
        }
    }
    
    //MARK: Notification
    func notificationJoinBtnPressed() {
        if taxiPoolDetailViewModel.ride != nil {
            joinTaxiPoolClicked()
        } else {
            taxiPoolDetailViewModel.createPassengerRide { (data) in
                if data {
                    self.joinTaxiPoolClicked()
                } else{
                    return
                }
            }
        }
    }
    
    func joinBtnPressed(index: Int) {
        joinTaxiPoolClicked()
    }
    
    private func joinTaxiPoolClicked() {
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if (defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI) {
            UIApplication.shared.keyWindow?.makeToast( Strings.request_in_progress)
            return
        }
        getPickUpAndDropLocation()
    }
    
    private func getPickUpAndDropLocation() {
        guard let ride = taxiPoolDetailViewModel.ride else { return }
        let pickupLocation = Location(latitude: ride.startLatitude, longitude: ride.startLongitude, shortAddress: ride.startAddress)
        let dropLocation = Location(latitude: ride.endLatitude ?? 0, longitude: ride.endLongitude ?? 0, shortAddress: ride.endAddress)
        let selectLocationFromMap = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "SelectLocationOnMapViewController") as! SelectLocationOnMapViewController
        selectLocationFromMap.initializeDataBeforePresenting(receiveLocationDelegate: self,location : pickupLocation, locationType: "", actnBtnTitle: Strings.done_caps, isFromEditRoute: false, dropLocation: dropLocation)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectLocationFromMap, animated: false)
    }
}

extension TaxiPoolRideDetailViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {}
    func locationSelectionCancelled(requestLocationType: String) {}
    func receivePickUPAndDropLocation(pickUpLocation:Location,dropLocation: Location,requestLocationType : String) {
        guard let rideObj = taxiPoolDetailViewModel.ride else {return}
        let ride = rideObj as! PassengerRide
        ride.startLatitude = pickUpLocation.latitude
        ride.startLongitude = pickUpLocation.longitude
        ride.startAddress = pickUpLocation.address ?? ""
        ride.endLatitude = dropLocation.latitude
        ride.endLongitude = dropLocation.longitude
        ride.endAddress = dropLocation.address ?? ""
        addJoinViewAsSubView()
        PassengerRideServiceClient.updatePassengerRide(rideId: ride.rideId, startAddress: ride.startAddress, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endAddress: ride.endAddress, endLatitude: ride.endLatitude!, endLongitude: ride.endLongitude!, startTime: nil, noOfSeats: nil, route: nil, pickupAddress: nil,pickupLatitude: nil,pickupLongitude: nil,dropAddress: nil,dropLatitude: nil,dropLongitude: nil,pickupTime: nil,dropTime: nil,points : nil,overlapDistance: nil, allowRideMatchToJoinedGroups: false, showMeToJoinedGroups: false, pickupNote: nil,viewController: self, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let passenegerRideUpdate = Mapper<PassengerRide>().map(JSONObject: responseObject!["resultData"])
                if passenegerRideUpdate != nil {
                    MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: passenegerRideUpdate!)
                }
                if self.taxiPoolDetailViewModel.analyticNotificationHandlerModel == nil {
                    self.joinTaxiPool()
                }else{
                    if self.taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                        self.createOrJoinTaxiPool()
                    } else {
                        self.joinTaxiPool()
                    }
                }
            } else {
                self.removeJoinViewFromSuperView()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error,viewController: nil, handler: nil)
            }
        })
    }
    
    private func joinTaxiPool() {
        var inviteId: String?
        if taxiPoolDetailViewModel.taxiInviteEntity != nil {
            inviteId = taxiPoolDetailViewModel.taxiInviteEntity?.id
        }
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        let joinTaxiPoolHandler = JoinTaxiPoolHandler(rideId: taxiPoolDetailViewModel.ride?.rideId ?? 0.0,matchedShareTaxiId: taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex].taxiId ?? 0, paymentType: defaultPaymentMethod?.type ?? "", taxiInviteId: inviteId, isRideNeedToCancel: false,  viewController: self)
        joinTaxiPoolHandler.joinTaxiPool { (data, error) in
            self.removeJoinViewFromSuperView()
            if data != nil {
            let rideObj = self.taxiPoolDetailViewModel.ride as? PassengerRide
            rideObj?.taxiRideId = data?.id
            MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: rideObj!)
            self.moveToLiveRide()
            }
        }
    }
    
    private func createOrJoinTaxiPool() {
        var taxiRideId: Double?
        var shareType = ""
        if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty{
            taxiRideId = taxiPoolDetailViewModel.matchedShareTaxi[0].taxiId
            shareType = taxiPoolDetailViewModel.matchedShareTaxi[0].shareType ?? ""
        } else {
            shareType = taxiPoolDetailViewModel.analyticNotificationHandlerModel?.shareType ?? ""
        }
        let creteORJoinTaxiPoolHandler = TaxiPoolCreateORJoinHandler(rideId: taxiPoolDetailViewModel.ride?.rideId ?? 0.0, shareType: shareType , taxiRideId: taxiRideId, viewController: self)
        creteORJoinTaxiPoolHandler.creteORJoinTaxiPool { (data, error) in
            self.removeJoinViewFromSuperView()
            if data != nil {
                let rideObj = self.taxiPoolDetailViewModel.ride as? PassengerRide
                rideObj?.taxiRideId = data?.id
                MyActiveRidesCache.getRidesCacheInstance()?.updateExistingRide(ride: rideObj!)
                self.moveToLiveRide()
            }
        }
    }
    
    private func addJoinViewAsSubView() {
        joinFlowUI = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewJoinShimmerViewController") as? NewJoinShimmerViewController
        joinFlowUI!.initLiseData(shareType: TaxiPoolConstants.SHARE_TYPE_ANY_SHARING, startTime: taxiPoolDetailViewModel.ride?.startTime, isOldTaxiRide: true,taxiType: TaxiPoolConstants.TAXI_TYPE_CAR)
        self.navigationController?.pushViewController(joinFlowUI!, animated: false)
    }
    
    private func removeJoinViewFromSuperView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func moveToLiveRide() {
        navigationController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.indexToSelect = 0
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: taxiPoolDetailViewModel.ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
}

//SwipeGesture
extension TaxiPoolRideDetailViewController {
    
    func floatingLabelPositionChanged(position: FloatingPanelPosition) {
        if position == .full {
            self.drawerState = position
            self.taxiRideDetailsTableView.isScrollEnabled = true
        }else{
            self.drawerState = position
            self.taxiRideDetailsTableView.isScrollEnabled = false
        }
        self.taxiRideDetailsTableView.reloadData()
    }
    
    func checkAndAddRideDetailViewSwipeGesture(cell: TaxiPoolDetailCardTableViewCell) {
        if drawerState == .full {
            cell.leftView.isHidden = true
            cell.rightView.isHidden = true
            cell.backGroundView.isUserInteractionEnabled = false
        } else {
            if taxiPoolDetailViewModel.matchedShareTaxi.count > 1 {
                cell.backGroundView.isUserInteractionEnabled = true
                backGroundView = cell.backGroundView
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                leftSwipe.direction = .left
                backGroundView!.addGestureRecognizer(leftSwipe)
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                rightSwipe.direction = .right
                backGroundView!.addGestureRecognizer(rightSwipe)
            }else{
                cell.leftView.isHidden = true
                cell.rightView.isHidden = true
            }
            if taxiPoolDetailViewModel.selectedIndex == 0{
                cell.leftView.isHidden = true
            }else{
                cell.leftView.isHidden = false
            }
            if taxiPoolDetailViewModel.selectedIndex == taxiPoolDetailViewModel.matchedShareTaxi.count - 1 {
                cell.rightView.isHidden = true
            }else{
                cell.rightView.isHidden = false
            }
        }
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if taxiPoolDetailViewModel.selectedIndex != taxiPoolDetailViewModel.matchedShareTaxi.count - 1{
                backGroundView!.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
        }else if gesture.direction == .right {
            
            if taxiPoolDetailViewModel.selectedIndex != 0 {
                backGroundView!.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
        }
        if gesture.direction == .left {
            taxiPoolDetailViewModel.selectedIndex += 1
            if taxiPoolDetailViewModel.selectedIndex > taxiPoolDetailViewModel.matchedShareTaxi.count - 1 {
                taxiPoolDetailViewModel.selectedIndex = taxiPoolDetailViewModel.matchedShareTaxi.count - 1
            }
        }else if gesture.direction == .right {
            taxiPoolDetailViewModel.selectedIndex -= 1
            if taxiPoolDetailViewModel.selectedIndex < 0 {
                taxiPoolDetailViewModel.selectedIndex = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.taxiRideDetailsTableView.reloadData()
            self.delegate?.selectedIndexChanged(selectedIndex: self.taxiPoolDetailViewModel.selectedIndex)
        })
    }
}
