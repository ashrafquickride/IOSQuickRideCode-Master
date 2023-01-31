//
//  ProfileVerificationRestClient.swift
//  Quickride
//
//  Created by Vinutha on 17/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Alamofire

class ProfileVerificationRestClient {
    
    //MARK: Verification through Endosement and company id card
    static let GET_ENDORSABLE_USERS_PATH = "/QREndorsement/endorsableUsers"//GET to show all endorsable contact
    static let REQUEST_FOR_ENDORSEMENT_PATH = "/QREndorsement/request"//PUT
    static let ACCEPT_ENDORSEMENT_PATH = "/QREndorsement/accept" //PUT
    static let REJECT_ENDORSEMENT_PATH = "/QREndorsement/reject" //PUT
    static let GET_ENDORSEMENT_DATA_PATH = "/QREndorsement/endorsementData/all" //GET to show endorsed data(after sending request)
    static let INITIATE_COMPANY_ID_VERIFICATION_PATH = "/companyIdVerification/initiate" //PUT
    static let GET_INITIATE_COMPANY_ID_VERIFICATION_PATH = "/companyIdVerification" //GET
    static let COMPANY_ID_REVERIFICATION_SENT_PATH = "/companyIdVerification/reVerificationSent" //GET
    static let GOVT_ID_VERIFICATION_PATH = "/QRUserVerification/link/governmentId" //POST
    
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    static func getAllEndorsableUsers(userId: String, contactList: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[User.CONTACT_NO] = contactList
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ENDORSABLE_USERS_PATH
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func requestForEndorsement(userId: String, endorsableUserObject: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[EndorsableUser.FLD_ENDORSABLE_USER] = endorsableUserObject
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REQUEST_FOR_ENDORSEMENT_PATH
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
    static func acceptEndorsementRequest(userId: String, requestorUserId: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[EndorsableUser.FLD_REQUESTOR_USER_ID] = requestorUserId
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + ACCEPT_ENDORSEMENT_PATH
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
    static func rejectEndorsementRequest(userId: String, requestorUserId: String, rejectReason: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[EndorsableUser.FLD_REQUESTOR_USER_ID] = requestorUserId
        params[EndorsableUser.FLD_REJECT_REASON] = requestorUserId
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REJECT_ENDORSEMENT_PATH
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
    static func getEndorsementData(userId: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ENDORSEMENT_DATA_PATH
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func initiateCompanyIdVerification(userId: String, frontSideImageUrl: String, backSideImageUrl: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[CompanyIdVerificationData.FLD_FRONT_SIDE_IMAGE_URL] = frontSideImageUrl
        params[CompanyIdVerificationData.FLD_BACK_SIDE_IMAGE_URL] = backSideImageUrl
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + INITIATE_COMPANY_ID_VERIFICATION_PATH
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
    static func getInitiateCompanyIdVerification(userId: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_INITIATE_COMPANY_ID_VERIFICATION_PATH
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func isCompanyIdReverificationSent(userId: String, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + COMPANY_ID_REVERIFICATION_SENT_PATH
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: handler)
    }
    
    static func storeGovtIDVerificationDetails(personalIdDetail: PersonalIdDetail, documentImageUrl: String?, handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = QRSessionManager.getInstance()?.getUserId()
        params[PersonalIdDetail.FLD_VERIFICATION_PROVIDER] = PersonalIdDetail.VERIFICATION_PROVIDER_NAME
        params[PersonalIdDetail.FLD_DOCUMENT_NO] = personalIdDetail.documentId
        params[PersonalIdDetail.FLD_DOCUMENT_TYPE] = personalIdDetail.documentType
        params[PersonalIdDetail.FLD_ADDRESS] = personalIdDetail.address
        if personalIdDetail.dob != nil && !personalIdDetail.dob!.isEmpty {
            if let dobDateString = DateUtils.getDateStringFromString(date: personalIdDetail.dob, requiredFormat: DateUtils.DATE_FORMAT_DD_MM_YYYY, currentFormat: DateUtils.DATE_FORMAT_D_M_YYYY) {
                params[PersonalIdDetail.FLD_DOB] = dobDateString
            }
        }
        if let dob = personalIdDetail.dateOfIssue, !dob.isEmpty {
            params[PersonalIdDetail.FLD_ISSUEDATE] = DateUtils.getDateStringFromString(date: dob, requiredFormat: DateUtils.DATE_FORMAT_DD_MM_YYYY, currentFormat: DateUtils.DATE_FORMAT_D_M_YYYY)
        }
        params[PersonalIdDetail.FLD_NAME] = personalIdDetail.name
        params[PersonalIdDetail.FLD_GENDER] = personalIdDetail.gender
        params[PersonalIdDetail.FLD_DOCUMENT_IMAGE] = documentImageUrl
        params[PersonalIdDetail.FLD_AGE] = personalIdDetail.age
        params[PersonalIdDetail.FLD_FATHER_NAME] = personalIdDetail.fatherName
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GOVT_ID_VERIFICATION_PATH
        
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil, handler: handler, body: params)
    }
    
}
