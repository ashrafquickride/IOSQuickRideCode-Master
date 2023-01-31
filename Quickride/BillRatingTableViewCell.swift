//
//  BillRatingTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 05/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol BillRatingTableViewCellDelegate {
    func ratingButtonTapped(rating: Int)
    func moveToRatingScreen(rating: Int)
}

class BillRatingTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var ratingRaderNameLabel: UILabel!
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var rideWithLabel: UILabel!
    @IBOutlet weak var addcomplimentBtn: UIButton!
    @IBOutlet weak var addcomplementView: UIView!
    @IBOutlet weak var addComplimentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingView: UIView!
    
    //MARK: Variables
    private var ratingButtonArray = [UIButton]()
    private var delegate: BillRatingTableViewCellDelegate?
    private var alreadyGivenRating = 0
    private var rating = 0
    
    func initializeRatingCell(bill: Bill?,userFeedback: UserFeedback?,delegate: BillRatingTableViewCellDelegate){
        self.delegate = delegate
        self.alreadyGivenRating = Int(userFeedback?.rating ?? 0)
        addcomplementView.isHidden = true
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        if QRSessionManager.getInstance()?.getUserId() == StringUtils.getStringFromDouble(decimalNumber: bill?.userId){
            rideWithLabel.text = String(format: Strings.how_was_your_ride, bill?.billByUserName?.capitalized ?? "")
        }else{
            rideWithLabel.text = String(format: Strings.how_was_your_ride, bill?.userName?.capitalized ?? "")
        }
        if alreadyGivenRating != 0{
            rating = alreadyGivenRating
            setGivenRating(selectedRating: Int(alreadyGivenRating))
            if userFeedback?.extrainfo == nil || userFeedback?.extrainfo?.isEmpty == true{
                addcomplementView.isHidden = false
                if alreadyGivenRating == 3{
                    addcomplimentBtn.setTitle(Strings.add_feedback, for: .normal)
                }else if alreadyGivenRating == 4 || alreadyGivenRating == 5{
                    addcomplimentBtn.setTitle(Strings.add_compliment, for: .normal)
                }else{
                    addcomplementView.isHidden = true
                }
            }else{
                addcomplementView.isHidden = true
            }
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
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
        rating = selectedRating
       handleFeedbackButton(givenRate: selectedRating)
    }
    
    private func handleFeedbackButton(givenRate: Int){
        switch givenRate{
        case 1,2:
            delegate?.moveToRatingScreen(rating: givenRate)
            addcomplementView.isHidden = true
            break
        case 3:
            addcomplementView.isHidden = false
            addcomplimentBtn.setTitle(Strings.add_feedback, for: .normal)
            break
        default:
            addcomplementView.isHidden = false
            addcomplimentBtn.setTitle(Strings.add_compliment, for: .normal)
            break
        }
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if alreadyGivenRating != 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.you_have_already_given_feedback)
            return
        }
        setRating(selectedRating: sender.tag + 1)
        delegate?.ratingButtonTapped(rating: sender.tag + 1)
    }
    @IBAction func addcomplimentButtonTappedTapped(_ sender: UIButton) {
        delegate?.moveToRatingScreen(rating: rating)
    }
}
