//
//  CommutePassTableViewCell.swift
//  Quickride
//
//  Created by Admin on 19/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CommutePassTableViewCell : UITableViewCell{
    
    @IBOutlet weak var passImageview: UIImageView!
    
    @IBOutlet weak var activatedView: UIView!
    
    @IBOutlet weak var totalRidesLbl: UILabel!
    
    @IBOutlet weak var validityLbl: UILabel!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var discountPercentageLbl: UILabel!
    
    @IBOutlet weak var saveLbl: UILabel!
    
    @IBOutlet weak var amountView: UILabel!
    
    @IBOutlet weak var rupeeSymbol: UIImageView!
    
    @IBOutlet weak var carImageView: UIImageView!

    @IBOutlet weak var daysAndRidesLeftLbl: UILabel!
    
    @IBOutlet weak var dataView: UIView!
    
    
    func initializeViews(pass : RidePass,index : Int){
        
        
        if pass.status != nil && pass.status! == RidePass.PASS_STATUS_ACTIVE{
            self.activatedView.isHidden = false
            ViewCustomizationUtils.addCornerRadiusToView(view: self.activatedView, cornerRadius: 5.0)
            self.daysAndRidesLeftLbl.isHidden = false
            self.daysAndRidesLeftLbl.text = String(format: Strings.days_and_rides_left, arguments: [String(pass.duration),String(pass.availableRides)])
            self.validityLbl.isHidden = true
        }else{
            self.activatedView.isHidden = true
            self.daysAndRidesLeftLbl.isHidden = true
            self.validityLbl.isHidden = false
            self.validityLbl.text = String(format: Strings.valid_for_days, arguments: [String(pass.duration)])
        }
        
        let string = (String(pass.passPrice)+"/"+String(pass.actualPrice)) as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex: 0x0D17BB), textSize: 14), range: string.range(of: String(pass.passPrice)))
        
        attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: String(pass.actualPrice)))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: UIColor(netHex: 0x0D17BB).withAlphaComponent(0.7), textSize: 14), range: string.range(of: String(pass.actualPrice)))
        self.amountView.attributedText = attributedString
        self.totalRidesLbl.text = String(pass.totalRides) + " " + Strings.rides
        
        self.discountPercentageLbl.text = String(pass.discountPercent) + Strings.percentage_symbol
        self.saveLbl.text = Strings.save
        
        self.dataView.addDashedBorder(view: self.separatorView, color: UIColor.white)
        
        if index % 2 == 0 {
            self.amountView.textColor = UIColor(netHex: 0x0d17bb)
            self.discountPercentageLbl.textColor = UIColor(netHex: 0x0d17bb)
            self.saveLbl.textColor = UIColor(netHex: 0x0d17bb)
            self.passImageview.image = UIImage(named: "pass_image_for_five_rides")
            ImageUtils.setTintedIcon(origImage: UIImage(named:"rupee-indian")!, imageView: self.rupeeSymbol,color : UIColor(netHex: 0x0d17bb))
        }else{
            self.amountView.textColor = UIColor(netHex: 0xffd457)
            self.discountPercentageLbl.textColor = UIColor(netHex: 0xffd457)
            self.saveLbl.textColor = UIColor(netHex: 0xffd457)
            self.passImageview.image = UIImage(named: "blue_back_pass")
            ImageUtils.setTintedIcon(origImage: UIImage(named:"rupee-indian")!, imageView: self.rupeeSymbol,color : UIColor(netHex: 0xffd457))
        }
    }
    

}
