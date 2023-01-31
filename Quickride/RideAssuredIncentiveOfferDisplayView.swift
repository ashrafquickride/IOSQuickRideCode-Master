//
//  RideAssuredIncentiveOfferDisplayView.swift
//  Quickride
//
//  Created by Admin on 14/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideAssuredIncentiveOfferDisplayView : ModelViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var rideAssuredIncentiveView: UIImageView!
    
    @IBOutlet weak var assuredAmountLbl: UILabel!
    
    @IBOutlet weak var knowMoreView: UIView!
    
    @IBOutlet weak var noOfDaysLabel: UILabel!
    
    
    var rideAssuredIncentive : RideAssuredIncentive?
    
    func initializeDataBeforePresenting(rideAssuredIncentive : RideAssuredIncentive?){
       self.rideAssuredIncentive = rideAssuredIncentive
    }
    
    override func viewDidLoad() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideAssuredIncentiveOfferDisplayView.backGroundViewTapped(_:))))
        rideAssuredIncentiveView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideAssuredIncentiveOfferDisplayView.rideAssuredIncentiveViewTapped(_:))))
        self.assuredAmountLbl.text = String(format: Strings.ride_assured_incentive_amount, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: self.rideAssuredIncentive?.amountAssured)])
        knowMoreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideAssuredIncentiveOfferDisplayView.rideAssuredIncentiveViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: knowMoreView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: rideAssuredIncentiveView, cornerRadius: 8.0)
        noOfDaysLabel.text = "/"+String(DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: rideAssuredIncentive!.validTo/1000), date2: NSDate(timeIntervalSince1970: rideAssuredIncentive!.validFrom/1000)))+" "+Strings.days
    }
    
    @objc func rideAssuredIncentiveViewTapped(_ gesture : UITapGestureRecognizer){
        
        let rideAssuredIncentiveDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAssuredIncentiveDetailViewController") as! RideAssuredIncentiveDetailViewController
        rideAssuredIncentiveDetailViewController.initializeDataBeforePresenting(rideAssuredIncentive: self.rideAssuredIncentive, handler: { _ in 
            
        })
        self.navigationController?.pushViewController(rideAssuredIncentiveDetailViewController, animated: false)
        removeView()
    }
    
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.removeView()
    }
    
    func removeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
