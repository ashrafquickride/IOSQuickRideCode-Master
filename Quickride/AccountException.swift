//
//  AccountException.swift
//  Quickride
//
//  Created by QuickRideMac on 1/7/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class AccountException
{
    static let ACCOUNT_ERROR_STARTER : Int = 1200
    static let INSUFFICIENT_FUNDS_IN_ACCOUNT : Int = 1201
    static let ACCOUNT_DOESNOT_EXIST : Int = 1202
    static let ACCOUNT_CREATION_FAILED : Int = 1203
    static let ACCOUNT_READ_FAILED : Int = 1204
    static let ACCOUNT_UPDATE_FAILED : Int = 1205
    static let ACCOUNT_TRANSACTION_READING_FAILED : Int = 1206
    static let ACCOUNT_TRANSACTION_CREATION_FAILED : Int = 1207
    static let ENCASHMENT_EXCEED_BALANCE : Int = 1209
    static let INSUFFICIENT_FUNDS_TO_ENCASH : Int = 1211
    static let UNSUPPORTED_TRANSACTION_TYPE : Int = 1212
    static let INVALID_TRANSACTION_VALUE : Int = 1213
    static let ENCASH_REQUEST_CREATION_FAILED : Int = 1214
    static let ENCASH_REQUEST_UPDATE_FAILED : Int = 1215
    static let ENCASH_GET_PENDING_REQUEST_FAILED : Int = 1216
    static let ENCASH_GET_ALL_REQUEST_FAILED : Int = 1217
    static let ENCASH_GET_PROCESSED_REQUEST_FAILED : Int = 1218
    static let ORDER_ID_CANNOT_BE_NULL : Int = 1219
    static let USER_CAN_DO_ONE_TRANSFER_PER_DAY_ERROR : Int = 1220
    static let REFUND_NOT_ALLOWED_FOR_THIS : Int = 1221
    static let REFUND_ALREADY_DONE_FOR_TRANSACTION_ERROR : Int = 1222
    static let INVALID_INPUT_PARAMS : Int = 1223
    static let TMW_REDEEM_REQUEST_FAILED_DUE_NO_WALLET_ACCOUNT = 4609
    static let AMAZON_PAY_LINK_AGAIN_ERROR = 1241
}
