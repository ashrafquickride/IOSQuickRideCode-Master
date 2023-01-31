//
//  TaxiHomePageBottomViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class TaxiHomePageBottomViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var taxiHomePageCardsTableView: UITableView!
    @IBOutlet weak var taxiButton: UIButton!
    @IBOutlet weak var rentalButton: UIButton!
    @IBOutlet weak var taxiMarkerView: UIView!
    @IBOutlet weak var rentalMarkerView: UIView!

    //MARK: Variables
    private var locationManager = CLLocationManager()
    var taxiHomePageViewModel = TaxiHomePageViewModel()

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsToView()
        setTaxiAndRentalButton(index: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(ratingGivenForDriver), name: .ratingGivenForDriver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .taxiRideCreatedFromTOC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .taxiDriverAllocationStatusChanged, object: nil)
    }

    private func registerCellsToView() {
        taxiHomePageCardsTableView.estimatedRowHeight = 44
        taxiHomePageCardsTableView.rowHeight = UITableView.automaticDimension
        taxiHomePageCardsTableView.register(UINib(nibName: "TaxiHomeLocationSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiHomeLocationSelectionTableViewCell")
        taxiHomePageCardsTableView.register(UINib(nibName: "UpcomingTripsTableViewCell", bundle: nil), forCellReuseIdentifier: "UpcomingTripsTableViewCell")
        taxiHomePageCardsTableView.register(UINib(nibName: "AirPortOfferTableViewCell", bundle: nil), forCellReuseIdentifier: "AirPortOfferTableViewCell")
        taxiHomePageCardsTableView.register(UINib(nibName: "TaxiTripPassengerFeedbackRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripPassengerFeedbackRatingTableViewCell")
        taxiHomePageCardsTableView.register(UINib(nibName: "RentalPackageSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "RentalPackageSelectionTableViewCell")
        taxiHomePageCardsTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        taxiHomePageCardsTableView.reloadData()
        taxiHomePageViewModel.getCompletedTaxiTripData(complitionHandler: { [weak self]
        result in
            if result {
                self?.taxiHomePageCardsTableView.reloadData()
            }
        })
    }

    private func moveToBookTaxiScreen() {
        if !taxiHomePageViewModel.isStartAndEndValid() {
            return
        }
        if taxiHomePageViewModel.isStartAndEndAddressAreSame() {
            UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height - 300), title: nil, image: nil, completion: nil)
            return
        }
        let taxiRideCreationMapViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
        taxiRideCreationMapViewController.initialiseData(startLocation: taxiHomePageViewModel.pickupLocation, endLocation: taxiHomePageViewModel.dropLocation, selectedRouteId: taxiHomePageViewModel.routeId ?? -1, tripType: taxiHomePageViewModel.selectedRideType, journeyType: TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY, commuteContactNo: taxiHomePageViewModel.behalfBookingPhoneNumber, commutePassengerName: taxiHomePageViewModel.behalfBookingName)
        taxiHomePageViewModel.dropLocation = nil
        taxiHomePageViewModel.pickupLocation = taxiHomePageViewModel.currentLocation
        if let homeVC = self.parent?.parent as? TaxiHomePageViewController, let currentLoc = taxiHomePageViewModel.currentLocation {
            homeVC.clearBehalfTaxiBookingData()
            homeVC.updateMapLocation(lat: currentLoc.latitude, long: currentLoc.longitude )
        }
        self.navigationController?.pushViewController(taxiRideCreationMapViewController, animated: false)
    }

    func moveToCurrentLocation(location: Location) {
        taxiHomePageViewModel.currentLocation = location
        taxiHomePageViewModel.pickupLocation = location
        UserDataCache.getInstance()?.userCurrentLocation = location
        if taxiHomePageViewModel.pickupLocation == nil {
            taxiHomePageViewModel.pickupLocation = location
        }
        taxiHomePageCardsTableView.reloadData()
    }

    @objc func ratingGivenForDriver(_ notification: Notification) {
        self.taxiHomePageViewModel.isRequiredToShowRatingCard = false
        self.taxiHomePageCardsTableView.reloadData()
    }
    @objc func reloadTableView(_ notification: Notification){
        self.taxiHomePageCardsTableView.reloadData()
    }

    @IBAction func taxiButtonTapped(_ sender: Any) {
        self.taxiHomePageViewModel.selectedOptionIndex = 0
        setTaxiAndRentalButton(index: 0)
        self.taxiHomePageCardsTableView.reloadData()
    }

    @IBAction func rentalButtonTapped(_ sender: Any) {
        self.taxiHomePageViewModel.selectedOptionIndex = 1
        setTaxiAndRentalButton(index: 1)
        QuickRideProgressSpinner.startSpinner()
        taxiHomePageViewModel.getRentalPackages { (responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseError != nil || error != nil {
                var userInfo = [String: Any]()
                userInfo["error"] = error
                userInfo["responseError"] = responseError
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            } else {
                self.taxiHomePageCardsTableView.reloadData()
            }
        }
    }

    func setTaxiAndRentalButton(index: Int) {
        if index == 0 {
            taxiButton.setTitleColor(UIColor(netHex: 0x009F4C), for: .normal)
            rentalButton.setTitleColor(UIColor(netHex: 0x929292), for: .normal)
            rentalMarkerView.isHidden = true
            taxiMarkerView.isHidden = false
        } else {
            taxiButton.setTitleColor(UIColor(netHex: 0x929292), for: .normal)
            rentalButton.setTitleColor(UIColor(netHex: 0x00B557), for: .normal)
            rentalMarkerView.isHidden = false
            taxiMarkerView.isHidden = true
        }
    }
}

//MARK: UITableViewDataSource
extension TaxiHomePageBottomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if !MyActiveTaxiRideCache.getInstance().getActiveTaxiRides().isEmpty {
                return 1
            } else {
                return 0
            }
        case 2:
            if taxiHomePageViewModel.isRequiredToShowRatingCard {
                return 1
            } else {
                return 0
            }
        case 3:
            return 1
        case 4:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if taxiHomePageViewModel.selectedOptionIndex == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RentalPackageSelectionTableViewCell", for: indexPath) as! RentalPackageSelectionTableViewCell
                cell.setupUI(pickup: taxiHomePageViewModel.pickupLocation, rentalPackageEstimates: taxiHomePageViewModel.rentalPackageEstimates, userSelectionDelegate: self, rentalPackageSelectionDelegate: self, selectedIndex: nil, isFromHomePage: true, startTime: nil)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiHomeLocationSelectionTableViewCell", for: indexPath) as! TaxiHomeLocationSelectionTableViewCell
                cell.initializeTaxiLocation(pickup: taxiHomePageViewModel.pickupLocation, drop: taxiHomePageViewModel.dropLocation, userSelectionDelegate: self)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTripsTableViewCell", for: indexPath) as! UpcomingTripsTableViewCell
            cell.initialiseNextTrip()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripPassengerFeedbackRatingTableViewCell", for: indexPath) as! TaxiTripPassengerFeedbackRatingTableViewCell
            cell.initialiseDriverData(taxiHomePageViewModel: taxiHomePageViewModel)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AirPortOfferTableViewCell", for: indexPath) as! AirPortOfferTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }

}

//MARK: UITableViewDataSource
extension TaxiHomePageBottomViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && !MyActiveTaxiRideCache.getInstance().getActiveTaxiRides().isEmpty {
            return 10
        } else if section == 1 {
            return 10
        } else if section == 2 && taxiHomePageViewModel.isRequiredToShowRatingCard {
            return 10
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return footerCell
    }
}

