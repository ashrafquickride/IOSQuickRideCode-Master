//
//  ServerErrorCodes.swift
//  Quickride
//
//  Created by KNM Rao on 12/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ServerErrorCodes {
  static let USER_ALREADY_REGISTERED_ERROR : Int = 1002
  static let USER_NOT_REGISTERED_ERROR : Int = 1004
  static let USER_NOT_ACTIVATED_ERROR : Int = 1007
  static let VERIFICATION_CODE_INCORRECT_ERROR : Int = 1008
  static let VERIFICATION_OTP_INCORRECT_ERROR : Int = 1256
  static let USER_NOT_SET_COMPANY_NAME_OFFICIAL_EMAIL_PROPERLY_ERROR : Int = 1157
  static let EMAIL_ALREADY_EXISTS_ERROR : Int = 1156
  static let USER_VERIFIACTION_CODE_NOT_CORRECT_ERROR : Int = 1008
  static let USER_VERIFYING_FAILED_ERROR : Int = 1104
  static let ACCOUNT_SUSPENDED_BY_THE_USER : Int = 1164
  static let USER_SUBSCRIPTION_REQUIRED_ERROR = 1176
  static let TOKEN_EXPIRED_ERROR = 11103
  static let TOKEN_MISSING_ERROR = 11104
  static let ACCOUNT_SUSPENDED_FOR_ETIQUETTE_VIOLATION : Int = 1244
  static let NOT_ELIGIBLE_FOR_LAZY_PAY_ERROR = 4051
  static let UNVERIFIED_USER_REDEEM_LIMITATION_ERROR = 4631
}
