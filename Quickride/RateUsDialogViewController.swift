//
//  RateUsDialogViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 7/26/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RateUsDialogViewController: UIViewController {
    
    @IBOutlet weak var rateUsDialogView: UIView!
    
    @IBOutlet weak var rateUsLabel: UILabel!
    
    @IBOutlet weak var imagesView: UIView!
    
    @IBOutlet weak var greatStarImage: UIImageView!
    
    @IBOutlet weak var goodStarImage: UIImageView!
    
    @IBOutlet weak var badStarImage: UIImageView!
    
    @IBOutlet weak var greatActnBtn: UIButton!
    
    @IBOutlet weak var goodActnBtn: UIButton!
    
    @IBOutlet weak var badActnBtn: UIButton!
    
    override func viewDidLoad()
    {
        ViewCustomizationUtils.addCornerRadiusToView(view: rateUsDialogView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: greatActnBtn, cornerRadius: 4.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: goodActnBtn, cornerRadius: 4.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: badActnBtn, cornerRadius: 4.0)
        goodStarImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RateUsDialogViewController.goodImageViewTapped(_:))))
        badStarImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RateUsDialogViewController.badImageViewTapped(_:))))
        greatStarImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RateUsDialogViewController.greatImageViewTapped(_:))))

    }
    
    @objc func goodImageViewTapped(_ gesture :UITapGestureRecognizer){
        greatStarImage.image = UIImage(named: "5_star")
        goodStarImage.image = UIImage(named: "3_star_selected")
        badStarImage.image = UIImage(named: "2_star")
    }
    
    @objc func badImageViewTapped(_ gesture :UITapGestureRecognizer){
        greatStarImage.image = UIImage(named: "5_star")
        goodStarImage.image = UIImage(named: "3_star")
        badStarImage.image = UIImage(named: "2_star_selected")
    }
    @objc func greatImageViewTapped(_ gesture :UITapGestureRecognizer){
        greatStarImage.image = UIImage(named: "5_star_selected")
        goodStarImage.image = UIImage(named: "3_star")
        badStarImage.image = UIImage(named: "2_star")
    }
    @IBAction func greatBtnTapped(_ sender: Any){
        SharedPreferenceHelper.setAllowRateUsDialogStatus(flag: true)
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.keyWindow?.makeToast( Strings.rate_us_review_message)
            UIApplication.shared.openURL(url! as URL)
        }
        else
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_launch_app_store)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func noActnBtnTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
