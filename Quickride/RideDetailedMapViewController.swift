//
//  RideDetailedMapViewController.swift
//  Quickride
//
//  Created by Vinutha on 31/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import FloatingPanel

class RideDetailedMapViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var lastRideTakenButton: UIButton!
    @IBOutlet weak var lastRideTakenWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideStatusButton: UIButton!
    @IBOutlet weak var rideStatusButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageNumberButton: UIButton!
    @IBOutlet weak var navigationViewForDetailView: UIView!
    @IBOutlet weak var rideTypeLabel: UILabel!
    @IBOutlet weak var rideTimeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var rideRequestAckView: UIView!
    @IBOutlet weak var rideRequestAckLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var routeEditButton: UIButton!
    @IBOutlet weak var mapComponentBottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var MatchedUserRideActionView: MatchedUserRideActionView!
    @IBOutlet weak var paymentPendingInfoView: UIView!
    
    //MARK: Properties
    private var rideDetailMapViewModel = RideDetailMapViewModel()
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    private var vehicleMarker : GMSMarker!
    private var guideView : UIView?
    private var floatingPanelController: FloatingPanelController!
    private var rideDetailedViewController: RideDetailedViewController!
    private var eta: String?
    private var matchedUserRideActionView: MatchedUserRideActionView!

    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapContainerView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 20, bottom: 300, right: 60)
        viewMap.delegate = self
        setDataToView()
        addRideDetailCardViewController()
        mapComponentBottomConstarint.constant = (floatingPanelController.layout.insetFor(position: floatingPanelController.position) ?? 0) + 5
        handleVisibilityAndContentOfPaymentInfoView()
        if rideDetailMapViewModel.viewType != DetailViewType.PaymentPendingView {
            self.view.addSubview(MatchedUserRideActionView)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        RideInviteCache.getInstance().addRideInviteStatusListener(rideInvitationUpdateListener: self)
        showRideActionButtonsView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        RideInviteCache.getInstance().removeRideInviteStatusListener()
    }

    //MARK: Methods
    func initializeData(ride: Ride, matchedUserList: [MatchedUser], viewType: DetailViewType, selectedIndex: Int, startAndEndChangeRequired: Bool, selectedUserDelegate: SelectedUserDelegate?,rideInviteId: Double? = nil){

        rideDetailMapViewModel.initializeData(ride: ride, matchedUserList: matchedUserList, routePathReceiveDelagate: self, rideParticipantLocationReceiveDelagate: self, viewType: viewType, selectedIndex: selectedIndex, startAndEndChangeRequired: startAndEndChangeRequired, selectedUserDelegate: selectedUserDelegate, matchedPassengerReciever: nil,rideInviteId: rideInviteId)
    }

    private func addRideDetailCardViewController(){
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self

        // Initialize FloatingPanelController and add the view
        floatingPanelController.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            floatingPanelController.surfaceView.cornerRadius = 20.0
        } else {
            floatingPanelController.surfaceView.cornerRadius = 0.0
        }
        floatingPanelController.surfaceView.shadowHidden = false
        floatingPanelController.surfaceView.grabberTopPadding = 10

        rideDetailedViewController = storyboard?.instantiateViewController(withIdentifier: "RideDetailedViewController") as? RideDetailedViewController
        rideDetailedViewController.initializeData(ride: rideDetailMapViewModel.ride!,  matchedUserList: rideDetailMapViewModel.matchedUserList, viewType: rideDetailMapViewModel.viewType!, selectedIndex: rideDetailMapViewModel.selectedIndex, startAndEndChangeRequired: rideDetailMapViewModel.startAndEndChangeRequired, selectedUserDelegate: rideDetailMapViewModel.selectedUserDelegate, matchedUserDataChangeDelagate: self)

        // Set a content view controller
        floatingPanelController.set(contentViewController: rideDetailedViewController)
        floatingPanelController.track(scrollView: rideDetailedViewController.userDetailTableView)
        floatingPanelController.addPanel(toParent: self, animated: true)
    }

    private func setDataToView() {
        eta = nil
        if let ride = rideDetailMapViewModel.ride {
            let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
            drawRouteOnMap()
            checkAndSetPickUpAndDropAddress()
            if ride.routePathPolyline.isEmpty {
                var endLatitude = ride.endLatitude
                var endLongitude = ride.endLongitude
                if endLatitude == 0 && endLongitude == 0{
                    endLatitude = matchedUser.toLocationLatitude
                    endLongitude = matchedUser.toLocationLongitude
                }
                MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App."+(ride.rideType ?? "Passenger")+".MainRoute.DetailedRouteView", rideId: ride.rideId, startLatitude: ride.startLatitude, startLongitude: ride.startLongitude, endLatitude: endLatitude!, endLongitude: endLongitude!, wayPoints: nil, routeReceiver: self,saveCustomRoute: false)

            }
            if matchedUser.routePolyline == nil || matchedUser.routePolyline!.isEmpty {
                var rideType : String?
                if matchedUser.userRole == MatchedUser.RIDER {
                    rideType = Ride.RIDER_RIDE
                }else if matchedUser.userRole == MatchedUser.PASSENGER {
                    rideType = Ride.PASSENGER_RIDE
                }else if matchedUser.userRole == MatchedUser.REGULAR_RIDER {
                    rideType = Ride.REGULAR_RIDER_RIDE
                }else if matchedUser.userRole == MatchedUser.REGULAR_PASSENGER {
                    rideType = Ride.REGULAR_PASSENGER_RIDE
                }
                if rideType == nil{
                    return
                }
                rideDetailMapViewModel.getRoutePath()
            }
            if ride.userId != 0, let currentUserId = Double(QRSessionManager.getInstance()?.getUserId() ?? "0"), currentUserId != 0, ride.userId != currentUserId {
                routeEditButton.isHidden = true
            } else {
                routeEditButton.isHidden = false
            }
        }
        let pageNumber = String(rideDetailMapViewModel.selectedIndex + 1) + "/" + String(rideDetailMapViewModel.matchedUserList.count)
        pageNumberButton.setTitle(pageNumber, for: .normal)
        pageNumberButton.isHidden = false
        setHeaderTitle()
        checkAndDisplayRideLastCreatedTime()
        setRideDateForHeader()
    }

    private func setHeaderTitle() {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if rideDetailMapViewModel.viewType == DetailViewType.RideInviteView {
            topInfoView.isHidden = false
            navigationViewForDetailView.isHidden = true
            ViewCustomizationUtils.addCornerRadiusToView(view: mapContainerView, cornerRadius: 20)
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            topInfoView.backgroundColor = UIColor(netHex: 0x2e2e2e)
            if rideDetailMapViewModel.ride?.rideType == Ride.PASSENGER_RIDE {
                titleLabel.text = "Quick Ride - New Invite"
            } else {
                titleLabel.text = "Quick Ride - New Request"
            }
            closeButton.isHidden = false
        } else if rideDetailMapViewModel.viewType == DetailViewType.RideConfirmView {
            topInfoView.isHidden = false
            navigationViewForDetailView.isHidden = true
            ViewCustomizationUtils.addCornerRadiusToView(view: mapContainerView, cornerRadius: 20)
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            titleLabel.text = "Quick Ride - Confirmed"
            topInfoView.backgroundColor = UIColor(netHex: 0x00B557)
            closeButton.isHidden = false
        } else if rideDetailMapViewModel.viewType == DetailViewType.PaymentPendingView {
            rideTypeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            rideTypeLabel.textColor = UIColor.black
            topInfoView.isHidden = true
            navigationViewForDetailView.isHidden = false
            rideTypeLabel.text = "Quick Ride - New Request"
            backButton.isHidden = false
        }else {
            rideTypeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            rideTypeLabel.textColor = UIColor.black
            topInfoView.isHidden = true
            navigationViewForDetailView.isHidden = false
            if matchedUser.userRole == Ride.RIDER_RIDE || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
                rideTypeLabel.text = "Matching Ride Givers"
            } else {
                rideTypeLabel.text = "Matching Ride Takers"
            }
            backButton.isHidden = false
        }
    }

    private func setRideStatus() {
        if eta != nil {
            return
        }
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if matchedUser.isReadyToGo {
            if MatchedUser.RIDER == matchedUser.userRole || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
                var pickupTimeText: String?
                if let time = matchedUser.pkTime {
                    pickupTimeText =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
                } else {
                    pickupTimeText = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
                }
                rideStatusButton.setTitle("PICK-UP: \(pickupTimeText!)", for: .normal)
                rideStatusButton.setTitleColor(UIColor.systemGray, for: .normal)
                rideStatusButton.backgroundColor = UIColor.white
                rideStatusButtonWidthConstraint.constant = 100
                rideStatusButton.isHidden = false
            } else {
                rideStatusButton.isHidden = true
                rideStatusButtonWidthConstraint.constant = 0
            }
            return
        }
        rideStatusButton.isHidden = false
        if MatchedUser.RIDER == matchedUser.userRole || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
            if Ride.RIDE_STATUS_STARTED == (matchedUser as?  MatchedRider)?.rideStatus {
                rideStatusButton.setTitle("  " + Ride.RIDE_STATUS_STARTED.uppercased() + "  ", for: .normal)
                rideStatusButton.backgroundColor = UIColor.white
                rideStatusButton.setTitleColor(UIColor(netHex: 0x00B557), for: .normal)
                rideStatusButtonWidthConstraint.constant = 60
            } else if Ride.RIDE_STATUS_DELAYED == (matchedUser as? MatchedRider)?.rideStatus {
                rideStatusButton.setTitleColor(UIColor.white, for: .normal)
                rideStatusButton.backgroundColor = UIColor(netHex: 0xFCA126)
                rideStatusButtonWidthConstraint.constant = 120
                let differece = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedUser.startDate!, time2: NSDate().getTimeStamp())
                var delayedText = Ride.RIDE_STATUS_DELAYED.uppercased()
                if differece > 0 {
                    delayedText = delayedText + " BY \(differece) MIN"
                }
                rideStatusButton.setTitle("  " + delayedText + "  ", for: .normal)
            } else {
                rideStatusButtonWidthConstraint.constant = 120
                rideStatusButton.setTitleColor(UIColor.systemGray, for: .normal)
                rideStatusButton.backgroundColor = UIColor.white
                var startTime = "  START TIME " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)! + "  "
                let differece = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: matchedUser.startDate!, time2: NSDate().getTimeStamp())
                if differece > 0 && differece <= 15 {
                    startTime = " STARTS IN \(differece) MIN  "
                }
                rideStatusButton.setTitle(startTime, for: .normal)
            }
        }else{
            rideStatusButtonWidthConstraint.constant = 120
            rideStatusButton.setTitleColor(UIColor.systemGray, for: .normal)
            rideStatusButton.backgroundColor = UIColor.white
            let startTime = "  START PLAN " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)! + "  "
            rideStatusButton.setTitle(startTime, for: .normal)
        }
    }

    private func checkAndDisplayRideLastCreatedTime() {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if matchedUser.rideid == 0 {
            if matchedUser.lastRideCreatedTime == nil || DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.lastRideCreatedTime, timeFormat: DateUtils.DATE_FORMAT_EEE_YY) == nil {
                lastRideTakenButton.isHidden = true
                lastRideTakenWidthConstraint.constant = 0
                setRideStatus()
            } else {
                rideStatusButton.isHidden = true
                rideStatusButtonWidthConstraint.constant = 0
                lastRideTakenButton.isHidden = false
                lastRideTakenWidthConstraint.constant = 130
                let text = "LAST TAKEN ON \(String(describing: DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.lastRideCreatedTime, timeFormat: DateUtils.DATE_FORMAT_EEE_YY)!))"
                lastRideTakenButton.setTitle(text, for: .normal)
            }
        } else {
            setRideStatus()
            lastRideTakenButton.isHidden = true
            lastRideTakenWidthConstraint.constant = 0
        }
    }

    private func setRideDateForHeader() {
        var rideTimeText: String?
        if let rideDay = rideDetailMapViewModel.getTodayAndTomorrowRide() {
            rideTimeText = rideDay
        } else if let day = rideDetailMapViewModel.getDayOfWeekForRideDate() {
            rideTimeText = day
        }
        if let rideTime = rideDetailMapViewModel.getRideTimeInADay(), let rideDay = rideTimeText {
            rideTimeText = rideDay + " " + rideTime
        }
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        rideTimeLabel.textColor = UIColor.darkGray
        rideTimeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        rideTimeLabel.text = rideTimeText
        subTitleLabel.text = rideTimeText
    }

    private func drawRouteOnMap() {
        if viewMap == nil{
            return
        }
        viewMap.clear()
        rideDetailMapViewModel.isOverlappingRouteDrawn = false
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        checkForRidePresentLocation()
    }
    private func checkAndSetPickUpAndDropAddress(){
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if matchedUser.pickupLocationAddress == nil {
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.pickup.RouteDetailView", coordinate: CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!), handler: { (location, error) in
                if location != nil{
                    if self.viewMap == nil{
                        return
                    }
                    matchedUser.pickupLocationAddress = location!.shortAddress
                    self.setPickUpMarker(pickUp: CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!), zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
                }
            })
        }
        if matchedUser.dropLocationAddress == nil{
            LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.drop.RouteDetailView", coordinate: CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!), handler: { (location, error) in
                if location != nil{
                    if self.viewMap == nil{
                        return
                    }
                    matchedUser.dropLocationAddress = location!.shortAddress
                    self.setDropMarker(drop: CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!), zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
                }
            })
        }
    }

    private func drawCurrentUserRoute(){
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let ride = rideDetailMapViewModel.ride, viewMap != nil, !ride.routePathPolyline.isEmpty, let matchedUserRoutePathPolyline = matchedUser.routePolyline, !matchedUserRoutePathPolyline.isEmpty {
            let rideRoutePathPolyline = ride.routePathPolyline
            guard let coordinates = Polyline(encodedPolyline: rideRoutePathPolyline).coordinates, coordinates.count > 2 else {
                return
            }

            if matchedUser.userRole == MatchedUser.PASSENGER || matchedUser.userRole == MatchedUser.REGULAR_PASSENGER || ride.distance == nil {
                GoogleMapUtils.drawRoute(pathString: rideRoutePathPolyline, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_5, tappable: false)
            }else{
                let start = CLLocation(latitude: ride.startLatitude,longitude: ride.startLongitude)
                let end =  CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)

                let pickUp = CLLocation(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
                let drop = CLLocation(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
                GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride.rideId,useCase :"iOS.App."+(ride.rideType ?? "Passenger")+".WalkRoute.DetailedRouteView", riderRoutePolyline: matchedUserRoutePathPolyline, passengerRoutePolyline: rideRoutePathPolyline, passengerStart: start, passengerEnd: end, pickup: pickUp, drop: drop, passengerRideDistance: ride.distance!, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5, handler: { (cumalativeDistance) in
                })
            }
            drawOverlappingRoute()
        }
    }


    private func drawMatchedUserRoute(){
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let ride = rideDetailMapViewModel.ride, let matchedUserRoutePathPolyline = matchedUser.routePolyline, !matchedUserRoutePathPolyline.isEmpty, !ride.routePathPolyline.isEmpty, viewMap != nil {
            let rideRoutePathPolyline = ride.routePathPolyline
            if matchedUser.userRole == MatchedUser.PASSENGER || matchedUser.userRole == MatchedUser.REGULAR_PASSENGER{
                let start = CLLocation(latitude: matchedUser.fromLocationLatitude!,longitude: matchedUser.fromLocationLongitude!)
                let end =  CLLocation(latitude: matchedUser.toLocationLatitude!, longitude: matchedUser.toLocationLongitude!)

                let pickup =  CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)

                let drop =  CLLocation(latitude: matchedUser.dropLocationLatitude!,longitude: matchedUser.dropLocationLongitude!)
                GoogleMapUtils.drawPassengerRouteWithWalkingDistance(rideId: ride.rideId,useCase: "IOS.App."+ride.rideType!+".WalkRoute.DetailedRouteView", riderRoutePolyline: rideRoutePathPolyline, passengerRoutePolyline: matchedUserRoutePathPolyline, passengerStart: start, passengerEnd: end, pickup: pickup, drop: drop, passengerRideDistance: matchedUser.rideDistance, map: viewMap, colorCode: UIColor(netHex:0xFF0000), zIndex: GoogleMapUtils.Z_INDEX_5,handler: { (cumalativeDistance) in
                })

            }else{
                GoogleMapUtils.drawRoute(pathString: matchedUserRoutePathPolyline, map: viewMap, colorCode: UIColor(netHex:0x353535), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
            }
            drawOverlappingRoute()
        }
    }

    private func drawOverlappingRoute(){
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let ride = rideDetailMapViewModel.ride, !rideDetailMapViewModel.isOverlappingRouteDrawn {
            rideDetailMapViewModel.isOverlappingRouteDrawn = true
            var riderRoutePolyline : String?
            if matchedUser.userRole == MatchedUser.PASSENGER || matchedUser.userRole == MatchedUser.REGULAR_PASSENGER{
                riderRoutePolyline = ride.routePathPolyline
            }else{
                riderRoutePolyline = matchedUser.routePolyline!
            }
            let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
            let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
            let matchedRoute = LocationClientUtils.getMatchedRouteLatLng(pickupLatLng: pickUp, dropLatLng: drop, polyline: riderRoutePolyline!)
            if matchedRoute.count < 3{
                return
            }
            setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
            setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
            let polyline = Polyline(coordinates: matchedRoute)
            GoogleMapUtils.drawRoute(pathString: polyline.encodedPolyline, map: viewMap, colorCode: UIColor(netHex: 0x2F77F2), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
            perform(#selector(drawRouteAfterDelay), with: self, afterDelay: 0.5)
        }
    }

    @objc func drawRouteAfterDelay(){
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let routePolyline = matchedUser.routePolyline, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }

    func setPickUpMarker(pickUp : CLLocationCoordinate2D, zoomState: String, matchedUser: MatchedUser) {
        pickUpMarker?.map = nil
        pickUpMarker = nil
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        var pickupTime : Double
        if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER { //MARK: Ride giver
            //MARK: For Time

            if let time = matchedUser.pkTime {
                pickupTime = time
            }else {
                pickupTime = matchedUser.pickupTime ?? 0
            }
        }else {
            if let time = matchedUser.psgReachToPk {
                pickupTime = time
            }else if let time = matchedUser.passengerReachTimeTopickup {
                pickupTime = time
            }else {
                pickupTime = Double(matchedUser.startDate ?? NSDate().getTimeStamp())
            }
        }

        let pickUpTiming = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? ""

        pickDropView.initializeViews(markerTitle: Strings.pick_up_caps + " " + pickUpTiming, markerImage: UIImage(named: "green")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.18, y: 0.25))
        pickUpMarker?.zIndex = 8
        pickUpMarker?.title = Strings.pick_up_caps
    }

    func setDropMarker(drop : CLLocationCoordinate2D, zoomState: String, matchedUser: MatchedUser) {
        dropMarker?.map = nil
        dropMarker = nil
        guard var dropTime = matchedUser.dropTime else {
            return
        }
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        var dropTiming = ""
        if let startDate = matchedUser.startDate, startDate <  NSDate().getTimeStamp() {
            dropTime = Double(NSDate().getTimeStamp() + (dropTime - matchedUser.startDate!))
        }

        dropTiming = DateUtils.getTimeStringFromTimeInMillis(timeStamp: dropTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? ""
        pickDropView.initializeViews(markerTitle: Strings.drop_caps + " " + dropTiming, markerImage: UIImage(named: "drop_icon")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.25, y: 0.25))
        dropMarker?.zIndex = 8
        dropMarker?.title = Strings.drop_caps
    }

    func setVehicleImageAtLocation(newLocation: RideParticipantLocation, matchedRider: MatchedUser, lastUpdateTime: Double?){
        AppDelegate.getAppDelegate().log.debug("setVehicleImageAtLocation()")
        if matchedRider.userRole != MatchedUser.RIDER{
            return
        }
        if vehicleMarker != nil{
            vehicleMarker.map = nil
            vehicleMarker = nil
        }
        vehicleMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: newLocation.latitude!,longitude: newLocation.longitude!))
        if newLocation.bearing != nil{
            vehicleMarker.rotation = newLocation.bearing!
        }
        vehicleMarker.zIndex = 10
        if (matchedRider as! MatchedRider).vehicleType ==  Vehicle.VEHICLE_TYPE_BIKE{
            vehicleMarker.icon = UIImage(named: "bike_top")
        }else{
            vehicleMarker.icon = ImageUtils.RBResizeImage(image: UIImage(named: "new_car")!, targetSize: CGSize(width: 55,height: 55))
        }
        vehicleMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.3)
        vehicleMarker.map = viewMap
        zoomAndShowPassengerRoutePath(rideCurrentLocation: newLocation)
    }

    func zoomAndShowPassengerRoutePath(rideCurrentLocation: RideParticipantLocation) {
        if viewMap == nil{
            return
        }
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        let startLat = rideCurrentLocation.latitude
        let startLong = rideCurrentLocation.longitude
        let endLat = matchedUser.pickupLocationLatitude
        let endLong = matchedUser.pickupLocationLongitude
        if startLat == nil || startLat! <= 0 || startLong == nil || startLong! <= 0 || endLat == nil || endLat! <= 0 || endLong == nil || endLong! <= 0 {
            if let routePolyline = matchedUser.routePolyline {
                GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
            }
        }else{
            viewMap.setMinZoom(viewMap.minZoom, maxZoom: 16)
            let uiEdgeInsets = UIEdgeInsets(top: 40, left: 100, bottom: 40, right: 40)
            let routePathToNextPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat!, startLong: startLong!, endLat: endLat!, endLong: endLong!, viewMap: viewMap)
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToNextPickUP)!)
            delay(seconds: 0.5) {
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            }
        }
    }

    func delay(seconds: Double, completion:@escaping ()->()) {
        let time = DispatchTime(uptimeNanoseconds: UInt64(10.0*Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: time) {
            completion()
        }
    }

    private func setEta(routeMetrics: RouteMetrics) {
        if let etaError = routeMetrics.error, etaError.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR {
            rideStatusButton.isHidden = false
            rideStatusButtonWidthConstraint.constant = 140
            rideStatusButton.backgroundColor = UIColor.red
            rideStatusButton.setTitleColor(UIColor.white, for: .normal)
            eta = Strings.rider_crossed_pickup
            rideStatusButton.setTitle(Strings.rider_crossed_pickup, for: .normal)
            return
        }
        let timeDifferenceInSeconds = DateUtils.getDifferenceBetweenTwoDatesInSecs(time1: DateUtils.getCurrentTimeInMillis(), time2: routeMetrics.creationTime)
        if timeDifferenceInSeconds <= 30 {
            let durationInTrafficMinutes = routeMetrics.journeyDurationInTraffic
            if durationInTrafficMinutes <= 59 {
                eta = "\(durationInTrafficMinutes) min away"
            } else {
                eta = "\(durationInTrafficMinutes/60) hour away"
            }
            rideStatusButtonWidthConstraint.constant = 80
        }else{
            let timeDifference: String?
            if timeDifferenceInSeconds <= 59 {
                timeDifference = "\(timeDifferenceInSeconds) sec ago"
            } else{
                timeDifference = "\(timeDifferenceInSeconds/60) min ago"
            }
            let distanceInMeters = routeMetrics.routeDistance
            if distanceInMeters > 1000 {
                let distanceInKm = distanceInMeters / 1000
                eta = timeDifference! + ", " + StringUtils.getStringFromDouble(decimalNumber: distanceInKm) + " km away"
            } else if distanceInMeters > 900 {
                eta = timeDifference! + ", " +  "1 km away"
            } else if distanceInMeters > 1 {
                eta = timeDifference! + ", " +  StringUtils.getStringFromDouble(decimalNumber: distanceInMeters) + " m away"
            } else {
                eta = timeDifference! + ", " +  "1 m away"
            }
            rideStatusButtonWidthConstraint.constant = 130
        }
        rideStatusButton.isHidden = false
        rideStatusButton.backgroundColor = UIColor(netHex: 0x00B557)
        rideStatusButton.setTitleColor(UIColor.white, for: .normal)
        rideStatusButton.setTitle(eta!.uppercased(), for: .normal)
    }
    
    private func handleVisibilityAndContentOfPaymentInfoView(){
        if rideDetailMapViewModel.viewType == DetailViewType.PaymentPendingView {
            paymentPendingInfoView.isHidden = false
        }else {
            paymentPendingInfoView.isHidden = true
        }
    }
    
    //MARK: Actions
    @IBAction func moveToCurrentRidePath(_ sender: UIButton) {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let routePolyline = matchedUser.routePolyline, viewMap != nil {
            navigationButton.isHidden = true
            if rideDetailMapViewModel.pickupZoomState == RideDetailMapViewModel.ZOOMED_IN {
                rideDetailMapViewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_OUT
                let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
                setPickUpMarker(pickUp: pickUp, zoomState: rideDetailMapViewModel.pickupZoomState, matchedUser: matchedUser)
            }
            if rideDetailMapViewModel.dropZoomState == RideDetailMapViewModel.ZOOMED_IN {
                rideDetailMapViewModel.dropZoomState = RideDetailMapViewModel.ZOOMED_OUT
                let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
                setDropMarker(drop: drop, zoomState: rideDetailMapViewModel.dropZoomState, matchedUser: matchedUser)
            }
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }

    @IBAction func changePickupDropAction(_ sender: UIButton) {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let ride = rideDetailMapViewModel.ride {
            if rideDetailMapViewModel.startAndEndChangeRequired {
                AppDelegate.getAppDelegate().log.debug("changeStartAndEndAction()")
                let startEndLocationViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "StartAndEndSelectionViewController") as! StartAndEndSelectionViewController
                startEndLocationViewController.initializeDataBeforePresenting(ride: ride, matchedPassenger: matchedUser, delegate: self)
                self.present(startEndLocationViewController, animated: false, completion: nil)
            }else{
                AppDelegate.getAppDelegate().log.debug("changePickUpDropAction()")
                let pickUpDropViewController = UIStoryboard(name: StoryBoardIdentifiers.pickUpandDrop_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PickUpandDropViewController") as! PickUpandDropViewController
                var riderRideId,passengerRideId,passengerId,riderId : Double?
                var noOfSeats = 1
                if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER{
                    riderRideId = matchedUser.rideid
                    riderId = matchedUser.userid
                    passengerRideId = ride.rideId
                    passengerId = ride.userId
                    if ride.isKind(of: PassengerRide.classForCoder()){
                        noOfSeats = (ride as! PassengerRide).noOfSeats
                    }
                }else{
                    riderRideId = ride.rideId
                    riderId = ride.userId
                    passengerRideId = matchedUser.rideid
                    passengerId = matchedUser.userid
                    if matchedUser.isKind(of: MatchedPassenger.classForCoder()){
                        noOfSeats = (matchedUser as! MatchedPassenger).requiredSeats
                    }
                }
                var riderRoutePolyline : String?
                var riderRideType : String?
                if matchedUser.userRole == MatchedUser.RIDER{
                    riderRoutePolyline = matchedUser.routePolyline
                    riderRideType = Ride.RIDER_RIDE
                }else if matchedUser.userRole == MatchedUser.REGULAR_RIDER{
                    riderRoutePolyline = matchedUser.routePolyline
                    riderRideType = Ride.REGULAR_RIDER_RIDE
                }else if ride.rideType == Ride.RIDER_RIDE{
                    riderRoutePolyline = ride.routePathPolyline
                    riderRideType = Ride.RIDER_RIDE
                }else{
                    riderRoutePolyline = ride.routePathPolyline
                    riderRideType = Ride.REGULAR_RIDER_RIDE
                }
                if riderRoutePolyline == nil{
                    return
                }
                pickUpDropViewController.initializeDataBeforePresenting(matchedUser: matchedUser,riderRoutePolyline: riderRoutePolyline!,riderRideType :riderRideType!, delegate: self,passengerRideId :passengerRideId,riderRideId: riderRideId,passengerId: passengerId,riderId: riderId,noOfSeats: noOfSeats)
                self.navigationController?.pushViewController(pickUpDropViewController, animated: false)
            }
        }
    }

    @IBAction func navigationButtonTapped(_ sender: UIButton) {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if matchedUser.userRole == Ride.PASSENGER_RIDE || matchedUser.userRole == Ride.REGULAR_PASSENGER_RIDE {
            return
        }
        if let ride = rideDetailMapViewModel.ride {
            var startPoint: String?
            var endPoint: String?
            if rideDetailMapViewModel.pickUpOrDropNavigation == Strings.pick_up_caps {
                startPoint = String(ride.startLatitude.roundToPlaces(places: 5))+","+String(ride.startLongitude.roundToPlaces(places: 5))
                endPoint = String(matchedUser.pickupLocationLatitude!.roundToPlaces(places: 5))+","+String(matchedUser.pickupLocationLongitude!.roundToPlaces(places: 5))
            } else {
                startPoint = String(ride.endLatitude!.roundToPlaces(places: 5))+","+String(ride.endLongitude!.roundToPlaces(places: 5))
                endPoint = String(matchedUser.dropLocationLatitude!.roundToPlaces(places: 5))+","+String(matchedUser.dropLocationLongitude!.roundToPlaces(places: 5))
            }
            var urlString = "https://www.google.com/maps/dir/?api=1&origin=" + startPoint!
            urlString = urlString + "&destination=" + endPoint! + "&travelmode=" + "walking"
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.keyWindow?.makeToast("Can't use Google maps in this device.", point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                }
            }
        }
    }

    @IBAction func closeActionTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        if rideDetailMapViewModel.viewType == DetailViewType.RideConfirmView {
            moveToLiveRideView()
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK: RoutePath recieve Delegate
extension RideDetailedMapViewController: RoutePathReceiveDelagate {
    func receiveRoutePath() {
        drawCurrentUserRoute()
        drawMatchedUserRoute()
    }
}

//MARK: Route Receiver Delegate
extension RideDetailedMapViewController: RouteReceiver {
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {

    }

    func receiveRoute(rideRoute:[RideRoute], alternative: Bool) {
        if rideRoute.isEmpty && rideDetailMapViewModel.ride != nil{
            return
        }
        rideDetailMapViewModel.ride?.routePathPolyline = rideRoute[0].overviewPolyline!
        drawCurrentUserRoute()
        drawMatchedUserRoute()
    }
}

//MARK: RideParticipantLocationReceive Delegate
extension RideDetailedMapViewController: RideParticipantLocationReceiveDelagate {

    func checkForRidePresentLocation(){
        AppDelegate.getAppDelegate().log.debug("checkForRidePresentLocation()")
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
            let startDate = matchedUser.startDate
            let riderRideId = matchedUser.rideid
            let pickupLocationLatitude = matchedUser.pickupLocationLatitude
            let pickupLocationLongitude = matchedUser.pickupLocationLongitude
            if matchedUser.userid == nil || startDate == nil || riderRideId == nil || pickupLocationLatitude == nil || pickupLocationLongitude == nil {
                return
            }
            let destinationLatLng = CLLocationCoordinate2D(latitude: pickupLocationLatitude!, longitude: pickupLocationLongitude!)
            if let rideParticipantLocation = SharedPreferenceHelper.getMatchedUserRideLocation(participantId: matchedUser.userid ?? 0) {
                setVehicleImageAndEta(rideParticipantLocation: rideParticipantLocation, riderStartTime: startDate!)
                if let latitude = rideParticipantLocation.latitude, let longitude = rideParticipantLocation.longitude {
                    let originLatLng = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    getRouteMetrixForMatchedRider(userid: matchedUser.userid!, riderRideId: riderRideId!, origin: originLatLng, destination: destinationLatLng, startDate: startDate!)
                }
                if rideParticipantLocation.lastUpdateTime == nil || DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: NSDate(timeIntervalSince1970: rideParticipantLocation.lastUpdateTime!/1000)) >= 2*60 {
                    self.rideDetailMapViewModel.getRideParticipantLocation(userId: rideParticipantLocation.userId, riderRideId: riderRideId!, startDate: startDate!, destinationLatLng: destinationLatLng, viewController: self)
                }
            } else {
                rideDetailMapViewModel.getRideParticipantLocation(userId: matchedUser.userid, riderRideId: riderRideId!, startDate: startDate!, destinationLatLng: destinationLatLng, viewController: self)
            }

        }
    }

    private func getRouteMetrixForMatchedRider(userid: Double,riderRideId: Double, origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, startDate: Double) {
        let key = ETACalculator.getInstance().getKey(riderRideId: riderRideId, dest: destination)
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if let routeMetrics = SharedPreferenceHelper.getRouteMetrics(key: key) {
            setEta(routeMetrics: routeMetrics)
            if routeMetrics.creationTime == 0 || DateUtils.getTimeDifferenceInSeconds(date1: NSDate(), date2: NSDate(timeIntervalSince1970: routeMetrics.creationTime/1000)) >= 2*60 {
                ETACalculator.getInstance().getRouteMetricsForMatchedRider(riderRideId: riderRideId, matchedUser: matchedUser,rideId: rideDetailMapViewModel.ride?.rideId ?? 0, origin: origin, destination: destination,useCase: "iOS.App.Passenger.Eta.ETACalculator.RideDetail") {[weak self] (routeMetrics) in
                    if matchedUser.userid == userid {
                        self?.setEta(routeMetrics: routeMetrics)
                    }
                }
            }
        } else {
            ETACalculator.getInstance().getRouteMetricsForMatchedRider(riderRideId: riderRideId, matchedUser: matchedUser,rideId: rideDetailMapViewModel.ride?.rideId ?? 0,origin: origin, destination: destination, useCase: "iOS.App.Passenger.Eta.ETACalculator.RideDetail") {[weak self] (routeMetrics) in
                if matchedUser.userid == userid {
                    self?.setEta(routeMetrics: routeMetrics)
                }
            }
        }

    }

    func receiveRideParticipantLocation(destinationLatLng: CLLocationCoordinate2D, rideParticipantLocation: RideParticipantLocation, riderStartTime : Double) {
        SharedPreferenceHelper.storeMatchedUserLocation(userId: rideParticipantLocation.userId, rideParticipantLocation: rideParticipantLocation)
        setVehicleImageAndEta(rideParticipantLocation: rideParticipantLocation, riderStartTime: riderStartTime)
        if let latitude = rideParticipantLocation.latitude, let longitude = rideParticipantLocation.longitude, let rideId = rideParticipantLocation.rideId, let userId = rideParticipantLocation.userId {
            let originLatLng = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            getRouteMetrixForMatchedRider(userid: userId, riderRideId: rideId, origin: originLatLng, destination: destinationLatLng, startDate: riderStartTime)
        }
    }

    private func setVehicleImageAndEta(rideParticipantLocation: RideParticipantLocation, riderStartTime : Double) {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if viewMap != nil && matchedUser.userid == rideParticipantLocation.userId {
            var startTime = NSDate().getTimeStamp()
            if startTime < riderStartTime{
                startTime = riderStartTime
            }
            if let matchedUserPickup = matchedUser.pickupTime, let matchedUserDropTime = matchedUser.dropTime, let startDate = matchedUser.startDate {
                let pickUpTime = startTime+Double(matchedUserPickup - startDate)
                let diffBPickupTimes = pickUpTime - matchedUserPickup
                matchedUser.pickupTime = pickUpTime
                matchedUser.dropTime = matchedUserDropTime + diffBPickupTimes
                matchedUser.pickupTimeRecalculationRequired = false
            }
            if viewMap != nil{
                viewMap.clear()
                rideDetailMapViewModel.isOverlappingRouteDrawn = false
                drawCurrentUserRoute()
                drawMatchedUserRoute()
                setVehicleImageAtLocation(newLocation: rideParticipantLocation , matchedRider: matchedUser, lastUpdateTime: rideParticipantLocation.lastUpdateTime)
            }
        }
    }

    private func moveToLiveRideView() {
        var isFreezeRideRequired = false
        if Ride.RIDER_RIDE == rideDetailMapViewModel.ride?.rideType {
            if let riderRide = (rideDetailMapViewModel.ride) as? RiderRide, riderRide.availableSeats == 0 {
                isFreezeRideRequired = true
            }
        }
        let centerViewController = ViewControllerUtils.getCenterViewController()
        var navigationController : UINavigationController?
        if centerViewController.navigationController != nil{
            navigationController = centerViewController.navigationController
        }else{
            navigationController = (centerViewController as? ContainerTabBarViewController)?.centerNavigationController
        }

        navigationController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.indexToSelect = 1

        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: rideDetailMapViewModel.ride, isFromRideCreation: false, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
}

//MARK: PickupDrop change Delegate
extension RideDetailedMapViewController: PickUpAndDropSelectionDelegate {
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?) {
        rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] = matchedUser
        if viewMap == nil{
            return
        }
        viewMap.clear()
        rideDetailMapViewModel.isOverlappingRouteDrawn = false
        matchedUser.newFare = -1
        matchedUser.fareChange = false
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        drawOverlappingRoute()
    }
}

