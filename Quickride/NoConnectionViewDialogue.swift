//
//  NoConnectionViewDialogue.swift
//  Quickride
//
//  Created by Admin on 19/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class NoConnectionViewDialogue : ModelView{
    
    @IBOutlet weak var noConnectionView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var errorMessageLbl: UILabel!
    
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewTopSpaceConstraint: NSLayoutConstraint!
    
    var viewController = UIViewController()
    
    func initializeView(errorMessage : String,image : UIImage,viewController : UIViewController){
        self.errorMessageLbl.text = errorMessage
        self.imageView.image = image
        self.viewController = viewController
        loadView()
    }
    
    func loadView(){
        addView()
    }
    
    func addView(){
        if self.viewController.isKind(of: LiveRideMapViewController.self){
            self.frame = CGRect(x: 0, y: viewController.view.frame.origin.y+65, width: viewController.view.frame.size.width, height: 30)
         }else{
              self.viewHeightConstraint.constant = 30
        }
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        self.viewTopSpaceConstraint.constant = statusBarHeight - 10
        self.viewWidthConstraint.constant = viewController.view.frame.size.width
        self.viewController.view.addSubview(self)
    }
}
