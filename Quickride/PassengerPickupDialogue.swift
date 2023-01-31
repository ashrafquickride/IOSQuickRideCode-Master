//
//  PassengerPickupDialogue.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import UIKit
protocol PassengerPickupDelegate {
  func passengerPickedUp(riderRideId : Double)
}
class PassengerPickupDialogue: ModelViewController,UITableViewDataSource,UITableViewDelegate{
  
  @IBOutlet var passengerTableView: UITableView!
  
  @IBOutlet var doneButton: UIButton!
  
  @IBOutlet var alertView: UIView!
  
  @IBOutlet var backGroundView: UIView!
  
  
  var passengerToBePickup  = [RideParticipant]()
  var pickedUpPassengers : [Int : Bool] = [Int : Bool]()
  var riderRideId : Double?
  var passengerPickupDelegate : PassengerPickupDelegate?
  func initializeDataBeforePresenting(riderRideId : Double,passengerToBePickup : [RideParticipant],passengerPickupDelegate : PassengerPickupDelegate?){
    self.riderRideId = riderRideId
    self.passengerToBePickup = passengerToBePickup
    self.passengerPickupDelegate = passengerPickupDelegate
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    handleBrandingChanges()
    ViewCustomizationUtils.addCornerRadiusToView(view: doneButton, cornerRadius: 5.0)
    ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10.0)
    backGroundView.isUserInteractionEnabled = true
    backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PassengerPickupDialogue.backGroundViewTapped(_:))))
    passengerTableView.delegate = self
    passengerTableView.dataSource = self
    for index in 0...passengerToBePickup.count-1{
         pickedUpPassengers[index] = true
    }
    passengerTableView.reloadData()
  }
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
    
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func handleBrandingChanges(){
    doneButton.backgroundColor = Colors.mainButtonColor
  }
  
  
  @IBAction func pickUpButtonClicked(_ sender: UIButton) {
    //Todo mig
    let cell = passengerTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! ConversationContactCell

    if pickedUpPassengers[sender.tag] == nil{
      pickedUpPassengers[sender.tag] = true
    }else if pickedUpPassengers[sender.tag] == false{
      pickedUpPassengers[sender.tag] = true
    }else{
      pickedUpPassengers[sender.tag] = false
    }
    setPickUpButtonBasedOnSelection(isSelected: pickedUpPassengers[sender.tag],button: cell.callButton)
    
  }
  @IBAction func positiveButtonClicked(_ sender: AnyObject) {
      self.completeRideAndUnjoinUnselectedRideParticipantsIfAny()
  }
    
    func completeRideAndUnjoinUnselectedRideParticipantsIfAny(){
        var unselectedPassengers = [RideParticipant]()
        for index in 0...passengerToBePickup.count-1{
            if pickedUpPassengers[index] == false{
                unselectedPassengers.append(passengerToBePickup[index])
            }
            
        }
        if unselectedPassengers.isEmpty{
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.passengerPickupDelegate?.passengerPickedUp(riderRideId: self.riderRideId!)
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
                    RideCancelActionProxy.unjoinParticipant(riderRideId: self.riderRideId!, passengerRIdeId: passenger.rideId, passengerUserId: passenger.userId, rideType: Ride.PASSENGER_RIDE , cancelReason : "",viewController: self,completionHandler: { (responseError,error) in
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
                    self.passengerPickupDelegate?.passengerPickedUp(riderRideId: self.riderRideId!)
                }
            }
        }
    }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ConversationContactCell
    if passengerToBePickup.endIndex <= indexPath.row{
        return cell
    }
    let rideParticipant = passengerToBePickup[indexPath.row]
    ImageCache.getInstance().setImageToView(imageView: cell.contactImage, imageUrl: rideParticipant.imageURI, gender: rideParticipant.gender!,imageSize: ImageCache.DIMENTION_TINY)
    
    cell.contactName.text = rideParticipant.name!
    
    setPickUpButtonBasedOnSelection(isSelected: pickedUpPassengers[indexPath.row],button: cell.callButton)
    
    cell.callButton.tag = indexPath.row
    return cell
  }
  func setPickUpButtonBasedOnSelection(isSelected : Bool?,button : UIButton){
    if isSelected != nil && isSelected == true
    {
        button.setImage(UIImage(named: "group_tick_icon"), for: .normal)
    }
    else
    {
        button.setImage(UIImage(named: "tick_icon"), for: .normal)
    }
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return passengerToBePickup.count
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
}
