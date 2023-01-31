//

//  DuplicateRideViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 26/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//



import Foundation
import CoreImage

class DuplicateRideViewController: UIViewController {
    
    
    //Outlets
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var rescheduleButton: QRCustomButton!
    @IBOutlet weak var creaternewButton: QRCustomButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    //Variables
    
    var isDismissViewRequired = false
    var message : String?
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var completionHandler : alertControllerActionHandler?
    
    
    func displayErrorAlertWithAction(message: String, positiveActnTitle : String?, negativeActionTitle : String?, handler: alertControllerActionHandler?)
    {
        self.message = message
        self.positiveBtnTitle = positiveActnTitle
        self.negativeBtnTitle = negativeActionTitle
        self.completionHandler = handler
    }
    
    
    //MARK:Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.messageLabel.text = message
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundClicked(_:))))
        
    }
    @IBAction func rescheduleactionButton(_ sender: Any) {
        
        AppDelegate.getAppDelegate().log.debug("positveActionClicked()")
        dismiss(animated: false)
        completionHandler?(rescheduleButton.titleLabel!.text!)
    }
    
    @IBAction func createnewrideAction(_ sender: Any) {
        dismiss(animated: false)
        completionHandler?(creaternewButton.titleLabel!.text!)
    }
    
    @objc func backGroundClicked(_ gesture: UITapGestureRecognizer){
        dismiss(animated: false)
    }
    
}
