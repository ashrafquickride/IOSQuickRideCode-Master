//
//  ProfileVerificationData.swift
//  Quickride
//
//  Created by Vinutha on 9/22/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class ProfileVerificationData : NSObject, Mappable {
    
    var userId : Double?
    var emailVerified = false
    var imageVerified = false
    var profileVerified = false
    var persIDVerified = false
    var profVerifSource : Int? //1- Email Id, 2- Customer Agent, 3 - Company id, 4- Organisation Incomimg email
    var persVerifSource : String?
    var emailVerifiedAtleastOnce = false
    var noOfEndorsers = 0
    var emailVerificationStatus: String?
    
    
    static let ENDORSED = "ENDORSED"
    static let ADHAR = "Aadhar"
    static let ADHAR_KYC_USERID = "adhaarKYCUserId"
    static let ADHAR_VERIFICATION_REQUEST = "adharVerificationRequest"
    static let ADHAR_CHANNEL_ID = "adharChannelId"
    static let CHANNEL_WEB_APP = "WEB_APP"
    
    static let FLD_CLIENT_CODE = "client_code"
    static let FLD_STAN = "stan"
    static let FLD_REDIRECT_URL = "redirect_url"
    static let FLD_API_KEY = "api_key"
    static let FLD_HASH = "hash"
    static let FLD_REQUEST_ID = "request_id"
    static let FLD_OTP_REQUIRED = "otp_required"
    
    static let PENDING = "PENDING"
    static let INITIATED = "INITIATED"
    static let VERIFIED = "VERIFIED"
    static let REJECTED = "REJECTED"
    
    public func mapping(map: Map) {
        userId <- map["userId"]
        emailVerified <- map["emailVerified"]
        imageVerified <- map["imageVerified"]
        profileVerified <- map["profileVerified"]
        persIDVerified <- map["persIDVerified"]
        profVerifSource <- map["profVerifSource"]
        persVerifSource <- map["persIdVerifSource"]
        emailVerifiedAtleastOnce <- map["emailVerifiedAtleastOnce"]
        noOfEndorsers <- map["noOfEndorsers"]
        emailVerificationStatus <- map["emailVerificationStatus"]
    }
    required public init?(map:Map){
        
    }
    override init() {
        
    }
    init(userId: Double, emailVerified: Bool, imageVerified: Bool, profileVerified: Bool){
        self.userId = userId
        self.emailVerified = emailVerified
        self.imageVerified = imageVerified
        self.profileVerified = profileVerified
    }
    
    func isVerifiedFromEndorsement() -> Bool {
        if persVerifSource == nil || persVerifSource!.isEmpty {
            return false
        }
        return persVerifSource!.contains(ProfileVerificationData.ENDORSED)
    }

    func isVerifiedOnlyFromEndorsement() -> Bool {
       if persVerifSource == nil || persVerifSource!.isEmpty {
           return false
       }
        let persVerifSources = persVerifSource?.components(separatedBy: ",")
        return persVerifSource!.contains(ProfileVerificationData.ENDORSED) && persVerifSources?.count == 1
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "emailVerified: \(String(describing: self.emailVerified))," + " imageVerified: \( String(describing: self.imageVerified))," + " profileVerified: \(String(describing: self.profileVerified))," + " persIDVerified: \(String(describing: self.persIDVerified)),"
            + " profVerifSource: \(String(describing: self.profVerifSource))," + "persVerifSource: \(String(describing: self.persVerifSource))," + "emailVerifiedAtleastOnce: \(String(describing: self.emailVerifiedAtleastOnce))," + "noOfEndorsers: \(noOfEndorsers)," + "emailVerificationStatus: \(String(describing: self.emailVerificationStatus))"
    }
}
