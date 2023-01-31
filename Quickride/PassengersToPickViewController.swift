//
//  PassengerPickupDialogue.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
protocol PassengerPickupDelegate {
    func passengerPickedUp(riderRideId : Double)
}
class PassengersToPickupViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet var passengerTableView: UITableView!
    @IBOutlet var pickupButton: UIButton!
    @IBOutlet var passengerTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var alertView: UIView!
    @IBOutlet var backGroundView: UIView!
    
    //MARK: Properties
    private var passengerPickupDelegate: PassengerPickupDelegate?
    private var passengersToPickupViewModel = PassengersPickupViewModel()
    
    //MARK: Initializer
    func initializeDataBeforePresenting(riderRideId: Double, ride: Ride?, passengerToBePickup : [RideParticipant], passengerPickupDelegate: PassengerPickupDelegate?){
        passengersToPickupViewModel.initializeData(passengerToBePickup: passengerToBePickup, ride: ride, riderRideId: riderRideId)
        self.passengerPickupDelegate = passengerPickupDelegate
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Methods
    private func setupUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                   animations: { [weak self] in
                    guard let self = `self` else {return}
                    self.alertView.center.y -= self.alertView.bounds.height
        }, completion: nil)
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10.0)
        backGroundView.isUserInteractionEnabled = true
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PassengersToPickupViewController.backGroundViewTapped(_:))))
        passengerTableView.estimatedRowHeight = 60
        passengerTableView.rowHeight = UITableView.automaticDimension
        passengerTableViewHeightConstraint.constant = CGFloat(passengersToPickupViewModel.passengerToBePickup.count * 60)
        for index in 0...passengersToPickupViewModel.passengerToBePickup.count-1 {
            if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: passengersToPickupViewModel.passengerToBePickup[index], ride: passengersToPickupViewModel.ride, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
                passengersToPickupViewModel.pickedUpPassengers[index] = false
            } else {
                passengersToPickupViewModel.pickedUpPassengers[index] = true
            }
        }
        passengerTableView.reloadData()
    }
    
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.alertView.center.y += self.alertView.bounds.height
            self.alertView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func completeRideAndUnjoinUnselectedRideParticipantsIfAny(){
        var unselectedPassengers = [RideParticipant]()
        for index in 0...passengersToPickupViewModel.passengerToBePickup.count-1{
            if passengersToPickupViewModel.pickedUpPassengers[index] == false{
                unselectedPassengers.append(passengersToPickupViewModel.passengerToBePickup[index])
            }
            
        }
        if unselectedPassengers.isEmpty{
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.passengerPickupDelegate?.passengerPickedUp(riderRideId: passengersToPickupViewModel.riderRideId!)
        }
        else{
            var unjoinResponseError: ResponseError?
            var unjoinError: NSError?
            let queue = DispatchQueue.main
            let group = DispatchGroup()
            QuickRideProgressSpinner.startSpinner()
            for passenger in unselectedPassengers{
                group.enter()
                queue.async(group:group){
                    RideCancelActionProxy.unjoinParticipant(riderRideId: self.passengersToPickupViewModel.riderRideId!, passengerRIdeId: passenger.rideId, passengerUserId: passenger.userId, rideType: Ride.PASSENGER_RIDE , cancelReason : "", isWaveOff: false,viewController: self,completionHandler: { (responseError,error) in
                        QuickRideProgressSpinner.stopSpinner()
                        unjoinResponseError = responseError
                        unjoinError = error
                        group.leave()
                    })
                }
            }
            group.notify(queue: queue){
                if unjoinResponseError == nil && unjoinError == nil{
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                    self.passengerPickupDelegate?.passengerPickedUp(riderRideId: self.passengersToPickupViewModel.riderRideId!)
                }
            }
        }
    }
    func onFailure(responseObject: NSDictionary?, error: NSError?){
        QuickRideProgressSpinner.stopSpinner()
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    func rideActionFailed(status : String, error : ResponseError?){
        if error != nil{
            MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: self, handler: nil)
        }
    }
    
    //MARK: Actions
    @IBAction func pickUpButtonClicked(_ sender: UIButton) {
        self.completeRideAndUnjoinUnselectedRideParticipantsIfAny()
    }
}
extension PassengersToPickupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengersToPickupViewModel.passengerToBePickup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengersToPickupTableViewCell", for: indexPath as IndexPath) as! PassengersToPickupTableViewCell
        if passengersToPickupViewModel.passengerToBePickup.endIndex <= indexPath.row{
            return cell
        }
        let rideParticipant = passengersToPickupViewModel.passengerToBePickup[indexPath.row]
        cell.initializeViews(passengerToPickup: rideParticipant, ride: passengersToPickupViewModel.ride, otpVerified: passengersToPickupViewModel.isOTPVerified[rideParticipant.userId], viewController: self)
        cell.callButton.tag = indexPath.row
        cell.chatButton.tag = indexPath.row
        if passengersToPickupViewModel.isOTPVerified[rideParticipant.userId] ?? false {
            passengersToPickupViewModel.pickedUpPassengers[indexPath.row] = true
        }
        setPickUpButtonBasedOnSelection(isSelected: passengersToPickupViewModel.pickedUpPassengers[indexPath.row], rideParticipant: rideParticipant, cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = passengerTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! PassengersToPickupTableViewCell
        let rideParticipant = passengersToPickupViewModel.passengerToBePickup[indexPath.row]
        if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: passengersToPickupViewModel.ride, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) && (passengersToPickupViewModel.isOTPVerified[rideParticipant.userId] == nil || !passengersToPickupViewModel.isOTPVerified[rideParticipant.userId]!) {
            moveToOTPView(rideParticipant: rideParticipant)
            return
        }
        if passengersToPickupViewModel.pickedUpPassengers[indexPath.row] == nil {
            passengersToPickupViewModel.pickedUpPassengers[indexPath.row] = true
        } else if passengersToPickupViewModel.pickedUpPassengers[indexPath.row] == false {
            passengersToPickupViewModel.pickedUpPassengers[indexPath.row] = true
        } else {
            passengersToPickupViewModel.pickedUpPassengers[indexPath.row] = false
        }
        setPickUpButtonBasedOnSelection(isSelected: passengersToPickupViewModel.pickedUpPassengers[indexPath.row], rideParticipant: rideParticipant, cell: cell)
        passengerTableView.reloadData()
    }
    
    private func setPickUpButtonBasedOnSelection(isSelected : Bool?, rideParticipant: RideParticipant, cell: PassengersToPickupTableViewCell) {
        if isSelected != nil && isSelected! {
            if passengersToPickupViewModel.isOTPVerified[rideParticipant.userId] ?? false {
                cell.checkBoxButton.setImage(UIImage(named: "icon_green_tick"), for: .normal)
            } else {
               cell.checkBoxButton.setImage(UIImage(named: "box_with_tick_icon"), for: .normal)
            }
        } else {
            cell.checkBoxButton.setImage(UIImage(named: "box_without_tick_icon"), for: .normal)
        }
        handlePickupButton()
    }
    
    private func handlePickupButton() {
        var isOtpVerified = false
        for (index,rideParticipant) in passengersToPickupViewModel.passengerToBePickup.enumerated() {
            if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: passengersToPickupViewModel.ride, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) && (passengersToPickupViewModel.pickedUpPassengers[index] == nil || passengersToPickupViewModel.pickedUpPassengers[index]!) {
                let otpVerified = passengersToPickupViewModel.isOTPVerified[rideParticipant.userId]
                if otpVerified == nil || !otpVerified! {
                    break
                } else {
                    isOtpVerified = true
                }
            } else {
                isOtpVerified = true
            }
        }
        if isOtpVerified {
            pickupButton.isUserInteractionEnabled = true
            CustomExtensionUtility.changeBtnColor(sender: pickupButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        } else {
            pickupButton.isUserInteractionEnabled = false
            CustomExtensionUtility.changeBtnColor(sender: pickupButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        }
    }
    
    private func moveToOTPView(rideParticipant: RideParticipant) {
        let otpToPickupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPToPickupViewController") as! OTPToPickupViewController
        otpToPickupViewController.initializeData(rideParticipant: rideParticipant, riderRideId: passengersToPickupViewModel.riderRideId!, isFromMultiPickup: true, passengerPickupDelegate: self)
        ViewControllerUtils.addSubView(viewControllerToDisplay: otpToPickupViewController)
    }
}
extension PassengersToPickupViewController: PassengerPickupWithOtpDelegate {
    func passengerPickedUpWithOtp(riderRideId : Double, userId: Double) {
        passengersToPickupViewModel.isOTPVerified[userId] = true
        passengerTableView.reloadData()
    }
    func passengerNotPickedUp(userId: Double) {
        passengersToPickupViewModel.isOTPVerified[userId] = false
        passengerTableView.reloadData()
    }
}
