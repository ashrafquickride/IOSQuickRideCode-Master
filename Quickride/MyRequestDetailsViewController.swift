//
//  MyRequestDetailsViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyRequestDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var viewModel = MyRequestDetailsViewModel()
    
    func initialiseRequiremnet(postedRequest: PostedRequest){
        viewModel = MyRequestDetailsViewModel(postedRequest: postedRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getMatchingProductList()
        viewModel.getRequestComments()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func setUpUI(){
        detailsTableView.register(UINib(nibName: "RequirementDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequirementDetailsTableViewCell")
        detailsTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCommentsTableViewCell")
        detailsTableView.register(UINib(nibName: "MatchingProductTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingProductTableViewCell")
        detailsTableView.reloadData()
        textView.delegate = self
        textView.textColor = UIColor.black.withAlphaComponent(0.4)
    }
    @objc func removeReplyView(_ sender :UITapGestureRecognizer){
        hideReplyView()
    }
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(newCommentAdded), name: .newCommentAdded ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productCommentsReceived), name: .productCommentsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(replayInitiated), name: .replayInitiated ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkReceivedCommentIsForThisProductOrNot), name: .newProductCommentReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(matchingProductsReceived), name: .matchingProductsReceived ,object: nil)
    }
    
    @objc func checkReceivedCommentIsForThisProductOrNot(_ notification: Notification){
        guard let newComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        if newComment.listingId == viewModel.postedRequest.id{
            viewModel.requetComments.append(newComment)
            detailsTableView.reloadData()
        }
    }
    @objc func matchingProductsReceived(_ notification: Notification){
        if !viewModel.matchingProducts.isEmpty{
           detailsTableView.reloadData()
        }
    }
    
    @objc func productCommentsReceived(_ notification: Notification){
        detailsTableView.reloadData()
    }
    
    @objc func newCommentAdded(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        guard let newProductComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        viewModel.requetComments.append(newProductComment)
        hideReplyView()
        detailsTableView.reloadData()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc func footerTapped(_ notification: Notification){
        guard let footerSection = notification.userInfo?["section"] as? Int else { return }
        if footerSection == 1{
            guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: viewModel.postedRequest.categoryCode ?? "") else { return }
            let requestProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductViewController") as! RequestProductViewController
            requestProductViewController.initialiseRequestView(productType: category.displayName ?? "", categoryCode: viewModel.postedRequest.categoryCode ?? "", requestProduct: RequestProduct(postedRequest: viewModel.postedRequest), isFromCovid: viewModel.postedRequest.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
            self.navigationController?.pushViewController(requestProductViewController, animated: false)
        }else{
            let productListViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
            productListViewController.initialiseProductsListing(categoryCode: nil,title: Strings.matching_products, availableProducts: viewModel.matchingProducts)
            self.navigationController?.pushViewController(productListViewController, animated: true)
        }
    }
    
    @objc func replayInitiated(_ notification: Notification){
        let userProfile = UserDataCache.getInstance()?.userProfile
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  userProfile?.imageURI ?? "", gender:  userProfile?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        replyView.isHidden = false
        textView.text = Strings.reply_here
        replyView.addShadow()
        textView.becomeFirstResponder()
        viewModel.parentId = notification.userInfo?["parentId"] as? String
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendButtonTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        viewModel.addAnswerForComment(comment: textView.text)
    }
}
//MARK: UITableViewDataSource
extension MyRequestDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if viewModel.matchingProducts.count > 3{
                return 3
            }else{
                return viewModel.matchingProducts.count
            }
        case 3:
            if viewModel.matchingProducts.count > 3{
                return 1
            }else{
                return 0
            }
        case 4:
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
            cell.initialiseDetails(title: viewModel.postedRequest.title, description: viewModel.postedRequest.description, categoryCode: viewModel.postedRequest.categoryCode, categoryImageURL: nil, requestedTime: viewModel.postedRequest.requestedTime, distance: nil, tradeType: viewModel.postedRequest.tradeType ?? "", sellOrBuyText: Strings.buy)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: Strings.edit_details)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingProductTableViewCell", for: indexPath) as! MatchingProductTableViewCell
            cell.initialiseMatchingProduct(matchingProduct: viewModel.matchingProducts[indexPath.row])
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: String(format: Strings.pluse_count_more, arguments: [String(viewModel.matchingProducts.count - 3)]))
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentsTableViewCell", for: indexPath) as! ProductCommentsTableViewCell
            cell.initialiseAllCommentsOfProduct(productComments: viewModel.requetComments, isFromPostedProduct: true)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
//MARK: UITableViewDataSource
extension MyRequestDetailsViewController: UITableViewDelegate{
    //Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return 1
        }else if section == 1{
            return 10
        }else
            if section == 3 && !viewModel.matchingProducts.isEmpty{
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
    
    //Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && !viewModel.matchingProducts.isEmpty{
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 && !viewModel.matchingProducts.isEmpty{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = .white
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 200, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            titleLabel.text = Strings.matching_request.uppercased()
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            return nil
        }
    }
}
//MARK:UITableViewDataSource
extension MyRequestDetailsViewController: UITextViewDelegate{
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
