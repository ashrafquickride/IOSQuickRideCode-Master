//
//  QuickShareNotifications.swift
//  Quickride
//
//  Created by Halesh on 13/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension Notification.Name{
    static let quickShareNotAvailable = NSNotification.Name("quickShareNotAvailable")
    static let handleApiFailureError = NSNotification.Name("handleApiFailureError")
    static let removeAddedProductPicture = NSNotification.Name("removeAddedProductPicture")
    static let changeButtonColorIfAllFieldsFilled = NSNotification.Name("changeButtonColorIfAllFieldsFilled")
    static let locationSelected = NSNotification.Name("locationSelected")
    static let productAddedSuccessfully = NSNotification.Name("productAddedSuccessfully")
    static let productDetailsAddedOrChanged = NSNotification.Name("productDetailsAddedOrChanged")
    static let productPriceAddedOrChanged = NSNotification.Name("productPriceAddedOrChanged")
    static let descriptionAdded = NSNotification.Name("descriptionAdded")
    static let productUpdatedSuccessfully = NSNotification.Name("productUpdatedSuccessfully")
    static let productUpdatingFailed = NSNotification.Name("productUpdatingFailed")
    static let productRequestedSuccessfully = NSNotification.Name("productRequestedSuccessfully")
    static let requestingTradeType = NSNotification.Name("requestingTradeType")
    static let recentlyAddedItemListReceived = NSNotification.Name("recentlyAddedItemListReceived")
    static let recentlyRequestedListReceived = NSNotification.Name("recentlyRequestedListReceived")
    static let myPostReceived = NSNotification.Name("myPostReceived")
    static let postedProductDeleted = NSNotification.Name("postedProductDeleted")
    static let receivedSearchedProductTitleList = NSNotification.Name("receivedSearchedProductTitleList")
    static let receivedSearchedProductMatchedList = NSNotification.Name("receivedSearchedProductMatchedList")
    static let postedRequestDeleted = NSNotification.Name("postedRequestDeleted")
    static let userSelectedPaymentWay = NSNotification.Name("userSelectedPaymentWay")
    static let requestSentToSelectedProduct = NSNotification.Name("requestSentToSelectedProduct")
    static let productRequestsReceived = NSNotification.Name("productRequestsReceived")
    static let rentalDaysUpdated = NSNotification.Name("rentalDaysUpdated")
    static let receivedProductOwnerDetails = NSNotification.Name("receivedProductOwnerDetails")
    static let tookPhotoWhileCollectingProduct = NSNotification.Name("tookPhotoWhileCollectingProduct")
    static let pickupOtpReceived = NSNotification.Name("pickupOtpReceived")
    static let pickUpCompleted = NSNotification.Name("pickUpCompleted")
    static let returnOtpReceived = NSNotification.Name("returnOtpReceived")
    static let returnProductCompleted = NSNotification.Name("returnProductCompleted")
    static let receivedOrderRejected = NSNotification.Name("receivedOrderRejected")
    static let placedOrderCancelled = NSNotification.Name("receivedOrderCancelled")
    static let showHowRentalWorks = NSNotification.Name("showHowRentalWorks")
    static let receivedSimilarItems = NSNotification.Name("receivedSimilarItems")
    static let footerTapped = NSNotification.Name("footerTapped")
    static let myOrdersRecieved = NSNotification.Name("myOrdersRecieved")
    static let myPlacedOrdersRecieved = NSNotification.Name("myPlacedOrdersRecieved")
    static let receivedOrderAccepted = NSNotification.Name("receivedOrderAccepted")
    static let invoiceRecieved = NSNotification.Name("invoiceRecieved")
    static let myOrderPaidAndBalanceReceived = NSNotification.Name("myOrderPaidAndBalanceReceived")
    static let numberOfViewsRecieved = NSNotification.Name("numberOfViewsRecieved")
    static let newCommentAdded = NSNotification.Name("newCommentAdded")
    static let productCommentsReceived = NSNotification.Name("productCommentsReceived")
    static let replayInitiated = NSNotification.Name("replayInitiated")
    static let ratingGivenToProduct = NSNotification.Name("ratingGivenToProduct")
    static let receivedProductRating = NSNotification.Name("receivedProductRating")
    static let productFeedbackInitiated = NSNotification.Name("productFeedbackInitiated")
    static let productsReceived = NSNotification.Name("productsReceived")
    static let showPendingAmount = NSNotification.Name("showPendingAmount")
    static let pendingAmountPaid = NSNotification.Name("pendingAmountPaid")
    static let reachabilityChanged = NSNotification.Name("reachabilityChanged")
    static let stopSpinner = NSNotification.Name("stopSpinner")
    static let showAllComments = NSNotification.Name("showAllComments")
    static let goToProductComments = NSNotification.Name("goToProductComments")
    static let showOTPInvalidError = NSNotification.Name("showOTPInvalidError")
    static let showDamageAmount = NSNotification.Name("showDamageAmount")
    static let productTitleAdded = NSNotification.Name("productTitleAdded")
    static let matchingRequestsReceived = NSNotification.Name("matchingRequestsReceived")
    static let matchingProductsReceived = NSNotification.Name("matchingProductsReceived")
    static let receivedSearchedRequestMatchedList = NSNotification.Name("receivedSearchedRequestMatchedList")
    static let notifiedToUserRequestedUser = NSNotification.Name("notifiedToUserRequestedUser")
    
    //MQTT Updates
    static let updateProductOrderStatus = NSNotification.Name("updateProductOrderStatus")
    static let newProductCommentReceived = NSNotification.Name("newProductCommentReceived")
}
