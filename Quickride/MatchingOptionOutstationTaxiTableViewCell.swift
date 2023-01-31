//
//  MatchingOptionOutstationTaxiTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class MatchingOptionOutstationTaxiTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var toView: UIView!
    
    private var ride: Ride?
    func initialiseOutstationCard(ride: Ride,detailedEstimatedFare : DetailedEstimateFare, isFromSendInvite: Bool){
        self.ride = ride
        getFromCity(latLng: CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude))
        getToCity(latLng: CLLocationCoordinate2D(latitude: ride.endLatitude ?? 0, longitude: ride.endLongitude ?? 0))
        let fare = getTaxiPoints(detailedEstimatedFare: detailedEstimatedFare)
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: fare)])
        if isFromSendInvite {
            contentview.backgroundColor = UIColor(netHex: 0xF6F6F6)
        }
        setGradientBackground(view: fromView)
        setGradientBackground(view: toView)
    }
    
    private func getFromCity(latLng: CLLocationCoordinate2D){
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.OutstationTaxi", coordinate: latLng) { (location,error) -> Void in
            if let loc = location,let city = loc.city,!city.isEmpty{
                self.fromLabel.text = city
            }else{
                self.fromLabel.text = ""
            }
        }
    }
    private func getToCity(latLng: CLLocationCoordinate2D){
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.currentlocation.OutstationTaxi", coordinate: latLng) { (location,error) -> Void in
            if let loc = location,let city = loc.city,!city.isEmpty{
                self.toLabel.text = city
            }else{
                self.toLabel.text = ""
            }
        }
    }
    
    private func getTaxiPoints( detailedEstimatedFare : DetailedEstimateFare) -> Double{
        var minFare = 0.0
        let fareForTaxis = detailedEstimatedFare.fareForTaxis
        for estimatedFare in fareForTaxis {
            let fares = estimatedFare.fares
            for fareForVehicle in fares {
                if TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE == fareForVehicle.shareType {
                    if fareForVehicle.vehicleClass == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK || fareForVehicle.vehicleClass  == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN{
                        if minFare == 0 || minFare > fareForVehicle.minTotalFare!{
                            minFare = fareForVehicle.minTotalFare!
                        }
                    }
                }
            }
        }
        return minFare;
    }
    
    @IBAction func bookNowTapped(_ sender: Any) {
        guard let scheduleRide = ride as? PassengerRide else { return }
        let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
        taxiPoolVC.initialiseData(passengerRide: scheduleRide)
        self.parentViewController?.navigationController?.pushViewController(taxiPoolVC, animated: false)
    }
    func setGradientBackground(view: UIView) {
        let colorTop =  UIColor(netHex: 0xE4E4E4).cgColor
        let colorBottom = UIColor(netHex: 0xD1D1D1).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint =  .init(x: 0, y: 0.5)
        gradientLayer.endPoint   = .init(x: 1, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = 3
        view.layer.insertSublayer(gradientLayer, at:0)
    }
}
