//
//  AddPaymentConfirmationViewController.swift
//  Quickride
//
//  Created by Rajesab on 09/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddPaymentConfirmationViewController: UIViewController {
    
    @IBOutlet weak var extraAmountLabel: UILabel!
    @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var dropAddressLabel: UILabel!
    @IBOutlet weak var bottomButtonView: UIView!
    @IBOutlet weak var chargeReasonLabel: UILabel!
    @IBOutlet weak var extarChargeReasonLabel: UILabel!
    @IBOutlet weak var extraChargeLabel: UILabel!
    
    private var addPaymentConfirmationViewModel = AddPaymentConfirmationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPaymentConfirmationViewModel.getActiveTaxiRides()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func initializeDataBeforePresenting(driverAddedPaymentNotification: DriverAddedPaymentNotification) {
        addPaymentConfirmationViewModel = AddPaymentConfirmationViewModel(driverAddedPaymentNotification: driverAddedPaymentNotification)
    }
    
    private func setupUI(){
        bottomButtonView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        chargeReasonLabel.text = addPaymentConfirmationViewModel.driverAddedPaymentNotification?.taxiTripExtraFareDetails?.fareType
        extarChargeReasonLabel.text = addPaymentConfirmationViewModel.driverAddedPaymentNotification?.taxiTripExtraFareDetails?.location
        extraChargeLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: addPaymentConfirmationViewModel.driverAddedPaymentNotification?.taxiTripExtraFareDetails?.amount)])
        extraAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: addPaymentConfirmationViewModel.driverAddedPaymentNotification?.taxiTripExtraFareDetails?.amount)])
        pickupAddressLabel.text = addPaymentConfirmationViewModel.requiredTaxiTrip?.startAddress
        dropAddressLabel.text = addPaymentConfirmationViewModel.requiredTaxiTrip?.endAddress
    }
    @IBAction func confirmButtonTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        addPaymentConfirmationViewModel.updateAddedChargesStatus(status: TaxiUserAdditionalPaymentDetails.STATUS_ACCEPTED, complitionHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.moveToLiveRide()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    @IBAction func disputeButtonTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        addPaymentConfirmationViewModel.updateAddedChargesStatus(status: TaxiUserAdditionalPaymentDetails.STATUS_REJECTED, complitionHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.moveToLiveRide()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    private func moveToLiveRide(){
        NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil)
        self.navigationController?.popViewController(animated: false)
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: Double(addPaymentConfirmationViewModel.driverAddedPaymentNotification?.taxiRidePassengerId ?? "") ?? 0.0)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
    }
    
    @IBAction func callSupportButtonTapped(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        AppUtilConnect.callSupportNumber(phoneNumber: clientConfiguration.quickRideSupportNumberForCarpool, targetViewController: self )
    }
}
