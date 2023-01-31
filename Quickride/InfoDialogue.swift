//
//  InfoDialogue.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/04/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class InfoDialogue : UIViewController {
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var alertDialogView: UIView!
    
    @IBOutlet weak var alertDialogViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var infoTextHeightConstraint: NSLayoutConstraint!
        
    var titleMessage : String?
    var infoMessage : String?
    
    func initializeDataBeforePresentingView(title : String?, message : String?)
    {
        self.titleMessage = title
        self.infoMessage = message
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogView, cornerRadius: 10.0)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoDialogue.dismissViewTapped(_:))))
        alertDialogViewWidthConstraint.constant = self.view.frame.size.width * 0.90
        titleLabel.text = titleMessage
        infoText.text = infoMessage
        resizeHeightToFit(message: infoMessage!, constraint: infoTextHeightConstraint, addedHeight : 12)
    }
    override func viewDidAppear(_ animated: Bool) {
        infoText.sizeToFit()
        titleLabel.sizeToFit()
        infoText.textAlignment = NSTextAlignment.left
    }
    func resizeHeightToFit(message : String, constraint: NSLayoutConstraint, addedHeight : CGFloat) {
        
        let lines = CGFloat(message.count * 15)/(alertDialogViewWidthConstraint.constant - 40)
        let height = lines * CGFloat(ViewCustomizationUtils.ALERT_DIALOG_LABEL_LINE_HEIGHT)
        constraint.constant = height + addedHeight
    }
    
    @objc func dismissViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
}
