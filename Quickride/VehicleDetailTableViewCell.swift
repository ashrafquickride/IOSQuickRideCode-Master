//
//  VehicleDetailTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 01/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class VehicleDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vehicleView: UIView!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var vehicleImageView: UIImageView!
    @IBOutlet weak var vehicleModelAndCategoryLabel: UILabel!
    
    private var matchedUser: MatchedUser?
    
    func initializeData(matchedUser: MatchedUser) {
        self.matchedUser = matchedUser
        var vehicleType: String?
        if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER {
            if (matchedUser as? MatchedRider)?.vehicleType == Vehicle.VEHICLE_TYPE_BIKE || (matchedUser as? MatchedRegularRider)?.vehicleType == Vehicle.VEHICLE_TYPE_BIKE {
                vehicleImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                vehicleImageView.tintColor = .lightGray
            } else {
                vehicleImageView.image = UIImage(named: "car_solid")
                vehicleType = Vehicle.VEHICLE_TYPE_CAR
            }
            setVehicleDetails(matchedUser: matchedUser, vehicleType: vehicleType)
            vehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(vehicleViewTapped(_:))))
        }
    }
    
    private func setVehicleDetails(matchedUser: MatchedUser, vehicleType: String?) {
        var vehicleNumber: String?
        var vehicleModel: String?
        var vehicleMakeAndCategory: String?
        var vehicleType: String?
        if matchedUser.userRole == MatchedUser.RIDER, let matchedRider = (matchedUser as? MatchedRider) {
            if matchedRider.vehicleType == Vehicle.VEHICLE_TYPE_CAR {
                vehicleType = Vehicle.VEHICLE_TYPE_CAR
            }
            ImageCache.getInstance().setVehicleImage(imageView: vehicleImageView, imageUrl: matchedRider.vehicleImageURI, model: matchedRider.model, imageSize: ImageCache.DIMENTION_SMALL)
            
            vehicleNumber = matchedRider.vehicleNumber
            vehicleModel = matchedRider.model
            vehicleMakeAndCategory = matchedRider.vehicleMakeAndCategory
            if matchedRider.vehicleImageURI == nil {
                vehicleImageView.contentMode = .scaleAspectFit
            } else {
                vehicleImageView.contentMode = .scaleAspectFill
            }
        } else if matchedUser.userRole == MatchedUser.REGULAR_RIDER, let matchedRegularRider = (matchedUser as? MatchedRegularRider) {
            if matchedRegularRider.vehicleType == Vehicle.VEHICLE_TYPE_CAR {
                vehicleType = Vehicle.VEHICLE_TYPE_CAR
            }
            ImageCache.getInstance().setVehicleImage(imageView: vehicleImageView, imageUrl: matchedRegularRider.vehicleImageURI, model: matchedRegularRider.model, imageSize: ImageCache.DIMENTION_SMALL)
            vehicleNumber = matchedRegularRider.vehicleNumber
            vehicleModel = matchedRegularRider.model
            vehicleMakeAndCategory = matchedRegularRider.vehicleMakeAndCategory
            if matchedRegularRider.vehicleImageURI == nil {
                vehicleImageView.contentMode = .scaleAspectFit
            } else {
                vehicleImageView.contentMode = .scaleAspectFill
            }
        }
        vehicleImageView.layer.cornerRadius = 5
        vehicleImageView.layer.masksToBounds = true
        if let vehicleNumber = vehicleNumber {
            vehicleNumberLabel.isHidden = false
            vehicleNumberLabel.text = vehicleNumber.uppercased()
            var vehicleDetails = vehicleType
            if vehicleModel != nil && !vehicleModel!.isEmpty {
                vehicleDetails = vehicleModel! + " " + (vehicleType ?? "")
            }
            if vehicleMakeAndCategory != nil && !vehicleMakeAndCategory!.isEmpty {
                vehicleDetails = (vehicleDetails ?? "") + " | " + vehicleMakeAndCategory!.capitalized
            }
            vehicleModelAndCategoryLabel.text = vehicleDetails
        } else {
            vehicleNumberLabel.isHidden = true
        }
    }
    
    @objc func vehicleViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let vehicle = self.getRiderVehicle() else {
            return
        }
        let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
        vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: vehicle)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: vehicleDisplayViewController, animated: false)
    }
    
    private func getRiderVehicle() -> Vehicle? {
        guard let matchedRider = matchedUser as? MatchedRider else {
             return nil
         }
        let vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model ?? "",vehicleType: matchedRider.vehicleType, registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity!, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
        vehicle.imageURI = matchedRider.vehicleImageURI
        return vehicle
    }
}
