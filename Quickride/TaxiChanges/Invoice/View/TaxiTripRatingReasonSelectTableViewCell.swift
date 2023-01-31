//
//  TaxiTripRatingReasonSelectTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 30/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol TaxiTripRatingReasonSelectTableViewCellDelegate {
    func reasonsListOpen(noOfReasons : Int)
    func reasonsListClosed()
}

class TaxiTripRatingReasonSelectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedbackReasonsCollectionView: UICollectionView!
    
    @IBOutlet weak var feedbackCategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitButtonbotomConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedBackTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedBackTextFieldView: UIView!
    @IBOutlet weak var feedBackTextField: UITextField!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private var taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel()
    private var reasonList = [String: [String]]()
    private var reasonCategories = [String]()
    private var selectedReasons = [String]()
    private var selectedCategory: String?
    private var delegate : TaxiTripRatingReasonSelectTableViewCellDelegate?
    
    
    func prepareBadRatingReasons(taxiTripPassengerFeedbackViewModel: TaxiTripPassengerFeedbackViewModel, delegate : TaxiTripRatingReasonSelectTableViewCellDelegate){
        self.delegate = delegate
        self.taxiTripPassengerFeedbackViewModel = taxiTripPassengerFeedbackViewModel
        self.reasonList = FeedbackCategorySegregator.taxiFeedbackCategoryMap
        self.selectedReasons = [String]()
        self.selectedCategory = nil
        self.reasonCategories = FeedbackCategorySegregator().sortFeedbackCategories([String](self.reasonList.keys))
        setupUI()
    }
    func setupUI(){
        feedBackTextFieldHeightConstraint.constant = 0
        submitButton.backgroundColor = .lightGray
        submitButton.isUserInteractionEnabled = false
        feedbackCategoryCollectionView.register(UINib(nibName: "FeedbackCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedbackCategoryCollectionViewCell")
        feedbackReasonsCollectionView.register(UINib(nibName: "FeedbackReasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedbackReasonCollectionViewCell")
        feedbackReasonsCollectionView.delegate = self
        feedbackReasonsCollectionView.dataSource = self
        feedbackReasonsCollectionView.reloadData()
        feedbackCategoryCollectionView.delegate = self
        feedbackCategoryCollectionView.dataSource = self
        feedbackCategoryCollectionView.reloadData()
        feedBackTextField.delegate = self
        
    }
    @IBAction func submitButtonTaped(_ sender: Any) {
        if let otherReason = feedBackTextField.text, !otherReason.isEmpty{
            selectedReasons.append(otherReason)
        }
        taxiTripPassengerFeedbackViewModel.submitRatingAndFeedBack(feedback: selectedReasons.joined(separator: ","))
    }
}


extension TaxiTripRatingReasonSelectTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == feedbackCategoryCollectionView {
            let count = self.reasonCategories.count
            return count
        }else {
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = reasonList[selectedCategory] else {
                return 0
            }
            return reasonForCategory.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == feedbackCategoryCollectionView {
            return CGSize(width: 65, height : 75)
        }else {
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = reasonList[selectedCategory] else {
                return CGSize(width: 120, height : 40)
            }
            let label = UILabel(frame: CGRect.zero)
            label.text = reasonForCategory[indexPath.item]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 25, height: 40)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == feedbackCategoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCategoryCollectionViewCell", for: indexPath) as! FeedbackCategoryCollectionViewCell
            let category = self.reasonCategories[indexPath.row]
            cell.categoryIV.image = FeedbackCategorySegregator.categoryImageMap[category]
            cell.categoryLbl.text = category
            if let selectedCategory = selectedCategory {
                cell.backGroundView.alpha = category == selectedCategory ? 1 : 0.5
            }else {
                cell.backGroundView.alpha = 1
            }
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackReasonCollectionViewCell", for: indexPath) as! FeedbackReasonCollectionViewCell
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = reasonList[selectedCategory] else {
                return cell
            }
            cell.reasonLabel.text = reasonForCategory[indexPath.row]
            cell.reasonView.backgroundColor = selectedReasons.contains(reasonForCategory[indexPath.row]) ? UIColor(netHex: 0x000000).withAlphaComponent(0.2) : UIColor(netHex: 0xF7F7F7)
            cell.reasonView.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
            cell.reasonView.layer.shadowRadius = 1
            cell.reasonView.layer.shadowOffset = CGSize(width: 0,height: 1)
            cell.reasonView.layer.shadowOpacity = 1
            ViewCustomizationUtils.addCornerRadiusToView(view: cell.reasonView, cornerRadius: 15)
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == feedbackCategoryCollectionView {
            let category = self.reasonCategories[indexPath.row]
            if category == selectedCategory {
                return
            }
            selectedCategory = category
            self.delegate?.reasonsListOpen(noOfReasons: reasonList[selectedCategory!]!.count)
            feedbackReasonsCollectionView.reloadData()
            feedbackCategoryCollectionView.reloadData()
            
        }else {
            
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = reasonList[selectedCategory] else {
                return
            }
            let reason = reasonForCategory[indexPath.row]
            if reason == "Other" {//LastIndex
                feedBackTextFieldView.isHidden = false
                feedBackTextFieldHeightConstraint.constant = 40
                feedBackTextField.text = ""
                submitButton.backgroundColor = .lightGray
                submitButton.isUserInteractionEnabled = false
            } else {
                feedBackTextField.endEditing(true)
                feedBackTextFieldView.isHidden = true
                feedBackTextFieldHeightConstraint.constant = 0
                submitButton.backgroundColor = UIColor(netHex: 0x00B557)
                submitButton.isUserInteractionEnabled = true
                if selectedReasons.contains(reason){
                    selectedReasons.removeAll { element in
                        element == reason
                    }
                }else{
                    selectedReasons.append(reason)
                }
            }
            feedbackReasonsCollectionView.reloadData()
        }
        
    }
}
extension TaxiTripRatingReasonSelectTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if feedBackTextField.text == nil || feedBackTextField.text?.isEmpty == true || feedBackTextField.text ==  Strings.feedback{
            feedBackTextField.text = ""
            submitButton.backgroundColor = .lightGray
            submitButton.isUserInteractionEnabled = false
        }else{
            submitButton.backgroundColor = UIColor(netHex: 0x00b557)
            submitButton.isUserInteractionEnabled = true
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if(feedBackTextField.text?.isEmpty == true){
            submitButton.backgroundColor = .lightGray
            submitButton.isUserInteractionEnabled = false
        }else if feedBackTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0 {
            submitButton.backgroundColor = .lightGray
            submitButton.isUserInteractionEnabled = false
        }else {
            submitButton.backgroundColor = UIColor(netHex: 0x00b557)
            submitButton.isUserInteractionEnabled = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if feedBackTextField.text == nil || feedBackTextField.text?.isEmpty == true || feedBackTextField.text ==  Strings.feedback{
            submitButton.backgroundColor = .lightGray
            submitButton.isUserInteractionEnabled = false
        }else {
            submitButton.backgroundColor = UIColor(netHex: 0x00B557)
            submitButton.isUserInteractionEnabled = true
        }
    }
}
