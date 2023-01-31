//
//  LocationPermissionViewController.swift
//  Quickride
//
//  Created by Ashutos on 29/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

typealias locationServiceIsEnabledComplitionHandler = (_ isEnabled: Bool) -> Void

class LocationPermissionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    //MARK: Properties
    private var handler: locationServiceIsEnabledComplitionHandler?
    private var locationManager = CLLocationManager()
    private var isLocationServiceTurnedOff = false
    func initialiseData(handler: @escaping locationServiceIsEnabledComplitionHandler){
        self.handler = handler
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI(){
        if !CLLocationManager.locationServicesEnabled(){
            titleLabel.text = "Location Services Turned Off "
            infoLabel.text = "Allow Quick Ride to turn on your phone Location Services"
            actionButton.setTitle("TURN ON LOCATION SERVICES", for: .normal)
            isLocationServiceTurnedOff = true
        }else{
            titleLabel.text = "Location Permission Required"
            infoLabel.text = "Allow Quick Ride to detect your current location to show carpool rides"
            actionButton.setTitle("GO TO SETTINGS", for: .normal)
            if CLLocationManager.authorizationStatus() == .notDetermined{
                LocationClientUtils.checkLocationAutorizationStatus(status: CLLocationManager.authorizationStatus()) { [self] (isConfirmed) in
                    if isConfirmed{
                        getLocation()
                    }else{
                        actionButton.setTitle("Continue", for: .normal)
                    }
                }
            }
        }
    }
    
    private func getLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: Notification.Name("appEnterForeground"), object: nil)
    }
    
    @objc func appEnterForeground(_ notification: Notification){
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .notDetermined{
            if CLLocationManager.locationServicesEnabled(){
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
                    self.navigationController?.popViewController(animated: false)
                    self.handler?(true)
                }else if self.isLocationServiceTurnedOff{
                    self.titleLabel.text = "Location Permission Required"
                    self.infoLabel.text = "Allow Quick Ride to detect your current location to show carpool rides"
                    if CLLocationManager.authorizationStatus() == .notDetermined{
                        self.actionButton.setTitle("CONTINUE", for: .normal)
                    }else{
                        self.actionButton.setTitle("GO TO SETTINGS", for: .normal)
                    }
                }
            }
        }
    }
    
    @IBAction func locationPermissionButton(_ sender: Any) {
        if !CLLocationManager.locationServicesEnabled(){
            UIApplication.shared.open(URL(string:"App-prefs:root=LOCATION_SERVICES")!, options: [:], completionHandler: nil)
        }else if CLLocationManager.authorizationStatus() == .notDetermined{
            getLocation()
        }else{
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
}
extension LocationPermissionViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        AppDelegate.getAppDelegate().log.debug("")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.getAppDelegate().log.debug("\(status)")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            self.navigationController?.popViewController(animated: false)
            self.handler?(true)
        }else{
            actionButton.setTitle("GO TO SETTINGS", for: .normal)
        }
    }
}
