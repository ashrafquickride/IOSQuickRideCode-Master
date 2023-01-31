//
//  TaxiEmergencyViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import Alamofire

class TaxiEmergencyViewModel{
    
    var taxiPassengerRide: TaxiRidePassenger?
    var isEmergencyAlreadyStarted = false
    var driverName: String?
    var driverContactNo: String?
    var noOfIntimations = 0
    var timerTask : Timer?
    var timeInterval : TimeInterval?
    var messageUrl : String?
    init() {}
    
    init(isEmergencyAlreadyStarted: Bool,taxiPassengerRide: TaxiRidePassenger?,driverName: String,driverContactNo: String) {
        self.isEmergencyAlreadyStarted = isEmergencyAlreadyStarted
        self.taxiPassengerRide = taxiPassengerRide
        self.driverName = driverName
        self.driverContactNo = driverContactNo
    }
    func prepareRideTrackCoreURL(taxiGroupId: String,handler : @escaping receiveURL){
        AppDelegate.getAppDelegate().log.debug("prepareRideTrackCoreURL()")
        let pwaPath = AppConfiguration.pwaServerUrl + AppConfiguration.PWA_serverPort
        let longUrl = pwaPath + "/#/taxi-emergency?taxiGroupId=" + taxiGroupId
        var googleAPIConfiguration = ConfigurationCache.getInstance()?.getGoogleAPIConfiguration()
        if googleAPIConfiguration != nil{
            googleAPIConfiguration = GoogleAPIConfiguration()
        }
        let shortDynamicLinkParams = ShortDynamicLinkParams()
        let dynamicLinkInfo = DynamicLinkInfo()
        dynamicLinkInfo.dynamicLinkDomain = googleAPIConfiguration!.googleDynamicLinksDomain
        dynamicLinkInfo.link = longUrl
        shortDynamicLinkParams.dynamicLinkInfo = dynamicLinkInfo
        
        var request = URLRequest(url: URL(string: "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key="+googleAPIConfiguration!.googleDynamicLinksWebApiKey)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let pjson = shortDynamicLinkParams.toJSONString(prettyPrint: false)
        let data = (pjson?.data(using: .utf8))! as Data
        var params = [String : String]()
        params["long_url"] = longUrl
        params["data"] = pjson
        request.httpBody = data
        Alamofire .request(request).responseJSON { (response) in
            if (response.result.error != nil) {
                handler(longUrl)
            }else{
                if let result = Mapper<ShortDynamicLinkResult>().map(JSONObject: response.result.value){
                    if let error = result.error{
                        APIFailureHandler.validateResponseAndReportFailure(errorCode: error.status, errorMessage: error.message, apiKey: googleAPIConfiguration!.googleDynamicLinksWebApiKey, apiName: APIFailureReport.DYNAMIC_LINKS_API, params: params)
                    }
                    if result.shortLink != nil{
                        handler(result.shortLink!)
                    }else{
                        handler(longUrl)
                    }
                }else{
                    handler(longUrl)
                }
            }
        }
    }
    
    
    func initiateEmeregency(url: String,complition: @escaping(_ result: Bool)->()){
        TaxiPoolRestClient.initiateTaxiEmergency(type: "Taxi", userId: UserDataCache.getInstance()?.userId ?? "", payload: getPayLoad(),rideTrackUrl: url, acknowledgedBy: "Support team") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                complition(true)
            }else{
                complition(false)
            }
        }
    }
    private func getPayLoad() -> String{
        let payload = EmergencyPayload(userId: StringUtils.getStringFromDouble(decimalNumber: taxiPassengerRide?.userId), userName: taxiPassengerRide?.userName ?? "", mobileNo: SharedPreferenceHelper.getLoggedInUserContactNo(), taxiGroupId: StringUtils.getStringFromDouble(decimalNumber: taxiPassengerRide?.taxiGroupId), taxiType: taxiPassengerRide?.taxiType ?? "", driverName: driverName ?? "", driverContactNo: driverContactNo ?? "")
        return payload.toJSONString() ?? ""
    }
    
    func getMessageForEmergency(contactNo: String,url: String) -> String{
        guard let userName = UserDataCache.getInstance()?.userProfile?.userName,let contactNo = SharedPreferenceHelper.getLoggedInUserContactNo() else { return "" }
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A) ?? ""
        let message = userName + " " + contactNo
        return message + " is in emergency at " + date + ". You can track the ride here " + url
    }
}
//PAyLoad
struct EmergencyPayload: Mappable{
    
    var userId: String?
    var userName: String?
    var mobileNo: String?
    var taxiGroupId: String?
    var taxiType: String?
    var driverName: String?
    var driverContactNo: String?
    var riderId: String?
    var rideType: String?
    var riderName: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        userName <- map["userName"]
        mobileNo <- map["mobileNo"]
        taxiGroupId <- map["taxiGroupId"]
        taxiType <- map["taxiType"]
        driverName <- map["driverName"]
        driverContactNo <- map["driverContactNo"]
        riderId <- map["RiderUserId"]
        rideType <- map["rideType"]
        riderName <- map["RiderName"]
    }
    
    init(userId: String?,userName: String?,mobileNo: String?,taxiGroupId: String?,taxiType: String?,driverName: String?,driverContactNo: String?) {
        self.userId = userId
        self.userName = userName
        self.mobileNo = mobileNo
        self.taxiGroupId = taxiGroupId
        self.taxiType = taxiType
        self.driverName = driverName
        self.driverContactNo = driverContactNo
    }
    
    init(userId: String?,userName: String?,mobileNo: String?,riderId: String?,rideType: String?,riderName: String?) {
               self.userId = userId
               self.userName = userName
               self.mobileNo = mobileNo
               self.riderId = riderId
               self.rideType = rideType
               self.riderName = riderName
           }
}
