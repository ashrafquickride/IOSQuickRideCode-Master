//
//  PassDetailViewController.swift
//  Quickride
//
//  Created by Admin on 19/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassDetailViewController : UIViewController{
    
    @IBOutlet weak var activatedView: UIView!
    
    @IBOutlet weak var TotalRidesLbl: UILabel!
    
    @IBOutlet weak var validityLbl: UILabel!
    
    @IBOutlet weak var buyPassBtn: UIButton!
    
    @IBOutlet weak var passImageView: UIImageView!

    @IBOutlet weak var daysAndRidesLeftLbl: UILabel!
    
    @IBOutlet weak var saveLbl: UILabel!
    
    @IBOutlet weak var discountPercentLbl: UILabel!
    
    @IBOutlet weak var rupeeSymbol: UIImageView!
    
    @IBOutlet weak var amountLbl: UILabel!
    
    @IBOutlet weak var activatedViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activatedViewTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fromLocationLbl: UILabel!

    @IBOutlet weak var toLocationLbl: UILabel!
    
    @IBOutlet weak var termsAndConditionLbl3: UILabel!

    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var notAvailabeleBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pass : RidePass?
    var index = 0
    var isCurrentPassActive = false
    var isAnyPassActive = false
    var activatedPassTotalRidesCount : Int?
    
    func initializeDataBeforePresenting(isCurrentPassActive : Bool,isAnyPassActive : Bool,activatedPassTotalRidesCount : Int?,pass : RidePass,index : Int){
        self.pass = pass
        self.index = index
        self.isAnyPassActive = isAnyPassActive
        self.isCurrentPassActive = isCurrentPassActive
        self.activatedPassTotalRidesCount = activatedPassTotalRidesCount
       
    }
    
    override func viewDidLoad() {
        fromLocationLbl.text = self.pass!.fromAddress
        toLocationLbl.text =  self.pass!.toAddress
        handlePassActivatedView()
        buyPassBtn.setTitle(String(format: Strings.buy_rides_pass_txt, arguments: [String(pass!.totalRides)]), for: .normal)
        self.TotalRidesLbl.text = String(pass!.totalRides) + " " + Strings.rides
        self.discountPercentLbl.text = String(pass!.discountPercent) + "%"
        self.termsAndConditionLbl3.text = String(format: Strings.days_left_terms_msg, arguments: [String(pass!.duration)])
        
        let string = (String(pass!.passPrice)+"/"+String(pass!.actualPrice)) as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor.black, textSize: 14), range: string.range(of: String(pass!.passPrice)))
        
        attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: String(pass!.actualPrice)))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: UIColor.black.withAlphaComponent(0.7), textSize: 14), range: string.range(of: String(pass!.actualPrice)))
       
        self.amountLbl.attributedText = attributedString
        
        if index % 2 == 0{
            amountLbl.textColor = UIColor(netHex: 0x0d17bb)
            discountPercentLbl.textColor = UIColor(netHex: 0x0d17bb)
            saveLbl.textColor = UIColor(netHex: 0x0d17bb)
            passImageView.image = UIImage(named: "green_back_pass")
             ImageUtils.setTintedIcon(origImage: UIImage(named:"rupee-indian")!, imageView: rupeeSymbol,color : UIColor(netHex: 0x0d17bb))
        }else{
            amountLbl.textColor = UIColor(netHex: 0xffd457)
            discountPercentLbl.textColor = UIColor(netHex: 0xffd457)
            saveLbl.textColor = UIColor(netHex: 0xffd457)
            passImageView.image = UIImage(named: "blue_back_full")
            ImageUtils.setTintedIcon(origImage: UIImage(named:"rupee-indian")!, imageView: rupeeSymbol,color : UIColor(netHex: 0xffd457))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        ViewCustomizationUtils.addCornerRadiusToView(view: buyPassBtn, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: buyPassBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: detailView, cornerRadius: 25.0, corner1: UIRectCorner.topLeft, corner2: UIRectCorner.topRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
    }
    
    func handlePassActivatedView(){
        
        if isCurrentPassActive{
            activatedView.isHidden = false
            buyPassBtn.isHidden = true
            notAvailabeleBtn.isHidden = true
            ViewCustomizationUtils.addCornerRadiusToView(view: activatedView, cornerRadius: 5.0)
            activatedViewHeightConstraint.constant = 21
            activatedViewTopSpaceConstraint.constant = 10
            daysAndRidesLeftLbl.isHidden = false
            validityLbl.isHidden = true
            self.daysAndRidesLeftLbl.text = String(format: Strings.days_and_rides_left, arguments: [String(pass!.duration),String(pass!.availableRides)])
        }else if isAnyPassActive{
            activatedView.isHidden = true
            buyPassBtn.isHidden = true
            notAvailabeleBtn.isHidden = false
            ViewCustomizationUtils.addCornerRadiusToView(view: activatedView, cornerRadius: 5.0)
            activatedViewHeightConstraint.constant = 0
            activatedViewTopSpaceConstraint.constant = 0
            daysAndRidesLeftLbl.isHidden = true
            validityLbl.isHidden = false
            validityLbl.text = String(format: Strings.valid_for_days, arguments: [String(pass!.duration)])
        }else{
            activatedView.isHidden = true
            buyPassBtn.isHidden = false
            notAvailabeleBtn.isHidden = true
            activatedViewHeightConstraint.constant = 0
            activatedViewTopSpaceConstraint.constant = 0
            daysAndRidesLeftLbl.isHidden = true
            validityLbl.isHidden = false
            validityLbl.text = String(format: Strings.valid_for_days, arguments: [String(pass!.duration)])
        }
    }

    @IBAction func buyRidesBtnClicked(_ sender: Any) {
        let account = UserDataCache.getInstance()!.userAccount
        
        if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil && account != nil && (account!.balance! - account!.reserved!) < Double(pass!.passPrice){
            MessageDisplay.displayErrorAlertWithAction(title: Strings.low_bal_in_account, isDismissViewRequired: true, message1: Strings.pass_low_balance_alert_msg, message2: nil, positiveActnTitle: Strings.recharge_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self) { (actionTxt) in
                if actionTxt == Strings.recharge_caps{
                    self.doRecharge()
                }
            }
         }else{
            buyPass()
        }
      
    
     }
    
    func buyPass(){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.buy_pass_confirmation_alert, message2: nil, positiveActnTitle: Strings.buy_now, negativeActionTitle: Strings.later_caps, linkButtonText: nil, viewController: self) { (actionText) in
            if actionText == Strings.buy_now{
                QuickRideProgressSpinner.startSpinner()
                AccountRestClient.purchaseRidePass(passObject: self.pass!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil{
                if responseObject!["result"] as! String == "SUCCESS"{
                    self.showActivatedAlert()
                }else{
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    if responseError?.errorCode == UserMangementException.PAYTM_WALLET_LOW_BALANCE || responseError?.errorCode == AccountException.INSUFFICIENT_FUNDS_IN_ACCOUNT || responseError?.errorCode == AccountException.INSUFFICIENT_FUNDS_TO_ENCASH{
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: responseError?.userMessage, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, viewController: nil, handler: { (actionTxt) in
                            if actionTxt == Strings.ok_caps{
                                self.doRecharge()
                            }
                        })
                    }else{
                       ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                }
            }else{
               ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
                }
            }
        }
    }
    
    func showActivatedAlert(){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: String(format: Strings.commute_pass_activated_alert_msg, arguments: [String(pass!.totalRides)]), isFromLinkedWallet: false, handler: {
            ContainerTabBarViewController.indexToSelect = 1
            self.navigationController?.popToRootViewController(animated: false)
        })
        self.view.addSubview(animationAlertController.view!)
        self.addChild(animationAlertController)
        animationAlertController.view!.layoutIfNeeded()
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func notAvailabelBtnClicked(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.not_available_why, titleColor: nil, message: String(format: Strings.pass_not_availble_msg, arguments: [String(activatedPassTotalRidesCount!)]), infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps, handler: {
        })
  }
    
    func doRecharge() {
        self.navigationController?.isNavigationBarHidden = false
        let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: paymentViewController, animated: false)
    }
    
}
