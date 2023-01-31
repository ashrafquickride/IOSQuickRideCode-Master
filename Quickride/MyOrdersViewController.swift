//
//  MyOrdersViewController.swift
//  Quickride
//
//  Created by HK on 08/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyOrdersViewController: UIViewController {
    
    //MARK:Outlets
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var ordersTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var orderEmptyView: UIView!
    @IBOutlet weak var emptyTextLabel: UILabel!
    @IBOutlet weak var browseNowButton: QRCustomButton!
    
    private var viewModel = MyOrdersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QuickShareSpinner.start()
        viewModel.getRecievedOrdersList()
        viewModel.getMyplacedaOrdersList()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func reloadOrderTableView(isRequiredToCheckContent: Bool){
        if viewModel.segmentControl == 0 && viewModel.acceptedOrders.isEmpty && viewModel.receivedOrders.isEmpty{
            if !viewModel.placedOrders.isEmpty && isRequiredToCheckContent{
                viewModel.segmentControl = 1
                segmentControl.selectedSegmentIndex = 1
                orderEmptyView.isHidden = true
                ordersTableView.isHidden = false
                ordersTableView.reloadData()
            }else{
                orderEmptyView.isHidden = false
                browseNowButton.isHidden = true
                emptyTextLabel.text = Strings.no_received_order
                ordersTableView.isHidden = true
            }
        }else if viewModel.segmentControl == 1 && viewModel.placedOrders.isEmpty{
            orderEmptyView.isHidden = false
            browseNowButton.isHidden = false
            emptyTextLabel.text = Strings.no_placed_order
            ordersTableView.isHidden = true
        }else{
            orderEmptyView.isHidden = true
            ordersTableView.isHidden = false
            ordersTableView.reloadData()
        }
    }
    
    private func setUpUI(){
        ordersTableView.register(UINib(nibName: "ReceivingOrdersTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceivingOrdersTableViewCell")
        ordersTableView.register(UINib(nibName: "ReceivedOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceivedOrderTableViewCell")
        ordersTableView.register(UINib(nibName: "PlacedOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "PlacedOrderTableViewCell")
    }
    
    //MARK: Notifications
    private func confirmNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOrderRejected), name: .receivedOrderRejected ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(placedOrderCancelled), name: .placedOrderCancelled ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myOrdersRecieved), name: .myOrdersRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myPlacedOrdersRecieved), name: .myPlacedOrdersRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAndUpdateOrderListAndStatus), name: .updateProductOrderStatus ,object: nil)
    }
    
    @objc func receivedOrderRejected(_ notification: Notification){
        let rejectedOrder = notification.userInfo?["order"] as? ProductOrder
        var orders = [Order]()
        for order in viewModel.receivedOrders{
            if rejectedOrder?.id != order.productOrder?.id{
                orders.append(order)
            }
        }
        viewModel.receivedOrders = orders
        reloadOrderTableView(isRequiredToCheckContent: false)
    }
    
    @objc func placedOrderCancelled(_ notification: Notification){
        let cancelledOrder = notification.userInfo?["order"] as? ProductOrder
        var orders = [Order]()
        for order in viewModel.placedOrders{
            if cancelledOrder?.id != order.productOrder?.id{
                orders.append(order)
            }
        }
        viewModel.placedOrders = orders
        reloadOrderTableView(isRequiredToCheckContent: false)
    }
    
    @objc func myOrdersRecieved(_ notification: Notification){
        QuickShareSpinner.stop()
        reloadOrderTableView(isRequiredToCheckContent: false)
    }
    
    @objc func myPlacedOrdersRecieved(_ notification: Notification){
        QuickShareSpinner.stop()
        reloadOrderTableView(isRequiredToCheckContent: false)
    }
    
    @objc func checkAndUpdateOrderListAndStatus(_ notification: Notification){
        guard let productOrder = notification.userInfo?["productOrder"] as? ProductOrder else { return}
        viewModel.updateOrderListAndStatus(productOrder: productOrder)
    }
    
    @IBAction func browseNowTapped(_ sender: Any) {
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        let availableProducts = QuickShareCache.getInstance()?.availableProducts ?? [AvailableProduct]()
        productListViewController.initialiseProductsListing(categoryCode: nil,title: Strings.recentlyAddedProducts, availableProducts: availableProducts)
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}
//MARK:UITableViewDataSource
extension MyOrdersViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.segmentControl == 0{
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.segmentControl == 0{
            if section == 0{
                return viewModel.receivedOrders.count
            }else{
                return viewModel.acceptedOrders.count
            }
        }else{
            return viewModel.placedOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewModel.segmentControl == 0{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedOrderTableViewCell", for: indexPath) as! ReceivedOrderTableViewCell
                cell.initialiseOrder(order: viewModel.receivedOrders[indexPath.row])
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivingOrdersTableViewCell", for: indexPath) as! ReceivingOrdersTableViewCell
                cell.initialiseOrder(order: viewModel.acceptedOrders[indexPath.row])
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlacedOrderTableViewCell", for: indexPath) as! PlacedOrderTableViewCell
            cell.initialisePlacedProduct(postedProduct: viewModel.placedOrders[indexPath.row].postedProduct ?? PostedProduct(), productOrder:viewModel.placedOrders[indexPath.row].productOrder ?? ProductOrder())
            return cell
        }
    }
}
//MARK:Outlets
extension MyOrdersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.segmentControl == 0{
            if indexPath.section == 0{
                let requestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestDetailsViewController") as! RequestDetailsViewController
                requestDetailsViewController.initialiseReceivedOrder(order: viewModel.receivedOrders[indexPath.row])
                self.navigationController?.pushViewController(requestDetailsViewController, animated: true)
            }else{
                let sellerOrderDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SellerOrderDetailsViewController") as! SellerOrderDetailsViewController
                sellerOrderDetailsViewController.initailiseReceivedOrder(order: viewModel.acceptedOrders[indexPath.row], isFromMyOrder: true)
                self.navigationController?.pushViewController(sellerOrderDetailsViewController, animated: true)
            }
        }else{
            if viewModel.placedOrders[indexPath.row].productOrder?.status != Order.CANCELLED{
                let orderedProductDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrderedProductDetailsViewController") as! OrderedProductDetailsViewController
                orderedProductDetailsViewController.initialiseOrderDetails(order: viewModel.placedOrders[indexPath.row], isFromMyOrder: true)
                self.navigationController?.pushViewController(orderedProductDetailsViewController, animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.order_rejected)
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
//Orders section
extension MyOrdersViewController{
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.view.endEditing(false)
        moveToSelectedView(index: segmentControl.selectedSegmentIndex)
    }
    
    private func moveToSelectedView(index : Int){
        AppDelegate.getAppDelegate().log.debug("moveToSelectedView()")
        if index == 0{
            viewModel.segmentControl = 0
        }else{
            viewModel.segmentControl = 1
        }
        reloadOrderTableView(isRequiredToCheckContent: false)
    }
}
