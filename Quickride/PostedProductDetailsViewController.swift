//
//  PostedProductDetailsViewController.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PostedProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: Variables
    private var postedProductDetailsViewModel = PostedProductDetailsViewModel()
    
    func initialiseProductDetails(postedProduct: PostedProduct){
        postedProductDetailsViewModel = PostedProductDetailsViewModel(postedProduct: postedProduct)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postedProductDetailsViewModel.prepareImageList()
        if postedProductDetailsViewModel.postedProduct.status == PostedProduct.ACTIVE{
            postedProductDetailsViewModel.getMatchingRequestList()
        }
        postedProductDetailsViewModel.getProductComments()
        postedProductDetailsViewModel.getNumberOfViewsOfProduct()
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
        detailsTableView.register(UINib(nibName: "PostedProductImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedProductImagesTableViewCell")
        detailsTableView.register(UINib(nibName: "PostedProductDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedProductDetailsTableViewCell")
        detailsTableView.register(UINib(nibName: "addDiscriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "addDiscriptionTableViewCell")
        detailsTableView.register(UINib(nibName: "TableViewFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewFooterTableViewCell")
        detailsTableView.register(UINib(nibName: "ProductCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCommentsTableViewCell")
        detailsTableView.register(UINib(nibName: "MatchingRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingRequestTableViewCell")
        textView.delegate = self
        detailsTableView.reloadData()
        textView.textColor = UIColor.black.withAlphaComponent(0.4)
        detailsTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeReplyView(_:))))
    }
    
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(footerTapped), name: .footerTapped ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newCommentAdded), name: .newCommentAdded ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productCommentsReceived), name: .productCommentsReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(replayInitiated), name: .replayInitiated ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(numberOfViewsRecieved), name: .numberOfViewsRecieved ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkReceivedCommentIsForThisProductOrNot), name: .newProductCommentReceived ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(matchingRequestsReceived), name: .matchingRequestsReceived ,object: nil)
    }
    
    @objc func matchingRequestsReceived(_ notification: Notification){
        if !postedProductDetailsViewModel.matchingRequests.isEmpty{
            detailsTableView.reloadData()
        }
    }
    
    @objc func checkReceivedCommentIsForThisProductOrNot(_ notification: Notification){
        guard let newComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        if newComment.listingId == postedProductDetailsViewModel.postedProduct.id{
            postedProductDetailsViewModel.productComments.append(newComment)
            detailsTableView.reloadData()
        }
    }
    
    @objc func removeReplyView(_ sender :UITapGestureRecognizer){
        replyView.isHidden = true
        textView.text = Strings.reply_here
        textView.endEditing(true)
        resignFirstResponder()
    }
    
    @objc func footerTapped(_ notification: Notification){
        let section = notification.userInfo?["section"] as? Int
        if section == 2{
            let allRequestsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AllRequestsViewController") as! AllRequestsViewController
            allRequestsViewController.initialiseAllRequests(availableRequests: postedProductDetailsViewModel.matchingRequests)
            self.navigationController?.pushViewController(allRequestsViewController, animated: true)
        }else{
            guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: postedProductDetailsViewModel.postedProduct.categoryCode ?? "") else { return }
            let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
            addProductStepsViewController.initialiseAddingProductSteps(productType: category.displayName ?? "", isFromEditDetails: true, product: Product(postedProduct: postedProductDetailsViewModel.postedProduct), categoryCode: postedProductDetailsViewModel.postedProduct.categoryCode ?? "", requestId: nil, covidHome: postedProductDetailsViewModel.postedProduct.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
            self.navigationController?.pushViewController(addProductStepsViewController, animated: false)
        }
    }
    
    @objc func productCommentsReceived(_ notification: Notification){
        detailsTableView.reloadData()
    }
    @objc func newCommentAdded(_ notification: Notification){
        QuickShareSpinner.stop()
        guard let newProductComment = notification.userInfo?["productComment"] as? ProductComment else { return }
        postedProductDetailsViewModel.productComments.append(newProductComment)
        replyView.isHidden = true
        textView.text = Strings.reply_here
        textView.endEditing(true)
        detailsTableView.reloadData()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func replayInitiated(_ notification: Notification){
        let userProfile = UserDataCache.getInstance()?.userProfile
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl:  userProfile?.imageURI ?? "", gender:  userProfile?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        replyView.isHidden = false
        textView.text = Strings.reply_here
        replyView.addShadow()
        textView.becomeFirstResponder()
        postedProductDetailsViewModel.parentId = notification.userInfo?["parentId"] as? String
    }
    @objc func numberOfViewsRecieved(_ notification: Notification){
        detailsTableView.reloadData()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        QuickShareSpinner.start()
        postedProductDetailsViewModel.addAnswerForComment(comment: textView.text)
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:UITableViewDataSource
extension PostedProductDetailsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if postedProductDetailsViewModel.matchingRequests.count > 3{
                return 3
            }else{
                return postedProductDetailsViewModel.matchingRequests.count
            }
        case 2:
            if postedProductDetailsViewModel.matchingRequests.count > 3{
                return 1
            }else{
                return 0
            }
        case 3:
            return 1
        case 4:
            if postedProductDetailsViewModel.postedProduct.status == PostedProduct.ACTIVE || postedProductDetailsViewModel.postedProduct.status == PostedProduct.REVIEW || postedProductDetailsViewModel.postedProduct.status == PostedProduct.REJECTED{
                return 1
            }else{
                return 0
            }
        case 5:
            if postedProductDetailsViewModel.productComments.count > 0{
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostedProductImagesTableViewCell", for: indexPath) as! PostedProductImagesTableViewCell
            cell.initialiseProduct(postedProduct: postedProductDetailsViewModel.postedProduct, noOfViews: postedProductDetailsViewModel.noOfViews)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingRequestTableViewCell", for: indexPath) as! MatchingRequestTableViewCell
            cell.initialiseMatchingRequest(availableRequest: postedProductDetailsViewModel.matchingRequests[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: String(format: Strings.pluse_count_more, arguments: [String(postedProductDetailsViewModel.matchingRequests.count - 3)]))
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostedProductDetailsTableViewCell", for: indexPath) as! PostedProductDetailsTableViewCell
            cell.initialiseView(postedProduct: postedProductDetailsViewModel.postedProduct)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewFooterTableViewCell", for: indexPath) as! TableViewFooterTableViewCell
            cell.initialiseView(section: indexPath.section, footerText: Strings.edit_details)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentsTableViewCell", for: indexPath) as! ProductCommentsTableViewCell
            cell.initialiseAllCommentsOfProduct(productComments: postedProductDetailsViewModel.productComments,isFromPostedProduct: true)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}

//MARK:UITextViewDelegate
extension PostedProductDetailsViewController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text == nil || textView.text.isEmpty || textView.text ==  Strings.reply_here{
            textView.text = ""
            sendButton.isHidden = true
            textView.textColor = .black
        }else{
            sendButton.isHidden = false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text.isEmpty || (textView.text.trimmingCharacters(in: NSCharacterSet.whitespaces)).count == 0{
            sendButton.isHidden = true
        }else{
            sendButton.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        replyView.isHidden = true
        textView.text = Strings.reply_here
        textView.endEditing(true)
        resignFirstResponder()
    }
}
//MARK: UITableViewDataSource
extension PostedProductDetailsViewController: UITableViewDelegate{
    //Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !postedProductDetailsViewModel.matchingRequests.isEmpty{
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && !postedProductDetailsViewModel.matchingRequests.isEmpty{
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
    
    //Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        if section == 2 && postedProductDetailsViewModel.matchingRequests.count > 3{
            return 10
        }else if section == 5 && postedProductDetailsViewModel.productComments.count > 0{
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
