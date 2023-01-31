//
//  SelectDeliveryTypeViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias rentalDaysSelectionComplitionHandler = (_ productRequest: RequestProduct) -> Void

class SelectDeliveryTypeViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var rentalDaysView: UIView!
    @IBOutlet weak var rentalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var doorStepDeliveryRadioImage: UIImageView!
    @IBOutlet weak var selfPickupRadioImage: UIImageView!
    @IBOutlet weak var selfPickupAddress: UILabel!
    @IBOutlet weak var continueButton: QRCustomButton!
    
    //MARK: Variables
    private var isFromStartDate = false
    private var productRequest = RequestProduct()
    private var handler: rentalDaysSelectionComplitionHandler?
    
    func initialiseDeliveryAddressType(productRequest: RequestProduct,handler: @escaping rentalDaysSelectionComplitionHandler){
        self.productRequest = productRequest
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        prepareUI()
        if productRequest.fromTime != 0.0{
            startDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productRequest.fromTime, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        }else{
            startDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().timeIntervalSince1970*1000, timeFormat: DateUtils.DATE_FORMAT_D_MM)
            productRequest.fromTime = NSDate().timeIntervalSince1970*1000
        }
        startDate.textColor = UIColor.black
        assignDeliveryType(type: RequestProduct.SELF_PICKUP)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundTapped(_:))))
        selfPickupAddress.text = productRequest.requestLocationInfo?.address
        if productRequest.toTime != 0.0{
            endDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productRequest.toTime, timeFormat: DateUtils.DATE_FORMAT_D_MM)
            endDate.textColor = UIColor.black
            continueButton.backgroundColor = Colors.green
        }else{
            endDate.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    private func prepareUI(){
        if productRequest.tradeType == Product.RENT{
            rentalDaysView.isHidden = false
            rentalHeightConstraint.constant = 100
        }else{
            rentalDaysView.isHidden = true
            rentalHeightConstraint.constant = 0
            continueButton.backgroundColor = Colors.green
        }
        if productRequest.fromTime != 0.0 && productRequest.toTime != 0.0{
            startDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productRequest.fromTime, timeFormat: DateUtils.DATE_FORMAT_D_MM)
            endDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: productRequest.toTime, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        }
    }
    
    private func assignDeliveryType(type: String){
        if type == RequestProduct.HOME_DELIVERY{
            doorStepDeliveryRadioImage.image = UIImage(named: "ic_radio_button_checked")
            selfPickupRadioImage.image = UIImage(named: "radio_button_1")
        }else{
            selfPickupRadioImage.image = UIImage(named: "ic_radio_button_checked")
            doorStepDeliveryRadioImage.image = UIImage(named: "radio_button_1")
        }
        productRequest.deliveryType = type
    }
    @objc func backGroundTapped(_ sender :UITapGestureRecognizer){
        closeView()
    }
    
    @IBAction func doorStepDeliveryTapped(_ sender: Any) {
        assignDeliveryType(type: RequestProduct.HOME_DELIVERY)
    }
    
    @IBAction func addAddressTapped(_ sender: Any) {
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: "", currentSelectedLocation: QuickShareCache.getInstance()?.getUserLocation(), hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        self.navigationController?.pushViewController(changeLocationViewController, animated: true)
    }
    
    @IBAction func selfPickupTapped(_ sender: Any) {
        assignDeliveryType(type: RequestProduct.SELF_PICKUP)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        if productRequest.tradeType == Product.RENT && (productRequest.fromTime == 0 || productRequest.toTime == 0){
            UIApplication.shared.keyWindow?.makeToast( "Select Rental Days")
            return
        }
        handler?(productRequest)
        closeView()
    }
    
    @IBAction func startDateTapped(_ sender: Any) {
        isFromStartDate = true
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleLater.initializeDataBeforePresentingView(minDate : NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: nil, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    @IBAction func endDateTapped(_ sender: Any) {
        var defaultDate : Double?
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        if startDate.text != nil{
            defaultDate = DateUtils.getNSDateFromTimeStamp(timeStamp: productRequest.fromTime)?.addDays(daysToAdd: 7).timeIntervalSince1970
        }else{
            defaultDate = nil
        }
        scheduleLater.initializeDataBeforePresentingView(minDate : NSDate().timeIntervalSince1970,maxDate: nil, defaultDate: defaultDate, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    
    private func closeView(){
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
//MARK: SelectDateDelegate
extension SelectDeliveryTypeViewController: SelectDateDelegate{
    func getTime(date: Double) {
        if isFromStartDate{
            startDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date*1000, timeFormat: DateUtils.DATE_FORMAT_D_MM)
            startDate.textColor = UIColor.black.withAlphaComponent(1)
            productRequest.fromTime = date*1000
            isFromStartDate = false
        }else{
            endDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date*1000, timeFormat: DateUtils.DATE_FORMAT_D_MM)
            endDate.textColor = UIColor.black.withAlphaComponent(1)
            productRequest.toTime = date*1000
            continueButton.backgroundColor = Colors.green
        }
    }
}
//ReceiveLocationDelegate
extension SelectDeliveryTypeViewController: ReceiveLocationDelegate{
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        
    }
    
    func locationSelectionCancelled(requestLocationType: String) {}
}