//MARK: RideLocationSelectionTableViewCellDelegate
extension TaxiHomePageBottomViewController: RideLocationSelectionTableViewCellDelegate {
    func rideTypeChanged(primary: String) {
        taxiHomePageViewModel.selectedRideType = primary
    }

    func fromLocationTapped() {
        if let pickupLocation = taxiHomePageViewModel.pickupLocation {
            moveToLocationSelection(locationType: ChangeLocationViewController.TAXI_PICKUP, location: pickupLocation, alreadySelectedLocation: taxiHomePageViewModel.dropLocation)
        } else {
            moveToLocationSelection(locationType: ChangeLocationViewController.TAXI_PICKUP, location: nil, alreadySelectedLocation: taxiHomePageViewModel.dropLocation)
        }
    }

    func toLocationTapped() {
        if let dropLocation = taxiHomePageViewModel.dropLocation {
            moveToLocationSelection(locationType: ChangeLocationViewController.TAXI_DROP, location: dropLocation, alreadySelectedLocation: taxiHomePageViewModel.pickupLocation)
        } else {
            moveToLocationSelection(locationType: ChangeLocationViewController.TAXI_DROP, location: nil, alreadySelectedLocation: taxiHomePageViewModel.pickupLocation)
        }
    }

    func selectedFavLocation(location: Location) {
        taxiHomePageViewModel.dropLocation = location
        taxiHomePageCardsTableView.reloadData()
        moveToBookTaxiScreen()
    }

