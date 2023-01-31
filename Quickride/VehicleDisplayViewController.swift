//
//  VehicleDisplayViewController.swift
//  Quickride
//
//  Created by KNM Rao on 28/12/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class VehicleDisplayViewController: UIViewController {
  
  @IBOutlet var vehicleImageView: UIImageView!
  
  @IBOutlet var vehicleTypeLabel: UILabel!
  
  @IBOutlet var vehicleTypeWidth: NSLayoutConstraint!
  
  @IBOutlet var vehicleDetailsViewHeight: NSLayoutConstraint!
  
  @IBOutlet var vehicleModelLabel: UILabel!
  
  @IBOutlet var vehicleModelWidth: NSLayoutConstraint!
  
  @IBOutlet var vehicleCapacityLabel: UILabel!
  
  @IBOutlet var vehicleFareLabel: UILabel!
  
  @IBOutlet var vehicleFareWidth: NSLayoutConstraint!
  
 
  
  @IBOutlet var vehicleCapacityWidth: NSLayoutConstraint!
  
  @IBOutlet var makeAndCategoryLabel: UILabel!
  
  @IBOutlet var makeAndCategoryWidth: NSLayoutConstraint!
  
  @IBOutlet var additionalFacilitiesLabel: UILabel!
  
  @IBOutlet var additionalFacilitiesWidth: NSLayoutConstraint!
  
  @IBOutlet var vehicleRegNumber: UILabel!
  
  var userVehicle : Vehicle?
  
  func initializeDataBeforePresentingView(vehicle : Vehicle) {
    AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView() \(vehicle)")
    self.userVehicle = vehicle
    
  }
  
  override func viewDidLoad() {
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    super.viewDidLoad()
    self.populateVehicleInfo(vehicleObject: self.userVehicle!)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }
  
  func populateVehicleInfo(vehicleObject : Vehicle){
    ImageCache.getInstance().setVehicleImage(imageView: self.vehicleImageView, imageUrl: vehicleObject.imageURI, model: vehicleObject.vehicleModel, imageSize: ImageCache.DIMENTION_SMALL)
      self.vehicleRegNumber.text = vehicleObject.registrationNumber
      let width = (self.view.frame.width-40)/3
      self.vehicleTypeLabel.text = vehicleObject.vehicleType
      self.vehicleTypeWidth.constant = width
      self.vehicleModelLabel.text = vehicleObject.vehicleModel
      self.vehicleModelWidth.constant = width
      self.vehicleFareLabel.isHidden = false
      self.vehicleFareLabel.text = String((vehicleObject.fare).roundToPlaces(places: 2))+" "+"Pts/km"
      self.vehicleFareWidth.constant = width
      self.vehicleCapacityLabel.isHidden = false
      self.vehicleCapacityLabel.text = String(vehicleObject.capacity)+" "+Strings.offering_seats
      self.vehicleCapacityWidth.constant = width
      if vehicleObject.makeAndCategory != nil && vehicleObject.makeAndCategory!.isEmpty == false{
        self.makeAndCategoryLabel.text = vehicleObject.makeAndCategory!
        self.makeAndCategoryWidth.constant = width
        self.makeAndCategoryLabel.isHidden = false
      }else{
        self.makeAndCategoryLabel.isHidden = true
      }
    vehicleDetailsViewHeight.constant = self.view.frame.height*0.3
    if vehicleObject.additionalFacilities != nil && vehicleObject.additionalFacilities!.isEmpty == false{
      self.additionalFacilitiesLabel.text = vehicleObject.additionalFacilities!
      self.additionalFacilitiesWidth.constant = width
      self.additionalFacilitiesLabel.isHidden = false
    }else{
      self.additionalFacilitiesLabel.isHidden = true
    }
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
  }
}
