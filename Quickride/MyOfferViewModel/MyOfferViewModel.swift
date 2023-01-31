//
//  MyOfferViewModel.swift
//  Quickride
//
//  Created by Ashutos on 04/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol MyOfferViewModelDelegate: class {
    func updateDataAfterFetchingRideIncentive()
    func couponApplied(systemCouponCode: SystemCouponCode?,responseError: ResponseError?, responseObject: NSDictionary?, error: NSError?)
}
class MyOfferViewModel {
    
    var applyPromoCodeView : ApplyPromoCodeDialogueView?
    var rideAssuredIncentive : RideAssuredIncentive?
    weak var delegate:  MyOfferViewModelDelegate?
    var offerLists: [Offer]? = []
    var categoryList: [String] = []
    var selectedFilterString = Strings.all
    let copiedOfferListFromCcahe = ConfigurationCache.getInstance()?.offersList
    
    init(selectedFilterString: String) {
        self.selectedFilterString = selectedFilterString
    }
    
    func getFilterData()-> [Offer] {
        if let offersList = copiedOfferListFromCcahe {
            return filterOffers(offerList : offersList) ?? [Offer]()
        }
        return [Offer]()
    }
    
   private func filterOffers(offerList: [Offer])-> [Offer]? {
        var filterList = [Offer]()
        for offer in offerList {
            if (offer.displayType == Strings.displaytype_both || offer.displayType == Strings.displaytype_offerscreen)  && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false {
                filterList.append(offer)
            }
        }
        if filterList.isEmpty {
            return nil
        }
        var finalOfferList = [Offer]()
        for offer in filterList {
            let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
            if userProfile != nil && (UserProfile.PREFERRED_ROLE_PASSENGER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_rider) {
                finalOfferList.append(offer)
            } else if offer.targetRole == Strings.targetrole_both {
                finalOfferList.append(offer)
            }
        }
        
        self.categoryList = getAllCategoriesFromOffers(offerList: finalOfferList)
        let finalOfferListForCategory = getFilterListAsPerChoosenFilter(filteredData: finalOfferList)
        self.offerLists = finalOfferListForCategory.sorted(by: { $0.validUpto > $1.validUpto})
        return offerLists
    }
    
    func getAllCategoriesFromOffers(offerList: [Offer]) -> [String]{
        var allOffersInSortedAsPerPriority = offerList
        allOffersInSortedAsPerPriority.sort(by: { $0.priority < $1.priority})
        categoryList.removeAll()
        var categoryList = [Strings.all]
        for offer in allOffersInSortedAsPerPriority {
            if let category = offer.category {
                if categoryList.contains(category){
                    continue
                }else{
                    categoryList.append(category)
                }
            }
        }
        return categoryList
    }
    
    func getFilterListAsPerChoosenFilter(filteredData : [Offer]) -> [Offer] {
        var filteredCategoryOfferList: [Offer] = []
       if selectedFilterString == Strings.all {
            filteredCategoryOfferList = filteredData
        }else{
            for data in filteredData {
                if data.category == selectedFilterString {
                    filteredCategoryOfferList.append(data)
                }
            }
        }
        return filteredCategoryOfferList
    }
    
    func getTMWRegURL()-> String {
        if AppConfiguration.useProductionServerForPG{
            let user = UserDataCache.getInstance()?.currentUser
            let urlString = "https://themobilewallet.com/TMWPG/signup?retailerId=\(AppConfiguration.TMW_RETAILER_ID)&firstname=\(user!.userName)&mobileno=\(StringUtils.getStringFromDouble(decimalNumber: user!.contactNo))"
            return urlString
        }
        return "https://staging.themobilewallet.com/Restruct_TMWPG/signup"
    }
    
    func updateRideAssuredIncentiveDisplayStatus(vc: UIViewController){
        AccountRestClient.updateRideAssuredIncentiveDisplayStatus(userId: QRSessionManager.getInstance()!.getUserId(), status: RideAssuredIncentive.INCENTIVE_STATUS_DISPLAYED, viewController: vc) { (responseObject, error) in
        }
    }
    
    func getRideAssuredIncentiveFromServer(vc: UIViewController){
           AccountRestClient.getRideAsurredIncentiveIfApplicable(userId: (QRSessionManager.getInstance()?.getUserId())!, viewController: vc) { (responseObject, error) in
               if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                   if responseObject!["resultData"] != nil{
                       self.rideAssuredIncentive = Mapper<RideAssuredIncentive>().map(JSONObject: responseObject!["resultData"])
                       self.rideAssuredIncentive?.lastFetchedTime = NSDate().getTimeStamp()
                       if self.rideAssuredIncentive?.status == RideAssuredIncentive.INCENTIVE_STATUS_OPEN{
                           self.updateRideAssuredIncentiveDisplayStatus(vc: vc)
                       }
                    }else{
                       self.rideAssuredIncentive = RideAssuredIncentive()
                       self.rideAssuredIncentive?.lastFetchedTime = NSDate().getTimeStamp()
                   }
                self.delegate?.updateDataAfterFetchingRideIncentive()
                 SharedPreferenceHelper.storeRideAssuredIncentive(rideAssuredIncentive: self.rideAssuredIncentive)
               }
           }
       }
    
    
    func applyCouponCode(appliedCoupon : String, vc: UIViewController){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.applyUserCoupon(userId: QRSessionManager.getInstance()!.getUserId(), appliedCoupon: appliedCoupon, viewController: vc) { (responseObject, error) in
            AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    let systemCouponCode = Mapper<SystemCouponCode>().map(JSONObject: responseObject!["resultData"])
                    self.delegate?.couponApplied(systemCouponCode: systemCouponCode!, responseError: nil, responseObject: nil, error: nil)
                }
                else if responseObject!["result"] as! String == "FAILURE" {
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    self.delegate?.couponApplied(systemCouponCode: nil, responseError: responseError, responseObject: responseObject, error: error)
                }
            }
            else{
                self.delegate?.couponApplied(systemCouponCode: nil, responseError: nil, responseObject: responseObject, error: error)
            }
        }
    }
    
}
