//
//  SimplAndFirstRideFreeOfferViewModel.swift
//  Quickride
//
//  Created by Halesh on 25/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

protocol SimplAndFirstRideFreeOfferViewModelDelegate {
    func handleSuccesResponse()
    func hnadleFailureResponse()
}

class SimplAndFirstRideFreeOfferViewModel{
    
    var isSimplSelected = false
    var isFirstRideSelected = false
    
    func linkSimplWallet(viewController: UIViewController, delegate: SimplAndFirstRideFreeOfferViewModelDelegate){
        AccountRestClient.linkSIMPLAccountToQRInSignUp(userId: UserDataCache.getInstance()?.userId, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"]){
                    self.updateDefaultLinkedWallet(linkedWallet: linkedWallet, viewController: viewController, listener: delegate)
                    UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet)
                    UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet)
                    delegate.handleSuccesResponse()
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                delegate.hnadleFailureResponse()
            }
        })
    }
    func updateDefaultLinkedWallet(linkedWallet: LinkedWallet, viewController: UIViewController?, listener: SimplAndFirstRideFreeOfferViewModelDelegate){
        AccountRestClient.updateDefaultLinkedWallet(userId: QRSessionManager.getInstance()?.getUserId() ?? "", type: linkedWallet.type, viewController: viewController) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UserDataCache.getInstance()?.updateUserDefaultLinkedWallet(linkedWallet: linkedWallet)
                UIApplication.shared.keyWindow?.makeToast( Strings.default_paymet_method_updated)
                listener.handleSuccesResponse()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                listener.hnadleFailureResponse()
            }
        }
    }
    
}
