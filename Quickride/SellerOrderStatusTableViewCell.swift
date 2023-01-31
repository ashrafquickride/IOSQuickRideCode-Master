//
//  SellerOrderStatusTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class SellerOrderStatusTableViewCell: UITableViewCell {
    
    //MARK:Outlets
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title1InfoLabel: UILabel!
    @IBOutlet weak var status1ImageView: UIImageView!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title2InfoLabel: UILabel!
    @IBOutlet weak var status2ImageView: UIImageView!
    @IBOutlet weak var uploadPhotoView: UIView!
    @IBOutlet weak var getOTpButton: UIButton!
    @IBOutlet weak var returnProductView: UIView!
    @IBOutlet weak var returnProductViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title3InfoLabel: UILabel!
    @IBOutlet weak var status3ImageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var damagedProductButton: UIButton!
    @IBOutlet weak var acceptedDateLabel: UILabel!
    @IBOutlet weak var hondoverDateLabel: UILabel!
    @IBOutlet weak var returnedDateLabel: UILabel!
    
    private var productOrder: ProductOrder?
    func initailseSellerOrderStatusView(productOrder: ProductOrder?,postedProduct: PostedProduct?, returnOTp: String?){
        self.productOrder = productOrder
        if productOrder?.tradeType == Product.SELL{
            returnProductView.isHidden = true
            progressView.isHidden = true
            returnProductViewHeightConstraint.constant = 0
        }else{
            progressView.isHidden = false
            otpView.isHidden = true
            getOTpButton.isHidden = true
            returnProductView.isHidden = false
            returnProductViewHeightConstraint.constant = 83
        }
        acceptedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.acceptedTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        hondoverDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.handOverTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        returnedDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productOrder?.returnHandOverTimeInMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        switch productOrder?.status {
        case Order.ACCEPTED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            uploadPhotoView.isHidden = false
        case Order.PICKUP_IN_PROGRESS:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            uploadPhotoView.isHidden = false
            title1InfoLabel.text = ""
        case Order.PICKUP_COMPETE:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            uploadPhotoView.isHidden = true
            getOTpButton.isHidden = false
            otpView.isHidden = true
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            returnProductViewHeightConstraint.constant = 113
            damagedProductButton.isHidden = false
            if productOrder?.damageAmount != 0.0{
                damagedProductButton.setTitle(String(format: Strings.damage_amount, arguments: [StringUtils.getStringFromDouble(decimalNumber: productOrder?.damageAmount)]), for: .normal)
            }
        case Order.RETURN_PICKUP_IN_PROGRESS:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            damagedProductButton.isHidden = true
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            if productOrder?.returnOtp?.isEmpty == false{
                otpView.isHidden = false
                otpLabel.text = String(format: Strings.pickUp_otp, arguments: [(productOrder?.returnOtp ?? "")])
                otpView.drawDashedLineArroundView(view: otpView, color: UIColor.black)
                getOTpButton.isHidden = true
                returnProductViewHeightConstraint.constant = 118
            }else{
                otpView.isHidden = true
                getOTpButton.isHidden = false
                returnProductViewHeightConstraint.constant = 113
            }
        case Order.CLOSED:
            status1ImageView.isHidden = false
            title1Label.textColor = Colors.green
            status2ImageView.isHidden = false
            title2Label.textColor = Colors.green
            status3ImageView.isHidden = false
            title3Label.textColor = Colors.green
            uploadPhotoView.isHidden = true
            title1InfoLabel.text = ""
            title2InfoLabel.text = ""
            title3InfoLabel.text = ""
        default:
            break
        }
    }
    
    //MARK: Pickup flow:- Upload product photo and enter otp given by taker
    @IBAction func uploadPhotoTapped(_ sender: Any) {
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: parentViewController,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    @IBAction func whyButtonTapped(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.why_product_photo_title, titleColor: nil, message: Strings.why_product_photo_title_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @IBAction func enterOtpTapped(_ sender: Any) {
        let enterHandoverOtpViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EnterHandoverOtpViewController") as! EnterHandoverOtpViewController
        enterHandoverOtpViewController.initialiseOtpView(type: EnterHandoverOtpViewModel.HANDOVER_PRODUCT, productOrder: productOrder ?? ProductOrder()) { (otp) in
            
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: enterHandoverOtpViewController)
    }
    
    //MARK: Return flow:- Get otp and share with taker and get back product
    @IBAction func getOtpTapped(_ sender: Any) {
        QuickShareSpinner.start()
        QuickShareRestClient.getReturnOtp(orderId: productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? "", damageAmount: StringUtils.getStringFromDouble(decimalNumber: productOrder?.damageAmount)){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOtpResponse = Mapper<ProductOtpResponse>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : Any]()
                userInfo["returnOtp"] = productOtpResponse?.otp
                NotificationCenter.default.post(name: .returnOtpReceived, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    @IBAction func damagedProductTapped(_ sender: Any) {
        let enterDamageChargesViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EnterDamageChargesViewController") as! EnterDamageChargesViewController
        enterDamageChargesViewController.initialiseDamageCharge { (damageAmount) in
            var userInfo = [String : Any]()
            userInfo["damageAmount"] = damageAmount
            NotificationCenter.default.post(name: .showDamageAmount, object: nil, userInfo: userInfo)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: enterDamageChargesViewController)
    }
}
extension SellerOrderStatusTableViewCell: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
                    self.productOrder?.handOverPic = url
                    self.takePhotoButton.setTitle("Photo Uploaded", for: .normal)
                    NotificationCenter.default.post(name: .tookPhotoWhileCollectingProduct, object: nil, userInfo: userInfo)
                }
            })
        }
    }
}
