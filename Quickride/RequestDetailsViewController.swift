//
//  RequestDetailsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var requetsDetailsTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    private var requestDetailsViewModel = RequestDetailsViewModel()
    
    func initialiseReceivedOrder(order: Order){
        requestDetailsViewModel = RequestDetailsViewModel(order: order)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        confirmNOtification()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    private func prepareUI(){
        requetsDetailsTableView.register(UINib(nibName: "RequestedUserDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestedUserDetailsTableViewCell")
        requetsDetailsTableView.register(UINib(nibName: "RentPeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "RentPeriodTableViewCell")
        requetsDetailsTableView.register(UINib(nibName: "PaymentBreakUpTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentBreakUpTableViewCell")
        requetsDetailsTableView.register(UINib(nibName: "DeliveryTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "DeliveryTypeTableViewCell")
        requetsDetailsTableView.reloadData()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
    }
    //MARK: Notifications
    private func confirmNOtification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOrderRejected), name: .receivedOrderRejected ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOrderAccepted), name: .receivedOrderAccepted ,object: nil)
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func receivedOrderRejected(_ notification: Notification){
        QuickShareSpinner.stop()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func receivedOrderAccepted(_ notification: Notification){
        QuickShareSpinner.stop()
        moveToDetailsScreen()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func moveToDetailsScreen(){
        guard let acceptedOrder = requestDetailsViewModel.order else { return }
        let sellerOrderDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SellerOrderDetailsViewController") as! SellerOrderDetailsViewController
        sellerOrderDetailsViewController.initailiseReceivedOrder(order: acceptedOrder, isFromMyOrder: false)
        self.navigationController?.pushViewController(sellerOrderDetailsViewController, animated: true)
    }
    //MARK: Actions
    @IBAction func callButtonTapped(_ sender: Any) {
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: requestDetailsViewModel.order?.borrowerInfo?.userId), refId: Strings.profile,  name: requestDetailsViewModel.order?.borrowerInfo?.name ?? "", targetViewController: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        guard let userId = requestDetailsViewModel.order?.borrowerInfo?.userId else { return }
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        QuickShareSpinner.start()
        requestDetailsViewModel.acceptOrder()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.reject, style: .default) { action -> Void in
            QuickShareSpinner.start()
            self.requestDetailsViewModel.rejectOrder()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true) {
        }
    }
}
//MARK: UITableViewDataSource
extension RequestDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if requestDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
               return 0
            }
        case 2:
            return 1
        case 3:
            if requestDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
                return 1
            }else{
               return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestedUserDetailsTableViewCell", for: indexPath) as! RequestedUserDetailsTableViewCell
            cell.initialiseOrder(order: requestDetailsViewModel.order ?? Order())
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentPeriodTableViewCell", for: indexPath) as! RentPeriodTableViewCell
            cell.isRequireToHideEditButton = true
            cell.initialiseRentalDays(fromDate: requestDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0, toDate: requestDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTypeTableViewCell", for: indexPath) as! DeliveryTypeTableViewCell
            cell.initialiseDeliveryType(deliveryType: requestDetailsViewModel.order?.productOrder?.deliveryType ?? "", address: requestDetailsViewModel.order?.productOrder?.pickUpAddress ?? "")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentBreakUpTableViewCell", for: indexPath) as! PaymentBreakUpTableViewCell
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (requestDetailsViewModel.order?.productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (requestDetailsViewModel.order?.productOrder?.fromTimeInMs ?? 0)/1000))
            cell.initialiseAmountDetailsView(perDayPrice: requestDetailsViewModel.order?.productOrder?.pricePerDay, noOfDays: rentalDays, deposite: nil)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDataSource
extension RequestDetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 2:
            return 10
        case 1,3:
            if requestDetailsViewModel.order?.productOrder?.tradeType == Product.RENT{
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
