//
//  ModelViewController.swift
//  Quickride
//
//  Created by rakesh on 7/28/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ModelViewController : UIViewController{
    
    static var viewControllerToBeRemoved : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ModelViewController.viewControllerToBeRemoved != nil{
           ModelViewController.viewControllerToBeRemoved!.view.removeFromSuperview()
           ModelViewController.viewControllerToBeRemoved!.removeFromParent()
        }
        
        if ModelView.viewToBeRemoved != nil{
            ModelView.viewToBeRemoved!.removeFromSuperview()
        }
        ModelViewController.viewControllerToBeRemoved = self
        ModelView.viewToBeRemoved = self.view
    }
    
}
