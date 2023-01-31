//
//  RecurringRideMatchingOptionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 26/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class RecurringRideMatchingOptionTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var favoriteIconShowingImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStarImage: UIImageView!
    @IBOutlet weak var routeMatchOrPointsLabel: UILabel!
    @IBOutlet weak var pickUpTimeLabel: UILabel!
    @IBOutlet weak var rideScheduleDaysLabel: UILabel!
    @IBOutlet weak var requestOrRemoveButton: UIButton!
    @IBOutlet weak var vehicleTypeImageView: UIImageView!
    @IBOutlet weak var firstSeatImageView: UIImageView!
    @IBOutlet weak var secondSeatImageView: UIImageView!
    @IBOutlet weak var thirdSeatImageView: UIImageView!
    @IBOutlet weak var fouthSeatImageView: UIImageView!
    @IBOutlet weak var fifthSeatImageView: UIImageView!
    @IBOutlet weak var sixthSeatImageView: UIImageView!
    @IBOutlet weak var routeMatchOrPointsShowingLabel: UILabel!
    @IBOutlet weak var poolTypeView: UIView!
    @IBOutlet weak var mapIcon: UIImageView!
    
    //MARK:Ride Taker PickUpDataShowingView
    @IBOutlet weak var rideTakerPickUpDataView: UIView!
    @IBOutlet weak var walkPathViewForPickUp: UIView!
    @IBOutlet weak var walkPathAfterTravelView: UIView!
    @IBOutlet weak var rideDistanceShowingView: UIView!
    @IBOutlet weak var walkPathdistanceShowingLabel: UILabel!
    @IBOutlet weak var afterRideWalkingDistanceShowingLabel: UILabel!
    @IBOutlet weak var carOrImageForWalkPathImageView: UIImageView!
    //MARK: Ride Giver PickUpDataShowingView
    @IBOutlet weak var seatShowingStackView: UIStackView!
    @IBOutlet weak var seatShowingStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var pointsOrPercentageRideMatchShowingLabel: UILabel!
    @IBOutlet weak var poolShowingLabel: UILabel!
    
    //MARK: Variables
    private var matchedRegularUser: MatchedRegularUser?
    private var ride: Ride?
    private var viewController: UIViewController?
    private var isConnectedRide = false
    private var numberOfSeatsImageArray = [UIImageView]()
    
    func initializeMatchedUser(matchedRegularUser: MatchedRegularUser,ride: Ride?,viewController: UIViewController,isConnectedRide: Bool){
        self.matchedRegularUser = matchedRegularUser
        self.ride = ride
        self.viewController = viewController
        self.isConnectedRide = isConnectedRide
        userNameLabel.text = matchedRegularUser.name
        ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: matchedRegularUser.imageURI ?? "", gender: matchedRegularUser.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedRegularUser.profileVerificationData, companyName: matchedRegularUser.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        verificationImage.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedRegularUser.profileVerificationData)
        favoriteIconShowingImageView.isHidden = isFavouritePartner()
        if matchedRegularUser.rating ?? 0 > 0.0{
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingStarImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(matchedRegularUser.rating!) + "(\(String(matchedRegularUser.noOfReviews)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            ratingStarImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 2.0
            ratingLabel.layer.masksToBounds = true
        }
        if isConnectedRide{
            requestOrRemoveButton.setTitle(Strings.unjoin.uppercased(), for: .normal)
        }else{
            requestOrRemoveButton.setTitle(Strings.request.uppercased(), for: .normal)
        }
        getmatchedUserRideDays()
        if isConnectedRide{
            poolTypeView.isHidden = true
            pointsOrPercentageRideMatchShowingLabel.isHidden = true
            routeMatchOrPointsShowingLabel.isHidden = true
            pickUpTimeLabel.isHidden = true
            routeMatchOrPointsLabel.isHidden = true
            routeMatchOrPointsShowingLabel.isHidden = true
            mapIcon.isHidden = true
            return
        }else{
            poolTypeView.isHidden = false
            pointsOrPercentageRideMatchShowingLabel.isHidden = false
            routeMatchOrPointsShowingLabel.isHidden = false
            pickUpTimeLabel.isHidden = false
            routeMatchOrPointsLabel.isHidden = false
            routeMatchOrPointsShowingLabel.isHidden = false
            mapIcon.isHidden = false
        }
        if matchedRegularUser.userRole == Ride.REGULAR_RIDER_RIDE{
            if let pickupTime = matchedRegularUser.pkTime {
                pickUpTimeLabel.text = String(format: Strings.pickup_time, arguments: [(DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")])
            }else {
                pickUpTimeLabel.text = String(format: Strings.pickup_time, arguments: [(DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedRegularUser.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")])
            }
            routeMatchOrPointsLabel.textColor = UIColor(netHex: 0x00B557)
            routeMatchOrPointsLabel.text = "\(matchedRegularUser.matchPercentage ?? 0)" + Strings.percentage_symbol
            routeMatchOrPointsShowingLabel.text = Strings.route_match
            vehicleTypeImageView.isHidden = false
            poolTypeView.isHidden = false
            pointsOrPercentageRideMatchShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: ceil(matchedRegularUser.points ?? 0)) + " \(Strings.points_new)"
            if (matchedRegularUser as! MatchedRegularRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                vehicleTypeImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                vehicleTypeImageView.tintColor = .lightGray
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                carOrImageForWalkPathImageView.tintColor = .lightGray
                seatShowingStackView.isHidden = true
                seatShowingStackViewWidth.constant = 0
                poolShowingLabel.isHidden = false
                poolShowingLabel.text = "BIKE POOL"
            } else {
                vehicleTypeImageView.image = UIImage(named: "car_solid")
                carOrImageForWalkPathImageView.image = UIImage(named: "car_solid")
                let matchedUserAsRider = matchedRegularUser as! MatchedRegularRider
                let capacity = matchedUserAsRider.capacity
                seatShowingStackView.isHidden = false
                seatShowingStackViewWidth.constant = CGFloat(capacity*17)
                poolShowingLabel.isHidden = false
                poolShowingLabel.text = "CAR POOL"
                //                setOccupiedSeats(availableSeats: (matchedUserAsRider.availableSeats ?? 1), capacity: capacity)
            }
            let startLocation = CLLocation(latitude: ride?.startLatitude ?? 0,longitude: ride?.startLongitude ?? 0)
            let pickUpLoaction = CLLocation(latitude: matchedRegularUser.pickupLocationLatitude!,longitude: matchedRegularUser.pickupLocationLongitude!)
            let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: ride?.routePathPolyline ?? "")
            walkPathdistanceShowingLabel.text = getDistanceString(distance: startToPickupWalkDistance)
            
            let endLocation =  CLLocation(latitude: ride?.endLatitude ?? 0, longitude: ride?.endLongitude ?? 0)
            let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: matchedRegularUser.dropLocationLatitude ?? 0, longitude: matchedRegularUser.dropLocationLongitude ?? 0), point2: endLocation , polyline: ride?.routePathPolyline ?? "")
            afterRideWalkingDistanceShowingLabel.text = getDistanceString(distance: dropToEndWalkDistance)
        }else{
            
            if let time = matchedRegularUser.psgReachToPk {
                let pickupTime =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
                pickUpTimeLabel.text = String(format: Strings.pickup_time, arguments: [(pickupTime ?? "")])
            } else if let time = matchedRegularUser.passengerReachTimeTopickup {
                let pickupTime =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
                pickUpTimeLabel.text = String(format: Strings.pickup_time, arguments: [(pickupTime ?? "")])
            }else {
                let pickupTime =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedRegularUser.startDate, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
                pickUpTimeLabel.text = String(format: Strings.pickup_time, arguments: [(pickupTime ?? "")])
            }
            
            pointsOrPercentageRideMatchShowingLabel.text = String.init(format: Strings.percentage_ride_taker_match, "\(matchedRegularUser.matchPercentage ?? 0)\(Strings.percentage_symbol)")
            routeMatchOrPointsShowingLabel.text = Strings.points_new
            seatShowingStackView.isHidden = true
            seatShowingStackViewWidth.constant = 0
            poolTypeView.isHidden = true
            routeMatchOrPointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedRegularUser.points)
            routeMatchOrPointsLabel.textColor = UIColor.black
            if matchedRegularUser.userRole == MatchedUser.RIDER && (matchedRegularUser as! MatchedRegularRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                vehicleTypeImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                vehicleTypeImageView.tintColor = .lightGray
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                vehicleTypeImageView.tintColor = .lightGray
            } else {
                vehicleTypeImageView.image = UIImage(named: "car_solid")
                carOrImageForWalkPathImageView.image = UIImage(named: "car_solid")
            }
            
            let startLocation = CLLocation(latitude: ride?.startLatitude ?? 0,longitude: ride?.startLongitude ?? 0)
            let pickUpLoaction = CLLocation(latitude: matchedRegularUser.pickupLocationLatitude!,longitude: matchedRegularUser.pickupLocationLongitude!)
            let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: ride?.routePathPolyline ?? "")
            walkPathdistanceShowingLabel.text = getDistanceString(distance: startToPickupWalkDistance)
            
            let endLocation =  CLLocation(latitude: ride?.endLatitude ?? 0, longitude: ride?.endLongitude ?? 0)
            let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: matchedRegularUser.dropLocationLatitude ?? 0, longitude: matchedRegularUser.dropLocationLongitude ?? 0), point2: endLocation , polyline: ride?.routePathPolyline ?? "")
            afterRideWalkingDistanceShowingLabel.text = getDistanceString(distance: dropToEndWalkDistance)
            
        }
        numberOfSeatsImageArray = [firstSeatImageView,secondSeatImageView,thirdSeatImageView,fouthSeatImageView,fifthSeatImageView,sixthSeatImageView]
    }
    
    private func getDistanceString( distance: Double) -> String {
        if distance > 1000{
            var convertDistance = (distance/1000)
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
    private func isFavouritePartner() -> Bool{
        let isFavoritePartner = UserDataCache.getInstance()?.isFavouritePartner(userId: matchedRegularUser?.userid ?? 0)
        if isFavoritePartner == nil || !isFavoritePartner!{
            return true
        }else{
            return false
        }
    }
    private func getmatchedUserRideDays(){
        var daysString = ""
        let rideStartTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedRegularUser?.startDate, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
        if matchedRegularUser?.monday != nil{
            if matchedRegularUser?.monday == rideStartTime || rideStartTime == nil{
                daysString = Strings.mon_short
            }else{
                daysString = Strings.mon_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.monday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.tuesday != nil{
            if matchedRegularUser?.tuesday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.tue_short
            }else{
                daysString += ", "+Strings.tue_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.tuesday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.wednesday != nil{
            if matchedRegularUser?.wednesday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.wed_short
            }else{
                daysString += ", "+Strings.wed_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.wednesday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.thursday != nil{
            if matchedRegularUser?.thursday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.thu_short
            }else{
                daysString += ", "+Strings.thu_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.thursday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.friday != nil{
            if matchedRegularUser?.friday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.fri_short
            }else{
                daysString += ", "+Strings.fri_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.friday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.saturday != nil{
            if matchedRegularUser?.saturday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.sat_short
            }else{
                daysString += ", "+Strings.sat_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.saturday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        if matchedRegularUser?.sunday != nil{
            if matchedRegularUser?.sunday == rideStartTime || rideStartTime == nil{
                daysString += ", "+Strings.sun_short
            }else{
                daysString += ", "+Strings.sun_short + ": " + (DateUtils.getTimeStringFromTime(time: matchedRegularUser?.monday, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) ?? "")
            }
        }
        rideScheduleDaysLabel.text = Strings.ride_scheduled + " - " + daysString
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seats_not_occupied")
        }
    }
    
    @IBAction func requestOrRemoveButtonTapped(_ sender: UIButton) {
        if isConnectedRide{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.ride_cancel_title, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if result == Strings.yes_caps{
                    var regularPassngerRideId : Double? = 0
                    if self.ride?.rideType == Ride.REGULAR_PASSENGER_RIDE{
                        regularPassngerRideId = self.ride?.rideId
                    }else{
                        regularPassngerRideId = self.matchedRegularUser?.rideid
                    }
                    QuickRideProgressSpinner.startSpinner()
                    RideServicesClient.unJoinParticipantFromRegularRide(regularPassengerRideId: regularPassngerRideId!, rideType: self.ride?.rideType ?? "", viewController: self.viewController!, completionHandler: { (responseObject, error) -> Void in
                        QuickRideProgressSpinner.stopSpinner()
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                            NotificationCenter.default.post(name: .unjoiningSucess, object: nil)
                        }else{
                            ErrorProcessUtils.handleError(responseObject: responseObject,error :error, viewController :self.viewController, handler: nil)
                        }
                    })
                }
            })
        }else{
            if matchedRegularUser?.userRole == MatchedUser.REGULAR_RIDER{
                let inviteRegularRider = InviteRegularRider(passengerRideId: ride?.rideId ?? 0, passengerId: ride?.userId ?? 0, matchedRegularUser: matchedRegularUser!, viewcontroller: viewController!)
                inviteRegularRider.sendInviteToRegularRider()
            }else{
                let inviteRegularPassenger = InviteRegularPassenger(matchedRegularUser: matchedRegularUser!, riderRideId: ride?.rideId ?? 0, riderId: ride?.userId ?? 0, viewController: viewController!)
                inviteRegularPassenger.sendRegularRideInvitationToPassenger()
            }
        }
    }
}