    private func moveToLocationSelection(locationType: String, location: Location?, alreadySelectedLocation: Location?) {
        taxiHomePageViewModel.isRequiredToClearBehalfBookingData = false
        var routeSelectionDelegate: RouteSelectionDelegate? = self
        if taxiHomePageViewModel.selectedOptionIndex == 1 {
            routeSelectionDelegate = nil
        }
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.receiveBehalfBookingDetails = self
        changeLocationVC.behalfBookingPhoneNumber = taxiHomePageViewModel.behalfBookingPhoneNumber
        changeLocationVC.behalfBookingName = taxiHomePageViewModel.behalfBookingName
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: routeSelectionDelegate, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
}

//MARK: ReceiveLocationDelegate
extension TaxiHomePageBottomViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        taxiHomePageViewModel.isRequiredToClearBehalfBookingData = true
        if taxiHomePageViewModel.selectedOptionIndex == 0 {
            if requestLocationType == ChangeLocationViewController.TAXI_PICKUP {
                taxiHomePageViewModel.pickupLocation = location
                if let taxiHomePageViewController = self.parent?.parent as? TaxiHomePageViewController {
                    taxiHomePageViewController.rideStartLocationChanged(location: location)
                }
            } else if requestLocationType == ChangeLocationViewController.TAXI_DROP {
                taxiHomePageViewModel.dropLocation = location
            }
            taxiHomePageViewModel.routeId = nil
            taxiHomePageCardsTableView.reloadData()
            if validateIsBookingForSome(), requestLocationType == ChangeLocationViewController.TAXI_PICKUP {
                moveToTaxiBookingSomeOneView { completed in
                    self.moveToBookTaxiScreen()
                }
            }else {
                moveToBookTaxiScreen()
            }
        } else if taxiHomePageViewModel.selectedOptionIndex == 1 {
            taxiHomePageViewModel.pickupLocation = location
            if validateIsBookingForSome() {
                moveToTaxiBookingSomeOneView { completed in }
            }
            if let taxiHomePageViewController = self.parent?.parent as? TaxiHomePageViewController {
                taxiHomePageViewController.rideStartLocationChanged(location: location)
            }
            taxiHomePageViewModel.getRentalPackages { (responseError, error) in
                self.taxiHomePageCardsTableView.reloadData()
                if responseError != nil || error != nil {
                    var userInfo = [String: Any]()
                    userInfo["error"] = error
                    userInfo["responseError"] = responseError
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }

        } else if requestLocationType == ChangeLocationViewController.DESTINATION {
            taxiHomePageViewModel.dropLocation = location
        }
    }
    
