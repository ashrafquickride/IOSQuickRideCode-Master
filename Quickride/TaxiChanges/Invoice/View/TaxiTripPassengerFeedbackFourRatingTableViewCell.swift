//
//  TaxiTripPassengerFeedbackFourRatingTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 28/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripPassengerFeedbackFourRatingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    private var taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel()
    
    func initializeData(taxiTripPassengerFeedbackViewModel: TaxiTripPassengerFeedbackViewModel){
        self.taxiTripPassengerFeedbackViewModel = taxiTripPassengerFeedbackViewModel
        feedbackTextView.delegate = self
        feedbackTextView.text = Strings.concern
        feedbackTextView.textColor = .darkGray
    }
    @IBAction func submitButtonTaped(_ sender: Any) {
        var feedback: String?
        if feedbackTextView.text != Strings.concern && !feedbackTextView.text.isEmpty {
            feedback = feedbackTextView.text
        }
        submitfeedback(feedback: feedback)
    }
    func submitfeedback(feedback: String?){
        taxiTripPassengerFeedbackViewModel.submitRatingAndFeedBack(feedback: feedback)
    }
}
extension TaxiTripPassengerFeedbackFourRatingTableViewCell: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if feedbackTextView.text == nil || feedbackTextView.text?.isEmpty == true || feedbackTextView.text == Strings.concern{
            feedbackTextView.text = ""
            feedbackTextView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if feedbackTextView.text == nil || feedbackTextView.text?.isEmpty == true {
            feedbackTextView.text = Strings.concern
            feedbackTextView.textColor = .darkGray
        }
    }
}

