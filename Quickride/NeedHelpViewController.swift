//
//  NeedHelpViewController.swift
//  Quickride
//
//  Created by Halesh on 27/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

enum NeedHelpAction {
    case refund
}

typealias refundRequestInitiated = (_ action : NeedHelpAction) -> Void

class NeedHelpViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backGroundTapped: UIView!
    @IBOutlet weak var mainView: UIView!
    
    var handler: refundRequestInitiated?
    
    func initializeView(handler: @escaping refundRequestInitiated){
        self.handler = handler
    }

    //MARK:Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.backGroundTapped.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundClicked(_:))))
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func refundmoneyClicked(_ sender: Any) {
        dismiss(animated: false)
        self.handler?(.refund)
    }
    
    func displayViewController(){
        HelpUtils.sendEmailToSupport(viewController: self, image: nil,listOfIssueTypes: Strings.list_of_issue_types)

    }

    @IBAction func otherIssuesClicked(_ sender: Any) {
        displayViewController()
    }

    @IBAction func emailSendClicked(_ sender: Any) {
        displayViewController()
    }
    
    @objc func backGroundClicked(_ gesture: UITapGestureRecognizer){
       dismiss(animated: false)
    }

}
