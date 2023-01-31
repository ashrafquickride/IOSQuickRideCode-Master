//
//  RequestPostTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 07/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestPostTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestDescription: UILabel!
    @IBOutlet weak var requestStatusLabel: UILabel!
    @IBOutlet weak var requestStatusView: UIView!
    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var categoryType: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    
    private var postedRequest: PostedRequest?
    private var isFromCovid = false
    
    func initialiseRequestView(postedRequest: PostedRequest,isFromCovid: Bool){
        self.postedRequest = postedRequest
        self.isFromCovid = isFromCovid
        menuButton.changeBackgroundColorBasedOnSelection()
        requestedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: postedRequest.modifiedDate, timeFormat: DateUtils.DATE_FORMAT_D_MM)?.uppercased()
        requestTitle.text = postedRequest.title
        requestDescription.text = postedRequest.description
        let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: postedRequest.categoryCode ?? "")
        categoryType.text = category?.displayName
        showTradeType(postedRequest: postedRequest)
        productStatus(postedRequest: postedRequest)
    }
    
    private func showTradeType(postedRequest: PostedRequest){
        switch postedRequest.tradeType {
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
        case Product.SELL:
            sellView.isHidden = false
            rentView.isHidden = true
        default:
            rentView.isHidden = false
            sellView.isHidden = false
        }
    }
    
    private func productStatus(postedRequest: PostedRequest){
        switch postedRequest.status {
        case PostedProduct.REVIEW:
            requestStatusLabel.text = Strings.in_review.uppercased()
            requestStatusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            requestStatusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.ACTIVE:
            requestStatusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            requestStatusLabel.text = Strings.active.uppercased()
            requestStatusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case PostedProduct.REJECTED:
            requestStatusLabel.text = Strings.reject_caps
            requestStatusView.backgroundColor = .red
            requestStatusLabel.textColor = .red
        default:
            requestStatusLabel.text = postedRequest.status
            requestStatusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            requestStatusView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.delete, style: .default) { action -> Void in
            self.deletePostedRequest()
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.edit_details, style: .default) { action -> Void in
            self.editDetails()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true) {
        }
    }
    
    private func deletePostedRequest(){
        QuickShareSpinner.start()
        QuickShareRestClient.updateMyRequestStatus(ownerId: UserDataCache.getInstance()?.userId ?? "", id: postedRequest?.id ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast("Request Deleted")
                var userInfo = [String : Any]()
                userInfo["postedRequest"] = self.postedRequest
                NotificationCenter.default.post(name: .postedRequestDeleted, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    private func editDetails(){
        guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: postedRequest?.categoryCode ?? "") else { return }
        let requestProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductViewController") as! RequestProductViewController
        requestProductViewController.initialiseRequestView(productType: category.displayName ?? "", categoryCode: postedRequest?.categoryCode ?? "", requestProduct: RequestProduct(postedRequest: postedRequest ?? PostedRequest()),isFromCovid: isFromCovid)
        self.parentViewController?.navigationController?.pushViewController(requestProductViewController, animated: false)
    }
    
}
