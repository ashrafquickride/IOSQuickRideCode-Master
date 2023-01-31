//
//  TaxiBillRatingTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/30/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper


class TaxiBillRatingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
  
    private var ratingButtonArray = [UIButton]()
    private var taxiRideFeedBack: TaxiRideFeedback?
    private var rating = 0.0
    private var taxiRidePassenger: TaxiRidePassenger?
    private var taxiRideInvoice: TaxiRideInvoice?
    
    func initializeRatingCell(taxiRideFeedBack: TaxiRideFeedback?,taxiRidePassenger: TaxiRidePassenger?,taxiRideInvoice: TaxiRideInvoice?,driverName: String){
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        self.taxiRideFeedBack = taxiRideFeedBack
        self.taxiRidePassenger = taxiRidePassenger
        self.taxiRideInvoice = taxiRideInvoice
        if let taxiFeedBack = taxiRideFeedBack,taxiFeedBack.rating != 0{
            titleLabel.text = "You Rated \(driverName.capitalized)"
            setGivenRating(selectedRating: Int(taxiFeedBack.rating))
        }else{
            titleLabel.text = "How was your ride?"
        }
    }
    
    
    private func setGivenRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.isHidden = true
            }
        }
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if let feedback = taxiRideFeedBack,feedback.rating != 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.you_have_already_given_feedback)
            return
        }
        let taxiTripPassengerFeedbackVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiTripPassengerFeedbackViewController") as! TaxiTripPassengerFeedbackViewController
        taxiTripPassengerFeedbackVC.initializeData(taxiRideInvoice: taxiRideInvoice, rating: Double(sender.tag + 1), taxiRidePassenger: taxiRidePassenger)
        ViewControllerUtils.addSubView(viewControllerToDisplay: taxiTripPassengerFeedbackVC)
    }
}

