//
//  TaxipoolLocationSelectionViewController.swift
//  Quickride
//
//  Created by HK on 23/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias taxipoolLocationSelectionComplitionHandler = (_ matchedTaxiRideGroup: MatchedTaxiRideGroup) -> Void
class TaxipoolLocationSelectionViewController: UIViewController {
    
    @IBOutlet weak var fromLocationButton: UIButton!
    @IBOutlet weak var toLocationButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var taxiRideDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    private var viewModel = TaxipoolLocationSelectionViewModel()
    
    func showLocation(matchedTaxiRideGroup: MatchedTaxiRideGroup,handler: @escaping taxipoolLocationSelectionComplitionHandler){
        viewModel = TaxipoolLocationSelectionViewModel(matchedTaxiRideGroup: matchedTaxiRideGroup,handler: handler)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        showDetails()
    }
    
    @IBAction func fromLocationTapped(_ sender: Any){
        moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: viewModel.fromLocation, alreadySelectedLocation: viewModel.toLocation)
    }
    
    @IBAction func ToLocationTapped(_ sender: Any){
        moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: viewModel.toLocation,alreadySelectedLocation: viewModel.fromLocation)
        
    }
    
    private func showDetails(){
        fromLocationButton.setTitle(viewModel.fromLocation?.shortAddress, for: .normal)
        toLocationButton.setTitle(viewModel.toLocation?.shortAddress, for: .normal)
        taxiRideDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(viewModel.matchedTaxiRideGroup?.pickupTimeMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa)
        var taxiFare: Double?
        if (viewModel.matchedTaxiRideGroup?.joinedPassengers.count ?? 0) > 1{
            taxiFare = viewModel.matchedTaxiRideGroup?.minPoints
        }else{
            taxiFare = viewModel.matchedTaxiRideGroup?.maxPoints
        }
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiFare)])
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any){
        viewModel.handler?(viewModel.matchedTaxiRideGroup!)
        closeView()
    }
    
    private func getUpdatedMatchedTaxiGroup(){
        QuickRideProgressSpinner.startSpinner()
        viewModel.getMatchedTaxiGroupForSelectedLocation { [weak self] matchedTaxiRideGroup, responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if let taxiRideGroup = matchedTaxiRideGroup{
                self?.viewModel.matchedTaxiRideGroup = taxiRideGroup
                self?.showDetails()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    private func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}

//TaxipoolLocationSelectionViewController
extension TaxipoolLocationSelectionViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            viewModel.fromLocation = location
            if let taxiHomePageViewController = self.parent?.parent as? TaxiHomePageViewController{
                taxiHomePageViewController.rideStartLocationChanged(location: location)
            }
        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            viewModel.toLocation = location
        }
        getUpdatedMatchedTaxiGroup()
    }
    
    func locationSelectionCancelled(requestLocationType: String) {}
}
