//
//  UserProfile.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public enum CommunicationType{
    case None
    case Chat
    case Call
}
public class UserProfile : NSObject, Mappable,NSCopying {
  
  var userId : Double = 0
  var userName : String?
  var gender : String?
  var confirmType : Bool = false
  var verificationStatus : Int = 0
  var rating : Double = 0
  var numberOfRidesAsPassenger : Double = 0
  var numberOfRidesAsRider : Double = 0
  var matchCompanyConstraint : Bool = false
  var matchGenderConstraint : Bool = false
  var matchGroupCompaniesConstraint = false
  var companyName : String?
  var companyCode : String?
  var profession : String?
  var aboutMe : String?
  var email : String?
  var emailForCommunication : String?
  var emergencyContactNumber : String?
  var imageURI : String?
  var facebook : String?
  var linkedin : String?
  var twitter : String?
  var noOfReviews : Int = 0
  var supportCall : String = "1"
  var preferredRole : String?
  var preferredVehicle : String?
  var onTimeComplianceRating: Int = 0
  var roleAtSignup = UserProfile.PREFERRED_ROLE_BOTH
  var roundedImage = false
  var dateOfBirth: Double?
  var dobInString: String?
  var interests: String?
  var skills: String?
  var rideEtiquetteCertification: RideEtiquetteCertification? // works only for opposite user profile
    
  var rideMatchPercentageAsRider : Int = 15
  var rideMatchPercentageAsPassenger : Int = 50
  var profileVerificationData : ProfileVerificationData?
  
  public static let SUPPORT_CALL_NEVER = "0"
  public static let SUPPORT_CALL_ALWAYS = "1"
  public static let SUPPORT_CALL_AFTER_JOINED = "2"
  public static let PREFERRED_ROLE_RIDER = "Rider"
  public static let PREFERRED_ROLE_PASSENGER = "Passenger"
  public static let PREFERRED_ROLE_BOTH = "Both"
  public static let PREFERRED_VEHICLE_BOTH = "Both"
  public static let PREFERRED_VEHICLE_CAR = "Car"
  public static let PREFERRED_VEHICLE_BIKE = "Bike"
  
  public static let supportCallValues = [Strings.From_anyone:"1",Strings.Joined_ride_partners:"2",Strings.No_calls_please:"0"]
  public static let callPreferences = [Strings.From_anyone,Strings.Joined_ride_partners,Strings.No_calls_please]
    
  public static let rideRestrictionPreferences = [Strings.org_verified_users,Strings.any_verified_users,Strings.all]
  
  public static let rideRestrictionValues = [Strings.org_verified_users:"1",Strings.any_verified_users:"2",Strings.all:"0"]
    
  static let publicDomainEmails : [String] = ["@gmail.com", "@yahoo.co.in", "@rocketmail.com", "@aol.com", "@outlook.com", "@hotmail.com", "@msn.com"]
  
  static let FLD_EMAIL = "email"
  static let FLD_COMPANY_NAME = "companyname"
  static let IMAGE_URI = "imageURI"
  static let EMAIL_FOR_COMMUNICATION = "emailforcommunication"
  static let PREFERRED_ROLE = "preferredRole"
  public override init()
  {
    
  }
  required public init? (map:Map){
    
  }

