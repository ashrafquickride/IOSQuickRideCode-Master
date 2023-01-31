//
//  AmazonAuthKey.swift
//  Quickride
//
//  Created by Admin on 26/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CommonCrypto

class AmazonAuthKey:NSObject{

    
    var codeVerifier:String!
    var codeChallenge:String!
    static var LENGTH = 80
    static var sharedInstance : AmazonAuthKey?
    
    static func getInstance() -> AmazonAuthKey{
        if sharedInstance == nil{
            let verifier = generateRandomBytes()
            let challenge = sha256Hash(value: verifier)
            self.sharedInstance = AmazonAuthKey(codeVerifier: verifier!, codeChallenge:
                challenge)
            return sharedInstance!
        }
        return sharedInstance!
    }
    
    required init(codeVerifier: String?, codeChallenge: String?) {
        super.init()
        self.codeChallenge = codeChallenge
        self.codeVerifier = codeVerifier
    }
    //to generate codeverifier
    class func generateRandomBytes() -> String? {
        var keyData = Data(count: LENGTH)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, LENGTH, mutableBytes)
        }
        if result == errSecSuccess {
            return self.urlSafeBase64encode(keyData)
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    //to get code challenge for supplied verifier
    class func sha256Hash(value: String?) -> String? {
        let data:Data = (value?.data(using: .utf8))!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return self.urlSafeBase64encode(Data(bytes: hash))
    }
 
    class func urlSafeBase64encode(_ data: Data?) -> String? {
        var base64String = data?.base64EncodedString(options: [])
        base64String = base64String?.replacingOccurrences(of: "/", with: "_")
        base64String = base64String?.replacingOccurrences(of: "+", with: "-")
        while (base64String?.hasSuffix("="))! {
            base64String = (base64String as NSString?)?.substring(to:
                (base64String?.count ?? 0) - 1)
        }
        return base64String
    }
}
