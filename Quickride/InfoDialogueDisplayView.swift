//
//  InfoDialogueDisplayView.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias infoDialogueDisplayActionCompletionHandler = () -> Void

class InfoDialogueDisplayView : ModelViewController{
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var gotItBtn: UIButton!
        
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var infoImageView: UIImageView!
    
    @IBOutlet weak var infoImageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoImageLeadingSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkView: UIView!
    
    @IBOutlet weak var linkImageView: UIImageView!
    
    @IBOutlet weak var linkTextLbl: UILabel!
    
    @IBOutlet weak var linkViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkViewTopSpaceConstraint: NSLayoutConstraint!
    
    var titleMessage : String?
    var infoMessage : String?
    var infoImage : UIImage?
    var imageColor : UIColor?
    var isLinkBtnRequired = false
    var linkTxt : String?
    var linkImage : UIImage?
    var handler : infoDialogueDisplayActionCompletionHandler?
    var buttonTitle: String?
    var titleColor: UIColor?
    
    func initializeDataBeforePresentingView(title : String?, titleColor: UIColor?, message : String,infoImage : UIImage?,imageColor : UIColor?,isLinkBtnRequired : Bool,linkTxt : String?,linkImage : UIImage?,buttonTitle: String?,handler : @escaping infoDialogueDisplayActionCompletionHandler)
    {
        self.titleMessage = title
        self.titleColor = titleColor
        self.infoMessage = message
        self.infoImage = infoImage
        self.imageColor = imageColor
        self.isLinkBtnRequired = isLinkBtnRequired
        self.linkTxt = linkTxt
        self.linkImage = linkImage
        self.buttonTitle = buttonTitle
        self.handler = handler
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        if titleColor != nil {
            titleLabel.textColor = titleColor
        } else {
            titleLabel.textColor = UIColor(netHex: 0x00B557)
        }
        titleLabel.text = titleMessage
        messageLabel.text = infoMessage
        handleInfoImageView()
        handleEmailSupportViewVisibility()
        let attributedString = NSMutableAttributedString(string: messageLabel.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.5
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 14.0), range: NSMakeRange(0, attributedString.length))
            
        self.messageLabel.attributedText = attributedString
        self.gotItBtn.setTitle(buttonTitle, for: .normal)
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: infoView, cornerRadius: 10.0)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoDialogueDisplayView.dismissViewTapped(_:))))
        gotItBtn.addTarget(self, action:#selector(InfoDialogueDisplayView.HoldGotItBtn(_:)), for: UIControl.Event.touchDown)
        gotItBtn.addTarget(self, action:#selector(InfoDialogueDisplayView.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        linkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoDialogueDisplayView.linkViewTapped(_:))))
    }
    @objc func HoldGotItBtn(_ sender:UIButton)
    {
        gotItBtn.backgroundColor = Colors.lightGrey
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1.0, color: Colors.lightGrey)
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 5.0)
    }
    @objc func HoldRelease(_ sender:UIButton){
        gotItBtn.backgroundColor = UIColor.white
        gotItBtn.layer.borderColor = UIColor.clear.cgColor
    }
    @objc func dismissViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func gotItTapped(_ sender: Any) {
        if !isLinkBtnRequired {
            handler?()
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func handleInfoImageView(){
        if infoImage != nil{
            infoImageWidthConstraint.constant = 20
            infoImageLeadingSpaceConstraint.constant = 26
            if imageColor != nil{
                ImageUtils.setTintedIcon(origImage: infoImage!, imageView: infoImageView, color: imageColor!)
            }else{
                infoImageView.image = infoImage
            }
        }else{
            infoImageWidthConstraint.constant = 0
            infoImageLeadingSpaceConstraint.constant = 16
        }
    }
    
    func handleEmailSupportViewVisibility(){
        if isLinkBtnRequired{
            linkView.isHidden = false
            linkViewHeightConstraint.constant = 30
            linkViewTopSpaceConstraint.constant = 10
            setDataToLinkView()
        }else{
            linkView.isHidden = true
            linkViewHeightConstraint.constant = 0
            linkViewTopSpaceConstraint.constant = 0
        }
    }
    
    func setDataToLinkView(){
        if linkTxt != nil{
           linkTextLbl.text = linkTxt!
        }
        if linkImage != nil{
           linkImageView.image = linkImage!
        }
    }
    
    @objc func linkViewTapped(_ gesture : UITapGestureRecognizer){
        handler?()
    }
  
  
}
