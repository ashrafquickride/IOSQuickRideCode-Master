//
//  EditTaxiTripTableViewCell.swift
//  Quickride
//
//  Created by HK on 31/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class EditTaxiTripTableViewCell: UITableViewCell {

    @IBOutlet weak var returnView: UIView!
    @IBOutlet weak var resheduleView: UIView!
    @IBOutlet weak var cancelRideView: UIView!

    private var actionComplitionHandler: actionComplitionHandler?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()
    var viewController : UIViewController?

    func initialiseEditView(taxiLiveRideViewModel: TaxiPoolLiveRideViewModel,viewController: UIViewController, actionComplitionHandler: @escaping actionComplitionHandler){
        self.actionComplitionHandler = actionComplitionHandler
        self.taxiLiveRideViewModel = taxiLiveRideViewModel
        self.viewController = viewController
        if (taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION && taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.journeyType == TaxiRidePassenger.ROUND_TRIP ) ||
            taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL{
            returnView.isHidden = true
        }else{
            returnView.isHidden = false
        }
        if taxiLiveRideViewModel.isTaxiStarted(){
            cancelRideView.isHidden = true
        }else{
           cancelRideView.isHidden = false
        }
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return  }

        if taxiRidePassenger.status == TaxiRidePassenger.STATUS_REQUESTED || taxiRidePassenger.status == TaxiRidePassenger.STATUS_CONFIRMED
        {
            resheduleView.isHidden = false
        }else{
            resheduleView.isHidden = true
        }
    }

    @IBAction func scheduleReturnTapped(_ sender: Any){
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
        taxiPoolVC.initialiseTaxiRidePassengerRide(taxiRidePassenger: taxiRidePassenger)
        self.parentViewController?.navigationController?.pushViewController(taxiPoolVC, animated: false)
    }

    @IBAction func rescheduleTapped(_ sender: Any) {

        actionComplitionHandler?(true)
        

    }



    @IBAction func cancelRideTapped(_ sender: Any) {
        if let taxiRidePassenger = self.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger{
            let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CancelTaxiPoolViewController") as! CancelTaxiPoolViewController
            rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(taxiRide: taxiRidePassenger, completionHandler: { [weak self] (cancelReason) in
                if let taxiRideId = self?.taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id,let cancelReason = cancelReason {
                    self?.taxiLiveRideViewModel.cancelTaxiRide(taxiId: taxiRideId, cancellationReason: cancelReason, complition: { (result) in
                        if result {
                            self?.parentViewController?.navigationController?.popViewController(animated: false)
                        }
                    })
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
        }
    }
}
