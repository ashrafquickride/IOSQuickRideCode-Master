//
//  RequirementRequestDetailsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequirementRequestDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var bottomView: UIView!
    
    private var viewModel = RequirementRequestDetailsViewModel()
    
    func initialiseRequiremnet(availableRequest: AvailableRequest){
        viewModel = RequirementRequestDetailsViewModel(availableRequest: availableRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.addShadow()
        viewModel.getRequestComments()
        setUpUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func setUpUI(){
        detailsTableView.register(UINib(nibName: "RequirementDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequirementDetailsTableViewCell")
        detailsTableView.register(UINib(nibName: "PostedByTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedByTableViewCell")
        detailsTableView.register(UINib(nibName: "EnterCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterCommentTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCommentsTableViewCell")
        detailsTableView.reloadData()
    }
    
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(newCommentAdded), name: .newCommentAdded ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productCommentsReceived), name: .productCommentsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkReceivedCommentIsForThisProductOrNot), name: .newProductCommentReceived ,object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(matchingProductsReceived), name: .matchingProductsReceived ,object: nil)
    }
    
    @objc func checkReceivedCommentIsForThisProductOrNot(_ notification: Notification){
        guard let newComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        if newComment.listingId == viewModel.availableRequest.id{
            viewModel.requetComments.append(newComment)
            detailsTableView.reloadData()
        }
    }
    
    @objc func productCommentsReceived(_ notification: Notification){
        detailsTableView.reloadData()
    }
    @objc func matchingProductsReceived(_ notification: Notification){
         guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: viewModel.availableRequest.categoryCode ?? "") else { return }
        if !viewModel.matchingPostedProducts.isEmpty{
            let offerProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OfferProductViewController") as! OfferProductViewController
            offerProductViewController.initialiseMyPostedProducts(requetedUserId: viewModel.availableRequest.userId,requestId: viewModel.availableRequest.id ?? "", categoryType: category, myPostedProducts: viewModel.matchingPostedProducts)
            ViewControllerUtils.addSubView(viewControllerToDisplay: offerProductViewController)
        }else{
            let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
            addProductStepsViewController.initialiseAddingProductSteps(productType: category.displayName ?? "", isFromEditDetails: false, product: nil,categoryCode: category.code ?? "", requestId: viewModel.availableRequest.id, covidHome: viewModel.availableRequest.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
            self.navigationController?.pushViewController(addProductStepsViewController, animated: true)
        }
    }
    
    @objc func newCommentAdded(_ notification: Notification){
        guard let newProductComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        viewModel.requetComments.append(newProductComment)
        detailsTableView.reloadData()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @IBAction func offerProductTapped(_ sender: Any) {
        if let listingId = viewModel.availableRequest.listingId{
            viewModel.offerYourPostedProductToRequestedUser()
        }else{
            viewModel.getMyMatchingPostedProduct()
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.isFromQuickShare = true
        viewController.initializeDataBeforePresentingView(ride: nil, userId: Double(viewModel.availableRequest.userId), isRideStarted: false, listener: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        AppUtilConnect.callNumber(receiverId: String(self.viewModel.availableRequest.userId), refId: Strings.profile,  name: self.viewModel.availableRequest.name ?? "", targetViewController: self)
    }
}
//MARK: UITableViewDataSource
extension RequirementRequestDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            if viewModel.requetComments.count > 0{
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequirementDetailsTableViewCell", for: indexPath) as! RequirementDetailsTableViewCell
            cell.initialiseDetails(title: viewModel.availableRequest.title, description: viewModel.availableRequest.description, categoryCode: viewModel.availableRequest.categoryCode, categoryImageURL: viewModel.availableRequest.categoryImageURL, requestedTime: viewModel.availableRequest.requestedTime, distance: viewModel.availableRequest.distance, tradeType: viewModel.availableRequest.tradeType ?? "", sellOrBuyText: Strings.sell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostedByTableViewCell", for: indexPath) as! PostedByTableViewCell
            cell.initialiseProfileView(userId: Double(viewModel.availableRequest.userId), userName: viewModel.availableRequest.name, companyName: viewModel.availableRequest.companyName, userImgUri: viewModel.availableRequest.imageURI, gender: viewModel.availableRequest.gender, profileVerificationData: viewModel.availableRequest.profileVerificationData, rating: viewModel.availableRequest.rating, noOfReviews: viewModel.availableRequest.noOfReviews,cardTitle: Strings.requested_by)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnterCommentTableViewCell", for: indexPath) as! EnterCommentTableViewCell
            cell.initialiseCommentView(listingId: viewModel.availableRequest.id ?? "", commentsCount: viewModel.requetComments.count,type: AvailableProduct.REQUEST)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentsTableViewCell", for: indexPath) as! ProductCommentsTableViewCell
            cell.initialiseAllCommentsOfProduct(productComments: viewModel.requetComments, isFromPostedProduct: false)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDataSource
extension RequirementRequestDetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1{
            return 10
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }
}
