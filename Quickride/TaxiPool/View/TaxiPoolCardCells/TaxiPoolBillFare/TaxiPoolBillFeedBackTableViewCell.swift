//
//  TaxiPoolBillFeedBackTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/30/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol updateRatingDelegate {
    func data(rating: Double)
}

class TaxiPoolBillFeedBackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var feedBackTextView: UITextView!
    @IBOutlet weak var bottomFeedBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    
    private var ratingButtonArray = [UIButton]()
    private var givenRating = 0.0
    private var isRatingGiven = false
    private var taxiRideId = 0.0
    private var feedBack = ""
    var delegate : updateRatingDelegate?
    func initializeRatingCell(rating: Double,isRatingGiven: Bool,taxiRideId: Double,feedBack: String){
        self.givenRating = rating
        self.isRatingGiven = isRatingGiven
        self.taxiRideId = taxiRideId
        self.feedBack = feedBack
        if isRatingGiven {
        setGivenRating(selectedRating: Int(rating))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        bottomFeedBackViewHeightConstraint.constant = 0
        feedBackView.isHidden = true
    }
    
    private func setGivenRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
               data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
    }
    
    private func setRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
        
    }
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if isRatingGiven {
            UIApplication.shared.keyWindow?.makeToast( Strings.you_have_already_given_feedback)
            return
        }
        givenRating = Double(sender.tag + 1)
        setRating(selectedRating: sender.tag + 1)
        feedBackTextView.text = Strings.share_feedback_placeholder
        feedBackTextView.textColor = .lightGray
        submitBtn.backgroundColor = .lightGray
        submitBtn.isUserInteractionEnabled = false
        saveRating(rating: givenRating, feedBack: feedBack)
    }
    
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        if !feedBackTextView.text.isEmpty {
            feedBack = feedBackTextView.text
            saveRating(rating: givenRating, feedBack: feedBack)
        }
    }
    
   private func saveRating(rating: Double,feedBack: String) {
        TaxiPoolRestClient.saveTaxiPoolRating(taxiRideId: taxiRideId, noOfRating: rating, feedback: feedBack) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if self.feedBackTextView.text == Strings.share_feedback_placeholder {
                    UIApplication.shared.keyWindow?.makeToast( Strings.thanks_for_rating)
                    self.bottomFeedBackViewHeightConstraint.constant = 130
                    self.feedBackView.isHidden = false
                    self.delegate?.data(rating: Double(self.givenRating))
                     return
                } else {
                    UIApplication.shared.keyWindow?.makeToast( Strings.thanks_for_feedback)
                    let parentVC = self.parentViewController as? BillViewController
                    if parentVC != nil {
                        self.bottomFeedBackViewHeightConstraint.constant = 0
                        self.feedBackView.isHidden = true
                        parentVC?.tableView.reloadData()
                    }
                }
               
            }
        }
    }
}

extension TaxiPoolBillFeedBackTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Strings.share_feedback_placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = Strings.share_feedback_placeholder
            textView.textColor = .lightGray
            submitBtn.backgroundColor = .lightGray
            submitBtn.isUserInteractionEnabled = false
        } else {
            submitBtn.backgroundColor = UIColor.init(netHex: 0x00B557)
            submitBtn.isUserInteractionEnabled = true
        }
    }
}
