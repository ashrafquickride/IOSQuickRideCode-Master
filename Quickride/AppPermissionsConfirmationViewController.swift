//
//  AppPermissionsConfirmationViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 18/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
typealias appPermissionsConfirmationComplitionHandler = (_ isConfirmed: Bool) -> Void

enum PermissionType {
    case Camera
    case Location
    case Contacts
}

class AppPermissionsConfirmationViewController: UIViewController {
    
    //MARK: OUtlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var permissionImage: UIImageView!
    @IBOutlet weak var permissionNameLabel: UILabel!
    @IBOutlet weak var permissionInfoLabel: UILabel!
    @IBOutlet weak var positiveActionButton: QRCustomButton!
    
    private var permissionType: PermissionType?
    private var handler: appPermissionsConfirmationComplitionHandler?
    private var isRequiredToGoSettings = false
    func showConfirmationView(permissionType: PermissionType,isRequiredToGoSettings: Bool,handler: @escaping appPermissionsConfirmationComplitionHandler){
        self.handler = handler
        self.permissionType = permissionType
        self.isRequiredToGoSettings = isRequiredToGoSettings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        changeContentBasedOnPermissionType()
        if isRequiredToGoSettings{
            positiveActionButton.setTitle(Strings.go_to_settings_caps, for: .normal)
        }else{
            positiveActionButton.setTitle("Continue", for: .normal)
        }
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
    }
    
    private func changeContentBasedOnPermissionType(){
        switch permissionType {
        case .Camera:
            permissionImage.image = UIImage(named: "camera_icon")
            permissionNameLabel.text = "Camera Permission"
            permissionInfoLabel.text = "To capture and upload photo, allow Quick Ride to access your camera"
        case .Contacts:
            permissionImage.image = UIImage(named: "contact_icon")
            permissionNameLabel.text = "Contacts Permission"
            permissionInfoLabel.text = "To send ride invites or refer your friends, allow Quick Ride to access your contacts"
        case .Location:
            permissionImage.image = UIImage(named: "location_permission_image")
            permissionNameLabel.text = "Location Permission"
            permissionInfoLabel.text = "Your current location is used to display relevant matching options, calculate accurate ETA, help you with ride mgmt actions like closing the ride when you reach your destination, SOS, etc."
        default:
            break
        }
    }
    
    @IBAction func allowButtonTapped(_ sender: Any) {
        if isRequiredToGoSettings{
            if permissionType == .Location{
                NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: Notification.Name("appEnterForeground"), object: nil)
            }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }else{
            handler?(true)
        }
        closeView()
    }
    
    @objc func appEnterForeground(_ notification: Notification){
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .notDetermined{
            closeView()
            handler?(true)
        }
    }
    
    private func closeView(){
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
}
