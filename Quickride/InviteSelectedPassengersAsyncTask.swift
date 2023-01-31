//
//  InviteSelectedPassengersAsyncTask.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

public typealias InvitePassengersCompletionHandler = (_ error : ResponseError?,_ nserror : NSError?) -> Void

class InviteSelectedPassengersAsyncTask {
    
    var riderRide:RiderRide?
    var selectedUsers:[MatchedPassenger]?
    var viewController : UIViewController
    var invitedPassengersCount = 0
    var displaySpinner = true
    var inviteFailedPassengers : [String] = [String]()
    var invitePassengersCompletionHandler : InvitePassengersCompletionHandler?
    var selectedIndex:String?
    
    init( riderRide:RiderRide,  selectedUsers:[MatchedPassenger],viewController : UIViewController,displaySpinner : Bool,selectedIndex:String?,invitePassengersCompletionHandler : InvitePassengersCompletionHandler?){
        self.riderRide=riderRide
        self.selectedUsers = selectedUsers
        self.viewController = viewController
        self.displaySpinner = displaySpinner
        self.invitePassengersCompletionHandler = invitePassengersCompletionHandler
        self.selectedIndex = selectedIndex
    }
    
    func completeInvite(matchedPassenger : MatchedPassenger){
        
        self.invitedPassengersCount += 1
        if self.invitedPassengersCount != self.selectedUsers!.count{
            return
        }
        let currentFilterStatus = RideViewUtils.getSortAndFilterData(rideId: riderRide!.rideId, rideType: riderRide?.rideType ?? "")
        RideMatcherServiceClient.sendInvitationToPassengers(rideId: riderRide!.rideId, riderId: riderRide!.userId, matchedUsers: self.selectedUsers!.toJSONString()!, invitePosition: selectedIndex, currentSortFilterStatus: currentFilterStatus, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
            if self.displaySpinner{
                QuickRideProgressSpinner.stopSpinner()
            }
            if(responseObject != nil && responseObject!["result"] as! String == "SUCCESS"){
                let rideInvitesResponse = Mapper<RideInviteResponse>().mapArray(JSONObject: responseObject!["resultData"])
                
                if rideInvitesResponse != nil && rideInvitesResponse!.isEmpty == false{
                    self.saveUserBasicInfoForSucceededInvites(rideInvitesResponse: rideInvitesResponse!)
                    if self.selectedUsers!.count == 1
                    {
                        if rideInvitesResponse![0].success {
                            self.invitePassengersCompletionHandler!(nil, nil)
                            if self.displaySpinner{
                                let successMessage : String?
                                if matchedPassenger.name == nil{
                                    successMessage = Strings.invite_sent_to_selected_user
                                }
                                else{
                                    successMessage = String(format: Strings.invite_sent_to_selected_passengers, matchedPassenger.name!)
                                }
                                UIApplication.shared.keyWindow?.makeToast(successMessage ?? "", point: CGPoint(x: self.viewController.view.frame.size.width/2, y: self.viewController.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                            }
                            
                        }else{
                            RideManagementUtils.handleRiderInviteFailedException(errorResponse: rideInvitesResponse![0].error!, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: nil)
                            self.invitePassengersCompletionHandler!(rideInvitesResponse![0].error!, nil)
                        }
                        
                    }else if rideInvitesResponse![0].error != nil{
                        let multiInviteVC = (UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "MultipleInvitesStatusController") as! MultipleInvitesStatusController)
                        multiInviteVC.initializeDataBeforePresenting(rideInvites: rideInvitesResponse!, matchedUsers: self.selectedUsers!, viewController: self.viewController)
                        ViewControllerUtils.addSubView(viewControllerToDisplay: multiInviteVC)
                        
                        multiInviteVC.view!.layoutIfNeeded()
                    }
                }
            }else{
                if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                    let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                    self.invitePassengersCompletionHandler!(error, nil)
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self.viewController)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error : error,viewController: self.viewController, handler: nil)
                    self.invitePassengersCompletionHandler!(nil, error)
                }
                
            }
        })
    }
    var accountUtils : AccountUtils?
    func invitePassengersFromMatches()
    {
        accountUtils = AccountUtils()
        accountUtils?.checkAndDeleteLinkedWalletNotSupportedByIOS(viewController: viewController, handler: {(result) in
            if result == .success {
                if(self.selectedUsers == nil || self.selectedUsers!.isEmpty == true) {return}
                
                if self.riderRide!.availableSeats <= 0{
                    MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: String(format: Strings.reusing_seats_message, arguments: [String(self.riderRide!.capacity)]), message2: nil, positiveActnTitle: Strings.ACCEPT_CAPS, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, viewController: self.viewController, handler: { (result) in
                        if result == Strings.ACCEPT_CAPS{
                            self.continueInvitePassengers()
                        } else {
                            self.invitePassengersCompletionHandler?(ResponseError(userMessage: String(format: Strings.reusing_seats_message, arguments: [String(self.riderRide!.capacity)])), nil)
                        }
                    })
                }else{
                    self.continueInvitePassengers()
                }
            } else if result == .addPayment {
                self.showPaymentDrawer()
            }else {
                self.invitePassengersCompletionHandler?(ResponseError(userMessage: Strings.failed_to_send_request),nil)
            }
        })
    }
    func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: true) {(data) in
            if data == .selected || data == .makeDefault {
                self.invitePassengersFromMatches()
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    func continueInvitePassengers(){
        for  matchedUser in selectedUsers!
        {
            if displaySpinner{
                QuickRideProgressSpinner.startSpinner()
            }
            completeInvite(matchedPassenger: matchedUser)
        }
    }
    func saveUserBasicInfoForSucceededInvites(rideInvitesResponse : [RideInviteResponse]){
        for rideInviteResponse in rideInvitesResponse{
            if rideInviteResponse.success && rideInviteResponse.rideInvite!.passengerId != 0 {
                let matchedPassengersDictionary = getMatchedPassengersDictionary(selectedUsers: self.selectedUsers!)
                let matchedUser = matchedPassengersDictionary[rideInviteResponse.rideInvite!.passengerId]
                if matchedUser != nil && matchedUser!.name != nil && matchedUser!.gender != nil{
                    UserDataCache.getInstance()?.saveUserBasicInfo(userBasicInfo: UserBasicInfo(userId : matchedUser!.userid!, gender : matchedUser!.gender!,
                                                                                                userName : matchedUser!.name!, imageUri : matchedUser!.imageURI,
                                                                                                companyName : matchedUser!.companyName, rating :
                                                                                                    Float(matchedUser!.rating!), noOfReviews : matchedUser!.noOfReviews, callSupport : matchedUser!.callSupport,
                                                                                                verificationStatus : matchedUser!.verificationStatus))
                    RideInviteCache.getInstance().saveNewInvitation(rideInvitation: rideInviteResponse.rideInvite!)
                }
            }
        }
    }
    func getMatchedPassengersDictionary(selectedUsers : [MatchedPassenger]) -> [Double : MatchedPassenger]{
        var matchedPassengersDictionary = [Double : MatchedPassenger]()
        for passenger in selectedUsers {
            matchedPassengersDictionary[passenger.userid!] = passenger
        }
        return matchedPassengersDictionary
    }
}
