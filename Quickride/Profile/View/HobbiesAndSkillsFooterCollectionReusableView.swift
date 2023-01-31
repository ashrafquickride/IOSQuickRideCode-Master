//
//  HobbiesAndSkillsFooterCollectionReusableView.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class HobbiesAndSkillsFooterCollectionReusableView: UICollectionReusableView {
    
    //MARK: Outlets
    @IBOutlet weak var addHobbyOrSkillView: UIView!
    @IBOutlet weak var hobbyOrSkilltextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var anchorViewPosition: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var addOrEditButton: UIButton!
    
    //MARK: Properties
    var searchDataForHobbies : [String] = []
    var searchDataForSkills : [String] = []
    var filteredData : [String] = []
    private var domainsDropDown = DropDown()
    
    //MARK: Methods
    func setupUI(searchDataForHobbies: [String], searchDataForSkills: [String], defaultText: String){
        if tag == 1 {
            addHobbyOrSkillView.isHidden = true
            addOrEditButton.isHidden = false
            addOrEditButton.setTitle(defaultText, for: .normal)
            addOrEditButton.isUserInteractionEnabled = true
        } else {
            addOrEditButton.isUserInteractionEnabled = false
            addHobbyOrSkillView.isHidden = false
            addOrEditButton.isHidden = true
            self.searchDataForHobbies = searchDataForHobbies
            self.searchDataForSkills = searchDataForSkills
            hobbyOrSkilltextField.delegate = self
            hobbyOrSkilltextField.text = nil
            hobbyOrSkilltextField.placeholder = defaultText
            addButton.isUserInteractionEnabled = false
            addButton.backgroundColor = UIColor(netHex: 0x838383)
        }
    }
    
    //MARK: Actions
    @IBAction func addButtonClicked(_ sender: UIButton) {
        var userInfo = [String : Any]()
        userInfo["skillsOrHobbies"] = [sender.tag:hobbyOrSkilltextField.text]
        NotificationCenter.default.post(name: .addHobbiesAndSkillsTapped, object: nil, userInfo: userInfo)
    }
    
    @IBAction func addOrEditButtonClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: .addOrEditHobbiesAndSkillsTapped, object: nil)
    }
}
extension HobbiesAndSkillsFooterCollectionReusableView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == hobbyOrSkilltextField {
            threshold = 20
        }else{
            return true
        }
        if string != ""{
            self.getSearchDataContains(textField.text! + string)
            addButton.isUserInteractionEnabled = true
            addButton.backgroundColor = UIColor(netHex: 0x00B557)
        } else {
            if range.location == 0 && range.length == 1 {
                addButton.isUserInteractionEnabled = false
                addButton.backgroundColor = UIColor(netHex: 0x838383)
            }
            domainsDropDown.dataSource = [String]()
            domainsDropDown.hide()
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func getSearchDataContains(_ text : String) {
        let predicate : NSPredicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", text)
        if hobbyOrSkilltextField.tag == 0 {
            filteredData = (searchDataForHobbies as NSArray).filtered(using: predicate) as! [String]
        } else {
            filteredData = (searchDataForSkills as NSArray).filtered(using: predicate) as! [String]
        }
        showAutoSuggestedText()
    }
    
    private func showAutoSuggestedText() {
        if !filteredData.isEmpty {
            domainsDropDown.anchorView = anchorViewPosition
            domainsDropDown.direction = .top
            domainsDropDown.dataSource = filteredData
            domainsDropDown.show()
            domainsDropDown.selectionAction = {(index, item) in
                self.hobbyOrSkilltextField.text = item
            }
        } else {
            domainsDropDown.dataSource = [String]()
            domainsDropDown.hide()
        }
    }
    
}
