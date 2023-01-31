//
//  EmailPreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EmailPreferences:NSObject, Mappable, NSCopying {
  
  var userId : Double?
  var receiveRideTripReports = false
  var receiveNewsAndUpdates = false
  var receivePromotionsAndOffers = false
  var receiveSuggestionsAndRemainders = false
  var recieveBonusReports = false
  var receiveMonthlyReports = false
  var unSubscribe = false
    

  static let USER_ID = "userId";
  static let RECEIVE_RIDE_TRIP_REPORTS = "receiveRideTripReports"
  static let RECEIVE_NEWS_AND_UPDATES = "receiveNewsAndUpdates"
  static let RECEIVE_PROMOTIONS_AND_OFFERS = "receivePromotionsAndOffers"
  static let RECEIVE_REMAINDERS_AND_SUGGESTIONS = "receiveSuggestionsAndRemainders"
  static let RECEIVE_BONUS_REPORTS="recieveBonusReports"
  static let RECEIVE_MONTHLY_REPORTS="receiveMonthlyReports"
  static let UN_SUBSCRIBE="unSubscribe"

    override init() {
        if QRSessionManager.getInstance()?.getUserId() != nil{
            userId = Double(QRSessionManager.getInstance()!.getUserId())
        }
       receiveRideTripReports = false
       receiveNewsAndUpdates = false
       receivePromotionsAndOffers = false
       receiveSuggestionsAndRemainders = false
       recieveBonusReports = false
       receiveMonthlyReports = false
       unSubscribe = false
   }
    
  func mapping(map: Map) {
    self.userId <- map["userId"]
    self.receiveRideTripReports <- map["receiveRideTripReports"]
    self.receiveNewsAndUpdates <- map["receiveNewsAndUpdates"]
    self.receivePromotionsAndOffers <- map["receivePromotionsAndOffers"]
    self.receiveSuggestionsAndRemainders <- map["receiveSuggestionsAndRemainders"]
    self.recieveBonusReports <- map["recieveBonusReports"]
    self.receiveMonthlyReports <- map["receiveMonthlyReports"]
    self.unSubscribe <- map["unSubscribe"]
  }
  required init?(map: Map) {
    
  }
  
  
  func  getParamsMap() -> [String : String] {
    var params = [String : String]()
    params["userId"] =  StringUtils.getStringFromDouble(decimalNumber : userId)
    params["receiveRideTripReports"] = String(receiveRideTripReports)
    params["receiveNewsAndUpdates"] = String(receiveNewsAndUpdates)
    params["receivePromotionsAndOffers"] = String(receivePromotionsAndOffers)
    params["receiveSuggestionsAndRemainders"] = String(receiveSuggestionsAndRemainders)
    params["recieveBonusReports"] = String(recieveBonusReports)
    params["receiveMonthlyReports"] = String(receiveMonthlyReports)
    params["unSubscribe"] = String(unSubscribe)
    return params
  }
  func copy(with zone: NSZone? = nil) -> Any  {
    let emailPreferences = EmailPreferences()
    emailPreferences.userId = self.userId
    emailPreferences.receiveRideTripReports = self.receiveRideTripReports
    emailPreferences.receiveNewsAndUpdates = self.receiveNewsAndUpdates
    emailPreferences.receivePromotionsAndOffers = self.receivePromotionsAndOffers
    emailPreferences.receiveSuggestionsAndRemainders = self.receiveSuggestionsAndRemainders
    emailPreferences.recieveBonusReports = self.recieveBonusReports
    emailPreferences.receiveMonthlyReports = self.receiveMonthlyReports
    emailPreferences.unSubscribe = self.unSubscribe
    return emailPreferences
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "receiveRideTripReports: \(String(describing: self.receiveRideTripReports))," + " receiveNewsAndUpdates: \(String(describing: self.receiveNewsAndUpdates))," + " receivePromotionsAndOffers: \(String(describing: self.receivePromotionsAndOffers))," + " receiveSuggestionsAndRemainders: \(String(describing: self.receiveSuggestionsAndRemainders)),"
            + " recieveBonusReports: \(self.recieveBonusReports)," + "receiveMonthlyReports: \(String(describing: self.receiveMonthlyReports))," + "unSubscribe:\(self.unSubscribe),"
    }
}
