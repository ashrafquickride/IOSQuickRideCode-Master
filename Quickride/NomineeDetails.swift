//
//  NomineeDetails.swift
//  Quickride
//
//  Created by Admin on 29/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class NomineeDetails : NSObject,Mappable{
    
    var userId : Double?
    var nomineeName : String?
    var nomineeAge : Int?
    var nomineeRelation : String?
    var nomineeMobile : String?
    var creationDate : NSDate?
    
    static let USER_ID = "userId"
    static let NOMINEE_NAME = "nomineeName"
    static let NOMINEE_AGE = "nomineeAge"
    static let NOMINEE_RELATION = "nomineeRelation"
    static let NOMINEE_MOBILE = "nomineeMobile"
    static let PHONE = "phone"
    static let CLAIM_TYPE = "claimType"
    
    override init() {
        
    }
    
    public static let insuranceClaimTypeValues = [Strings.insurance_claim_type_death:"1",Strings.insurance_claim_type_accidental_hospitalization:"2",Strings.insurance_claim_type_OPD_Expense:"3"]
    
    required init?(map: Map) {
    }
    
    init(userId : Double?,nomineeName : String?,nomineeAge : Int?,nomineeMobile : String?,nomineeRelation : String?) {
        self.userId = userId
        self.nomineeName = nomineeName
        self.nomineeAge = nomineeAge
        self.nomineeMobile = nomineeMobile
        self.nomineeRelation = nomineeRelation
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        nomineeAge <- map["nomineeAge"]
        nomineeName <- map["nomineeName"]
        nomineeRelation <- map["nomineeRelation"]
        nomineeMobile <- map["nomineeMobile"]
        creationDate <- map["creationDate"]
    }
    
    public func getParams() -> [String : String]{
        
        var params = [String : String]()
        if self.userId != nil{
            params[NomineeDetails.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId!)
        }
        if self.nomineeName != nil{
            params[NomineeDetails.NOMINEE_NAME] = self.nomineeName!
        }
        
        if self.nomineeAge != nil{
            params[NomineeDetails.NOMINEE_AGE] = String(nomineeAge!)
        }
        
        if self.nomineeMobile != nil{
            params[NomineeDetails.NOMINEE_MOBILE] = nomineeMobile!
        }
        
        if self.nomineeRelation != nil{
            params[NomineeDetails.NOMINEE_RELATION] = nomineeRelation
        }
       
        return params
    }
    public override var description: String {
           return "userId: \(String(describing: self.userId))," + "nomineeName: \(String(describing: self.nomineeName))," + " nomineeAge: \( String(describing: self.nomineeAge))," + " status: \(String(describing: self.nomineeRelation))," + " nomineeMobile: \(String(describing: self.nomineeMobile)),"
               + " creationDate: \(String(describing: self.creationDate)),"
       }
    
}