//MARK: MapView Delegate
extension RideDetailedMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            currentLocationButton.isHidden = false
        } else {
            currentLocationButton.isHidden = true
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
        if marker.title == Strings.pick_up_caps {
            if rideDetailMapViewModel.pickupZoomState == RideDetailMapViewModel.ZOOMED_IN {
                self.navigationButton.isHidden = true
                rideDetailMapViewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
                setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
            } else {
                if matchedUser.userRole != Ride.PASSENGER_RIDE && matchedUser.userRole != Ride.REGULAR_PASSENGER_RIDE {
                    self.navigationButton.isHidden = false
                    rideDetailMapViewModel.pickUpOrDropNavigation = Strings.pick_up_caps
                }
                rideDetailMapViewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.pick_up_caps)
                let pickUp = CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!, longitude: matchedUser.pickupLocationLongitude!)
                setPickUpMarker(pickUp: pickUp, zoomState: RideDetailMapViewModel.ZOOMED_IN, matchedUser: matchedUser)
            }
        }
        if marker.title == Strings.drop_caps {
            if rideDetailMapViewModel.dropZoomState == RideDetailMapViewModel.ZOOMED_IN {
                self.navigationButton.isHidden = true
                rideDetailMapViewModel.dropZoomState = RideDetailMapViewModel.ZOOMED_OUT
                let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
                setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_OUT, matchedUser: matchedUser)
                zoomOutToSelectedPoint()
            } else {
                if matchedUser.userRole != Ride.PASSENGER_RIDE && matchedUser.userRole != Ride.REGULAR_PASSENGER_RIDE {
                    self.navigationButton.isHidden = false
                    rideDetailMapViewModel.pickUpOrDropNavigation = Strings.drop_caps
                }
                rideDetailMapViewModel.dropZoomState = RideDetailMapViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.drop_caps)
                let drop = CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!)
                setDropMarker(drop: drop, zoomState: RideDetailMapViewModel.ZOOMED_IN, matchedUser: matchedUser)
            }
        }
        return true
    }

    private func zoomInToSelectedPoint(zoomPoint: CLLocationCoordinate2D, markerType: String) {
        if let rideObj = rideDetailMapViewModel.ride {
            let matchedUser = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex]
            if matchedUser.userRole == Ride.PASSENGER_RIDE || matchedUser.userRole == Ride.REGULAR_PASSENGER_RIDE {
                let cameraPosition = GMSCameraPosition.camera(withTarget: zoomPoint, zoom: 16.0)
                CATransaction.begin()
                CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
                self.viewMap.animate(to: cameraPosition)
                CATransaction.commit()

            } else {
                var startLat: Double?
                var startLng: Double?
                var endLat: Double?
                var endLng: Double?
                if markerType == Strings.pick_up_caps {
                    startLat = rideObj.startLatitude
                    startLng = rideObj.startLongitude
                    endLat = matchedUser.pickupLocationLatitude
                    endLng = matchedUser.pickupLocationLongitude
                } else {
                    startLat = rideObj.endLatitude
                    startLng = rideObj.endLongitude
                    endLat = matchedUser.dropLocationLatitude
                    endLng = matchedUser.dropLocationLongitude
                }
                viewMap.setMinZoom(viewMap.minZoom, maxZoom: 16)
                let uiEdgeInsets = UIEdgeInsets(top: 40, left: 100, bottom: 40, right: 40)
                let routePathToPickUP = GoogleMapUtils.getPolylineBoundsForParticularPoints(startLat: startLat!, startLong: startLng!, endLat: endLat!, endLong: endLng!, viewMap: viewMap)
                let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: routePathToPickUP)!)
                CATransaction.begin()
                CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
                CATransaction.commit()
            }
        }
    }

    private func zoomOutToSelectedPoint() {
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].routePolyline!)!)
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        CATransaction.commit()
    }
}

