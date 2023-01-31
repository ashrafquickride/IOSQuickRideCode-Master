//
//  RequestsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class RequestsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var requestedUserImageView: UIImageView!
    @IBOutlet weak var requestedUserNameLabel: UILabel!
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    @IBOutlet weak var requestCommentsLabel: UILabel!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var shareButton: CustomUIButton!
    
    private var availableRequest: AvailableRequest?
    
    func initialiseRequirement(availableRequest: AvailableRequest){
        shareButton.changeBackgroundColorBasedOnSelection()
        getProductComments(availableRequest: availableRequest)
        self.availableRequest = availableRequest
        requestDescriptionLabel.text = availableRequest.description
        ImageCache.getInstance().setImageToView(imageView: categoryImage, imageUrl: availableRequest.categoryImageURL ?? "", placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
        requestTitle.text = availableRequest.title
        let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: availableRequest.categoryCode ?? "")
        categoryTypeLabel.text = category?.displayName
        requestedUserNameLabel.text = availableRequest.name
        ImageCache.getInstance().setImageToView(imageView: requestedUserImageView, imageUrl: availableRequest.imageURI, gender: availableRequest.gender ?? "", imageSize: ImageCache.DIMENTION_TINY)
        let requestedTimeInNSDate = DateUtils.getNSDateFromTimeStamp(timeStamp: availableRequest.requestedTime)
        let timeDiff = QuickShareUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: requestedTimeInNSDate)
        var distance = availableRequest.distance
        if timeDiff < 1{
            requestedDateLabel.text = "Today . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }else if timeDiff == 1{
            requestedDateLabel.text = "\(timeDiff) day ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }else{
            requestedDateLabel.text = "\(timeDiff) days ago . \(QuickShareUtils.checkDistnaceInMeterOrKm(distance: distance.roundToPlaces(places: 2)))"
        }
        showTradeType(availableRequest: availableRequest)
    }
    private func showTradeType(availableRequest: AvailableRequest){
        switch availableRequest.tradeType{
        case Product.RENT:
            rentView.isHidden = false
            sellView.isHidden = true
        case Product.SELL:
            rentView.isHidden = true
            sellView.isHidden = false
        default:
            rentView.isHidden = false
            sellView.isHidden = false
        }
    }
    func getProductComments(availableRequest: AvailableRequest){
        QuickShareRestClient.getProductComments(listingId: availableRequest.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productComments = Mapper<ProductComment>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ProductComment]()
                if productComments.count > 0{
                    self.requestCommentsLabel.text = String(productComments.count)
                }else{
                    self.requestCommentsLabel.text = ""
                }
            }
        }
    }
    
    @IBAction func requestShareButtonTapped(_ sender: Any) {
        QuickShareUrlHandler.prepareURLForDeepLink(producId: availableRequest?.id ?? "", type: QuickShareUrlHandler.PRODUCT_REQUEST) { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    @IBAction func offerProductTapped(_ sender: Any) {
        if let listingId = availableRequest?.listingId{
            offerYourPostedProductToRequestedUser(listingId:listingId)
        }else{
            getMyMatchingPostedProduct()
        }
    }
    
    private func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_product, arguments: [(availableRequest?.title ?? ""),urlString])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast(Strings.message_sent)
            } else {
                UIApplication.shared.keyWindow?.makeToast(Strings.message_sending_cancelled)
            }
        }
        parentViewController?.present(avc, animated: true, completion: nil)
    }
    private func offerYourPostedProductToRequestedUser(listingId: String){
        QuickShareRestClient.notifyProductToRequestedUser(sellerId: UserDataCache.getInstance()?.userId ?? "", borrowerId: availableRequest?.userId ?? 0, id: availableRequest?.id ?? "", listingId: listingId){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast("Notified to requestd user successfully")
            }
        }
    }
    
    func getMyMatchingPostedProduct(){
        QuickShareSpinner.start()
        QuickShareRestClient.getMyMatchingProductsForRequest(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: availableRequest?.categoryCode, tradeType: availableRequest?.tradeType ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let products = Mapper<PostedProduct>().mapArray(JSONObject: responseObject!["resultData"]) ?? [PostedProduct]()
                self.moveToOfferProductView(postedProducts: products)
            }
        }
    }
    
    func moveToOfferProductView(postedProducts: [PostedProduct]){
        guard let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: availableRequest?.categoryCode ?? "") else { return }
        if !postedProducts.isEmpty{
            let offerProductViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OfferProductViewController") as! OfferProductViewController
            offerProductViewController.initialiseMyPostedProducts(requetedUserId: availableRequest?.userId ?? 0,requestId: availableRequest?.id ?? "", categoryType: category, myPostedProducts: postedProducts)
            ViewControllerUtils.addSubView(viewControllerToDisplay: offerProductViewController)
        }else{
            let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
            addProductStepsViewController.initialiseAddingProductSteps(productType: category.displayName ?? "", isFromEditDetails: false, product: nil,categoryCode: category.code ?? "", requestId: availableRequest?.id, covidHome: availableRequest?.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
            self.parentViewController?.navigationController?.pushViewController(addProductStepsViewController, animated: true)
        }
    }
    
}
