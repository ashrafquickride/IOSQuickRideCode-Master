//
//  DontShowAgainAlertDialouge.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 02/02/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias dontShowAgainAlertDialougeHandler = (_ result : String, _ checkBoxSelelcted : Bool) -> Void


class DontShowAgainAlertDialouge: UIViewController{
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var messagelabel: UILabel!
    
    @IBOutlet weak var dontShowAgainButton: UIButton!
    
    @IBOutlet weak var dontShowAgainToggle: UIButton!
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton!
    
    @IBOutlet weak var alertDialogue: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var alertDialogViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var msgLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var alertDialogViewWidthConstraint: NSLayoutConstraint!


    var message : String?
    var titlemsg : String?
    var dontShowAgain = false
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var handler : dontShowAgainAlertDialougeHandler?

    func initializeDataBeforePersentingView(titlemsg : String?,message : String?,viewController: UIViewController,positiveActnTitle : String?,negativeActionTitle : String?, handler: @escaping dontShowAgainAlertDialougeHandler){
        self.titlemsg = titlemsg
        self.message = message
        self.positiveBtnTitle = positiveActnTitle
        self.negativeBtnTitle = negativeActionTitle
        self.handler = handler

    }
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: negativeButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogue, cornerRadius: 10.0)
        positiveButton.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        negativeButton.setTitle(negativeBtnTitle, for: UIControl.State.normal)
        let attributedString = NSMutableAttributedString(string: message!)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithUnderline(textColor: UIColor(netHex:0x0A60FF), textSize: 13), range: (message! as NSString).range(of: "Refer Once – Earn Everyday"))
        messagelabel.attributedText = attributedString
        titleLabel.text = titlemsg
        adjustTheHeightOfAlertView()
        messagelabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DontShowAgainAlertDialouge.navigateToReferEarnOfferURl(_:))))
    }
    func adjustTheHeightOfAlertView(){
        alertDialogViewHeightConstraint.constant = alertDialogViewHeightConstraint.constant - msgLblHeightConstraint.constant
        let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 14)!]
        let rect = messagelabel.text?.boundingRect(with: CGSize(width: alertDialogViewWidthConstraint.constant - 40, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        msgLblHeightConstraint.constant = rect!.height + 5
        alertDialogViewHeightConstraint.constant = alertDialogViewHeightConstraint.constant + msgLblHeightConstraint.constant
    }
    @objc func navigateToReferEarnOfferURl(_ sender: UITapGestureRecognizer)
    {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.refer_once_offers_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.refer_and_rewards, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    @IBAction func positiveButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.navigationController?.removeFromParent()
        handler?(sender.titleLabel!.text!, dontShowAgain)
    }
    
    @IBAction func negativeButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.navigationController?.removeFromParent()
        handler?(sender.titleLabel!.text!, dontShowAgain)
    }
    
    
    @IBAction func dontShowAgainButtonAction(_ sender: Any) {
        if dontShowAgain == false{
            dontShowAgain = true
            dontShowAgainToggle.setImage(UIImage(named: "group_tick_icon"), for: .normal)
        }else{
            dontShowAgain = false
            dontShowAgainToggle.setImage(UIImage(named: "tick_icon"), for: .normal)
        }
    }
    
}
