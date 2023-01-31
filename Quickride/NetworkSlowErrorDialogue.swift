//
//  NetworkSlowErrorDialogue.swift
//  Quickride
//
//  Created by rakesh on 12/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import Lottie


class NetworkSlowErrorDialogue : UIViewController{
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var animationView : AnimationView?
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addBorderToView(view: okBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: okBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NetworkSlowErrorDialogue.backgroundViewTapped(_:))))
        addAnimatedView()
    }


    func addAnimatedView(){
        animationView = AnimationView(name: "no_connection")
        animationView!.frame = CGRect(x: self.view.center.x - 30, y: self.view.center.y - 60, width: 50, height: 50)
        animationView!.contentMode = .scaleAspectFit
        self.view.addSubview(animationView!)
        animationView!.play()
        animationView!.loopMode = .playOnce
    }

    
    @IBAction func actionClicked(_ sender: Any) {
    AppDelegate.getAppDelegate().log.debug("actionClciked()")
        animationView?.stop()
        self.view.removeFromSuperview()
        self.removeFromParent()
      }
    
   @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        animationView?.stop()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
  }
