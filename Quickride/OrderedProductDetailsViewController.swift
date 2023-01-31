//
//  OrderedProductDetailsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OrderedProductDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var orderCreatedSuccessView: UIView!
    @IBOutlet weak var orderCancelledSuccessView: UIView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var orderedProductDetailsViewModel = OrderedProductDetailsViewModel()
    
    func initialiseOrderDetails(order: Order,isFromMyOrder: Bool){
        orderedProductDetailsViewModel = OrderedProductDetailsViewModel(order: order,isFromMyOrder: isFromMyOrder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        if orderedProductDetailsViewModel.order?.sellerInfo != nil{
            orderedProductDetailsViewModel.productOwnerInfo = orderedProductDetailsViewModel.order?.sellerInfo
            orderedProductDetailsViewModel.getProductRating()
        }else{
            orderedProductDetailsViewModel.getProductOwnerBasicInfo()
        }
        orderedProductDetailsViewModel.getInvoice()
        if  orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.SELL || (orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT && orderedProductDetailsViewModel.order?.productOrder?.status != Order.CLOSED) {
            orderedProductDetailsViewModel.getMyOrderPaidAndBalance()
        }
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNotification()
        if !orderedProductDetailsViewModel.isFromMyOrder{
            orderCreatedSuccessView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.orderCreatedSuccessView.isHidden = true
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI(){
        detailsTableView.register(UINib(nibName: "BuyingOrRentProductTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyingOrRentProductTableViewCell")
        detailsTableView.register(UINib(nibName: "RentPeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "RentPeriodTableViewCell")
        detailsTableView.register(UINib(nibName: "DeliveryTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "DeliveryTypeTableViewCell")
        detailsTableView.register(UINib(nibName: "PostedByTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedByTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductStatusTableViewCell")
        detailsTableView.register(UINib(nibName: "PaymentBreakUpTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentBreakUpTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductPaymentDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductPaymentDetailsTableViewCell")
        detailsTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductSellStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductSellStatusTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductRatingTableViewCell")
        detailsTableView.register(UINib(nibName: "OrderRentPaymentDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderRentPaymentDetailsTableViewCell")
        textView.delegate = self
        detailsTableView.reloadData()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        detailsTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeReplyView(_:))))
    }
    
    //MARK: Notification
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedProductOwnerDetails), name: .receivedProductOwnerDetails ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tookPhotoWhileCollectingProduct), name: .tookPhotoWhileCollectingProduct ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rentalDaysUpdated), name: .rentalDaysUpdated ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pickupOtpReceived), name: .pickupOtpReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(placedOrderCancelled), name: .placedOrderCancelled ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invoiceRecieved), name: .invoiceRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myOrderPaidAndBalanceReceived), name: .myOrderPaidAndBalanceReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnProductCompleted), name: .returnProductCompleted ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ratingGivenToProduct), name: .ratingGivenToProduct ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedProductRating), name: .receivedProductRating ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productFeedbackInitiated), name: .productFeedbackInitiated ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPendingAmount), name: .showPendingAmount ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pendingAmountPaid), name: .pendingAmountPaid ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProductOrderStatus), name: .updateProductOrderStatus ,object: nil)
    }
    
    @objc func updateProductOrderStatus(_ notification: Notification){
        let productOrder = notification.userInfo?["productOrder"] as? ProductOrder
        if productOrder?.id == orderedProductDetailsViewModel.order?.productOrder?.id{
            orderedProductDetailsViewModel.order?.productOrder = productOrder
            detailsTableView.reloadData()
        }
    }
    
    @objc func pendingAmountPaid(_ notification: Notification){
        QuickShareSpinner.stop()
        UIApplication.shared.keyWindow?.makeToast( Strings.pending_bills_cleared)
        self.orderedProductDetailsViewModel.getMyOrderPaidAndBalance()
        self.orderedProductDetailsViewModel.getInvoice()
        detailsTableView.reloadData()
    }
    
    @objc func ratingGivenToProduct(_ notification: Notification){
        let rating = notification.userInfo?["rating"] as? Int
        orderedProductDetailsViewModel.rating = rating ?? 0
    }
    @objc func removeReplyView(_ sender :UITapGestureRecognizer){
        hideReplyView()
    }
    
    @objc func showPendingAmount(_ sender :UITapGestureRecognizer){
        detailsTableView.reloadData()
        if orderedProductDetailsViewModel.failedAmount != 0 && orderedProductDetailsViewModel.isShowedPendingScreen == false{
            let payOutstandingAmountViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PayOutstandingAmountViewController") as! PayOutstandingAmountViewController
            payOutstandingAmountViewController.initialiseOutstandingAmount(failedAmount: orderedProductDetailsViewModel.failedAmount, failedType: orderedProductDetailsViewModel.failedTransactionType, damageAmount: nil, extraRent: nil, extraDays: 0, perDayRent: 0) { (Amount) in
                QuickShareSpinner.start()
                self.orderedProductDetailsViewModel.payFailedAndOutstandingAmount(viewController: self)
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: payOutstandingAmountViewController)
        }
    }
    
    @objc func receivedProductRating(_ notification: Notification){
        detailsTableView.reloadData()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc func receivedProductOwnerDetails(_ notification: Notification){
        detailsTableView.reloadData()
    }
    @objc func tookPhotoWhileCollectingProduct(_ notification: Notification){
        let photo = notification.userInfo?["photoUrl"] as? String
        orderedProductDetailsViewModel.order?.productOrder?.returnHandOverPic = photo
    }
    
    @objc func rentalDaysUpdated(_ notification: Notification){
        let requestProduct = notification.userInfo?["productRequest"] as? RequestProduct
        orderedProductDetailsViewModel.order?.productOrder?.fromTimeInMs = requestProduct?.fromTime ?? 0
        orderedProductDetailsViewModel.order?.productOrder?.toTimeInMs = requestProduct?.toTime ?? 0
        detailsTableView.reloadData()
    }
    
    @objc func pickupOtpReceived(_ notification: Notification){
        let pickupOtp = notification.userInfo?["pickupOtp"] as? String
        orderedProductDetailsViewModel.order?.productOrder?.pickUpOtp = pickupOtp ?? ""
        orderedProductDetailsViewModel.order?.productOrder?.status = Order.PICKUP_IN_PROGRESS
        detailsTableView.reloadData()
        self.orderedProductDetailsViewModel.getMyOrderPaidAndBalance()
    }
    
    @objc func returnProductCompleted(_ notification: Notification){
        let productOrder = notification.userInfo?["productOrder"] as? ProductOrder
        orderedProductDetailsViewModel.order?.productOrder = productOrder
        detailsTableView.reloadData()
        orderedProductDetailsViewModel.getInvoice()
    }
    
    
    @objc func placedOrderCancelled(_ notification: Notification){
        QuickShareSpinner.stop()
        orderCancelledSuccessView.isHidden = false
        orderedProductDetailsViewModel.isRequiredToShowCancelOption = false
        detailsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.orderCancelledSuccessView.isHidden = true
        })
    }
    
    @objc func invoiceRecieved(_ notification: Notification){
        detailsTableView.reloadData()
    }
    
    @objc func myOrderPaidAndBalanceReceived(_ notification: Notification){
        detailsTableView.reloadData()
    }
    
    @objc func footerTapped(_ notification: Notification){
        let orderCancellationViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderCancellationViewController") as! OrderCancellationViewController
        orderCancellationViewController.initialiseOrderCancellationView(userType: Order.BUYER) { (reason) in
            QuickShareSpinner.start()
            self.orderedProductDetailsViewModel.cancelOrder(reason: reason)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: orderCancellationViewController)
    }
    
    @objc func productFeedbackInitiated(_ notification: Notification){
        let userProfile = UserDataCache.getInstance()?.userProfile
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  userProfile?.imageURI ?? "", gender:  userProfile?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        replyView.isHidden = false
        textView.text = Strings.reply_here
        replyView.addShadow()
        textView.becomeFirstResponder()
    }
    //MARK: Actions
    @IBAction func callButtonTapped(_ sender: Any) {
        if let userId = orderedProductDetailsViewModel.productOwnerInfo?.userId{
            callProductOwner(receiverId: StringUtils.getStringFromDouble(decimalNumber:userId), name: orderedProductDetailsViewModel.productOwnerInfo?.name ?? "")
        }
    }
    
    private func callProductOwner(receiverId: String,name: String){
        AppUtilConnect.callNumber(receiverId: receiverId, refId: Strings.profile,  name: name, targetViewController: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        if let userId = self.orderedProductDetailsViewModel.order?.postedProduct?.ownerId{
            chatWithProductOwner(userId: userId)
        }
    }
    private func chatWithProductOwner(userId: Double){
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func sendButtonTapped(_ sender: Any) {
        orderedProductDetailsViewModel.productFeedback = textView.text
        hideReplyView()
        detailsTableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if orderedProductDetailsViewModel.isFromMyOrder{
            if orderedProductDetailsViewModel.rating != 0{
                orderedProductDetailsViewModel.saveRating()
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: false)
            let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            ContainerTabBarViewController.indexToSelect = 2
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeTabBar, animated: false)
        }
    }
}
//MARK: UITableViewDataSource
extension OrderedProductDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if orderedProductDetailsViewModel.productOwnerInfo != nil{
                return 1
            }else{
                return 0
            }
        case 2:
            return 1
        case 3:
            if orderedProductDetailsViewModel.order?.productOrder?.status == Order.CLOSED && orderedProductDetailsViewModel.alreadyGivenRating >= 0 && orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 4:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 5:
            return 1
        case 6:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 7:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.SELL && orderedProductDetailsViewModel.orderPayment != nil{
                return 1
            }else if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                if orderedProductDetailsViewModel.orderPayment != nil && orderedProductDetailsViewModel.invoice != nil{
                    return 1
                }else if orderedProductDetailsViewModel.order?.productOrder?.status == Order.CLOSED && orderedProductDetailsViewModel.invoice != nil{
                    return 1
                }else{
                    return 0
                }
            }else{
                return 0
            }
        case 8:
            if (orderedProductDetailsViewModel.order?.productOrder?.status == Order.PLACED || orderedProductDetailsViewModel.order?.productOrder?.status == Order.ACCEPTED) && orderedProductDetailsViewModel.isRequiredToShowCancelOption{
                return 1 //cancel order
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BuyingOrRentProductTableViewCell", for: indexPath) as! BuyingOrRentProductTableViewCell
            let productOrder = orderedProductDetailsViewModel.order?.productOrder
            cell.initialiseProduct(modifiedTime: productOrder?.creationDateInMs, title: orderedProductDetailsViewModel.order?.postedProduct?.title ?? "", id: productOrder?.id, productImgList: orderedProductDetailsViewModel.order?.postedProduct?.imageList, requiredTradetype: productOrder?.tradeType ?? "", pricePerDay: productOrder?.pricePerDay ?? 0, rentPerMonth: 0, finalPrice: productOrder?.finalPrice ?? 0, deposite: productOrder?.deposit ?? 0, sellOrBuyText: Strings.buy)
            cell.showingProductDetails(postedProduct: orderedProductDetailsViewModel.order?.postedProduct, sellerInfo: orderedProductDetailsViewModel.order?.sellerInfo)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostedByTableViewCell", for: indexPath) as! PostedByTableViewCell
            let user = orderedProductDetailsViewModel.productOwnerInfo
            cell.initialiseProfileView(userId: user?.userId, userName: user?.name, companyName: user?.companyName, userImgUri: user?.imageURI, gender: user?.gender, profileVerificationData: user?.profileVerificationData, rating: Int(user?.rating ?? 0), noOfReviews: user?.noOfReviews ?? 0,cardTitle: Strings.owner)
            return cell
        case 2:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductStatusTableViewCell", for: indexPath) as! ProductStatusTableViewCell
                cell.initailseOrderStatusForRent(productOrder: orderedProductDetailsViewModel.order?.productOrder, postedProduct: orderedProductDetailsViewModel.order?.postedProduct)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductSellStatusTableViewCell", for: indexPath) as! ProductSellStatusTableViewCell
                cell.initailseOrderStatusForSell(productOrder: orderedProductDetailsViewModel.order?.productOrder, postedProduct: orderedProductDetailsViewModel.order?.postedProduct)
                return cell
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductRatingTableViewCell", for: indexPath) as! ProductRatingTableViewCell
            cell.initialiseRating(alreadyGivenRating: orderedProductDetailsViewModel.alreadyGivenRating, rating: orderedProductDetailsViewModel.rating, productFeedBack: orderedProductDetailsViewModel.productFeedback)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentPeriodTableViewCell", for: indexPath) as! RentPeriodTableViewCell
            cell.isRequireToHideEditButton = true
            cell.initialiseRentalDays(fromDate: orderedProductDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0, toDate: orderedProductDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTypeTableViewCell", for: indexPath) as! DeliveryTypeTableViewCell
            cell.initialiseDeliveryType(deliveryType: orderedProductDetailsViewModel.order?.productOrder?.deliveryType ?? "", address: orderedProductDetailsViewModel.order?.productOrder?.pickUpAddress ?? "")
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentBreakUpTableViewCell", for: indexPath) as! PaymentBreakUpTableViewCell
            let productOrder = orderedProductDetailsViewModel.order?.productOrder
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (orderedProductDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (orderedProductDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0)/1000))
            var deposite: Int?
            if orderedProductDetailsViewModel.order?.postedProduct?.status != Order.PLACED || orderedProductDetailsViewModel.order?.postedProduct?.status != Order.ACCEPTED{
                deposite = orderedProductDetailsViewModel.order?.postedProduct?.deposit
            }
            cell.initialiseAmountDetailsView(perDayPrice: productOrder?.pricePerDay,noOfDays: rentalDays, deposite: deposite)
            return cell
        case 7:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.SELL{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPaymentDetailsTableViewCell", for: indexPath) as! ProductPaymentDetailsTableViewCell
                cell.initialiseSellPaymentDetails(productOrder: orderedProductDetailsViewModel.order?.productOrder, orderPayment: orderedProductDetailsViewModel.orderPayment ?? OrderPayment())
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderRentPaymentDetailsTableViewCell", for: indexPath) as! OrderRentPaymentDetailsTableViewCell
                cell.initialiseRentPaymentDetails(productOrder: orderedProductDetailsViewModel.order?.productOrder, orderPayment: orderedProductDetailsViewModel.orderPayment ?? OrderPayment(), invoice: orderedProductDetailsViewModel.invoice ?? ProductOrderInvoice())
                return cell
            }
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: Strings.cancel_order)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDataSource
extension OrderedProductDetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 1:
            if orderedProductDetailsViewModel.productOwnerInfo != nil{
                return 10
            }else{
                return 0
            }
        case 2:
            return 10
        case 3:
            if orderedProductDetailsViewModel.order?.productOrder?.status == Order.CLOSED && orderedProductDetailsViewModel.alreadyGivenRating >= 0{
                return 10
            }else{
                return 0
            }
        case 4:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 10
            }else{
                return 0
            }
        case 5:
            return 10
        case 6:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 10
            }else{
                return 0
            }
        case 7:
            if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.SELL && orderedProductDetailsViewModel.orderPayment != nil{
                return 10
            }else if orderedProductDetailsViewModel.order?.productOrder?.tradeType == Product.RENT && orderedProductDetailsViewModel.orderPayment != nil && orderedProductDetailsViewModel.invoice != nil{
                return 10 //Payment details
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }
}
//MARK:UITableViewDataSource
extension OrderedProductDetailsViewController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text == nil || textView.text.isEmpty || textView.text ==  Strings.reply_here{
            textView.text = ""
            sendButton.isEnabled = false
            textView.textColor = .black
        }else{
            sendButton.isEnabled = true
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text.isEmpty || (textView.text.trimmingCharacters(in: NSCharacterSet.whitespaces)).count == 0{
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        hideReplyView()
    }
    private func hideReplyView(){
        replyView.isHidden = true
        textView.text = Strings.reply_here
        textView.endEditing(true)
        resignFirstResponder()
    }
}
