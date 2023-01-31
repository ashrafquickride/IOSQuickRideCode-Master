//
//  NotificationHandlerFactory.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.

import Foundation

public class NotificationHandlerFactory{

    public static func getNotificationHandler(clientNotification : UserNotification) -> NotificationHandler?{
        AppDelegate.getAppDelegate().log.debug("getNotificationHandler()")
        if clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_REMINDER{
            return PassengerReminderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDE_RESCHEDULED {
            return RideRescheduledNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION {
            return PassengerInvitationNotificationHandlerToRider()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION {
            return RiderInvitationNotificationHandlerToPassenger()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION_STATUS {
            return RiderRejectedPassengerInviteNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_STATUS{
            return PassengerRejectedRiderInviteNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_UNJOIN{
            return RideCancelledByPassengerHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDE_CANCELLED{
            return PassengerJoinedRideGotCancelledHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_RIDE_RIDER{
            return PassengerJoinNotificationToRiderHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_RIDE_PASSENGER{
            return PassengerJoinNotificationToPassengerHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDE_CANCELLED_BY_SYSTEM{
            return MyRiderRideCancelledNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_ACCOUNT_TRANSACTION{
            return AccountTransactionNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_LOW_BALANCE_REMAINDER{
            return LowBalanceNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_GROUP_CHAT{
            return OfflineChatMessageNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RIDE || clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RESEND_ALERT_RIDE{
            return PassengerToCheckInRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKOUT_RIDE{
            return PassengerToCheckOutRideNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_TO_START_RIDE || clientNotification.type == UserNotification.NOT_TYPE_RE_RIDE_DELAYED_SECOND_ALERT_TO_RIDER ||
            clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_TO_START_RIDE_REMAINDER{
            return RiderToStartRideNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_TO_STOP_RIDE{
            return RiderToStopRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_USER_CUSTOM_NOTIFICATION{
            return UserCustomNotificationHandler()

        }else if clientNotification.type == UserNotification.NOT_TYPE_REGULAR_PASSENGER_RIDE_INSTANCE_CREATION{
            return NotifyPassengerRideInstanceCreationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_REGULAR_RIDER_RIDE_INSTANCE_CREATION{
            return NotifyRiderRideInstanceCreationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RM_REGULAR_PASSENGER_UNJOIN{
            return RegularRideCancelledByPassengerHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_REGULAR_RIDE_CANCELLED{
            return PassengerJoinedRegularRideGotCancelledHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_PASSENGER{
            return PassengerJoinRegularRideNotificationToPassengerHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_REGULAR_RIDE_RIDER{
            return PassengerJoinRegularRideNotificationToRiderHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_REGULAR_RIDE_REJECT{
            return  RegularRideRejectNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_REGULAR_RIDER_RIDE_REMINDER
            || clientNotification.type == UserNotification.NOT_TYPE_REGULAR_PASSENGER_RIDE_REMINDER{
            return RegularRideReminderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_CONTACT_INVITATION || clientNotification.type == UserNotification.NOT_TYPE_RM_INVITATION_TO_OLD_USER{
            return  RideDirectInviteNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_GROUP_INVITATION
        {
            return GroupInvitationNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_RIDER{
            return PassengersFoundRemainderToRiderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PASSEGER{
            return RiderFoundRemainderToPassengerNotificationHandler();
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_REJECT_REGULAR_RIDE{
            return RiderRejectRegularRideNotificationToPassengerHandler();
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_REJECT_REGULAR_RIDE{
            return PassengerRejectRegularRideNotificationToRiderHandler();
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_RIDER
            || clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCH_FOUND_NOTIFICATION_TO_PAST_PASSEGER{
            return  RideFoundRemainderToPastUserNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_CREATE_PASSENGER_RIDE_TO_RIDER{
            return RiderToCreatePassengerRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_PASSENGER_TO_CREATE_REGULAR_RIDE || clientNotification.type == UserNotification.NOT_TYPE_RIDER_TO_CREATE_REGULAR_RIDE{
            return  CreateRegularRideNotificationHandler();
        }else if clientNotification.type == UserNotification.NOT_TYPE_CREATE_RIDE_REMAINDER{
            return RideCreationRemainderNotificationHandler()

        }else if clientNotification.type == UserNotification.NOT_TYPE_CREATE_FIRST_RIDE_REMAINDER{
            return UserToCreateFirstRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDER_TO_START_RIDE_VOICE_NOTIFICATION{
            return RiderToStartRideVoiceNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RIDER_PICKED_UP_PASSENGER
        {
            return RiderPickedUpPassengerNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_USER_TO_CREATE_RIDE
        {
            return CreateRideNotificaitonHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_PERSONAL_CHAT
        {
            return OfflineConversationMessageHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE{
            return RideInvitationWithFareChangeNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ALERT{
            return RiderRouteDeviationEmergencyNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_ROUTE_DEVIATION_ACK{
            return NotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_EMERGENCY_INITIATED_DUE_TO_NOT_CHECKOUT_RIDE{

            return PassengerNotCheckedOutEmergencyInitiatorHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_GROUP_MATCH_NOTIFICATION_TO_USER
        {
            return UserRouteGroupMatchNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_EMAIL_VERIFICATION_EXIPRED_REMINDER
        {
            return UserProfileVerificationNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_AMOUNT_TRANSFER_REQUEST
        {
            return AmountTransferRequestNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_REFUND
        {
            return RefundRequestToRiderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_AMOUNT_TRANSFER_REQUEST_REJECT
        {
            return TransferRequestRejectNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_REFUND_REQUEST_REJECT
        {
            return RefundRequestRejectNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_CHANGE_PICKUP_DROP_RIDER
        {
            return PassengerPickupDropChangeNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_ENABLE_LOCATION_REMINDER{
            return RideTrackingEnableNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_PASSENGER_REMINDER_RIDE_MATCHER{
            return PassengerRideDelayedAlertNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_USER_GROUP_JOIN_REQUEST_TO_ADMIN{
            return UserGroupJoinInvitationToAdminNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_USER_GROUP_JOIN{
            return UserGroupMemberJoinResponseNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_USER_GROUP_REJECT{
            return UserGroupInvitationRejectNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_USER_GROUP_REMOVE{
            return UserGroupMemberRemoveNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RE_RIDER_PICKUP_PASSENGER{
            return RiderReachPickupPointToRiderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_SUBSCRIPTION_REMINDER{
            return SubscriptionExpiredNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_MESSAGE_TO_USERS{
            return SupportNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_PROFILE_VERIFICATION_CANCELLATION{
            return ProfileVerificationCancellationNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_FIREBASE_NOT{
            return FirebaseNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_IMAGE_NOTIFICATION{
            return NotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_LINKED_WALLET_EXPIRED{
            return LinkedWalletNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_PASS_EXPIRE{
            return RidePassExpiredNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_UPDATE_USER_APP_RETAINED_TIME{
            return AppRetainedStatusUpdateNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_OFFER_EXPIRE_REMINDER || clientNotification.type == UserNotification.NOT_TYPE_OFFER_APPLIED{
            return offerExpiredNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_HIGH_BALANCE_REMAINDER{
            return HighBalanceNotificationHandler()
        }
        else if clientNotification.type == UserNotification.RM_RIDE_CANCELLATION_SUGGESTION{
            return RecurringRideCancellationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RESCHEDULE_RIDE_TO_PASSEGER{
            return PassengerRideRescheduleSuggestionNotificationHandler()
        }
        else if clientNotification.type == UserNotification.NOT_TYPE_RESCHEDULE_RIDE_TO_RIDER{
            return RiderRideRescheduleSuggestionNotificationHandler()
        }
        else if clientNotification.type == UserNotification.RM_RIDE_CANCELLATION_SUGGESTION{
            return RecurringRideCancellationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_PENDING_INVITES_REMINDER_TO_ASSURED_RIDER{
            return AssuredRiderInviteRemainderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDER_INITIATE_PENDING_BILL_FOR_RIDE{
            return PendingBillPaymentReminderNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDE_INVITE_REJECT_BY_MODERATOR {
            return RideInviteRejectByModeratorNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_TO_MODERATOR {
            return RiderInvitationToModeratorNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_WITH_REQUESTED_FARE_TO_MODERATOR {
            return RiderInvitationToModeratorWithRequestedFareNotificationHanlder()
        }else if clientNotification.type == UserNotification.NOT_TYPE_INACTIVE_USERS_WITH_REGULAR_RIDE{
            return ReccurringRideRemainderHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_REACHED_NEXT_LEVEL_IN_REFERRAL{
            return ReferralNextLevelReachedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_COMPLETED {
            return TaxiPoolBillNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_POOL_YET_TO_CONFIRM || clientNotification.type == UserNotification.NOT_TYPE_TAXI_POOL_CONFIRM || clientNotification.type == UserNotification.NOT_TYPE_TAXI_STARTED || clientNotification.type == UserNotification.NOT_TYPE_TAXI_DELAYED || clientNotification.type == UserNotification.NOT_TYPE_TAXI_POOL_CONFIRM ||
                    clientNotification.type == UserNotification.NOT_TYPE_TAXI_NOT_ALLOTED || clientNotification.type == UserNotification.NOT_TYPE_DRIVER_REACHED_TO_PICKUP{
            return TaxiPoolLiveRideNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_REFUND_REQUEST {
            return RefundRequestToRiderNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_ENDORSEMENT_REQUEST {
            return EndorsementRequestNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_ENDORSEMENT_ACCEPT {
            return EndorsementAcceptedNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_VERIFICATION {
            return VerificationStatusNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_VERIFICATION_PENDING {
            return EndorsementRequestNotificationHandler()
        } else if clientNotification.type == UserNotification.NOT_TYPE_CANCEL_PARENT_RELAY_RIDE{
        } else if clientNotification.type == UserNotification.NOT_JOIN_TAXI_POOL {
            return TaxiPoolAnalyticsNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_CANCEL_PARENT_RELAY_RIDE{
            return RelayParentRideCancellationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_CANCEL_RELAY_RIDE_LEGS{
            return RelayRideChildRidesCancellationHandler()
        }else if clientNotification.type == UserNotification.NOT_TAXI_INVITE || clientNotification.type == UserNotification.NOT_TAXI_INVITE_BY_CONTACT{
            return TaxiPoolInviteNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_LIVE{
            return ProductIsLiveNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_ORDER_RECEIVED{
            return OrderReceivedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PAYMENT_RECEIVED{
            return ProductPaymentReceivedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_SELLER{
            return ReturnRemainderSellerNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_ORDER_COMPLETED_TO_SELLER{
            return SellerOrderCompletedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_ORDER_COMPLETED_TO_BUYER{
            return BuyerOrderCompletedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_REQUEST_ACCEPTED{
            return OrderAcceptedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_DELIVERED{
            return ProductDeliverdNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_RETURN_REMAINDER_BUYER{
            return ReturnRemainderBuyerNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_REJECTED{
            return ProductRejectedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_REQUEST_REJECTED{
            return OrderRejectedBySellerNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_DELETED{
            return ProductDeletedByOwnerNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_NEW_PRODUCT_FOUND{
            return NewProductFoundNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_COMMENT_TO_BUYER{
            return BuyerReceivedAnswerCommentNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_COMMENT_TO_SELLER{
            return SellerReceivedNewCommentNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PICK_UP_REMAINDER_SELLER{
            return PickupRemainderSellerNotificationHandler()
        }else if clientNotification.type == UserNotification.JOB_REFERRER || clientNotification.type == UserNotification.JOB_SEEKER{
            return QuickJobsNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_SELLER{
            return RequestCommentNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QS_PRODUCT_REQUEST_COMMENT_TO_BUYER{
            return RequestAnswerCommentNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_PASSEGER{
            return BestMatchFoundForPassengerNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_RIDER{
            return BestMatchFoundForRiderNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_ADDITIONAL_PAYMENT_DETAILS_REJECTED_TO_CUSTOMER || clientNotification.type == UserNotification.NOT_TYPE_QT_EXTRA_FARE_DETAILS_CANCELLED_TO_CUSTOMER{
            return DriverRejectedAdditionalCashPaymentsByPassenger()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_EXTRA_FARE_DETAILS_ADDED_TO_CUSTOMER{
            return DriverAddedPaymentsOnTheWayNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_DRIVER_CANCELLED{
            return DriverCancelTripNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_FARE_CHANGE_BY_OPERATOR_TO_CUSTOMER{
            return FareChangeByOperatorNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_OPERTOR_CANCELLED_RIDE{
            return OperatorCancelTripNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_POOL_USER_UNJOIN{
            return TaxiPoolUserUnjoinedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_FEEDBACK_REMINDER{
            return FeedbackNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_TAXI_ALLOTTED{
            return TaxiPoolLiveRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_GRP_QT_TAXI_BOOKING_DETAILS_UPDATED_NOTIFICATION{
            return TaxiBookingDetailsUpdatedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_NPS_REVIEW_REMINDER {
            return TaxiNPSReviewNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_REFUND_INITIATED {
            return TaxiRefundInitiatedNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_START_ODOMETER_DETAILS {
            return RentalTaxiStartOdometerDetailsHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_END_ODOMETER_DETAILS {
            return RentalTaxiEndOdometerDetailsHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_QT_RISKY_RIDE_NOTIFICATION {
            return RiskyRideNotificationHandler()
        }else if clientNotification.type == UserNotification.NOT_TYPE_RM_RIDER_ACCEPTED_PAYMENT_PENDING {
            return RiderAcceptedPaymentPendingNotificationHandler()
        }else  {
            return NotificationHandler()
        }
        return nil
    }
}
