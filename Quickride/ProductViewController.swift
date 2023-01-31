//
//  ProductViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var productDetailsTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buyButton: QRCustomButton!
    @IBOutlet weak var rentButton: QRCustomButton!
    
    @IBOutlet weak var callButton: UIButton!
    
    private var productViewModel = ProductViewModel()
    
    func initialiseView(product: AvailableProduct,isFromOrder: Bool){
        productViewModel = ProductViewModel(product: product,isFromOrder: isFromOrder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productViewModel.getSimilarProducts()
        productViewModel.getNumberOfViewsOfProduct()
        productViewModel.updateProductViews()
        productViewModel.getProductComments()
        confirmNotification()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if productViewModel.isFromOrder{
            bottomView.isHidden = true
        }else{
            bottomView.isHidden = false
        }
        if productViewModel.product.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL{
            callButton.isHidden = false
        }else{
            callButton.isHidden = true
        }
    }
    
    private func prepareUI(){
        productDetailsTableView.register(UINib(nibName: "ProductImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductImageTableViewCell")
        productDetailsTableView.register(UINib(nibName: "ProductDescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDescriptionTableViewCell")
        productDetailsTableView.register(UINib(nibName: "ProductPostedByProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductPostedByProfileTableViewCell")
        productDetailsTableView.register(UINib(nibName: "HowRentalWorksTableViewCell", bundle: nil), forCellReuseIdentifier: "HowRentalWorksTableViewCell")
        productDetailsTableView.register(UINib(nibName: "SimilarProductsTableViewCell", bundle: nil), forCellReuseIdentifier: "SimilarProductsTableViewCell")
        productDetailsTableView.register(UINib(nibName: "EnterCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterCommentTableViewCell")
        productDetailsTableView.register(UINib(nibName: "ProductCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCommentsTableViewCell")
        productDetailsTableView.reloadData()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        if productViewModel.product.tradeType == Product.SELL{
            rentButton.isHidden = true
        }else if productViewModel.product.tradeType == Product.RENT{
            buyButton.isHidden = true
        }
    }
    
    //MARK: Notifications
    func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(showHowRentalWorks), name: .showHowRentalWorks ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSimilarItems), name: .receivedSimilarItems ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(numberOfViewsRecieved), name: .numberOfViewsRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newCommentAdded), name: .newCommentAdded ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productCommentsReceived), name: .productCommentsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAllComments), name: .showAllComments ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToProductComments), name: .goToProductComments ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkReceivedCommentIsForThisProductOrNot), name: .newProductCommentReceived ,object: nil)
    }
    
    @objc func checkReceivedCommentIsForThisProductOrNot(_ notification: Notification){
        guard let newComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        if newComment.listingId == productViewModel.product.productListingId{
            productViewModel.productComments.append(newComment)
            productDetailsTableView.reloadData()
        }
    }
    @objc func showHowRentalWorks(_ notification: Notification){
        productViewModel.isRequiredToShowHowRentalWorks = true
        productDetailsTableView.reloadData()
    }
    
    @objc func goToProductComments(_ notification: Notification){
        if productViewModel.productComments.count > 0{
            productViewModel.isRequiredToShowAllComments = true
            productDetailsTableView.reloadData()
            productDetailsTableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .bottom, animated: true)
        }else{
            productDetailsTableView.scrollToRow(at: IndexPath(row: 0, section: 5), at: .bottom, animated: true)
        }
    }
    
    @objc func showAllComments(_ notification: Notification){
        if !productViewModel.isRequiredToShowAllComments{
            productViewModel.isRequiredToShowAllComments = true
            productDetailsTableView.reloadData()
            if productViewModel.productComments.count > 0{
                productDetailsTableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .bottom, animated: true)
            }else{
                productDetailsTableView.scrollToRow(at: IndexPath(row: 0, section: 5), at: .bottom, animated: true)
            }
        }
    }
    @objc func receivedSimilarItems(_ notification: Notification){
        productDetailsTableView.reloadData()
    }
    @objc func numberOfViewsRecieved(_ notification: Notification){
        productDetailsTableView.reloadData()
    }
    @objc func productCommentsReceived(_ notification: Notification){
        productDetailsTableView.reloadData()
    }
    @objc func newCommentAdded(_ notification: Notification){
        guard let newProductComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        productViewModel.productComments.append(newProductComment)
        productViewModel.isRequiredToShowAllComments = true
        productDetailsTableView.reloadData()
        productDetailsTableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .bottom, animated: true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Actions
    @IBAction func buyButtonTapped(_ sender: Any) {
        moveToDeliveryTypeSelection(type: Product.SELL)
    }
    
    @IBAction func rentButtonTapped(_ sender: Any) {
        moveToDeliveryTypeSelection(type: Product.RENT)
    }
    
    private func moveToDeliveryTypeSelection(type: String){
        var productRequest = RequestProduct()
        productRequest.tradeType = type
        if productViewModel.product.locations.isEmpty == false{
            productRequest.requestLocationInfo = productViewModel.product.locations[0]
        }
        let selectDeliveryTypeViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectDeliveryTypeViewController") as! SelectDeliveryTypeViewController
        selectDeliveryTypeViewController.initialiseDeliveryAddressType(productRequest: productRequest, handler: {(productRequest) in
            self.moveToReviewAndPayScreen(productRequest: productRequest)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: selectDeliveryTypeViewController)
    }
    
    private func moveToReviewAndPayScreen(productRequest: RequestProduct){
        let productRequest = RequestProduct(borrowerId: UserDataCache.getInstance()?.userId, listingId: productViewModel.product.productListingId, fromTime: productRequest.fromTime, toTime: productRequest.toTime, requestingPricePerDay: productViewModel.product.pricePerDay, requestingPricePerWeek: productViewModel.product.pricePerMonth, requestingSellingPrice: productViewModel.product.finalPrice, locations: productViewModel.product.locations, categoryCode: productViewModel.product.categoryCode, title: productViewModel.product.title, description: productViewModel.product.description, tradeType: productRequest.tradeType,deliveryType: productRequest.deliveryType)
        let reviewAndPayViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ReviewAndPayViewController") as! ReviewAndPayViewController
        reviewAndPayViewController.initialiseReviewAndPayView(productRequest: productRequest, selectedProduct: productViewModel.product)
        self.navigationController?.pushViewController(reviewAndPayViewController, animated: true)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: Double(productViewModel.product.userId), isRideStarted: false, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        AppUtilConnect.callNumber(receiverId: String(productViewModel.product.userId), refId: Strings.profile,  name: productViewModel.product.userName!, targetViewController: self)
    }
}
//MARK:UITableViewDataSource
extension ProductViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if productViewModel.product.description != nil && productViewModel.product.description?.isEmpty == false{
                return 1
            }else{
                return 0
            }
        case 2:
            return 1
        case 3:
            if productViewModel.product.tradeType != Product.SELL{
                return 1
            }else{
                return 0
            }
        case 4:
            if !productViewModel.similarProducts.isEmpty{
                return 1
            }else{
                return 0
            }
        case 5:
            return 1
        case 6:
            if productViewModel.productComments.count > 0 && productViewModel.isRequiredToShowAllComments{
                return 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductImageTableViewCell", for: indexPath) as! ProductImageTableViewCell
            cell.initialiseProductImageAndDetails(availableProduct: productViewModel.product, noOfComments: productViewModel.productComments.count)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDescriptionTableViewCell", for: indexPath) as! ProductDescriptionTableViewCell
            cell.initialiseDescriptionView(descriptionText: productViewModel.product.description ?? "")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPostedByProfileTableViewCell", for: indexPath) as! ProductPostedByProfileTableViewCell
            cell.initialiseProfileView(availableProduct: productViewModel.product)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HowRentalWorksTableViewCell", for: indexPath) as! HowRentalWorksTableViewCell
            cell.showHowRentalWorks(isRequiredToShowFull: productViewModel.isRequiredToShowHowRentalWorks)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimilarProductsTableViewCell", for: indexPath) as! SimilarProductsTableViewCell
            cell.initialiseMostViewedproduct(similarProducts: productViewModel.similarProducts)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnterCommentTableViewCell", for: indexPath) as! EnterCommentTableViewCell
            cell.initialiseCommentView(listingId: productViewModel.product.productListingId ?? "", commentsCount: productViewModel.productComments.count,type: AvailableProduct.LISTING)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentsTableViewCell", for: indexPath) as! ProductCommentsTableViewCell
            cell.initialiseAllCommentsOfProduct(productComments: productViewModel.productComments,isFromPostedProduct: false)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}
