//
//  SellerOrderDetailsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SellerOrderDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var orderCancelledSuccessView: UIView!
    
    private var sellerOrderDetailsViewModel = SellerOrderDetailsViewModel()
    func initailiseReceivedOrder(order: Order,isFromMyOrder: Bool){
        sellerOrderDetailsViewModel = SellerOrderDetailsViewModel(order: order, isFromMyOrder: isFromMyOrder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setUpUI()
        sellerOrderDetailsViewModel.getInvoice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI(){
        detailsTableView.register(UINib(nibName: "BuyingOrRentProductTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyingOrRentProductTableViewCell")
        detailsTableView.register(UINib(nibName: "RentPeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "RentPeriodTableViewCell")
        detailsTableView.register(UINib(nibName: "DeliveryTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "DeliveryTypeTableViewCell")
        detailsTableView.register(UINib(nibName: "RequestedByUserTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestedByUserTableViewCell")
        detailsTableView.register(UINib(nibName: "PaymentBreakUpTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentBreakUpTableViewCell")
        detailsTableView.register(UINib(nibName: "SellerOrderStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "SellerOrderStatusTableViewCell")
        detailsTableView.register(UINib(nibName: "SellingInvoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "SellingInvoiceTableViewCell")
        detailsTableView.register(UINib(nibName: "RentInvoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "RentInvoiceTableViewCell")
        detailsTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        detailsTableView.reloadData()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
    }
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(returnOtpReceived), name: .returnOtpReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tookPhotoWhileCollectingProduct), name: .tookPhotoWhileCollectingProduct ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invoiceRecieved), name: .invoiceRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pickUpCompleted), name: .pickUpCompleted ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOrderRejected), name: .receivedOrderRejected ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDamageAmount), name: .showDamageAmount ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProductOrderStatus), name: .updateProductOrderStatus ,object: nil)
    }
    
    @objc func updateProductOrderStatus(_ notification: Notification){
        let productOrder = notification.userInfo?["productOrder"] as? ProductOrder
        if productOrder?.id == sellerOrderDetailsViewModel.order?.productOrder?.id{
            sellerOrderDetailsViewModel.order?.productOrder = productOrder
            detailsTableView.reloadData()
        }
    }
    
    @objc func showDamageAmount(_ notification: Notification){
        let damageAmount = notification.userInfo?["damageAmount"] as? String
        sellerOrderDetailsViewModel.order?.productOrder?.damageAmount = Double(damageAmount ?? "") ?? 0
        detailsTableView.reloadData()
    }
    
    @objc func footerTapped(_ notification: Notification){
        let orderCancellationViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderCancellationViewController") as! OrderCancellationViewController
        orderCancellationViewController.initialiseOrderCancellationView(userType: Order.SELLER) { (reason) in
            QuickShareSpinner.start()
            self.sellerOrderDetailsViewModel.cancelOrder(reason: reason)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: orderCancellationViewController)
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func receivedOrderRejected(_ notification: Notification){
        QuickShareSpinner.stop()
        orderCancelledSuccessView.isHidden = false
        sellerOrderDetailsViewModel.showCancelOption = false
        detailsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.orderCancelledSuccessView.isHidden = true
        })
    }
    
    @objc func tookPhotoWhileCollectingProduct(_ notification: Notification){
        let photo = notification.userInfo?["photoUrl"] as? String
        sellerOrderDetailsViewModel.order?.productOrder?.handOverPic = photo
    }
    
    @objc func pickUpCompleted(_ notification: Notification){
        let productOrder = notification.userInfo?["productOrder"] as? ProductOrder
        sellerOrderDetailsViewModel.order?.productOrder = productOrder
        detailsTableView.reloadData()
        sellerOrderDetailsViewModel.getInvoice()
    }
    
    @objc func returnOtpReceived(_ notification: Notification){
        let returnOtp = notification.userInfo?["returnOtp"] as? String
        sellerOrderDetailsViewModel.order?.productOrder?.returnOtp = returnOtp
        sellerOrderDetailsViewModel.order?.productOrder?.status = Order.RETURN_PICKUP_IN_PROGRESS
        detailsTableView.reloadData()
    }
    @objc func invoiceRecieved(_ notification: Notification){
        detailsTableView.reloadData()
    }
    //MARK: Actions
    @IBAction func callButtonTapped(_ sender: Any) {
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: sellerOrderDetailsViewModel.order?.borrowerInfo?.userId), refId: Strings.profile,  name: sellerOrderDetailsViewModel.order?.borrowerInfo?.name ?? "", targetViewController: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        guard let userId = sellerOrderDetailsViewModel.order?.borrowerInfo?.userId else { return }
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if sellerOrderDetailsViewModel.isFromMyOrder{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
//MARK: UITableViewDataSource
extension SellerOrderDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if sellerOrderDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            if sellerOrderDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 6:
            if sellerOrderDetailsViewModel.order?.productOrder?.status == Order.CLOSED && sellerOrderDetailsViewModel.invoice != nil{
                return 1
            }else{
                return 0
            }
        case 7:
            if (sellerOrderDetailsViewModel.order?.productOrder?.status == Order.ACCEPTED || sellerOrderDetailsViewModel.order?.productOrder?.status == Order.PICKUP_IN_PROGRESS)  && sellerOrderDetailsViewModel.showCancelOption{
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
            cell.initialiseProduct(modifiedTime: sellerOrderDetailsViewModel.order?.productOrder?.creationDateInMs, title: sellerOrderDetailsViewModel.order?.postedProduct?.title ?? "", id: sellerOrderDetailsViewModel.order?.productOrder?.id, productImgList: sellerOrderDetailsViewModel.order?.postedProduct?.imageList, requiredTradetype: sellerOrderDetailsViewModel.order?.productOrder?.tradeType ?? "", pricePerDay: sellerOrderDetailsViewModel.order?.productOrder?.pricePerDay ?? 0, rentPerMonth: 0, finalPrice: sellerOrderDetailsViewModel.order?.productOrder?.finalPrice ?? 0,deposite: sellerOrderDetailsViewModel.order?.productOrder?.deposit ?? 0, sellOrBuyText: Strings.sell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestedByUserTableViewCell", for: indexPath) as! RequestedByUserTableViewCell
            cell.initialiseProfileView(borrowerInfo: sellerOrderDetailsViewModel.order?.borrowerInfo)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentPeriodTableViewCell", for: indexPath) as! RentPeriodTableViewCell
            cell.isRequireToHideEditButton = true
            cell.initialiseRentalDays(fromDate: sellerOrderDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0, toDate: sellerOrderDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTypeTableViewCell", for: indexPath) as! DeliveryTypeTableViewCell
            cell.initialiseDeliveryType(deliveryType: sellerOrderDetailsViewModel.order?.productOrder?.deliveryType ?? "", address: sellerOrderDetailsViewModel.order?.productOrder?.pickUpAddress ?? "")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SellerOrderStatusTableViewCell", for: indexPath) as! SellerOrderStatusTableViewCell
            cell.initailseSellerOrderStatusView(productOrder: sellerOrderDetailsViewModel.order?.productOrder, postedProduct: sellerOrderDetailsViewModel.order?.postedProduct, returnOTp: sellerOrderDetailsViewModel.returnOtp)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentBreakUpTableViewCell", for: indexPath) as! PaymentBreakUpTableViewCell
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (sellerOrderDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (sellerOrderDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0)/1000))
            cell.initialiseAmountDetailsView(perDayPrice: sellerOrderDetailsViewModel.order?.productOrder?.pricePerDay, noOfDays: rentalDays, deposite: nil)
            return cell
        case 6:
            if sellerOrderDetailsViewModel.order?.productOrder?.tradeType == Product.SELL{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SellingInvoiceTableViewCell", for: indexPath) as! SellingInvoiceTableViewCell
                cell.initailisePaymnetDetails(productOrder: sellerOrderDetailsViewModel.order?.productOrder, productOrderInvoice: sellerOrderDetailsViewModel.invoice ?? ProductOrderInvoice())
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RentInvoiceTableViewCell", for: indexPath) as! RentInvoiceTableViewCell
                cell.initailisePaymnetDetails(productOrder: sellerOrderDetailsViewModel.order?.productOrder, productOrderInvoice: sellerOrderDetailsViewModel.invoice ?? ProductOrderInvoice())
                return cell
            }
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: Strings.cancel_order)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDataSource
extension SellerOrderDetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 1:
            return 10
        case 2:
            if sellerOrderDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 10
            }else{
                return 0
            }
        case 3:
            return 10 
        case 4:
            return 10
        case 5:
            if sellerOrderDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 10
            }else{
                return 0
            }
        case 6:
            if sellerOrderDetailsViewModel.order?.productOrder?.status == Order.ACCEPTED || sellerOrderDetailsViewModel.order?.productOrder?.status == Order.PICKUP_IN_PROGRESS{
                return 10 //cancel order
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