//MARK: MatchedUserDataChange Delegate From RideDetailVC
extension RideDetailedMapViewController: MatchedUserDataChangeDelagate {
    func selectedIndexChanged(selectedIndex: Int) {
        if selectedIndex < 0 || selectedIndex > rideDetailMapViewModel.matchedUserList.count {
            viewMap.clear()
            pageNumberButton.isHidden = true
            routeEditButton.isHidden = true
            rideStatusButton.isHidden = true
            lastRideTakenButton.isHidden = true
            navigationButton.isHidden = true
            rideDetailMapViewModel.selectedIndex = selectedIndex
            return
        }
        rideDetailMapViewModel.selectedIndex = selectedIndex
        setDataToView()
    }

    func displayAckForRideRequest(matchedUser : MatchedUser){
        var successMessage : String!
        if matchedUser.name == nil{
            successMessage = Strings.invite_sent_to_selected_user
        }
        else{
            if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
                successMessage = String(format: Strings.invite_sent_to_selected_riders, matchedUser.name!)
            }
            else{
                successMessage = String(format: Strings.invite_sent_to_selected_passengers, matchedUser.name!)
            }
        }
        rideRequestAckLabel.text = successMessage

        rideRequestAckView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            self.rideRequestAckView.isHidden = true
        })
        showRideActionButtonsView()
    }

    func pickupDropChangedForJoinMyRide(matchedUser: MatchedUser) {
        pickUpAndDropChanged(matchedUser: matchedUser, userPreferredPickupDrop: nil)
    }
}

