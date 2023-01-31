//
//  HomeScreenLoadingAnimationTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 17/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HomeScreenLoadingAnimationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var animationView1: ShimmerView!
    @IBOutlet weak var animationView2: ShimmerView!
    @IBOutlet weak var animationView3: ShimmerView!
    @IBOutlet weak var animationView4: ShimmerView!
    @IBOutlet weak var animationView5: ShimmerView!
    @IBOutlet weak var animationView6: ShimmerView!
    @IBOutlet weak var animationView7: ShimmerView!
    @IBOutlet weak var animationView8: ShimmerView!
    @IBOutlet weak var animationView9: ShimmerView!
    @IBOutlet weak var animationView10: ShimmerView!
    @IBOutlet weak var animationView11: ShimmerView!
    @IBOutlet weak var animationView12: ShimmerView!
    @IBOutlet weak var animationView13: ShimmerView!
    @IBOutlet weak var animationView14: ShimmerView!
    @IBOutlet weak var animationView15: ShimmerView!
    
    func setupUI(){
        animationView1.startAnimating()
        animationView2.startAnimating()
        animationView3.startAnimating()
        animationView4.startAnimating()
        animationView5.startAnimating()
        animationView6.startAnimating()
        animationView7.startAnimating()
        animationView8.startAnimating()
        animationView9.startAnimating()
        animationView10.startAnimating()
        animationView11.startAnimating()
        animationView12.startAnimating()
        animationView13.startAnimating()
        animationView14.startAnimating()
        animationView15.startAnimating()
    }
}
