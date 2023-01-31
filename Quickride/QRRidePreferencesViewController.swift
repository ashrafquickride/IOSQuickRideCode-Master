//
//  QRRidePreferencesViewController.swift
//  Quickride
//
//  Created by KNM Rao on 19/06/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QRRidePreferencesViewController: MyRidePreferencesViewController {
  
  @IBOutlet var allowFareChangeSwitch: UISwitch!
  
  @IBOutlet weak var minFareView: UIView!
    
  @IBOutlet weak var minFareLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    allowFareChangeSwitch.setOn(ridePreferences!.allowFareChange, animated: false)
     minFareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(QRRidePreferencesViewController.selectMinFare(_:))))
    minFareLabel.text = String(ridePreferences!.minFare)
    
  }
  override func checkIfRidePreferencesChanged() {
    super.checkIfRidePreferencesChanged()
    if ridePreferences!.allowFareChange != allowFareChangeSwitch.isOn{
      isRidePreferencesChanged = true;
    }
    if Int(minFareLabel.text!)! != ridePreferences!.minFare
    {
        isRidePreferencesChanged = true
    }
    
  }
  override func updateRidePreferencesWithNewData() {
    super.updateRidePreferencesWithNewData()
    ridePreferences!.allowFareChange = allowFareChangeSwitch.isOn
    ridePreferences!.minFare = Int(minFareLabel.text!)!
  }
  override func resetAllowFareChange(){
    allowFareChangeSwitch.isOn = true
  }
    override func resetMinfare(minFare: Int) {
        minFareLabel.text = String(minFare)
    }
    
    
    @objc func selectMinFare(_ sender : UITapGestureRecognizer)
    {
        showSliderView(title: Strings.mimimumFare, firstValue: 0, lastValue: 40, minValue: 0, currentValue: ridePreferences!.minFare) { (value) in
            self.minFareLabel.text = String(value)
        }
    }
    
    @IBAction func minimumFareInfo(_ sender: Any) {
        MessageDisplay.displayAlert(messageString: Strings.minimum_fare_info, viewController: self, handler: nil)
    }
    
    @IBAction func allowFareChangeSwitchTapped(_ sender: Any) {
        if !allowFareChangeSwitch.isOn{
            UIApplication.shared.keyWindow?.makeToast( Strings.fare_negotiation_disabling_alert, duration: 5.0)
        }
    }
}