//MARK: StartAndEndSelection Delegate
extension RideDetailedMapViewController: StartAndEndSelectionDelegate {
    func startAndEndChanged(matchedUser: MatchedUser, ride: Ride) {
        AppDelegate.getAppDelegate().log.debug("startAndEndChanged() \(matchedUser) and \(ride)")
        rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] = matchedUser
        rideDetailMapViewModel.ride = ride
        if viewMap == nil{
            return
        }
        viewMap.clear()
        rideDetailMapViewModel.isOverlappingRouteDrawn = false
        matchedUser.newFare = -1
        matchedUser.fareChange = false
        drawCurrentUserRoute()
        drawMatchedUserRoute()
        drawOverlappingRoute()
    }

}
extension RideDetailedMapViewController: FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let rideDetailFloatingPanelLayout = RideDetailFloatingPanelLayout()
        rideDetailFloatingPanelLayout.initialiseData(rideDetailMapViewModel: rideDetailMapViewModel)
        return rideDetailFloatingPanelLayout
    }

    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .full {
                            self.floatingPanelController.surfaceView.cornerRadius = 0.0
                            self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
                            self.floatingPanelController.backdropView.isHidden = true
                            self.floatingPanelController.surfaceView.shadowHidden = true
                        }else{
                            if #available(iOS 11, *) {
                                self.floatingPanelController.surfaceView.cornerRadius = 20.0
                            } else {
                                self.floatingPanelController.surfaceView.cornerRadius = 0.0
                            }
                            self.floatingPanelController.surfaceView.grabberHandle.isHidden = false
                            self.floatingPanelController.backdropView.isHidden = false
                            self.floatingPanelController.surfaceView.shadowHidden = false
                        }
                        if self.rideDetailMapViewModel.selectedIndex >= 0 && self.rideDetailMapViewModel.selectedIndex <= self.rideDetailMapViewModel.matchedUserList.count - 1 {
                            if targetPosition == .full {
                                self.pageNumberButton.isHidden = true
                                self.rideStatusButton.isHidden = true
                                self.lastRideTakenButton.isHidden = true
                                self.routeEditButton.isHidden = true
                                self.currentLocationButton.isHidden = true
                                self.navigationButton.isHidden = true
                            } else {
                                self.pageNumberButton.isHidden = false
                                if let ride = self.rideDetailMapViewModel.ride, ride.userId != 0, let currentUserId = Double(QRSessionManager.getInstance()?.getUserId() ?? "0"), currentUserId != 0, ride.userId != currentUserId {
                                    self.routeEditButton.isHidden = true
                                } else {
                                    self.routeEditButton.isHidden = false
                                }
                                self.checkAndDisplayRideLastCreatedTime()
                            }
                        }
                        self.mapComponentBottomConstarint.constant = (vc.layout.insetFor(position: targetPosition) ?? 0) + 5
                        self.rideDetailedViewController.floatingLabelPositionChanged(position: targetPosition)

        }, completion: nil)
    }

}

