//
 //  HttpUtils.swift
 //  Quickride
 //
 //  Created by KNM Rao on 18/09/15.
 //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
 //
 
 import Foundation
 import Alamofire
 import ObjectMapper

 class HttpUtils {
    
    static let RESPONSE_SUCCESS = "SUCCESS"
    static let RESPONSE_FAILURE = "FAILURE"
    static let RESULT_DATA = "resultData"
    static let RESULT = "result"
    static let Authorization = "Authorization"
    static let Secure = "Secure"
    static let UnSecure = "UnSecure"
    static let utils = HttpUtils()
    var alamoFireSSLManager : SessionManager?
    var alamoFireManager : SessionManager?
    static let REFRESH_SECURITY_TOKEN_PATH = "/QRUser/refreshToken"
    static let REFRESH_AUTH_TOKEN_USING_CONTACT_NO_SERVICE_PATH = "/QRUser/refreshToken/contactNo"
    typealias ErrorResponseCompletionHandler = (_ error: NSError?) -> Void
    
    static func putRequestWithBody(url: String, targetViewController: UIViewController?, handler: @escaping UserRestClient.responseJSONCompletionHandler, body : Dictionary<String, String>){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
        if isNetworkAvailable
        {
            utils.createAlamoFireManager(url: url)
            if url.contains("https")
            {
                utils.alamoFireSSLManager!.request(url, method: .put, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { response -> Void in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .put, reqSecureType: UnSecure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
                
            }
            else{
                utils.alamoFireManager!.request(url, method: .put, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { response -> Void in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .put, reqSecureType: UnSecure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
                
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    
    static func postRequestWithBody(url: String, targetViewController: UIViewController?, handler: @escaping UserRestClient.responseJSONCompletionHandler, body : Dictionary<String, String>){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            
            if url.contains("https"){
                utils.alamoFireSSLManager!.request(url, method: .post, parameters: body, encoding: URLEncoding.httpBody , headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .post, reqSecureType: UnSecure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
            }
            else{
                utils.alamoFireManager!.request(url, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { (reponse) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: reponse, url: url, params: body, requestType: .post, reqSecureType: UnSecure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
                
                
            }
        }
            
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
        
    }
    
    
    
    public static func getJSONRequestWithBody(url: String, targetViewController: UIViewController?,params : Dictionary<String, String>, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            if url.contains("https"){
                utils.alamoFireSSLManager!.request(url, method: .get, parameters: params, encoding: URLEncoding.methodDependent, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: params, requestType: .get, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
                
            }else{
                utils.alamoFireManager!.request(url, method: .get, parameters: params, encoding: URLEncoding.methodDependent, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: params, requestType: .get, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
                
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    
    
    static func getJSONRequestWithBodyUnSecure(url: String, targetViewController: UIViewController?,params : Dictionary<String, String>, completionHandler: @escaping UserRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.methodDependent, headers: authHeader).responseJSON(completionHandler: { (response) in
                AppDelegate.getAppDelegate().log.debug("Value: \(response.result)")
                checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: params, requestType: .get, reqSecureType: UnSecure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: completionHandler)
         })
        }
        else {
            completionHandler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    
    
    static func postJSONRequestWithBody(url: String, targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler,body : Dictionary<String, String>){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            if url.contains("https"){
                utils.alamoFireSSLManager!.request(url, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .post, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
            }
            else{
                utils.alamoFireManager!.request(url, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .post, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                })
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    static func putJSONRequestWithBody(url: String, targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler,body : Dictionary<String, String>){
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            if url.contains("https")
            {
                utils.alamoFireSSLManager!.request(url, method: .put, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .put, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                    
                })
            }else{
                utils.alamoFireManager!.request(url, method: .put, parameters: body, encoding: URLEncoding.httpBody, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: body, requestType: .put, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                 })
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
        
    }
    
    
    
    static func deleteJSONRequest(url: String,params : [String: String], targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("")
        var authHeader = [String: String]()
        if let token = SharedPreferenceHelper.getJWTAuthenticationToken(){
            authHeader[Authorization] = token
        }
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            
            if url.contains("https"){
                HttpUtils.utils.alamoFireSSLManager!.request(url, method: .delete, parameters: params, encoding: URLEncoding.methodDependent, headers: authHeader).responseJSON(completionHandler: { (response) in
                    
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: params, requestType: .delete, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                    
                })
            }else{
                HttpUtils.utils.alamoFireManager!.request(url, method: .delete, parameters: params, encoding: URLEncoding.methodDependent, headers: authHeader).responseJSON(completionHandler: { (response) in
                    checkResponseErrorTypeAndRefAuthTokenIfExpired(response: response, url: url, params: params, requestType: .delete, reqSecureType: Secure, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: handler)
                    
                })
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    
    static func performJSONRequestWithBodyAndStoreAuthToken(url: String,params : [String: String],requestType :HTTPMethod,encodingType : ParameterEncoding,targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("")
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            
            if url.contains("https"){
                HttpUtils.utils.alamoFireSSLManager!.request(url, method: requestType, parameters: params, encoding: encodingType, headers: nil).responseJSON(completionHandler: { (response) in
                    storeJWTAuthHeaderFromResponse(response: response)
                    handleResponse(url: url,response: response, completionHandler: handler)
                 })
            }else{
                HttpUtils.utils.alamoFireManager!.request(url, method: requestType, parameters: params, encoding: encodingType, headers: nil).responseJSON(completionHandler: { (response) in
                    storeJWTAuthHeaderFromResponse(response: response)
                    handleResponse(url: url, response: response, completionHandler: handler)
                  })
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }

     
     static func storeJWTAuthHeaderFromResponse(response : DataResponse<Any>){
         if let headers = response.response?.allHeaderFields as? [String: String]{
             if headers["Authorization"] != nil{
                 SharedPreferenceHelper.storeJWTAuthenticationToken(value: headers["Authorization"]!)
             }
         }
     }
     

     
    static func performRestCallToOtherServer(url: String,params : [String: String],requestType :HTTPMethod, targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        QRReachability.isInternetAvailable { (isNetworkAvailable) in
            if isNetworkAvailable
            {
            utils.createAlamoFireManager(url: url)
            if url.contains("https"){
                utils.alamoFireSSLManager!.request(url, method: requestType, parameters: params, encoding: URLEncoding.methodDependent, headers: nil).responseJSON(completionHandler: { (response) in
                   handleResponse(url: url, response: response, completionHandler: handler)
                })
            }else{
                utils.alamoFireManager!.request(url, method: requestType, parameters: params, encoding: URLEncoding.methodDependent, headers: nil).responseJSON(completionHandler: { (response) in
                    handleResponse(url: url, response: response, completionHandler: handler)
                })
            }
        }
        else {
            handler(nil, QuickRideErrors.NetworkConnectionNotAvailableError)
        }
        }
    }
    
    func createAlamoFireManager(url : String){
        if url.range(of: "https") != nil{
            if (HttpUtils.utils.alamoFireSSLManager == nil) {
                let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
                    certificates: ServerTrustPolicy.certificates(),
                    validateCertificateChain: true,
                    validateHost: true)
                
                var serverTrustPolicies = [String : ServerTrustPolicy] ()
                serverTrustPolicies[AppConfiguration.RM_SERVER_DOMAIN_NAME] = serverTrustPolicy
                serverTrustPolicies[AppConfiguration.RE_SERVER_DOMAIN_NAME] = serverTrustPolicy
                serverTrustPolicies[AppConfiguration.AE_SERVER_DOMAIN_NAME] = serverTrustPolicy
                serverTrustPolicies[AppConfiguration.ROUTE_MATCH_SERVER_DOMAIN_NAME] = serverTrustPolicy
                serverTrustPolicies[AppConfiguration.ROUTES_SERVER_DOMAIN_NAME] = serverTrustPolicy
                
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = AppConfiguration.API_TIME_OUT_INTERVAL
                configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
                HttpUtils.utils.alamoFireSSLManager =  SessionManager(configuration: configuration,serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
            }
            
        }
        else{
            if HttpUtils.utils.alamoFireManager == nil{
                HttpUtils.utils.alamoFireManager = SessionManager()
            }
        }
    }
    static func handleResponse(url: String?,response : DataResponse<Any>,handler: @escaping UserRestClient.responseStringCompletionHandler)->Void{
        AppDelegate.getAppDelegate().log.debug("url: \(url! .suffix(20))")
        AppDelegate.getAppDelegate().log.debug("Value: \(response.result)")
        if (response.result.error != nil) {
            checkRestResponseErrorAndGetUserUnderstandableError(error: response.result.error! as NSError, completionHandler: { (error) in
                handler(nil, error)
            })
            return
        }
        handler(response.result.value as? String, response.result.error as NSError?)
    }
     static func handleResponse(url: String?,response : DataResponse<Any>,completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler)->Void{
         AppDelegate.getAppDelegate().log.debug("url: \(url!.suffix(20))")
        #if DEBUG
        AppDelegate.getAppDelegate().log.debug("Value: \(response);")
        #else
        AppDelegate.getAppDelegate().log.debug("Value: \(response.result);")
       
        #endif
        if (response.result.error != nil) {
            checkRestResponseErrorAndGetUserUnderstandableError(error: response.result.error! as NSError, completionHandler: { (error) in
                completionHandler(nil, error)
            })
            return
        }
        completionHandler(response.result.value as? NSDictionary, response.result.error as NSError?)
    }
    
    static func checkRestResponseErrorAndGetUserUnderstandableError(error : NSError,completionHandler : @escaping ErrorResponseCompletionHandler)
    {
        var userInfo = error.userInfo
        
        userInfo.removeValue(forKey: NSURLErrorFailingURLErrorKey)
        userInfo[NSURLErrorFailingURLStringErrorKey] = nil
        AppDelegate.getAppDelegate().log.error("Error code :\(error.code) , UserInfo : \(userInfo)")
        
        if error.code == QuickRideErrors.NetworkConnectionSlow{
          completionHandler(QuickRideErrors.NetworkConnectionSlowError)
        }else{
            QRReachability.isInternetAvailable { (isConnectedToNetwork) in
                if !isConnectedToNetwork{
                    completionHandler( QuickRideErrors.NetworkConnectionNotAvailableError)
                    
                }else{
                    completionHandler(QuickRideErrors.RequestTimedOutError)
                }
            }
        }
      
    }
    static func refreshAuthToken(url: String,parameters : [String: String],reqType : HTTPMethod,encodingType : ParameterEncoding,reqSecureType : String,viewController: UIViewController?, completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        let userId = SharedPreferenceHelper.getLoggedInUserId()
        let userPwd = SharedPreferenceHelper.getLoggedInUserPassword()
        let contactNo = SharedPreferenceHelper.getLoggedInUserContactNo()
        let countryCode = SharedPreferenceHelper.getLoggedInUserCountryCode()
        
        
        if (userId != nil && !userId!.isEmpty) && (userPwd != nil && !userPwd!.isEmpty){
            var params = [String : String]()
            params[User.FLD_USER_ID] = userId
            params[User.FLD_PWD] = userPwd
            params[User.CLIENT_DEVICE_TYPE] = Strings.ios
            let refreshTokenUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REFRESH_SECURITY_TOKEN_PATH
            performJSONRequestWithBodyAndStoreAuthToken(url: refreshTokenUrl, params: params, requestType: .get, encodingType: encodingType, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    resumeRestCallBasedOnReqTypeAndReqSecureType(url: url, parameters: parameters, reqType: reqType, reqSecureType: reqSecureType, viewController: viewController, completionHandler: completionHandler)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
                
            })
        }
        else if (contactNo != nil && !contactNo!.isEmpty) && (countryCode != nil && !countryCode!.isEmpty){
            var params = [String : String]()
            params[User.CONTACT_NO] = contactNo
            params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
            params[User.FLD_COUNTRY_CODE] = countryCode
            params[User.CLIENT_DEVICE_TYPE] = Strings.ios
            let refreshTokenUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REFRESH_AUTH_TOKEN_USING_CONTACT_NO_SERVICE_PATH
            performJSONRequestWithBodyAndStoreAuthToken(url: refreshTokenUrl, params: params, requestType: .get, encodingType: encodingType, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    resumeRestCallBasedOnReqTypeAndReqSecureType(url: url, parameters: parameters, reqType: reqType, reqSecureType: reqSecureType, viewController: viewController, completionHandler: completionHandler)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
                
            })
        }
    }
  
    static func checkResponseErrorTypeAndRefAuthTokenIfExpired(response : DataResponse<Any>,url: String,params : [String: String],requestType : HTTPMethod,reqSecureType : String,encodingType : ParameterEncoding,targetViewController: UIViewController?, handler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        
        let isTokenExpiredError = checkAuthTokenStatus(response: response)
        
        if isTokenExpiredError{
            refreshAuthToken(url: url,parameters : params,reqType : requestType, encodingType: encodingType,reqSecureType : reqSecureType,viewController: targetViewController, completionHandler: handler)
        }else{
            handleResponse(url: url,response: response, completionHandler: handler)
        }

  }
    
    static func resumeRestCallBasedOnReqTypeAndReqSecureType(url: String,parameters : [String: String],reqType : HTTPMethod,reqSecureType : String,viewController: UIViewController?, completionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler){
        if reqType == .get{
            if reqSecureType == Secure{
                getJSONRequestWithBody(url: url, targetViewController: viewController, params: parameters, handler: completionHandler)
            }else{
                getJSONRequestWithBodyUnSecure(url: url, targetViewController: viewController, params: parameters, completionHandler: completionHandler)
            }
         }else if reqType == .put{
            putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: parameters)
          
        }else if reqType == .post{
            postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: parameters)
        }else{
            deleteJSONRequest(url: url, params: parameters, targetViewController: viewController, handler: completionHandler)
        }
    }
    
    static func checkAuthTokenStatus(response : DataResponse<Any>) -> Bool{
       let responseObject = response.result.value as? NSDictionary
        if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
            let responseError = Mapper<ResponseError>().map(JSONObject:  responseObject!["resultData"])
            if responseError?.errorCode == ServerErrorCodes.TOKEN_EXPIRED_ERROR || responseError?.errorCode == ServerErrorCodes.TOKEN_MISSING_ERROR{
              return true
            }else{
              return false
            }
        }else{
            return false
        }
    }
    static func refreshAuthToken( viewController : UIViewController,completionHandler: @escaping (_ jwtToken : String)-> Void){
        let userId = SharedPreferenceHelper.getLoggedInUserId()
        let userPwd = SharedPreferenceHelper.getLoggedInUserPassword()
        let contactNo = SharedPreferenceHelper.getLoggedInUserContactNo()
        let countryCode = SharedPreferenceHelper.getLoggedInUserCountryCode()
        
        
        if (userId != nil && !userId!.isEmpty) && (userPwd != nil && !userPwd!.isEmpty){
            var params = [String : String]()
            params[User.FLD_USER_ID] = userId
            params[User.FLD_PWD] = userPwd
            params[User.CLIENT_DEVICE_TYPE] = Strings.ios
            let refreshTokenUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REFRESH_SECURITY_TOKEN_PATH
            performJSONRequestWithBodyAndStoreAuthToken(url: refreshTokenUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let jwtToken = SharedPreferenceHelper.getJWTAuthenticationToken() {
                        completionHandler(jwtToken)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
                
            })
        }
        else if (contactNo != nil && !contactNo!.isEmpty) && (countryCode != nil && !countryCode!.isEmpty){
            var params = [String : String]()
            params[User.CONTACT_NO] = contactNo
            params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
            params[User.FLD_COUNTRY_CODE] = countryCode
            params[User.CLIENT_DEVICE_TYPE] = Strings.ios
            let refreshTokenUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REFRESH_AUTH_TOKEN_USING_CONTACT_NO_SERVICE_PATH
            performJSONRequestWithBodyAndStoreAuthToken(url: refreshTokenUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let jwtToken = SharedPreferenceHelper.getJWTAuthenticationToken() {
                        completionHandler(jwtToken)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
                
            })
        }
    }
}
