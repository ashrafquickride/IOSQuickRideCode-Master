//
//  WarningAlertView.swift
//  Quickride
//
//  Created by Quick Ride on 11/22/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

public typealias clickActionCompletionHandler = (_ action: String?) -> Void

class WarningAlertView: UIView {
    
    // MARK: Outlets
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningIconView: UIView!
    @IBOutlet weak var warningIcon: UIImageView!
    @IBOutlet weak var warningTitle: UILabel!
    @IBOutlet weak var warningMessage: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var completionHandler: clickActionCompletionHandler?
    private var actionMessage: String?
    
    //MARK: Initializer
    func initializeViews(backGroundColor : UIColor,warningIncon : UIImage,warningTitle : String? ,warningMessage : String?, actionMessage: String?, handler: clickActionCompletionHandler?) {
        
        warningView.backgroundColor = backGroundColor
        ViewCustomizationUtils.addCornerRadiusToView(view: self.warningIconView, cornerRadius: warningIconView.frame.width/2)
        self.warningIcon.image = warningIncon
        self.warningTitle.text = warningTitle
        self.warningMessage.text = warningMessage
        self.actionMessage = actionMessage
        if actionMessage == Strings.go_to_settings {
            actionButton.setImage(UIImage(named: "arrow_right_img"), for: .normal)
        } else {
            actionButton.setImage(UIImage(named: "ic_close"), for: .normal)
        }
        self.completionHandler = handler
    }
    
    //MARK: Action
    @IBAction func closeAction(_ sender: Any) {
        if actionMessage == Strings.go_to_settings {
            completionHandler?(actionMessage)
        } else {
            self.removeFromSuperview()
        }
    }
    
}
