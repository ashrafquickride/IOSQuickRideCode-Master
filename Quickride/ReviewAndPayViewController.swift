//
//  ReviewAndPayViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReviewAndPayViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var bookingFeeLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    private var reviewAndPayViewModel = ReviewAndPayViewModel()
    
    func initialiseReviewAndPayView(productRequest: RequestProduct,selectedProduct: AvailableProduct){
        reviewAndPayViewModel = ReviewAndPayViewModel(productRequest: productRequest,selectedProduct: selectedProduct)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prpareView()
        confirmNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func prpareView(){
        detailsTableView.register(UINib(nibName: "BuyingOrRentProductTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyingOrRentProductTableViewCell")
        detailsTableView.register(UINib(nibName: "RentPeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "RentPeriodTableViewCell")
        detailsTableView.register(UINib(nibName: "DeliveryTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "DeliveryTypeTableViewCell")
        detailsTableView.register(UINib(nibName: "DepositePaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "DepositePaymentTableViewCell")
        detailsTableView.register(UINib(nibName: "PaymentBreakUpTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentBreakUpTableViewCell")
        detailsTableView.reloadData()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        reviewAndPayViewModel.productRequest.paymentMode = RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE
        let showingAmount = reviewAndPayViewModel.calculateFullAmountAndShow()
        bookingFeeLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(showingAmount)])
    }
    
    //MARK: Notification
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(userSelectedPaymentWay), name: .userSelectedPaymentWay ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestSentToSelectedProduct), name: .requestSentToSelectedProduct ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rentalDaysUpdated), name: .rentalDaysUpdated ,object: nil)
    }
    
    @objc func userSelectedPaymentWay(_ notification: Notification){
        let selectedPaymentWay = notification.userInfo?["paymentWay"] as? String
        reviewAndPayViewModel.productRequest.paymentMode = selectedPaymentWay
        let showingAmount = reviewAndPayViewModel.calculateFullAmountAndShow()
        bookingFeeLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(showingAmount)])
    }
    
    @objc func requestSentToSelectedProduct(_ notification: Notification){
        QuickShareSpinner.stop()
        guard let order = notification.userInfo?["order"] as? Order else { return }
        let reviewAndPayViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderedProductDetailsViewController") as! OrderedProductDetailsViewController
        reviewAndPayViewController.initialiseOrderDetails(order: order, isFromMyOrder: false)
        self.navigationController?.pushViewController(reviewAndPayViewController, animated: true)
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func rentalDaysUpdated(_ notification: Notification){
        let productRequest = notification.userInfo?["productRequest"] as? RequestProduct
        reviewAndPayViewModel.productRequest.fromTime = productRequest?.fromTime ?? 0
        reviewAndPayViewModel.productRequest.toTime = productRequest?.toTime ?? 0
        detailsTableView.reloadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        let postOrderAsRequirementViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PostOrderAsRequirementViewController") as! PostOrderAsRequirementViewController
        postOrderAsRequirementViewController.initialiseRequirementScreen { (result, title, description) in
            self.reviewAndPayViewModel.productRequest.postAsReq = result
            self.reviewAndPayViewModel.productRequest.title = title
            self.reviewAndPayViewModel.productRequest.description = description
                QuickShareSpinner.start()
            self.reviewAndPayViewModel.sendRequestToSelectedProduct(viewController: self)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: postOrderAsRequirementViewController)
    }
}
//MARK: UITableViewDataSource
extension ReviewAndPayViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if reviewAndPayViewModel.productRequest.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 2:
            return 1
        case 3:
            if reviewAndPayViewModel.productRequest.tradeType == Product.RENT{
                return 1
            }else{
                return 0
            }
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BuyingOrRentProductTableViewCell", for: indexPath) as! BuyingOrRentProductTableViewCell
            cell.initialiseProduct(modifiedTime: reviewAndPayViewModel.selectedProduct.modifiedTime, title: reviewAndPayViewModel.selectedProduct.title ?? "", id: reviewAndPayViewModel.selectedProduct.productListingId, productImgList: reviewAndPayViewModel.selectedProduct.productImgList, requiredTradetype: reviewAndPayViewModel.productRequest.tradeType ?? "", pricePerDay: reviewAndPayViewModel.selectedProduct.pricePerDay, rentPerMonth: reviewAndPayViewModel.selectedProduct.pricePerMonth, finalPrice: reviewAndPayViewModel.selectedProduct.finalPrice, deposite: reviewAndPayViewModel.selectedProduct.deposit, sellOrBuyText: Strings.buy)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentPeriodTableViewCell", for: indexPath) as! RentPeriodTableViewCell
            cell.initialiseRentalDays(fromDate: reviewAndPayViewModel.productRequest.fromTime, toDate: reviewAndPayViewModel.productRequest.toTime)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTypeTableViewCell", for: indexPath) as! DeliveryTypeTableViewCell
            cell.initialiseDeliveryType(deliveryType: reviewAndPayViewModel.productRequest.deliveryType ?? "", address: reviewAndPayViewModel.productRequest.requestLocationInfo?.address ?? "")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentBreakUpTableViewCell", for: indexPath) as! PaymentBreakUpTableViewCell
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: reviewAndPayViewModel.productRequest.toTime/1000), date2: NSDate(timeIntervalSince1970: reviewAndPayViewModel.productRequest.fromTime/1000))
            cell.initialiseAmountDetailsView(perDayPrice: reviewAndPayViewModel.selectedProduct.pricePerDay, noOfDays: rentalDays, deposite: reviewAndPayViewModel.selectedProduct.deposit)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DepositePaymentTableViewCell", for: indexPath) as! DepositePaymentTableViewCell
            cell.initialisePaymentView(productRequest: reviewAndPayViewModel.productRequest,selectedProduct: reviewAndPayViewModel.selectedProduct)
            return cell
            
        default:
            break
        }
        return UITableViewCell()
    }
}
//MARK: UITableViewDataSource
extension ReviewAndPayViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 1:
            if reviewAndPayViewModel.productRequest.tradeType == Product.RENT{
                return 10
            }else{
                return 0
            }
        case 2:
            return 10
        case 3:
            if reviewAndPayViewModel.productRequest.tradeType == Product.RENT{
                return 10
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
