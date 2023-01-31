//
//  QuickShareRestClient.swift
//  Quickride
//
//  Created by Halesh on 12/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickShareRestClient{
    
    typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    //MARK: Apis Paths
    static let CHECK_QUICK_SHARE_AVAILABILITY = "/category/locateCity"
    static let GET_AVAILABLE_CATEGORY_LIST = "/category/city/new"
    
    static let ADD_PRODUCT = "/ProductListing"
    static let UPDATE_ADDED_PRODUCT = "/ProductListing/update"
    static let GET_POSTED_PRODUCTS_LIST = "/ProductListing/active"
    static let CHANGE_PRODUCT_STATUS = "/ProductListing/status"
    static let DELETE_POSTED_PRODUCT = "/ProductListing/cancel"
    static let GET_MY_POSTED_PRODUCT = "/ProductListing/product"
    
    static let REQUEST_PRODUCT = "/ProductListingRequest"
    static let CHANGE_REQUEST_STATUS = "/ProductListingRequest/update/status"
    static let DELETE_POSTED_REQUEST = "/ProductListingRequest/cancel"
    
    static let GET_RECENTLY_ADDED_ITEMS = "/ProductListingSearch/matching/productListing"
    static let GET_RECENT_REQUESTS = "/ProductListingSearch/matching/productListingRequest"
    static let GET_PARTICULAR_PRODUCT = "/ProductListingSearch/matched/active/productListing"
    
    static let SEARCH_PRODUCTS = "/ProductListingSearch/matching/productListing/query"
    static let GET_PERTICULAR_PRODUCT_FOR_SEARCHED_TITLE = "/ProductListingSearch/matching/productListing/query/full"
    
    static let GET_MY_PLACED_ORDERS = "/ProductListingRequest/request/borrower"
    static let GET_MY_RECEIVED_ORDERS = "/ProductListingRequest/request/seller"
    static let GET_PARTICULAR_ORDER = "/ProductListingRequest/order/status"
    
    static let ACCEPT_ORDER = "/ProductOrder/accept"
    static let REJECT_ORDER = "/ProductOrder/reject"
    static let CANCEL_ORDER = "/ProductOrder/cancel"
    
    static let GET_PICKUP_OTP = "/ProductOrder/pickupOTP"
    static let COMPLETE_PICKUP_PRODUCT = "/ProductOrder/pickupComplete"
    static let GET_RETURN_OTP = "/ProductOrder/initiateReturnPickup"
    static let COMPLETE_RETURN_PRODUCT = "/ProductOrder/completeReturnPickup"
    
    static let GET_INVOICE_FOR_ORDER = "/ProductOrder/invoice"
    static let GET_MY_ORDER_PAID_AND_BALANCE = "/ProductOrder/myOrders/payment"
    
    static let GET_NUMBER_OF_VIEWS = "/enitytView"
    static let UPDATE_PRODUCT_RATING = "/ProductRating"
    static let GET_PRODUCT_RATING = "/ProductRating/product"
    
    static let ADD_COMMENT = "/ProductComment"
    static let PAY_FAILED_AND_OUTSTANDING_AMOUNT = "/ProductOrder/order/pay"
    
    static let SEARCH_REQUESTS = "/ProductListingSearch/matching/productListingRequest/query"
    static let MATCHING_REQUEST_LIST = "/ProductListingSearch/matching/productListingRequest/query/full"
    static let NOTIFY_PRODUCT_TO_REQUESTED_USER = "/ProductListingRequest/offer/product/notification"
    
    static let MATCHING_PRODUCT_LIST = "/ProductListingSearch/matching/productListing/query/full"
    static let POSTED_MATCHING_PRODUCTS_FOR_REQUEST = "/ProductListing/category/active"
    
    //MARK: Apis calls
    public static func checkQuickShareAvailabilityForCurrentLoaction(latitude: Double,longitude: Double, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[CurrentCity.latitude] = String(latitude)
        params[CurrentCity.longitude] = String(longitude)
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + CHECK_QUICK_SHARE_AVAILABILITY 
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getAvailableCategoriesList(cityName: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[CurrentCity.city] = cityName
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_AVAILABLE_CATEGORY_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func addProduct(product: Product?, requestId: String?,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params = product?.getParamsMap() ?? [String : String]()
        params["requestId"] = requestId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + ADD_PRODUCT
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    public static func updateAddedProduct(productId: String,product: Product?, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params = product?.getParamsMap() ?? [String : String]()
        params["id"] = productId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + UPDATE_ADDED_PRODUCT
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getPostedProductsList(ownerId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableRequest.ownerId] = ownerId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_POSTED_PRODUCTS_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func deletePostedProduct(ownerId: String,id: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.id] = id
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + DELETE_POSTED_PRODUCT
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getRecentlyAddedItemsList(ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double,tabType: String?, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.offSet] = String(offSet)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[CategoryType.categoryType] = tabType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_RECENTLY_ADDED_ITEMS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func requestProduct(requestProduct: RequestProduct?, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params = requestProduct?.getParamsMap() ?? [String : String]()
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + REQUEST_PRODUCT
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getRecentRequestsList(ownerId: String,categoryCode: String,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableRequest.ownerId] = ownerId
        params[AvailableRequest.catCode] = categoryCode
        params[AvailableRequest.latitude] = String(latitude)
        params[AvailableRequest.longitude] = String(longitude)
        params[AvailableRequest.offSet] = String(offSet)
        params[AvailableRequest.maxDistance] = String(maxDistance)
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_RECENT_REQUESTS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getProductListBasedOnEnterdCharacters(query: String,ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double, tradeType: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.query] = query
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.offSet] = String(offSet)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + SEARCH_PRODUCTS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getPerticularProductForSearchedTitle(query: String,ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double,tradeType: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.query] = query
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.offSet] = String(offSet)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_PERTICULAR_PRODUCT_FOR_SEARCHED_TITLE
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func updateMyRequestStatus(ownerId: String,id: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.id] = id
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + DELETE_POSTED_REQUEST
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getMyPlacedOrders(borrowerId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableRequest.borrowerId] = borrowerId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_MY_PLACED_ORDERS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func cancelMyPlacedOrder(orderId: String,userId: String,reason: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        params[Order.reason] = reason
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + CANCEL_ORDER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getMyReceivedOrders(ownerId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableRequest.ownerId] = ownerId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_MY_RECEIVED_ORDERS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func acceptRecievedOrder(orderId: String,userId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + ACCEPT_ORDER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func rejectRecievedOrder(orderId: String,userId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + REJECT_ORDER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getPickUpOtp(orderId: String, userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_PICKUP_OTP
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func completePickUpProduct(orderId: String,pickupLat: Double, pickupLng: Double, pickupAddress: String, otp: String,handoverImageURL: String?,userId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.pickupLat] = String(pickupLat)
        params[Order.pickupLng] = String(pickupLng)
        params[Order.pickupAddress] = pickupAddress
        params[Order.otp] = otp
        params[Order.handoverImageURL] = handoverImageURL
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + COMPLETE_PICKUP_PRODUCT
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getReturnOtp(orderId: String, userId: String,damageAmount: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        params[Order.damageAmount] = damageAmount
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_RETURN_OTP
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func completeReturnProduct(orderId: String, userId: String,otp: String,returnImageURL: String?,damageAmount: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        params[Order.otp] = otp
        params[Order.returnImageURL] = returnImageURL
        params[Order.damageAmount] = damageAmount
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + COMPLETE_RETURN_PRODUCT
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getInvoiceForOrder(orderId: String, userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_INVOICE_FOR_ORDER
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getNumberOfViewsOfProduct(entityId: String, entityType: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.entityId] = entityId
        params[AvailableProduct.entityType] = entityType
        params[AvailableProduct.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_NUMBER_OF_VIEWS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func updateViewsOfProduct(entityId: String, entityType: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.entityId] = entityId
        params[AvailableProduct.entityType] = entityType
        params[AvailableProduct.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_NUMBER_OF_VIEWS // SAME API BUT JUST REQUEST TYPE IS POST FOR UPADTE
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getMyOrderPaidAndBalanceAmount(orderId: String, userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_MY_ORDER_PAID_AND_BALANCE
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func getPerticularProductRating(listingId: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.listingId] = listingId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_PRODUCT_RATING
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func upadteProductRating(listingId: String, rating: Int,userId: String,comment: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.listingId] = listingId
        params[Order.rating] = String(rating)
        params[Order.userId] = userId
        params[Order.comment] = comment
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + UPDATE_PRODUCT_RATING // SAME API BUT JUST REQUEST TYPE IS POST FOR UPADTE
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func addCommentToProduct(listingId: String, commentId: String?,userId: String,comment: String, parentId: String?,type: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.listingId] = listingId
        params[ProductComment.commentId] = commentId
        params[Order.userId] = userId
        params[ProductComment.comment] = comment
        params[ProductComment.parentId] = parentId
        params[ProductComment.type] = type
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + ADD_COMMENT
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    public static func getProductComments(listingId: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.listingId] = listingId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + ADD_COMMENT
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func payFailedAndOutstandingAmount(orderId: String,userId: String,typeList: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.orderId] = orderId
        params[Order.userId] = userId
        params[Order.typeList] = typeList
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + PAY_FAILED_AND_OUTSTANDING_AMOUNT
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    public static func getSeletedProduct(listingId: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.id] = listingId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_PARTICULAR_PRODUCT
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func getParticularOrder(listingId: String,userId: String,orderId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Order.listingId] = listingId
        params[Order.userId] = userId
        params[Order.orderId] = orderId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_PARTICULAR_ORDER
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func getMyPostedProduct(listingId: String,userId: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.id] = listingId
        params[Order.userId] = userId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + GET_MY_POSTED_PRODUCT
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func getMatchingRequestList(query: String,ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double,tradeType: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.query] = query
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.offSet] = String(offSet)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + MATCHING_REQUEST_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func notifyProductToRequestedUser(sellerId: String,borrowerId: Int,id: String,listingId: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableRequest.borrowerId] = String(borrowerId)
        params[AvailableRequest.sellerId] = sellerId
        params[AvailableRequest.id] = id
        params[AvailableRequest.listingId] = listingId
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + NOTIFY_PRODUCT_TO_REQUESTED_USER
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    
    public static func getMatchingProductList(query: String,ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,offSet: Int,maxDistance: Double,tradeType: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.query] = query
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.offSet] = String(offSet)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + MATCHING_PRODUCT_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    public static func getMyMatchingProductsForRequest(ownerId: String,categoryCode: String?,tradeType: String, completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + POSTED_MATCHING_PRODUCTS_FOR_REQUEST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    public static func getRequestsBasedOnEnterdCharacters(query: String,ownerId: String,categoryCode: String?,latitude: Double,longitude: Double,maxDistance: Double, tradeType: String,completionController: @escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[AvailableProduct.query] = query
        params[AvailableProduct.ownerId] = ownerId
        params[AvailableProduct.catCode] = categoryCode
        params[AvailableProduct.latitude] = String(latitude)
        params[AvailableProduct.longitude] = String(longitude)
        params[AvailableProduct.maxDistance] = String(maxDistance)
        params[AvailableProduct.tradeType] = tradeType
        let url = AppConfiguration.quickShareServerUrlIp + AppConfiguration.QS_serverPort + AppConfiguration.quickShareServerPath + SEARCH_REQUESTS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
}
