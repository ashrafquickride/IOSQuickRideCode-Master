//
//  RideEtiquetteCerificationViewController.swift
//  Quickride
//
//  Created by Vinutha on 06/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideEtiquetteCerificationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var certificateView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var certificationDateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: Properties
    private var rideEtiquetteCertification: RideEtiquetteCertification?
    private var userName: String?
    
    //MARK: Initializer
    func initialiseData(userName: String, rideEtiquetteCertification: RideEtiquetteCertification) {
        self.userName = userName
        self.rideEtiquetteCertification = rideEtiquetteCertification
    }
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var isDashedLineDrawn = false
        if let subLayers = certificateView.layer.sublayers {
            for layer in subLayers {
                if layer.name == "dashedLine" {
                    isDashedLineDrawn = true
                }
            }
        }
        if !isDashedLineDrawn {
            certificateView.addDashedLineAroundView(color: UIColor.black)
        }
    }
    
    //MARK: Methods
    private func setupUI() {
        userNameLabel.text = userName
        if let createdDate = rideEtiquetteCertification?.createdDate, let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: createdDate, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy) {
            certificationDateLabel.isHidden = false
            certificationDateLabel.text = date
        } else {
            certificationDateLabel.isHidden = true
        }
    }
    
    @objc private func takeScreenShotAndShare(){
        
            let screen = self.view
    
            if let window = UIApplication.shared.keyWindow {
                UIGraphicsBeginImageContextWithOptions(screen!.bounds.size, false, 0);
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
                let image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
    
                let activityItem: [AnyObject] = [image as AnyObject]
                let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
                avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
                if #available(iOS 11.0, *) {
                    avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
                }
                avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    self.backButton.isHidden = false
                    self.shareButton.isHidden = false
                    self.certificateView.addDashedLineAroundView(color: UIColor.black)
                }
                self.present(avc, animated: true, completion: nil)
                
            }
        }
    
    //MARK: Actions
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        backButton.isHidden = true
        shareButton.isHidden = true
        if let subLayers = certificateView.layer.sublayers {
            for layer in subLayers {
                if layer.name == "dashedLine" {
                    layer.removeFromSuperlayer()
                }
            }
        }
        self.perform(#selector(takeScreenShotAndShare), with: nil, afterDelay: 0.5)
    }
}
