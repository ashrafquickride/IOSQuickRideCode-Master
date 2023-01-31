//
//  DiscountFareDetailsViewController.swift
//  Quickride
//
//  Created by KNM Rao on 21/09/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class DiscountFareDetailsViewController: ModelViewController {
    
    @IBOutlet var titleView: UIView!
    
    @IBOutlet var columnsView: UIView!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet weak var firstDiscountPer: UILabel!
    
    @IBOutlet weak var secondDiscountPer: UILabel!
    
    @IBOutlet weak var thirdDiscountPer: UILabel!
    
    @IBOutlet weak var fourthDiscountPer: UILabel!
    
    @IBOutlet weak var fifthDiscountPer: UILabel!
    
    @IBOutlet weak var sixthDiscountPer: UILabel!
    
    @IBOutlet weak var seventhDiscountPer: UILabel!
    
    @IBOutlet weak var eighthDiscountPer: UILabel!
    
    @IBOutlet weak var firstFare: UILabel!
    
    @IBOutlet weak var secondFare: UILabel!
    
    @IBOutlet weak var thirdFare: UILabel!
    
    @IBOutlet weak var fourthFare: UILabel!
    
    @IBOutlet weak var fifthFare: UILabel!
    
    @IBOutlet weak var sixthFare: UILabel!
    
    @IBOutlet weak var seventhFare: UILabel!
    
    @IBOutlet weak var eigthFare: UILabel!
    
    @IBOutlet weak var firstExFare: UILabel!
    
    @IBOutlet weak var secondExFare: UILabel!
    
    @IBOutlet weak var thirdExFare: UILabel!
    
    @IBOutlet weak var fourthExFare: UILabel!
    
    @IBOutlet weak var fifthExFare: UILabel!
    
    @IBOutlet weak var sixthExFare: UILabel!
    
    @IBOutlet weak var seventhExFare: UILabel!
    
    @IBOutlet weak var eigthExFare: UILabel!
    
    @IBOutlet weak var discountFareDetailsText: UILabel!
    
    var clientConfiguration : ClientConfigurtion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        initializeView()
        fareCalculation()
        exFareCalculation()
        handleBrandingChanges()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DiscountFareDetailsViewController.backGroundViewTapped(_:))))
    }
    func handleBrandingChanges(){
        discountFareDetailsText.text = String(format: Strings.discount_policy_text , arguments: [StringUtils.getPointsInDecimal(points: clientConfiguration!.carDefaultFare)])
        titleView.backgroundColor = Colors.discountDetailsTitleViewColor
        columnsView.backgroundColor = Colors.discountDetailsColumnViewColor
    }
    
    func initializeView(){
        firstDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowTenKm) + Strings.percentage_symbol
        secondDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowTwentyKm) + Strings.percentage_symbol
        thirdDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowThirtyKm) + Strings.percentage_symbol
        fourthDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowFiftyKm) + Strings.percentage_symbol
        fifthDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowHundredKm) + Strings.percentage_symbol
        sixthDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowThreeHundredKm) + Strings.percentage_symbol
        seventhDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountBelowFiveHundredKm) + Strings.percentage_symbol
        eighthDiscountPer.text = StringUtils.getPointsInDecimal(points: clientConfiguration!.discountAboveFiveHundredKm) + Strings.percentage_symbol
    }
    
    func fareCalculation(){
        firstFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowTenKm))
        secondFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowTwentyKm ))
        thirdFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowThirtyKm))
        fourthFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowFiftyKm))
        fifthFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowHundredKm))
        sixthFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowThreeHundredKm))
        seventhFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountBelowFiveHundredKm))
        eigthFare.text = StringUtils.getPointsInDecimal(points: calculateFareBasedOnDiscountPercentage(discountPercentage: clientConfiguration!.discountAboveFiveHundredKm))
    }
    func calculateFareBasedOnDiscountPercentage(discountPercentage: Double) -> Double{
        return clientConfiguration!.carDefaultFare * ((100-discountPercentage)/100)
    }
    
    func exFareCalculation(){
        firstExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 10))
        secondExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 20))
        thirdExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 30))
        fourthExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 50))
        fifthExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 100))
        sixthExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 300))
        seventhExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 500))
        eigthExFare.text = StringUtils.getPointsInDecimal(points: getExFareCalculation(distance : 1000))
    }
    
    func getExFareCalculation(distance : Double) -> Double{
        
        
        var billAmt = 0.0
        let bellowTenFare = 1 - (clientConfiguration!.discountBelowTenKm/100)
        let bellowTwentyFare = 1 - (clientConfiguration!.discountBelowTwentyKm/100)
        let bellowThirtyFare = 1-(clientConfiguration!.discountBelowThirtyKm/100)
        let bellowFiftyFare = 1-(clientConfiguration!.discountBelowFiftyKm/100)
        let bellowHundredFare = 1-(clientConfiguration!.discountBelowHundredKm/100)
        let bellowThreeHundredFare = 1-(clientConfiguration!.discountBelowThreeHundredKm/100)
        let bellowFiveHundredFare = 1-(clientConfiguration!.discountBelowFiveHundredKm/100)
        let aboveHundredFare = 1-(clientConfiguration!.discountAboveFiveHundredKm / 100)
        let farePerKm = clientConfiguration!.carDefaultFare
        if(distance <= 10)
        {
            billAmt = distance * farePerKm * bellowTenFare
            return billAmt;
        }
        else
        {
            billAmt =  10 * farePerKm * bellowTenFare
        }
        
        if distance <= 20
        {
            billAmt = billAmt + ((distance-10) * farePerKm * bellowTwentyFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (10 * farePerKm * bellowTwentyFare)
        }
        
        if distance <= 30
        {
            billAmt = billAmt + ((distance-20) * farePerKm * bellowThirtyFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (10 * farePerKm * bellowThirtyFare)
        }
        
        if distance <= 50
        {
            billAmt = billAmt + ((distance-30) * farePerKm * bellowFiftyFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (20 * farePerKm * bellowFiftyFare)
        }
        
        if distance <= 100
        {
            billAmt = billAmt + ((distance-50) * farePerKm * bellowHundredFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (50 * farePerKm * bellowHundredFare)
        }
        
        if distance <= 300
        {
            billAmt = billAmt + ((distance-100) * farePerKm * bellowThreeHundredFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (200 * farePerKm * bellowThreeHundredFare)
        }
        if distance <= 500
        {
            billAmt = billAmt + ((distance-300) * farePerKm * bellowFiveHundredFare)
            return billAmt;
        }
        else
        {
            billAmt = billAmt + (200 * farePerKm * bellowFiveHundredFare)
        }
        if distance > 500
        {
            billAmt = billAmt +  ((distance-500) * farePerKm * aboveHundredFare)
        }
        return billAmt
    }
    
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
    self.view.removeFromSuperview()
        self.removeFromParent()
  }
}
