//
//  FreeRideInfoDialogue.swift
//  Quickride
//
//  Created by Vinutha on 9/25/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class FreeRideInfoDialogue : UIViewController {
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var alertDialogView: UIView!
    
    @IBOutlet weak var freeRideTitleLabel: UILabel!
    
    @IBOutlet weak var messageLabel2: UILabel!
    
    @IBOutlet weak var messageLabel3: UILabel!
    
    @IBOutlet weak var messageLabel4: UILabel!
    
    @IBOutlet weak var offerIcon: UIImageView!
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogView, cornerRadius: 10.0)
        offerIcon.image = offerIcon.image!.withRenderingMode(.alwaysTemplate)
        offerIcon.tintColor = UIColor(netHex:0xd81b60)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeRideInfoDialogue.dismissViewTapped(_:))))
        
        let freeRideCoupon = RideManagementUtils.checkWhetherFreeRideCouponIsPresent()
        freeRideTitleLabel.text = String(format: Strings.offer_or_take_first_ride, arguments: [StringUtils.getPointsInDecimal(points: freeRideCoupon!.maxFreeRidePoints)])
        messageLabel2.text = String(format: Strings.offer_ride_and_take_bonus_point, arguments: [StringUtils.getPointsInDecimal(points: freeRideCoupon!.maxFreeRidePoints)])
        messageLabel3.text = String(format: Strings.take_first_ride, arguments: [StringUtils.getPointsInDecimal(points: freeRideCoupon!.maxFreeRidePoints)])
        let expiryDate = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: (freeRideCoupon!.expiryTime!)/1000), dateFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)!
        messageLabel4.text = String(format: Strings.free_ride_offer_validity, arguments: [String(expiryDate)])
    }
    
    @objc func dismissViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
