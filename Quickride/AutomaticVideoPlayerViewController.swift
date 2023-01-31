//
//  AutomaticVideoPlayerViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import YoutubePlayer_in_WKWebView
import UIKit
import AVKit


class AutomaticVideoPlayerViewController: UIViewController, WKYTPlayerViewDelegate{
    
    
    @IBOutlet weak var autoPlayerView: WKYTPlayerView!
    
    var id: String = ""
    
    func initializeDataBeforePresenting(id: String){
        self.id = id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoPlayerView.load(withVideoId: id)
        autoPlayerView.delegate = self
    }
    
 
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
    
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
    self.navigationController?.popViewController(animated: false)
        
    }
    
    
    
    
}
