//
//  DaysTableViewCell.swift
//  QuickRideSchedule
//
//  Created by Tilakkumar Gondi on 13/02/16.
//  Copyright © 2016 Tilakkumar Gondi. All rights reserved.
//

import UIKit

class DaysTableViewCell: UITableViewCell {
    

    @IBOutlet weak var indicatorImage: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func initailizeDayCell(day: String, daytime: String?,dayIsDisable: Bool){
        dayLabel.text = day
        timeLabel.text = daytime
        indicatorImage.image = UIImage(named: "check")
        if dayIsDisable{
            timeLabel.textColor = UIColor(netHex: 0xA9A9A9)
            dayLabel.textColor = UIColor(netHex: 0xA9A9A9)
            indicatorImage.image = UIImage(named: "uncheck")
        }else{
            timeLabel.textColor = UIColor(netHex: 0x363636)
            dayLabel.textColor = UIColor(netHex: 0x363636)
        }
    }

}
