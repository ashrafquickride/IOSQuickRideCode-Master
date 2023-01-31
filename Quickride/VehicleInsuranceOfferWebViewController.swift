//
//  VehicleInsuranceOfferWebViewController.swift
//  Quickride
//
//  Created by Admin on 13/12/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import UIKit

typealias vehicleInsuranceSuccessResponseHandler = ()->Void

class VehicleInsuranceOfferWebViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var registrationNumber : String?
    var vehicleType : String?
    var handler : vehicleInsuranceSuccessResponseHandler?
    
    func initializeData(registrationNumber: String, vehicleType: String?, handler: @escaping vehicleInsuranceSuccessResponseHandler){
        self.registrationNumber = registrationNumber
        self.vehicleType = vehicleType
        self.handler = handler
    }
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addCornerRadiusToView(view: webView, cornerRadius: 10.0)
        closeBtn.imageView?.image = closeBtn.imageView?.image!.withRenderingMode(.alwaysTemplate)
        closeBtn.imageView?.tintColor = UIColor.black
         backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VehicleInsuranceOfferWebViewController.backGroundViewTapped(_:))))
        let url = getCoverfoxUrlBasedOnVehicleType()
        let request = URLRequest(url:url! as URL)
        webView.delegate = self
        QuickRideProgressSpinner.startSpinner()
        webView.loadRequest(request)
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func getCoverfoxUrlBasedOnVehicleType() -> URL?{
        if self.vehicleType == Vehicle.VEHICLE_TYPE_CAR{
            if AppConfiguration.useProductionServerForPG{
                return URL(string : AppConfiguration.COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_CAR + (String(describing: self.registrationNumber!)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }
            else{
              return URL(string : AppConfiguration.COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_CAR + (String(describing: self.registrationNumber!)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }
            
        }
        else if self.vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            if AppConfiguration.useProductionServerForPG{
                return URL(string : AppConfiguration.COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_BIKE + (String(describing: self.registrationNumber!)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }
            else{
                return URL(string : AppConfiguration.COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_BIKE + (String(describing: self.registrationNumber!)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }
        }
        else{
            if AppConfiguration.useProductionServerForPG{
                return URL(string : AppConfiguration.COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_TERM)
            }
            else{
               return URL(string : AppConfiguration.COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_TERM)
            }
        }
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let url = webView.request?.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug("shouldStartLoadWith \(String(describing: url))")
        
        if !AppConfiguration.useProductionServerForPG && url != nil && (url!.contains(AppConfiguration.COVERFOX_INSURANCE_STAGGING_SURL_FOR_CAR) || url!.contains(AppConfiguration.COVERFOX_INSURANCE_STAGGING_SURL_FOR_BIKE)){
            self.view.removeFromSuperview()
            self.removeFromParent()
            handler!()
        }
        else if AppConfiguration.useProductionServerForPG && url != nil && (url!.contains(AppConfiguration.COVERFOX_INSURANCE_SURL_FOR_CAR) || url!.contains(AppConfiguration.COVERFOX_INSURANCE_SURL_FOR_BIKE)){
            self.view.removeFromSuperview()
            self.removeFromParent()
            handler!()
        }
        return true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug("webViewDidFinishLoadWithError \(String(describing: webView.request?.url?.absoluteString))")
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        AppDelegate.getAppDelegate().log.debug("webViewDidStartLoad : \(String(describing: webView.request?.url?.absoluteString))")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        QuickRideProgressSpinner.stopSpinner()
        let url = webView.request?.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug( "webViewDidFinishLoad: \(String(describing: url))")
        if !AppConfiguration.useProductionServerForPG && url != nil && (url!.contains(AppConfiguration.COVERFOX_INSURANCE_STAGGING_SURL_FOR_CAR) || url!.contains(AppConfiguration.COVERFOX_INSURANCE_STAGGING_SURL_FOR_BIKE)){
            self.view.removeFromSuperview()
            self.removeFromParent()
            handler!()
        }
        else if AppConfiguration.useProductionServerForPG && url != nil && (url!.contains(AppConfiguration.COVERFOX_INSURANCE_SURL_FOR_CAR) || url!.contains(AppConfiguration.COVERFOX_INSURANCE_SURL_FOR_BIKE)){
            self.view.removeFromSuperview()
            self.removeFromParent()
            handler!()
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}



