//
//  UserFeedback.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserFeedback:NSObject,Mappable{
  
  var rideid:Double?
  var feedbackbyphonenumber:Double?
  var feedbacktophonenumber:Double?
  var rating:Float = 0.0
  var extrainfo:String?
  var feebBackToName:String?
  var feebBackToImageURI : String?
  var feedBackToUserGender : String?
  var isBlockedUser = false
  var isFiveRatingGiven = false
  var feedBackCommentIds : String?
  
  public static let  FEEDBACK_BY : String = "feedbackby"
  public static let FEEDBACK_TO : String = "feedbackto"
  public static let  RIDE_ID : String = "rideid"
  public static let RATING : String = "rating"
  public static let EXTRAINFO : String = "extrainfo"
  public static let ETIQUETTE_IDS : String = "etiquetteIds"
    
  required public init(map:Map){
    
  }
  
    init(rideid : Double?,feedbackbyphonenumber:Double, feedbacktophonenumber:Double, rating:Float, extrainfo:String?, feebBackToName:String,feebBackToImageURI :String?,feedBackToUserGender : String, feedBackCommentIds: String?) {
    self.rideid = rideid
    self.feedbackbyphonenumber = feedbackbyphonenumber
    self.feedbacktophonenumber = feedbacktophonenumber
    self.rating = rating
    self.extrainfo = extrainfo
    self.feebBackToName = feebBackToName
    self.feebBackToImageURI = feebBackToImageURI
    self.feedBackToUserGender = feedBackToUserGender
    self.feedBackCommentIds = feedBackCommentIds
  }
    init(feedbackbyphonenumber:Double, feedbacktophonenumber:Double, rating:Float, extrainfo:String?, feebBackToName:String,feebBackToImageURI :String?,feedBackToUserGender : String){
        self.feedbackbyphonenumber = feedbackbyphonenumber
        self.feedbacktophonenumber = feedbacktophonenumber
        self.rating = rating
        self.extrainfo = extrainfo
        self.feebBackToName = feebBackToName
        self.feebBackToImageURI = feebBackToImageURI
        self.feedBackToUserGender = feedBackToUserGender
    }
  
  public func mapping(map:Map){
    rideid <- map["rideid"]
    feedbackbyphonenumber <- map["feedbackby"]
    feedbacktophonenumber <- map["feedbackto"]
    rating <- map["rating"]
    extrainfo <- map["extrainfo"]
    feebBackToName <- map["feebBackToName"]
    feedBackCommentIds <- map["etiquetteIds"]
  }
  
  func getParams() -> [String : String]{
    AppDelegate.getAppDelegate().log.debug("getParams()")
    var params : [String : String] = [String : String]()
    params[UserFeedback.FEEDBACK_BY] = String(feedbackbyphonenumber!).components(separatedBy: ".")[0]
    params[UserFeedback.FEEDBACK_TO] = String(feedbacktophonenumber!).components(separatedBy: ".")[0]
    if rideid != nil{
    params[UserFeedback.RIDE_ID] =  String(rideid!).components(separatedBy: ".")[0]
    }
    else{
    params[UserFeedback.RIDE_ID] = "0"
    }
    params[UserFeedback.RATING] =  String(rating)
    if extrainfo != nil{
        params[UserFeedback.EXTRAINFO] = extrainfo!
    }
    params[UserFeedback.ETIQUETTE_IDS] = feedBackCommentIds
    return params
  }
    public override var description: String {
        return "rideid: \(String(describing: self.rideid))," + "feedbackbyphonenumber: \(String(describing: self.feedbackbyphonenumber))," + " feedbacktophonenumber: \( String(describing: self.feedbacktophonenumber))," + " rating: \(String(describing: self.rating))," + " extrainfo: \(String(describing: self.extrainfo)),"
            + " feebBackToName: \(String(describing: self.feebBackToName))," + "feebBackToImageURI: \(String(describing: self.feebBackToImageURI))," + "feedBackToUserGender:\(String(describing: self.feedBackToUserGender)),"
    }
}



