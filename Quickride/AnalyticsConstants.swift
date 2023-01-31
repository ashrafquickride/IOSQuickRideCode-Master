//
//  AnalyticsConstants.swift
//  Quickride
//
//  Created by Admin on 12/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AnalyticsConstants {
    
    static let USER_SIGNED_UP = "UserSignedup"
    static let USER_ROUTE_DETAILS = "UserRouteDetailsGiven"; // to address, from address
    static let USER_SELECTED_ROLE = "UserRoleSelected";// ridetaker/ridegiver
    static let USER_MOBILE_VERIFIED = "UserMobileVerified";// user activation status  - true/false
    static let RIDE_INVITE_REJECTED = "RideInviteRejected";//userId,requesteduserId,to from, ride to and from,online,matching option pos, route match
    static let HELP_SUPPORT_RAISED = "HelpSupportRaised";// resaon selected,version number,useremail/id
    static let HELP_VIDEOS_CHECKED = "HelpVideosChecked";// video selected,version number
    static let RIDER_CONTACT_INITIATED = "RiderContactInitiated"; //riderId, from,to
    static let PASSENGER_CONTACT_INITIATED = "PassengerContactInitiated"; //riderId, from,to
    static let ECO_METER_VIEWED = "ViewedEcometer";// userId,
    static let OTHER_PROFILE_VIEWED = "ViewedOtherUserProfile";
    static let RIDER_CHAT_INITIATED = "RiderChatInitiated";
    static let PASSENGER_CHAT_INITIATED = "PassengerChatInitiated";// initiatedFromUserId,initiatedToUserId
    static let FAV_ADDED = "Favouriteadded";// favouritePartnerUserId,userId
    static let OFFER_TAB_VIEWED = "OfferSeen";
    static let APP_OPEN_SIGNUP_WINDOW = "AppOpenSignupWindow" // DeviceID
    static let FIRST_PAGE_CAROUSAL_USED = "FirstPageCarousalUsed" // DeviceID
    static let FIRST_PAGE_CTA_CLICK = "FirstPageCTAClick" // DeviceID Facebook/Google/Phone
    static let CONTACT_NUMBER_ENTERED = "ContactNoEntered" // DeviceID
    static let OTP_NEED_SUPPORT = "OTPneedsupport" // DeviceID
    static let RESEND_OTP = "ResentOTP" // DeviceID
    static let APPLY_PROMO_CLICKED = "Applypromoclick" // DeviceID
    static let QR_PLEDGE_AGREED = "QRPledgeagreed" // UserID
    static let SIGN_UP_SKIPPED = "SignupSkipped" // UserID
    static let USER_TIMINGS_ENTERED = "UserTimingsEntered" // UserID, Home time or office time
    static let DL_VERIFICATION_INITIATED = "DLVerificationInitiated" // UserID
    static let DL_NUMBER_ENTERED = "DLNumberEntered" // UserID
    static let ORG_EMAIL_ENTERED = "OrgEmailEntered" // UserID
    static let VEHICLE_ADDED = "Vehicleadded"//UserID,car/bike
    static let PICTURE_ADDED = "PictureAdded"//UserId,Context
    static let ORG_EMAIL_NOT_AVAILABLE = "Orgemailnotavailable"//UserID
    static let VERIFY_GOVT_ID = "GovtIdVerification"//UserId
    static let VIEWED_OWN_PROFILE = "ViewedOwnProfile"
    static let REFERRAL_IGNORED = "ReferralIgnored"
    static let REFERRAL_CREATED = "ReferralCreated"
    static let RIDER_ACCEPTED_PASSENGER = "RiderAcceptedPassenger"
    static let PASSENGER_ACCEPTED_RIDER = "PassengerAcceptedRider"
    static let RIDE_INVITE_VIEWED = "RideInviteViewed"
    static let HIGH_ALERT_DISPLAYED = "HighAlertDisplayed"
    static let HIGH_ALERT_ACCEPT = "HighAlertInviteAccepted"
    static let HIGH_ALERT_DECLINE = "HighAlertInviteDeclined"
    static let HIGH_ALERT_CLOSED = "HighAlertClosed"
    static let ADHAAR_CLICKED = "Aadharclicked"
    static let QUICK_JOBS_TAP = "Quickjobstap"
    static let qrTaxiSearched = "qrTaxiSearched"
    static let qrTaxiTabClicked = "qrTaxiTabClicked"
    static let qrTaxiBooked = "qrTaxiBooked"
    static let qrTaxiCancelled = "qrTaxiCancelled"
    static let qrTaxiPaymentMode =  "qrTaxiPaymentMode"
    static let qrTaxiRentalSelected = "qrTaxiRentalSelected"
    static let qrTaxiOutstationSearched =  "qrTaxiOutstationSearched"
    static let qrTaxiRideEnd = "qrTaxiRideEnd"
}
