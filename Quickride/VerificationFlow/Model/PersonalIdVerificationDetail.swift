//
//  PersonalIdVerificationDetail.swift
//  Quickride
//
//  Created by Vinutha on 14/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PersonalIdVerificationDetail: NSObject, Mappable {
    
    //MARK: Aadhar response params
    var adhaarId: PersonalIdVerificationData?
    var dobInAadhar : PersonalIdVerificationData?
    var fatherNameInAadhar: PersonalIdVerificationData?
    var genderInAadhar: PersonalIdVerificationData?
    var nameInAadhar: PersonalIdVerificationData?
    var addressInAadhar: PersonalIdVerificationData?
    
    //MARK: Pan response params
    var dobInPan : PersonalIdVerificationData?
    var fatherNameInPan: PersonalIdVerificationData?
    var nameInPan: PersonalIdVerificationData?
    var pan_no: PersonalIdVerificationData?
    var dateOfIssueInPan: PersonalIdVerificationData?
    
    //MARK: Voter response params
    var voterid: PersonalIdVerificationData?
    var nameInVoter: PersonalIdVerificationData?
    var genderInVoter: PersonalIdVerificationData?
    var dobInVoter: PersonalIdVerificationData?
    var ageInVoter: PersonalIdVerificationData?
    var dateOfIssueInVoter: PersonalIdVerificationData?
    var addressInVoter: PersonalIdVerificationData?
    var relationInVoter: PersonalIdVerificationData?
    
    //MARK: DL response params
    var dl_num: PersonalIdVerificationData?
    var dobInDL: PersonalIdVerificationData?
    var dateOfIssueInDL: PersonalIdVerificationData?
    var nameInDL : PersonalIdVerificationData?
    var swd: PersonalIdVerificationData?
    var addressInDL: PersonalIdVerificationData?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        adhaarId <- map["aadhaar"]
        dobInAadhar <- map["dob"]
        fatherNameInAadhar <- map["father"]
        genderInAadhar <- map["gender"]
        nameInAadhar <- map["name"]
        addressInAadhar <- map["address"]
        
        dobInPan <- map["date"]
        fatherNameInPan <- map["father"]
        nameInPan <- map["name"]
        pan_no <- map["pan_no"]
        dateOfIssueInPan <- map["date_of_issue"]
        
        voterid <- map["voterid"]
        nameInVoter <- map["name"]
        genderInVoter <- map["gender"]
        dobInVoter <- map["dob"]
        ageInVoter <- map["age"]
        dateOfIssueInVoter <- map["date"]
        addressInVoter <- map["address"]
        relationInVoter <- map["relation"]
        
        dl_num <- map["dl_num"]
        dobInDL <- map["dob"]
        dateOfIssueInDL <- map["doi"]
        nameInDL <- map["name"]
        swd <- map["swd"]
        addressInDL <- map["address"]
    }
}
