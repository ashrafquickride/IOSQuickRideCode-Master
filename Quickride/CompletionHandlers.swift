//
//  CompletionHandlers.swift
//  Quickride
//
//  Created by KNM Rao on 24/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class CompletionHandlers {
    
    public typealias responseCompletionHandler = (_ responseObject: Int, _ error: NSError?) -> Void
    public typealias sessionCompletionHandler = (_ sessionCompletionStatus : Bool, _ error: NSError?) -> Void
    public typealias defaultCompletionHandler = (_ completionStatus : Bool, _ error: NSError?) -> Void
    public typealias imageRecievedCompletionHandler = (completionStatus : Bool, image : UIImage, error : NSError?)
    public typealias responseReturnCompletionHandler = (_ responseObject: AnyObject?, _ error: ResponseError?) -> Void
    
    public typealias accountRetrievalCompletionHandler = (_ accountObject: Account?, _ responseError: ResponseError?) -> Void
    public typealias completeProfileRetrievalCompletionHandler = (_ completeProfileObject: CompleteProfile?, _ responseError: ResponseError?) -> Void
    public typealias profileRetrievalCompletionHandler = (_ userProfileObject: UserProfile?, _ responseError: NSError?, _ responseObject: NSDictionary?) -> Void
    public typealias userRetrievalCompletionHandler = (_ userObject: User?, _ responseError: NSError?, _ responseObject: NSDictionary?) -> Void
    public typealias vehicleRetrievalCompletionHandler = (_ vehicleObject: Vehicle?, _ responseError: ResponseError?) -> Void
    public typealias favouriteLocationRetrivalCompletionHandler = (_ favouriteLocationObject: [UserFavouriteLocation]?, _ responseError: ResponseError?) -> Void
    
    public typealias sessionChangeCompletionHandler = (_ sessionChangeCompletionStatus : Bool, _ responseError: ResponseError?) -> Void
    public typealias otherUserCompleteProfileRetrievalCompletionHandler = (_ completeProfileObject: UserFullProfile?, _ responseError: NSError?, _ responseObject: NSDictionary?) -> Void
    typealias rideContributionRetrievalCompletionHandler = (_ rideContribution: RideContribution?, _ responseError: ResponseError?) -> Void
    
    typealias recurringRideCreatedComplitionHandler = (_ regularRide : RegularRide?,_ responseError : ResponseError?,_ error: NSError?) -> Void
    public typealias notificationRetrievalCompletionHandler = (_ userNotification: UserNotification?) -> Void
    typealias companyIdVerificationDataCompletionHandler = (_ companyIdVerificationData: CompanyIdVerificationData?) -> Void
    typealias userProfileRetrievalCompletionHandler = (_ userProfile: UserProfile?) -> Void
    typealias endorsementVerificationInfoCompletionHandler = (_ endorsementVerificationInfo: [EndorsementVerificationInfo]) -> Void
    typealias skillsAndInterestsDataCompletionHandler = (_ skillsAndInterestsData: SkillsAndInterestsData?) -> Void
    typealias rideEtiquetteCertificateCompletionHandler = (_ rideEtiquetteCertification: RideEtiquetteCertification?) -> Void
}
