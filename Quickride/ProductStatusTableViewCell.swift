//
//  ProductStatusTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class ProductStatusTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title1InfoLabel: UILabel!
    @IBOutlet weak var status1ImageView: UIImageView!
    @IBOutlet weak var requestedDateLabel: UILabel!
    
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title2InfoLabel: UILabel!
    @IBOutlet weak var status2ImageView: UIImageView!
    @IBOutlet weak var acceptedDateLabel: UILabel!
    
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title3InfoLabel: UILabel!
    @IBOutlet weak var status3ImageView: UIImageView!
    @IBOutlet weak var payButton: QRCustomButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var collectedDateLabel: UILabel!
    
    @IBOutlet weak var title4Label: UILabel!
    @IBOutlet weak var title4InfoLabel: UILabel!
    @IBOutlet weak var status4ImageView: UIImageView!
    @IBOutlet weak var uploadPhotoView: UIView!
    @IBOutlet weak var uploadPhotoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var returnedDateLabel: UILabel!
    
    private var productOrder: ProductOrder?
    func initailseOrderStatusForRent(productOrder: ProductOrder?,postedProduct: PostedProduct?){
        self.productOrder = productOrder
        if productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
            title3InfoLabel.text = String(format: Strings.collect_product_info, arguments: [String(postedProduct?.deposit ?? 0)])
        }else{
            title3InfoLabel.text = Strings.get_otp_to_share
        }
        requestedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.creationDateInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        acceptedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.acceptedTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        collectedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.handOverTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        returnedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.returnHandOverTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        switch productOrder?.status {
        case Order.PLACED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
        case Order.ACCEPTED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            title1InfoLabel.text = ""
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            payButton.isHidden = false
            if productOrder?.remainingAmount != 0.0{
                payButton.setTitle(String(format: Strings.pay_amount, arguments: [String(productOrder?.remainingAmount ?? 0)]), for: .normal)
            }
            otpView.isHidden = true
        case Order.PICKUP_IN_PROGRESS:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            if productOrder?.pickUpOtp?.isEmpty == false{
                otpView.isHidden = false
                otpLabel.text = String(format: Strings.pickUp_otp, arguments: [(productOrder?.pickUpOtp ?? "")])
                otpView.drawDashedLineArroundView(view: otpView, color: UIColor.black)
                payButton.isHidden = true
            }else{
                otpView.isHidden = true
                payButton.isHidden = false
            }
        case Order.PICKUP_COMPETE:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            title3InfoLabel.text = ""
            otpView.isHidden = true
            payButton.isHidden = true
            uploadPhotoView.isHidden = false
            uploadPhotoViewHeightConstraint.constant = 70
        case Order.RETURN_PICKUP_IN_PROGRESS:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            title3InfoLabel.text = ""
            uploadPhotoView.isHidden = false
            uploadPhotoViewHeightConstraint.constant = 70
        case Order.CLOSED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            status4ImageView.isHidden = false
            title4Label.textColor = Colors.green
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            title3InfoLabel.text = ""
            title4InfoLabel.text = ""
            uploadPhotoView.isHidden = true
            uploadPhotoViewHeightConstraint.constant = 0
        default:
            break
        }
    }
    //Collect product:- Get pickup otp share with seller
    @IBAction func payButtonTapped(_ sender: Any) {
        payRemainingBalance()
    }
    private func payRemainingBalance(){
        QuickShareSpinner.start()
        QuickShareRestClient.getPickUpOtp(orderId: productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOtpResponse = Mapper<ProductOtpResponse>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : String]()
                userInfo["pickupOtp"] = productOtpResponse?.otp
                NotificationCenter.default.post(name: .pickupOtpReceived, object: nil, userInfo: userInfo)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                QuickShareSpinner.stop()
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if responseError?.errorCode == RideValidationUtils.INSUFFICIENT_BALANCE_FOR_BUY_OR_RENT
                    || responseError?.errorCode == RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE{
                    RideValidationUtils.handleBalanceInsufficientError(viewController:  self.parentViewController, title: Strings.low_bal_in_account, errorMessage: Strings.add_money_for_product, primaryAction: "", secondaryAction: nil, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.payRemainingBalance()
                    })
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    //Return
    @IBAction func takePhotoTapped(_ sender: Any) {
        takePictureOfProductWhileReturning()
    }
    private func takePictureOfProductWhileReturning(){
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: parentViewController,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    @IBAction func whyTapped(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.why_product_photo_title, titleColor: nil, message: Strings.why_product_photo_title_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @IBAction func enterOtpTapped(_ sender: Any) {
        if (productOrder?.returnHandOverPic) != nil{
            let enterHandoverOtpViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EnterHandoverOtpViewController") as! EnterHandoverOtpViewController
            enterHandoverOtpViewController.initialiseOtpView(type: EnterHandoverOtpViewModel.RETURN_PRODUCT, productOrder: productOrder ?? ProductOrder()) { (otp) in
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: enterHandoverOtpViewController)
        }else{
            UIApplication.shared.keyWindow?.makeToast( "Upload product photo")
        }
    }
}
extension ProductStatusTableViewCell: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if let picture = image{
            QuickShareSpinner.start()
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: picture), targetViewController: self.parentViewController, completionHandler: {(responseObject, error) in
                QuickShareSpinner.stop()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                    let imageUrl = responseObject!["resultData"] as? String
                    let url = imageUrl?.trimmingCharacters(in: .whitespaces)
                    var userInfo = [String : String]()
                    userInfo["photoUrl"] = url
                    self.takePhotoButton.setTitle("Photo Uploaded", for: .normal)
                    self.productOrder?.returnHandOverPic = url
                    NotificationCenter.default.post(name: .tookPhotoWhileCollectingProduct, object: nil, userInfo: userInfo)
                }
            })
        }
    }
}
