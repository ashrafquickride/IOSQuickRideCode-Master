//
//  SuspendedRecurringRideTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 15/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SuspendedRecurringRideTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rideTimingLabel: UIButton!
    @IBOutlet weak var rideSwitch: UISwitch!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    func initialiseRecurringRide(regularRide: RegularRide){
        fromLabel.text = regularRide.startAddress
        toLabel.text = regularRide.endAddress
        showDate(startTime: regularRide.startTime)
    }
    
    private func showDate(startTime: Double){
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        rideTimingLabel.setTitle(date, for: .normal)
        if let time = DateUtils.getTimeStringFromTimeInMillis(timeStamp: startTime, timeFormat: DateUtils.TIME_FORMAT_HH), Int(time) ?? 0 < Int("12") ?? 0{
            rideTimingLabel.setTitle((date ?? "") + " Morning", for: .normal)
        }else{
            rideTimingLabel.setTitle((date ?? "") + " Evening", for: .normal)
        }
    }
    
    @IBAction func changeTimeTapped(_ sender: UIButton) {
        var userInfo = [String:Int]()
        userInfo["index"] = rideSwitch.tag
        NotificationCenter.default.post(name: .changeRideTime, object: nil, userInfo: userInfo)
    }
    
    @IBAction func rideStatusChanged(_ sender: UISwitch) {
        var userInfo = [String:Any]()
        userInfo["index"] = sender.tag
        userInfo["switchStatus"] = sender.isOn
        NotificationCenter.default.post(name: .rideStatusChanged, object: nil, userInfo: userInfo)
    }
}
