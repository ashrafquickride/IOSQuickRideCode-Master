//
//  QuickRideProgressBar.swift
//  Quickride
//
//  Created by Admin on 17/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickRideProgressBar {
    
    var progressBar : UIProgressView?
    var progressBarTimer : Timer?
    
    
    init(progressBar : UIProgressView) {
        self.progressBar = progressBar
    }
    
    @objc func updateProgressBar(){
        progressBar?.progress += 0.1
        progressBar?.setProgress(progressBar!.progress, animated: true)
        if progressBar?.progress == 1.0
        {
            progressBar?.progress = 0
            updateProgressBar()
        }
    }
    
    
    func startProgressBar(){
        progressBar?.progress = 0
        self.progressBar?.isHidden = false
        self.progressBarTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(QuickRideProgressBar.updateProgressBar), userInfo: nil, repeats: true)
    }
    func stopProgressBar(){
        self.progressBarTimer?.invalidate()
        self.progressBar?.isHidden = true
    }


}
