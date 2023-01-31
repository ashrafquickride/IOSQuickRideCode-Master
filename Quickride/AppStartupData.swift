//
//  AppStartupData.swift
//  Quickride
//
//  Created by KNM Rao on 18/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AppStartupData : NSObject, Mappable {
    
    var clientConfiguration : ClientConfigurtion?
    var isUpgradeRequired : String?
    var offersList : [Offer]?
    var publishLocUpdatesToRideMgmtBroker = false
    var customerSupportFileURL = "https://qr-images.s3.ap-south-1.amazonaws.com/customerSupport.json"
    var emailVerificationInitiatedDate: Double?
    var googleAPIConfiguration : GoogleAPIConfiguration?
    var adhaarClientCodeForWeb: String?
    var adhaarApiKeyForWeb: String?
    var adhaarSaltForWeb: String?
    var freechargeAddMoneyURL: String?
    var freechargeAddMoneyCallbackURL: String?
    var paytmAddMoneyURL: String?
    var enableNumberMasking = false
    
    
    
    static let SUBSCRIPTION_DEFAULT_AMOUNT = 100
    
    func mapping(map: Map) {
        clientConfiguration <- map["clientConfiguration"]
        isUpgradeRequired <- map["isUpgradeRequired"]
        offersList <- map["offersList"]
        publishLocUpdatesToRideMgmtBroker <- map["publishLocUpdatesToRideMgmtBroker"]
        customerSupportFileURL <- map["customerSupportFileURL"]
        emailVerificationInitiatedDate <- map["emailVerificationInitiatedTime"]
        googleAPIConfiguration <- map["googleAPIConfigurationNew"]
        adhaarClientCodeForWeb <- map["adhaarClientCodeForWeb"]
        adhaarApiKeyForWeb <- map["adhaarApiKeyForWeb"]
        adhaarSaltForWeb <- map["adhaarSaltForWeb"]
        freechargeAddMoneyURL <- map["freechargeAddMoneyURL"]
        freechargeAddMoneyCallbackURL <- map["freechargeAddMoneyCallbackURL"]
        paytmAddMoneyURL <- map["paytmAddMoneyURL"]
        enableNumberMasking <- map["enableNumberMasking"]
    }
    required init?(map:Map){
        
    }
    override init(){
        super.init()
    }
  
    public override var description: String {
        return "clientConfiguration: \(String(describing: clientConfiguration))," + "isUpgradeRequired: \(String(describing: isUpgradeRequired))," + "offersList: \(String(describing: offersList))," + "publishLocUpdatesToRideMgmtBroker: \(String(describing: publishLocUpdatesToRideMgmtBroker))," + "customerSupportFileURL: \(String(describing: customerSupportFileURL))," + "emailVerificationInitiatedDate: \( String(describing: emailVerificationInitiatedDate))," + "googleAPIConfiguration: \(String(describing: googleAPIConfiguration))," + "adhaarClientCodeForWeb: \( String(describing: adhaarClientCodeForWeb))," + "adhaarApiKeyForWeb: \(String(describing: adhaarApiKeyForWeb))," + "adhaarSaltForWeb: \(String(describing: adhaarSaltForWeb))" + "freechargeAddMoneyURL: \(String(describing: freechargeAddMoneyURL))" + "freechargeAddMoneyCallbackURL: \(String(describing: freechargeAddMoneyCallbackURL))" + "paytmAddMoneyURL: \(String(describing: paytmAddMoneyURL))" + "enableNumberMasking: \(String(describing: enableNumberMasking))"
    }
}
