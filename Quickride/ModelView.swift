//
//  ModelView.swift
//  Quickride
//
//  Created by rakesh on 7/28/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ModelView : UIView{
    
    static var viewToBeRemoved : UIView?
    
    override func didAddSubview(_ subview: UIView) {
        if ModelView.viewToBeRemoved != nil{
            ModelView.viewToBeRemoved!.removeFromSuperview()
            ModelView.viewToBeRemoved = nil
        }
        
        if ModelViewController.viewControllerToBeRemoved != nil{
            ModelViewController.viewControllerToBeRemoved!.view.removeFromSuperview()
            ModelViewController.viewControllerToBeRemoved!.removeFromParent()
        }
        ModelView.viewToBeRemoved = self
        

    }
}
