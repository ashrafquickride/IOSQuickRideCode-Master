//
//  TaxipoolPassengersViewModel.swift
//  Quickride
//
//  Created by HK on 14/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxipoolPassengersViewModel {
    typealias CarPoolMatchesClosure =  (_ responseObject: NSDictionary?, _ error: NSError?) -> Void

    var capoolMatches : [MatchingTaxiPassenger]?
    var taxiRide: TaxiRidePassenger?
    var carpoolMatchesClosure : CarPoolMatchesClosure?
    init() {}
    init(taxiRide: TaxiRidePassenger?) {
    
        self.taxiRide = taxiRide
    }
    
    func getCarpoolMatches( receiver: @escaping(_ responseObject: NSDictionary?, _ error: NSError?) -> Void){
        self.carpoolMatchesClosure = receiver
        MyActiveTaxiRideCache.getInstance().getCarpoolPassengerMatches(taxiRide: self.taxiRide!, dataReceiver: self)

    }
    
    func sendInviteToCarpoolPassenger(taxiInvite: TaxiPoolInvite,complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
        TaxiSharingRestClient.inviteCarpoolPassenger(taxiPoolInvite: taxiInvite) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let invite = Mapper<TaxiPoolInvite>().map(JSONObject: responseObject!["resultData"]){
                    MyActiveTaxiRideCache.getInstance().updateTaxipoolInvite(taxiInvite: invite)
                }
                complitionHandler(nil,nil)
            }else{
                complitionHandler(responseObject,error)
            }
        }
    }
    
    func cancelCarpoolPassengerInvite(inviteId: String,complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
        TaxiSharingRestClient.cancelCarpoolPassengerInvite(inviteId: inviteId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                MyActiveTaxiRideCache.getInstance().removeTaxiOutgoingInvite(inviteId: inviteId)
                complitionHandler(nil,nil)
            }else{
                complitionHandler(responseObject,error)
            }
        }
    }
}
extension TaxipoolPassengersViewModel: CarpoolPassengerDataReceiver{
    func receivedCarpoolPassengerList(carpoolMatches: [MatchingTaxiPassenger]) {
        self.capoolMatches = carpoolMatches
        if let closure = self.carpoolMatchesClosure{
            closure(nil,nil)
        }
    }
    func carpoolMatchesRetrivalFailed(responseObject: NSDictionary?, error: NSError?) {
        self.capoolMatches = [MatchingTaxiPassenger]()
        if let closure = self.carpoolMatchesClosure{
            closure(responseObject,error)
        }
    }
}
