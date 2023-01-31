//
//  BookExclusiveTaxiTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BookExclusiveTaxiTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingSwitch: UISwitch!
    
    private var viewModel = TaxiPoolLiveRideViewModel()
    func showUserBookTaxiPreference(viewModel: TaxiPoolLiveRideViewModel){
        self.viewModel = viewModel
        settingSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.allocateTaxiIfPoolNotConfirmed == true{
            settingSwitch.setOn(true, animated: true)
        }else{
            settingSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if sender.isOn{
            guard let taxiRidePassenger = viewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return  }
            QuickRideProgressSpinner.startSpinner()
            
            TaxiUtils.getAvailableVehicleClass(startTime: taxiRidePassenger.startTimeMs!, startAddress: taxiRidePassenger.startAddress, startLatitude: taxiRidePassenger.startLat!, startLongitude: taxiRidePassenger.startLng!, endLatitude: taxiRidePassenger.endLat!, endLongitude: taxiRidePassenger.endLng!, endAddress: taxiRidePassenger.endAddress, journeyType: taxiRidePassenger.journeyType!, routeId: taxiRidePassenger.routeId) { [weak self] result, responseError, error in
                QuickRideProgressSpinner.stopSpinner()
                
                if let fareForVehicleClass = self?.getExclusiveVehicle(detailedEstimateFares: result){
                    self?.showDifference(fareForVehicleClass: fareForVehicleClass)
                }else{
                    self?.settingSwitch.setOn(false, animated: true)
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
                }
            }
            
        }else{
            QuickRideProgressSpinner.startSpinner()
            viewModel.updateSharingToExclusive(allocateTaxiIfPoolNotConfirmed: false, fixedFareId: nil) { [weak self] isSaved in
                if !isSaved{
                    self?.settingSwitch.setOn(false, animated: true)
                }
                self?.viewModel.getTaxiRideFromServer(handler: { responseError, error in
                    QuickRideProgressSpinner.stopSpinner()
                    NotificationCenter.default.post(name: .taxiRideStatusReceived, object: nil)
                })
            }
        }
    }
    
    private func getExclusiveVehicle(detailedEstimateFares: DetailedEstimateFare?) -> FareForVehicleClass?{
        var fareForVehicleData: FareForVehicleClass?
        for detailedEstimateFare in detailedEstimateFares?.fareForTaxis ?? []{
            for fareForVehicleClass in detailedEstimateFare.fares{
                if fareForVehicleClass.vehicleClass == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK || fareForVehicleClass.vehicleClass == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN{
                    fareForVehicleData = fareForVehicleClass
                    break
                }
            }
        }
        return fareForVehicleData
    }
    
    private func showDifference(fareForVehicleClass: FareForVehicleClass){
        let showTaxiFareDifferenceViewController  = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTaxiFareDifferenceViewController") as! ShowTaxiFareDifferenceViewController
        showTaxiFareDifferenceViewController.showDiffrence(sharingAmount: viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.initialFare ?? 0, exclusiveAmount: fareForVehicleClass.maxTotalFare ?? 0) { [weak self] (result) in
            if result{
                QuickRideProgressSpinner.startSpinner()
                self?.viewModel.updateSharingToExclusive(allocateTaxiIfPoolNotConfirmed: true, fixedFareId: fareForVehicleClass.fixedFareId,complitionHandler: { isSaved in
                    if !isSaved{
                        self?.settingSwitch.setOn(false, animated: true)
                    }
                    self?.viewModel.getTaxiRideFromServer(handler: { responseError, error in
                        QuickRideProgressSpinner.stopSpinner()
                        NotificationCenter.default.post(name: .taxiRideStatusReceived, object: nil)
                    })
                })
            }else{
                self?.settingSwitch.setOn(false, animated: true)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTaxiFareDifferenceViewController)
    }
}
