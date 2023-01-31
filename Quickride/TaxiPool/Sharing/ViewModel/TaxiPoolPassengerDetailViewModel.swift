//
//  TaxiPoolPassengerDetailViewModel.swift
//  Quickride
//
//  Created by HK on 19/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiPoolPassengerDetailViewModel{
    
    var taxipoolMatches =  [MatchingTaxiPassenger]()
    var taxiRide: TaxiRidePassenger?
    var selectedIndex = -1
    var selecetdMatchedUser: MatchingTaxiPassenger?
    
    init() {}
    init(taxipoolMatches: [MatchingTaxiPassenger],taxiRide: TaxiRidePassenger?,selectedIndex: Int) {
        self.taxipoolMatches = taxipoolMatches
        self.taxiRide = taxiRide
        self.selectedIndex = selectedIndex
        selecetdMatchedUser = taxipoolMatches[selectedIndex]
    }
    
    func sendInviteToCarpoolPassenger(complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
        let taxiInvite = TaxiPoolInvite(taxiRideGroupId: Int(taxiRide?.taxiGroupId ?? 0), invitingUserId: Int(taxiRide?.userId ?? 0), invitingRideId: Int(taxiRide?.id ?? 0), invitingRideType: TaxiPoolInvite.TAXI, invitedUserId: Int(selecetdMatchedUser?.userid ?? 0), invitedRideId: Int(selecetdMatchedUser?.rideid ?? 0), invitedRideType: TaxiPoolInvite.TAXI, fromLat: selecetdMatchedUser?.fromLocationLatitude ?? 0, fromLng: selecetdMatchedUser?.fromLocationLongitude ?? 0, toLat: selecetdMatchedUser?.toLocationLatitude ?? 0, toLng: selecetdMatchedUser?.toLocationLongitude ?? 0, distance: selecetdMatchedUser?.distance ?? 0, pickupTimeMs: Int(selecetdMatchedUser?.pickupTime ?? 0), overviewPolyLine: selecetdMatchedUser?.taxiRoutePolyline ?? "")
        sendTaxiInvite(taxiInvite: taxiInvite, complitionHandler: complitionHandler)
    }
    
    func sendTaxiInvite(taxiInvite: TaxiPoolInvite,complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
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
        TaxiSharingRestClient.cancelCarpoolPassengerInvite(inviteId: inviteId) {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                MyActiveTaxiRideCache.getInstance().removeTaxiOutgoingInvite(inviteId: inviteId)
                complitionHandler(nil,nil)
            }else{
                complitionHandler(responseObject,error)
            }
        }
    }
    
    func getErrorMessageForCall() -> String?{
        if (selecetdMatchedUser?.userRole == MatchedUser.RIDER || selecetdMatchedUser?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else if let enableChatAndCall = selecetdMatchedUser?.enableChatAndCall, !enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }else if selecetdMatchedUser?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            return Strings.call_joined_partner_msg
        }else if selecetdMatchedUser?.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
}