    init(user : User, emailForCommunication: String?) {
        self.userId = user.phoneNumber
        self.userName = user.userName
        self.gender = user.gender
        self.emailForCommunication = emailForCommunication
    }
  func getParamsMap() -> [String: String] {
    var params : [String: String] = [String: String]()
    params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.userId)
    params["confirmtype"] = String(self.confirmType)
    params["name"] = self.userName
    params["gender"] = self.gender
    params["companyname"] = self.companyName
    params["profession"] = self.profession
    params["imageURI"] = self.imageURI
    params["officeemail"] = self.email
    params["facebook"] = self.facebook
    params["twitter"] = self.twitter
    params["linkedin"] = self.linkedin
    params["matchCompanyConstraint"] = String(self.matchCompanyConstraint)
    params["matchGenderConstraint"] = String(self.matchGenderConstraint)
    params["emergencyContactNumber"] = self.emergencyContactNumber
    params["emailforcommunication"] = self.emailForCommunication
    params["supportCall"] = self.supportCall
    params["rideMatchPercentageAsRider"] = String(self.rideMatchPercentageAsRider)
    params["rideMatchPercentageAsPassenger"] = String(self.rideMatchPercentageAsPassenger)
    params["matchGroupCompaniesConstraint"] = String(self.matchGroupCompaniesConstraint)
    params["preferredRole"] = self.preferredRole
    params["preferredVehicle"] = self.preferredVehicle
    params["onTimeComplianceRating"] = String(self.onTimeComplianceRating)
    params["roleAtSignup"] = self.roleAtSignup
    if self.dateOfBirth != nil{
        params["dob"] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: self.dateOfBirth!))
    }
    params["interests"] = self.interests
    params["skills"] = self.skills
    return params
  }
  
  public func mapping(map: Map) {
    email <- map["email"]
    emailForCommunication <- map["emailforcommunication"]
    imageURI <- map["imageURI"]
    userId <- map["id"]
    userName <- map["userName"]
    gender <- map["gender"]
    confirmType <- map["confirmtype"]
    companyName <- map["companyname"]
    companyCode <- map["companyCode"]
    profession <- map["profession"]
    verificationStatus <- map["verificationstatus"]
    rating <- map["rating"]
    numberOfRidesAsPassenger <- map["noofridesaspassenger"]
    numberOfRidesAsRider <- map["noofridesasrider"]
    matchCompanyConstraint <- map["matchCompanyConstraint"]
    matchGenderConstraint <- map["matchGenderConstraint"]
    noOfReviews <- map["noOfReviews"]
    emergencyContactNumber <- map["emergencyContactNumber"]
    supportCall <- map["supportCall"]
    rideMatchPercentageAsRider <- map["rideMatchPercentageAsRider"]
    rideMatchPercentageAsPassenger <- map["rideMatchPercentageAsPassenger"]
    matchGroupCompaniesConstraint <- map["matchGroupCompaniesConstraint"]
    preferredRole <- map["preferredRole"]
    preferredVehicle <- map["preferredVehicle"]
    onTimeComplianceRating <- map["onTimeComplianceRating"]
    roleAtSignup <- map["defaultRole"]
    profileVerificationData <- map["profileVerificationData"]
    roundedImage <- map["roundedImage"]
    dateOfBirth <- map["dateOfBirth"]
    if dateOfBirth == nil{
        dobInString <- map["dateOfBirth"]
        dateOfBirth = AppUtil.createNSDate(dateString: dobInString)?.getTimeStamp()
    }
    interests <- map["interest"]
    skills <- map["skill"]
    rideEtiquetteCertification <- map["rideEtiquetteCertification"]
  }
  static func isCallSupportAlways(callSupport : String, enableChatAndCall: Bool) -> CommunicationType{
    if enableChatAndCall == false{
        return CommunicationType.None
    }
    if UserProfile.SUPPORT_CALL_ALWAYS == callSupport{
      return CommunicationType.Call
    }else{
      return CommunicationType.Chat
    }
  }
    static func isCallSupportAfterJoined(callSupport : String, enableChatAndCall: Bool) -> CommunicationType{
    if enableChatAndCall == false{
       return CommunicationType.None
    }
    if UserProfile.SUPPORT_CALL_ALWAYS == callSupport || UserProfile.SUPPORT_CALL_AFTER_JOINED == callSupport{
      return CommunicationType.Call
    }else{
      return CommunicationType.Chat
    }
  }
  static func getSupportCallPreference(supportCall : String?) -> String{
    for callPreference in UserProfile.supportCallValues{
      if callPreference.1 == supportCall{
        return callPreference.0
      }
    }
    return "Open"
  }
  static func getStorableSupportCallPreference(supportCall : String?) -> String{
    for callPreference in UserProfile.supportCallValues{
      if callPreference.1 == supportCall{
        return callPreference.0
      }
    }
    return "Open"
  }

    static func checkIsOfficeEmailAndConveyAccordingly(emailId : String?) -> Bool{
        if emailId == nil || emailId!.isEmpty{
            return true
        }
        for emailDomain in UserProfile.publicDomainEmails{
            if emailId!.contains(emailDomain){
                return false
            }
        }
        return true
    }

 public func copy(with zone: NSZone? = nil) -> Any  {
    let userProfile = UserProfile()
    userProfile.userId = self.userId
    userProfile.userName = self.userName
    userProfile.gender = self.gender
    userProfile.confirmType = self.confirmType
    userProfile.verificationStatus = self.verificationStatus
    userProfile.rating = self.rating
    userProfile.numberOfRidesAsPassenger = self.numberOfRidesAsPassenger
    userProfile.numberOfRidesAsRider = self.numberOfRidesAsRider
    userProfile.matchCompanyConstraint = self.matchCompanyConstraint
    userProfile.matchGenderConstraint = self.matchGenderConstraint
    userProfile.companyName = self.companyName
    userProfile.profession = self.profession
    userProfile.aboutMe = self.aboutMe
    userProfile.email = self.email
    userProfile.emailForCommunication = self.emailForCommunication
    userProfile.emergencyContactNumber = self.emergencyContactNumber
    userProfile.imageURI = self.imageURI
    userProfile.facebook = self.facebook
    userProfile.linkedin = self.linkedin
    userProfile.twitter = self.twitter
    userProfile.noOfReviews = self.noOfReviews
    userProfile.supportCall = self.supportCall
    userProfile.preferredRole = self.preferredRole
    userProfile.preferredVehicle = self.preferredVehicle
    userProfile.rideMatchPercentageAsRider = self.rideMatchPercentageAsRider
    userProfile.rideMatchPercentageAsPassenger = self.rideMatchPercentageAsPassenger
    userProfile.matchGroupCompaniesConstraint = self.matchGroupCompaniesConstraint
    userProfile.onTimeComplianceRating = self.onTimeComplianceRating
    userProfile.roleAtSignup = self.roleAtSignup
    userProfile.profileVerificationData = self.profileVerificationData
    userProfile.roundedImage = self.roundedImage
    userProfile.dateOfBirth = self.dateOfBirth
    userProfile.interests = self.interests
    userProfile.skills = self.skills
    return userProfile
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "userName: \(String(describing: self.userName))," + " gender: \( String(describing: self.gender))," + " confirmType: \(String(describing: self.confirmType))," + " verificationStatus: \(String(describing: self.verificationStatus)),"
            + " rating: \(String(describing: self.rating))," + "numberOfRidesAsPassenger: \(String(describing: self.numberOfRidesAsPassenger))," + "numberOfRidesAsRider:\(String(describing: self.numberOfRidesAsRider))," + "matchCompanyConstraint:\(String(describing: self.matchCompanyConstraint))," + "matchGenderConstraint:\(String(describing: self.matchGenderConstraint))," + "matchGroupCompaniesConstraint:\(String(describing: self.matchGroupCompaniesConstraint))," + "companyName: \(String(describing: self.companyName))," + "companyCode: \( String(describing: self.companyCode))," + "profession: \(String(describing: self.profession))," + "aboutMe: \( String(describing: self.aboutMe))," + "email: \(String(describing: self.email))," + "emailForCommunication: \( String(describing: self.emailForCommunication))," + "emailForCommunication:\(String(describing: self.emailForCommunication))," + "emergencyContactNumber:\(String(describing: self.emergencyContactNumber))," + "imageURI: \(String(describing: self.imageURI))," + "facebook:\(String(describing: self.facebook))," + "linkedin: \(String(describing: self.linkedin))," + "twitter\(String(describing: self.twitter))," + "noOfReviews: \(String(describing: self.noOfReviews))," + "supportCall: \( String(describing: self.supportCall))," + "preferredVehicle: \( String(describing: self.preferredVehicle))," + "preferredRole: \(String(describing: self.preferredRole))," + "onTimeComplianceRating: \( String(describing: self.onTimeComplianceRating))," + "roleAtSignup: \(String(describing: self.roleAtSignup))," + "roundedImage: \( String(describing: self.roundedImage))," + "interests: \(String(describing: interests))," + "skills:\(String(describing: skills))"
    }
}
