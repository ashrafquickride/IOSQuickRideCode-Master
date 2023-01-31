//
//  RideContributionViewController.swift
//  Quickride
//
//  Created by iDisha on 25/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideContributionViewController: ModelViewController{
    
    @IBOutlet weak var labelNoOfVehiclesRemoved: UILabel!
    
    @IBOutlet weak var labelCo2Reduced: UILabel!
    
    @IBOutlet weak var labelFuelSaved: UILabel!
    
    @IBOutlet var co2Image: UIImageView!
    
    @IBOutlet var vehicleImage: UIImageView!
    
    @IBOutlet var fuelImage: UIImageView!
    
    @IBOutlet weak var appreciationDialog: UIView!
    
    @IBOutlet weak var seperatorView1: UIView!
    
    @IBOutlet weak var seperatorView2: UIView!
    
    @IBOutlet weak var backGroundView: UIView!
    
    var rideContribution: RideContribution?
    var vehiclesRemoved: String?
    var rideType: String?
    
    func initializeDataBeforePresenting(rideContribution : RideContribution, vehiclesRemoved: String, rideType: String?){
        self.rideContribution = rideContribution
        self.vehiclesRemoved = vehiclesRemoved
        self.rideType = rideType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seperatorView1.addDashedView(color: Colors.dottedLineGreenColor.cgColor)
        seperatorView2.addDashedView(color: Colors.dottedLineGreenColor.cgColor)
        labelNoOfVehiclesRemoved.text = String(format: Strings.vehiclesRemoved, arguments: [self.vehiclesRemoved!])
        labelCo2Reduced.text = String(format: Strings.co2Reduced, arguments: [String(rideContribution!.co2Reduced!.roundToPlaces(places: 1))])
        labelFuelSaved.text = String(format: Strings.fuelSaved, arguments: [String(rideContribution!.petrolSaved!.roundToPlaces(places: 1))])
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if userProfile?.gender == User.USER_GENDER_FEMALE{
            self.co2Image.image = UIImage(named: "icon_leaf_female")
        }
        else{
            self.co2Image.image = UIImage(named: "icon_leaf_male")
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideContributionViewController.backGroundViewTapped(_:))))
    }
    
    @objc func backGroundViewTapped(_ gesture: UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
