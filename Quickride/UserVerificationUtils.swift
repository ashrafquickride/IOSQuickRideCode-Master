//
//  UserVerificationUtils.swift
//  Quickride
//
//  Created by Admin on 16/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserVerificationUtils {
    
    static func getVerificationImageBasedOnVerificationData(profileVerificationData : ProfileVerificationData?) -> UIImage{
        
        if profileVerificationData != nil {
            if profileVerificationData!.profileVerified || profileVerificationData!.imageVerified {
                if (profileVerificationData!.emailVerified || profileVerificationData!.isVerifiedFromEndorsement()) && (profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
                    return UIImage(named: "verified")!
                }else if profileVerificationData!.emailVerified{
                    return UIImage(named: "org_mail_verified")!
                }else if profileVerificationData!.isVerifiedFromEndorsement() {
                    return UIImage(named: "endorsed_verification_icon")!
                } else if profileVerificationData!.persIDVerified{
                    return UIImage(named: "pers_id_verified")!
                }else{
                    return UIImage(named: "not_verified_new")!
                }
            }else{
                return UIImage(named: "not_verified_new")!
            }
        }else{
            return UIImage(named: "not_verified_new")!
            
        }
    }
    
    static func getVerificationTextBasedOnVerificationData(profileVerificationData : ProfileVerificationData?,companyName : String?) -> String{

        if profileVerificationData != nil{
            
             if profileVerificationData!.profileVerified || profileVerificationData!.imageVerified{
                if (profileVerificationData!.emailVerified || profileVerificationData!.isVerifiedFromEndorsement()) && (profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
                    if companyName != nil {
                        return companyName!
                    } else {
                        return Strings.profile_verified
                    }
                }else if profileVerificationData!.emailVerified{
                    if companyName != nil {
                        return companyName!
                    } else {
                        return Strings.org_verified
                    }
                    
                } else if profileVerificationData!.isVerifiedFromEndorsement() {
                    return String(format: Strings.endorsed_by_users, arguments: [String(profileVerificationData!.noOfEndorsers)])
                }
                else if profileVerificationData!.persIDVerified{
                    
                    return Strings.personal_id_verified
                    
                } else{
                    
                    return Strings.not_verified
                    
                }
            } else {
                
                return Strings.not_verified
                
            }
        } else if companyName != nil{
            
          return companyName!
            
        } else{
          return Strings.not_verified
        }
    }
    
    static func getProfileVerificationProgress() -> Double {
        var profileCompletionPercentage: Double = 0.0
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let user = UserDataCache.getInstance()?.getUser()
        let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()
        if userProfile?.emailForCommunication != nil && !userProfile!.emailForCommunication!.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.05
        }
        if user?.contactNo != nil && user?.contactNo != 0 {
            profileCompletionPercentage = profileCompletionPercentage + 0.03
        }
        if user?.userName != nil && !user!.userName.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.02
        }
        if profileVerificationData != nil {
            if profileVerificationData!.emailVerified || profileVerificationData!.isVerifiedFromEndorsement() {
                profileCompletionPercentage = profileCompletionPercentage + 0.2
            }
            if profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement() {
                profileCompletionPercentage = profileCompletionPercentage + 0.2
            }
        }
        if userProfile?.imageURI != nil && !userProfile!.imageURI!.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.2
        }
        if userProfile?.profession != nil && !userProfile!.profession!.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.1
        }
        if userProfile?.skills != nil && !userProfile!.skills!.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.1
        }
        if userProfile?.interests != nil && !userProfile!.interests!.isEmpty {
            profileCompletionPercentage = profileCompletionPercentage + 0.1
        }
        return profileCompletionPercentage.roundToPlaces(places: 1)
    }
    
    static func getProfileVerificationCategories() -> [ProfileVerificationCategory]{
        var profileVerificationCategory = [ProfileVerificationCategory]()
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()
        if profileVerificationData != nil {
            var isPending: Bool?
            var name: String?
            if (profileVerificationData!.emailVerified || profileVerificationData!.isVerifiedFromEndorsement()) && (profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
                isPending = false
            } else if !profileVerificationData!.emailVerified && !profileVerificationData!.isVerifiedFromEndorsement() {
                isPending = true
                name = Strings.verify_organization
            } else if !profileVerificationData!.persIDVerified || (profileVerificationData!.persIDVerified && profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
                isPending = true
                name = Strings.verify_personal_identity
            } else {
                isPending = true
                name = Strings.type_verify_profile
            }
            profileVerificationCategory.append(ProfileVerificationCategory(type: Strings.type_verify_profile, imageName: "not_verified_new", status: isPending, name: name))
        }
        if userProfile != nil {
            var isPending: Bool?
            var name: String?
            if userProfile!.imageURI != nil && !userProfile!.imageURI!.isEmpty {
                isPending = false
            } else {
                isPending = true
                name = Strings.type_upload_photo
            }
            profileVerificationCategory.append(ProfileVerificationCategory(type: Strings.type_upload_photo, imageName: "camera_pic_gray", status: isPending, name: name))
            if userProfile!.profession != nil && !userProfile!.profession!.isEmpty && userProfile?.skills != nil && !userProfile!.skills!.isEmpty {
                isPending = false
                name = Strings.professional_profile_updated
            } else if (userProfile!.profession == nil || userProfile!.profession!.isEmpty) && (userProfile?.skills == nil || userProfile!.skills!.isEmpty) {
                isPending = true
                name = Strings.add_professional_profile
            } else if userProfile!.profession == nil || userProfile!.profession!.isEmpty {
                isPending = true
                name = Strings.add_designation
            } else {
                isPending = true
                name = Strings.add_skills
            }
            profileVerificationCategory.append(ProfileVerificationCategory(type: Strings.add_professional_profile, imageName: "designation_icon", status: isPending, name: name))
            
            if userProfile?.interests != nil && !userProfile!.interests!.isEmpty {
                isPending = false
                name = Strings.personal_profile_updated
            } else {
                isPending = true
                name = Strings.add_hobbies
            }
            profileVerificationCategory.append(ProfileVerificationCategory(type: Strings.add_personal_profile, imageName: "hobby_icon", status: isPending, name: name))
        }
        return sortOnlyPending(profileVerifications: profileVerificationCategory)
    }

    static func sortOnlyPending(profileVerifications: [ProfileVerificationCategory]) -> [ProfileVerificationCategory] {
        if profileVerifications.isEmpty {
            return profileVerifications
        }
        var pendingProfileVerfication = [ProfileVerificationCategory]()
        for profileVerification in profileVerifications {
            if profileVerification.status == true {
                pendingProfileVerfication.append(profileVerification)
            }else {
                continue
            }
        }
        return pendingProfileVerfication
    }
}
