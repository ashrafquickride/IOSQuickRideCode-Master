//
//  PersonalIdDetail.swift
//  Quickride
//
//  Created by Vinutha on 14/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PersonalIdDetail: NSObject {
    
    var documentId: String?
    var documentType: String?
    var name: String?
    var fatherName: String?
    var gender: String?
    var dob: String?
    var address: String?
    var faceImageUri: String?
    var frontSideDocImageUri: String?
    var backSideDocImageUri: String?
    var dateOfIssue: String?
    var age: String?
    
    static let FLD_VERIFICATION_PROVIDER = "verificationProvider"
    static let FLD_DOCUMENT_NO = "documentNumber"
    static let FLD_DOCUMENT_TYPE = "documentType"
    static let FLD_ADDRESS = "address"
    static let FLD_DOB = "dob"
    static let FLD_ISSUEDATE = "issuedDate"
    static let FLD_NAME = "name"
    static let FLD_GENDER = "gender"
    static let FLD_DOCUMENT_IMAGE = "documentImage"
    static let FLD_AGE = "age"
    static let FLD_FATHER_NAME = "fatherName"
    
    static let ADHAR = "Aadhar"
    static let DL = "DL"
    static let PAN = "PAN"
    static let VOTER_ID = "VOTER ID"
    
    static let VERIFICATION_PROVIDER_NAME = "Hyper Verge"
    
    override init() { }
    
    init(documentId: String?, documentType: String?, name: String?, fatherName: String?, gender: String?, dob: String?, address: String?, faceImageUri: String?, frontSideDocImageUri: String?, backSideDocImageUri: String?, dateOfIssue: String?, age: String?) {
        self.documentId = documentId
        self.documentType = documentType
        self.name = name
        self.fatherName = fatherName
        self.gender = gender
        self.dob = dob
        self.address = address
        self.faceImageUri = faceImageUri
        self.frontSideDocImageUri = frontSideDocImageUri
        self.backSideDocImageUri = backSideDocImageUri
        self.dateOfIssue = dateOfIssue
        self.age = age
    }
}