    private func moveToTaxiBookingSomeOneView(handler: @escaping actionComplitionHandler){
        let tripTypeViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_behalf_someone_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TripTypeViewController") as! TripTypeViewController
        tripTypeViewController.initialiseData(behalfBookingPhoneNumber: taxiHomePageViewModel.behalfBookingPhoneNumber, behalfBookingName: taxiHomePageViewModel.behalfBookingName){  contactName, contactNumber in
            if let contactName = contactName, let contactNumber = contactNumber {
                self.taxiHomePageViewModel.behalfBookingName = contactName
                self.taxiHomePageViewModel.behalfBookingPhoneNumber = contactNumber
            }
            handler(true)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: tripTypeViewController)
    }

    func locationSelectionCancelled(requestLocationType: String) {
        taxiHomePageViewModel.isRequiredToClearBehalfBookingData = true
    }
    
    private func validateIsBookingForSome() -> Bool{
        guard !taxiHomePageViewModel.isCheckedForBehalfBooking, let location = locationManager.location,let startLat = taxiHomePageViewModel.pickupLocation?.latitude , let startLng = taxiHomePageViewModel.pickupLocation?.longitude  else {
            return false
        }
        let distanceBetweenTwoLocation = LocationClientUtils.getDistance(fromLatitude: location.coordinate.latitude, fromLongitude: location.coordinate.longitude, toLatitude: startLat, toLongitude: startLng)
        if distanceBetweenTwoLocation > 3000 {
            taxiHomePageViewModel.isCheckedForBehalfBooking = true
            return true
        }else{
            return false
        }
        
    }
}

//MARK: ReceiveLocationDelegate
extension TaxiHomePageBottomViewController: RouteSelectionDelegate {
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
    }

    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        if preferredRoute.fromLocation != nil {
            taxiHomePageViewModel.pickupLocation = Location(latitude: preferredRoute.fromLatitude ?? 0, longitude: preferredRoute.fromLongitude ?? 0, shortAddress: preferredRoute.fromLocation)
        }
        if preferredRoute.toLocation != nil {
            taxiHomePageViewModel.dropLocation = Location(latitude: preferredRoute.toLatitude ?? 0, longitude: preferredRoute.toLongitude ?? 0, shortAddress: preferredRoute.toLocation)
        }
        taxiHomePageViewModel.routeId = preferredRoute.routeId
        taxiHomePageCardsTableView.reloadData()
        moveToBookTaxiScreen()
    }
}

extension TaxiHomePageBottomViewController: RentalPackageSelectionDelegate {
    func pickUpDateTapped() {

    }

    func pickupLocationChanged() {
        moveToLocationSelection(locationType: ChangeLocationViewController.TAXI_PICKUP, location: nil, alreadySelectedLocation: nil)
    }

    func selectedRentalPackage(packageDistance: Int, packageDuration: Int) {
        if let index = taxiHomePageViewModel.rentalPackageEstimates?.firstIndex(where: { $0.packageDistance == packageDistance && $0.packageDuration == packageDuration }) {
            let selectedPackage = taxiHomePageViewModel.rentalPackageEstimates?[index]
            let taxiRideCreationMapViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
            taxiRideCreationMapViewController.initialiseData(startLocation: taxiHomePageViewModel.pickupLocation, selectedRentalPackage: selectedPackage, rentalPackageEstimates: taxiHomePageViewModel.rentalPackageEstimates, commuteContactNo: taxiHomePageViewModel.behalfBookingPhoneNumber, commutePassengerName: taxiHomePageViewModel.behalfBookingName)
            self.navigationController?.pushViewController(taxiRideCreationMapViewController, animated: false)
        }
    }

    func showPackageInfo() {

    }
}

extension TaxiHomePageBottomViewController: ReceiveBehalfBookingDetails{
    func receiveBehalfBookingDetails(commuteContactNo: String?, commutePassengerName: String?) {
        taxiHomePageViewModel.behalfBookingPhoneNumber = commuteContactNo
        taxiHomePageViewModel.behalfBookingName = commutePassengerName
    }
}