class RideDetailFloatingPanelLayout: FloatingPanelLayout {
    var rideDetailMapViewModel = RideDetailMapViewModel()
    func initialiseData(rideDetailMapViewModel: RideDetailMapViewModel){
        self.rideDetailMapViewModel = rideDetailMapViewModel
    }
    public var initialPosition: FloatingPanelPosition {
        return .half
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 55.0 // A top inset from safe area
        case .half: // A bottom inset from the safe area
            if rideDetailMapViewModel.viewType == DetailViewType.PaymentPendingView {
                return 210
            }
            return 270
        case .tip: // A bottom inset from the safe area
            if rideDetailMapViewModel.viewType == DetailViewType.PaymentPendingView {
                return 209
            }
            return 269
        default: return nil // Or `case .hidden: return nil`
        }
    }
}
extension RideDetailedMapViewController { // To add Bottom Ride Action Buttons
    func showRideActionButtonsView(){
        guard let matchedUserRideActionView = MatchedUserRideActionView else { return }
        matchedUserRideActionView.initialiseUIWithData(ride: rideDetailMapViewModel.ride, matchedUser: rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex], viewController: self, viewType: rideDetailMapViewModel.viewType!, selectedIndex: rideDetailMapViewModel.selectedIndex, rideInviteActionCompletionListener: rideDetailedViewController, userSelectionDelegate: rideDetailedViewController, selectedUserDelegate: rideDetailMapViewModel.selectedUserDelegate)
        if !rideDetailMapViewModel.isRideActionViewAdded && rideDetailMapViewModel.viewType != .PaymentPendingView {
            matchedUserRideActionView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
            self.view.addSubview(matchedUserRideActionView)
            self.view!.layoutIfNeeded()
            rideDetailMapViewModel.isRideActionViewAdded = true
        }
    }
}
extension RideDetailedMapViewController: RideInvitationUpdateListener {
    func rideInvitationStatusUpdated(){
        guard let rideInviteId = rideDetailMapViewModel.inviteId else { return  }
        if let _ = RideInviteCache.getInstance().getActiveInvite(inviteId: rideInviteId){
            return
        }
        self.navigationController?.popViewController(animated: false)

    }
}
