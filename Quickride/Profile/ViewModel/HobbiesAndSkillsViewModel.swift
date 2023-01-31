//
//  HobbiesAndSkillsViewModel.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class HobbiesAndSkillsViewModel {

    //MARK: Properties
    var defaultSkillsList = [String]()
    var defaultHobbiesList = [String]()
    var selectedHobbies = [String]()
    var selectedSkills = [String]()
    var allSkillsList = [String]()
    var allHobbiesList = [String]()
    
    //MARK: Methods
    func getUserSkillsAndInterest() {
        filterSelectedHobbiesAndSkills()
        UserDataCache.getInstance()?.getSkillsAndInterests(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", handler: { (skillsAndHobbies) in
            if let skillsAndHobbies = skillsAndHobbies {
                self.filterHobbiesAndSkills(skillsAndHobbiesData: skillsAndHobbies)
            }
            NotificationCenter.default.post(name: .hobbiesAndSkillRetrieved, object: nil)
        })
    }

    private func filterHobbiesAndSkills(skillsAndHobbiesData: SkillsAndInterestsData) {
        for hobby in skillsAndHobbiesData.interestsData {
            let attributeName = hobby.attributeName.trimmingCharacters(in: .whitespaces)
            if !defaultHobbiesList.contains(attributeName) {
                if defaultHobbiesList.count < 10 {
                    defaultHobbiesList.append(attributeName)
                }
                allHobbiesList.append(attributeName)
            }
        }
        
        for skill in skillsAndHobbiesData.skillsData {
            let attributeName = skill.attributeName.trimmingCharacters(in: .whitespaces)
            if !defaultSkillsList.contains(attributeName) {
                if defaultSkillsList.count < 10 {
                    defaultSkillsList.append(attributeName)
                }
                allSkillsList.append(attributeName)
            }
        }
    }
    
    private func filterSelectedHobbiesAndSkills() {
        if let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile() {
            if let hobbies = userProfile.interests?.split(separator: ",").map({ String($0) }) {
                for hobby in hobbies {
                    let attributeName = hobby.trimmingCharacters(in: .whitespaces)
                    selectedHobbies.append(attributeName)
                    if !defaultHobbiesList.contains(attributeName) {
                        defaultHobbiesList.append(attributeName)
                        allHobbiesList.append(attributeName)
                    }
                }
            }
            if let skills = userProfile.skills?.split(separator: ",").map({ String($0) }) {
                for skill in skills {
                    let attributeName = skill.trimmingCharacters(in: .whitespaces)
                    selectedSkills.append(attributeName)
                    if !defaultSkillsList.contains(attributeName) {
                        defaultSkillsList.append(attributeName)
                        allSkillsList.append(attributeName)
                    }
                }
            }
        }
    }
    
    func updateUserProfile() {
        if let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile() {
            userProfile.interests = selectedHobbies.joined(separator: ",")
            userProfile.skills = selectedSkills.joined(separator: ",")
            QuickRideProgressSpinner.startSpinner()
            ProfileRestClient.putProfileWithBody(targetViewController: nil, body: userProfile.getParamsMap()) { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]) {
                        UserDataCache.getInstance()?.storeUserProfile(userProfile: userProfile)
                    }
                    NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
                }else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
            }
        }
    }
    
    func getAutoSuggestionName(type: String) -> [String] {
        var searchData = [String]()
        if type == Strings.hobbies {
            searchData.append(contentsOf: allHobbiesList)
        } else {
            searchData.append(contentsOf: allSkillsList)
        }
        return searchData
    }
    
    func updateSkillsAndHobbies(hobbyOrSkill: [Int:String]) {
        if hobbyOrSkill.keys.contains(0) && hobbyOrSkill[0] != nil {
            let hobby = hobbyOrSkill[0]!.capitalized
            let attributeName = hobby.trimmingCharacters(in: .whitespaces)
            if !defaultHobbiesList.contains(attributeName) {
                defaultHobbiesList.append(attributeName)
                allHobbiesList.append(attributeName)
            }
            if !selectedHobbies.contains(attributeName) {
                selectedHobbies.append(attributeName)
            }
        } else if hobbyOrSkill.keys.contains(1) && hobbyOrSkill[1] != nil {
            let skill = hobbyOrSkill[1]!.capitalized
            let attributeName = skill.trimmingCharacters(in: .whitespaces)
            if !defaultSkillsList.contains(attributeName) {
                defaultSkillsList.append(attributeName)
                allSkillsList.append(attributeName)
            }
            if !selectedSkills.contains(attributeName) {
                selectedSkills.append(attributeName)
            }
        }
    }
}
