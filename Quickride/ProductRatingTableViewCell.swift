//
//  ProductRatingTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductRatingTableViewCell: UITableViewCell {
    
    //MARK: Outltes
    @IBOutlet weak var ratingforLabel: UILabel!
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var giveFeedbackButton: UIButton!
    
    
    //MARK: Variables
    private var ratingButtonArray = [UIButton]()
    private var alreadyGivenRating = 0
    private var productFeedBack: String?
    
    func initialiseRating(alreadyGivenRating: Int,rating: Int,productFeedBack: String?){
        self.alreadyGivenRating = alreadyGivenRating
        self.productFeedBack = productFeedBack
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        if productFeedBack != nil{
            giveFeedbackButton.setTitle(Strings.thanks_for_feedback, for: .normal)
            giveFeedbackButton.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        }else{
            giveFeedbackButton.setTitle("Give Feedback", for: .normal)
            giveFeedbackButton.setTitleColor(Colors.link, for: .normal)
        }
        if alreadyGivenRating != 0{
            setGivenRating(selectedRating: alreadyGivenRating)
            giveFeedbackButton.isHidden = true
        }
    }
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if alreadyGivenRating != 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.you_have_already_given_feedback)
            return
        }
        setRating(selectedRating: sender.tag + 1)
        var userInfo = [String: Int]()
        userInfo["rating"] = sender.tag + 1
        NotificationCenter.default.post(name: .ratingGivenToProduct, object: nil, userInfo: userInfo)
    }
    
    @IBAction func giveFeedbackButtonTapped(_ sender: Any) {
        if productFeedBack == nil{
            NotificationCenter.default.post(name: .productFeedbackInitiated, object: nil)
        }
    }
    
    func setGivenRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
                data.isUserInteractionEnabled = false
            }else{
                data.isHidden = true
            }
        }
    }
    
    func setRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else if alreadyGivenRating != 0{
                data.isHidden = true
                giveFeedbackButton.isHidden = true
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
    }
}
