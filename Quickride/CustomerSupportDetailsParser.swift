//
//  CustomerSupportDetailsParser.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias CustomerSupportDataHandler = (_ customerSupportElement : CustomerSupportElement?) -> Void
class CustomerSupportDetailsParser {
    
    var customerSupportElement :  CustomerSupportElement?
    static var instance : CustomerSupportDetailsParser?
    
    static func getInstance() -> CustomerSupportDetailsParser{
        if instance == nil{
            instance = CustomerSupportDetailsParser()
            let url = ConfigurationCache.getInstance()?.customerSupportFileUrl
          if url == nil{
            return instance!
          }
            HttpUtils.performRestCallToOtherServer(url: ConfigurationCache.getInstance()!.customerSupportFileUrl!, params:  [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil {
                    let customerSupportBaseElement = Mapper<CustomerSupportBaseElement>().map(JSONObject: responseObject)
                    instance?.customerSupportElement = customerSupportBaseElement?.customerSupportElement
                }
            })
        }
        return instance!
    }
    func getCustomerSupportElement(handler : @escaping CustomerSupportDataHandler){
        if customerSupportElement != nil{
            return handler(self.customerSupportElement)
        }
      let url = ConfigurationCache.getInstance()?.customerSupportFileUrl
      if url == nil{
        return handler(self.readFromLocal())
      }else{
        QuickRideProgressSpinner.startSpinner()
        HttpUtils.performRestCallToOtherServer(url: (ConfigurationCache.getInstance()?.customerSupportFileUrl)!, params: [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                let customerSupportBaseElement = Mapper<CustomerSupportBaseElement>().map(JSONObject: responseObject)
                self.customerSupportElement = customerSupportBaseElement?.customerSupportElement
                handler(self.customerSupportElement)
            }else{
                handler(self.readFromLocal())
            }

        })
      }
    }
    
    func readFromLocal() -> CustomerSupportElement? {
        
        let file = Bundle.main.url(forResource: "customerSupport", withExtension: "json")
        
        if file == nil{
            return nil
        }
        do {
            
            let data = try Data(contentsOf: file!)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let customerSupportBaseElement = Mapper<CustomerSupportBaseElement>().map(JSONObject: json)
            return customerSupportBaseElement?.customerSupportElement
        } catch {
            print(error.localizedDescription)
        }
        return nil
        
    }
}
