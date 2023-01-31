//
//  CompanyDomainSuggestionUtils.swift
//  Quickride
//
//  Created by Halesh on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import DropDown
import UIKit

class CompanyDomainSuggestionUtils{
    
    private var domainsDropDown = DropDown()
    
    func getCompanyDomainsBasedOnEnteredCharacter(emailDomain: String, textField: UITextField, anchorView: UIView){
        if let range = emailDomain.range(of: "@"){
            let domainName = "@" + emailDomain[range.upperBound...]
            if domainName.count < 3{
                domainsDropDown.dataSource = [String]()
                domainsDropDown.show()
                return
            }
            getCompanyDomains(emailDomain: domainName,textField: textField,anchorView: anchorView)
        }
    }
    
    private func getCompanyDomains(emailDomain: String,textField: UITextField, anchorView: UIView){
        if emailDomain.count >= 3 && emailDomain.count%3 == 0{
            UserRestClient.getCompanyDomains(userId: UserDataCache.getInstance()?.userId ?? "", identifier: emailDomain) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let allCompanyDomains = responseObject!["resultData"] as? [String] ?? [String]()
                    self.prepareDropDownAndShowSuggestions(searchedDomains: allCompanyDomains,textField: textField, anchorView: anchorView)
                }
            }
        }
    }
    private func prepareDropDownAndShowSuggestions(searchedDomains: [String],textField: UITextField, anchorView: UIView){
        if !searchedDomains.isEmpty{
            domainsDropDown.anchorView = anchorView
            domainsDropDown.direction = .bottom
            domainsDropDown.dataSource = searchedDomains
            domainsDropDown.show()
            domainsDropDown.selectionAction = {(index, item) in
                let orgEmail = textField.text
                if let email = orgEmail?.components(separatedBy: "@").first{
                    textField.text = email + item
                }else{
                    textField.text = orgEmail
                }
            }
        }
    }
    
}
