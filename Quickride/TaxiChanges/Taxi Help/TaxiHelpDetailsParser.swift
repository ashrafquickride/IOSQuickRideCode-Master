//
//  TaxiHelpDetailsParser.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiCustomerSupportHandler = (_ taxiCustomerSupport : TaxiCustomerSupport?) -> Void

class TaxiHelpDetailsParser {
    
    static var instance: TaxiHelpDetailsParser?
    static var url = "https://objectstore.e2enetworks.net/qr-images1/TaxiHelpcopy.json"
    
    static func getInstance() -> TaxiHelpDetailsParser{
        if instance == nil{
            instance = TaxiHelpDetailsParser()
        }
        return instance!
    }
    
    func getTaxiHelpFaqs(handler: @escaping taxiCustomerSupportHandler){
        QuickRideProgressSpinner.startSpinner()
        HttpUtils.performRestCallToOtherServer(url: TaxiHelpDetailsParser.url, params:  [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                let customerSupportBaseElement = Mapper<TaxiCustomerSupport>().map(JSONObject: responseObject)
                handler(customerSupportBaseElement)
            }else{
                return handler(self.readFromLocal())
            }
        })
    }
    
    func readFromLocal() -> TaxiCustomerSupport?{
        let file = Bundle.main.url(forResource: "taxiHelp", withExtension: "json")
        if file == nil{
            return nil
        }
        do {
            let data = try Data(contentsOf: file!)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let taxiCustomerSupport = Mapper<TaxiCustomerSupport>().map(JSONObject: json)
            return taxiCustomerSupport
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
