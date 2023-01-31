//
//  QuickrideTests.swift
//  QuickrideTests
//
//  Created by KNM Rao on 17/09/15.
//  Copyright (c) 2015 iDisha. All rights reserved.
//

import UIKit
import XCTest
@testable import Quickride
class QuickrideTests: XCTestCase {
    
    var userDetailsTVC : UserDetailsTableViewCell!
    override func setUp() {
        super.setUp()
        userDetailsTVC = .init(frame: CGRect.zero)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        static let TRANSACTION_WALLET_TYPE_INAPP =
        static let TRANSACTION_WALLET_TYPE_PAYTM = ""
        static let TRANSACTION_WALLET_TYPE_TMW = "TMW"
        static let TRANSACTION_WALLET_TYPE_SIMPL = "SIMPL"
        static let TRANSACTION_WALLET_TYPE_LAZYPAY = "LAZYPAY"
        static let TRANSACTION_WALLET_TYPE_AMAZON_PAY = "AMAZONPAY"
        static let TRANSACTION_WALLET_TYPE_MOBIQWIK = "MOBIKWIK"
        static let TRANSACTION_WALLET_TYPE_UPI = "UPI"
        static let TRANSACTION_WALLET_TYPE_FREECHARGE = "FREECHARGE"
        static let TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE = "UPI_GPAY_IPHONE"
        static let TRANSACTION_WALLET_TYPE_UPI_GPAY_ANDROID = "UPI_GPAY"
        static let TRANSACTION_WALLET_TYPE_UPI_PHONEPE_ANDROID = "UPI_PHONEPE"

        let result = userDetailsTVC.formatPaymentTypeString(paymentType: "PAYTM,INAPP,FREECHARGE")
        XCTAss
        XCTAssert(result == "Paid via PAYTM, FREECHARGE and Quickride wallet", "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
