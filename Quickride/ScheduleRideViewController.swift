//
//  ScheduleRideViewController.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 30/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol SelectDateDelegate{
    func getTime(date : Double)
}
typealias dateCompletionHandler = (_ date : NSDate)->Void

class ScheduleRideViewController: UIViewController {
    
    var vc:UIViewController?
    var rideType:String?
    var selected:Int?
    var delegate:SelectDateDelegate?
    var handler : dateCompletionHandler?
    var minDate :Double?
    var maxDate :Double?
    var defaultDate :Double = 0.0
    var datePickerMode : UIDatePicker.Mode?
    var datePickerTitle : String?
    var isDefaultDateToShow = false
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var datePickerTitleView: UIView!
    @IBOutlet weak var datePickerViewHeightConstant: NSLayoutConstraint!
  
    
    @IBOutlet weak var datePickerTitleLbl: UILabel!
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBAction func ibaCancel(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func ibaOK(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
        self.delegate?.getTime(date: self.datePicker.date.timeIntervalSince1970)
        self.handler?(self.datePicker.date as NSDate)
    }
    
    func initializeDataBeforePresentingView(minDate :Double?, maxDate: Double?, defaultDate :Double?, isDefaultDateToShow: Bool,  delegate:SelectDateDelegate?, datePickerMode : UIDatePicker.Mode?,datePickerTitle : String?,handler: dateCompletionHandler?){
        self.minDate = minDate
        self.maxDate = maxDate
        if defaultDate != nil{
            self.defaultDate = defaultDate!
        }
        if datePickerTitle != nil{
            self.datePickerTitle = datePickerTitle
        }
        if delegate != nil{
            self.delegate = delegate
        }
        if handler != nil {
        self.handler = handler
        }
        self.datePickerMode = datePickerMode
        self.isDefaultDateToShow = isDefaultDateToShow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScheduleRideViewController.dismissViewTapped(_:))))
        if datePickerTitle != nil{
            datePickerTitleView.isHidden = false
            datePickerViewHeightConstant.constant = 40
            datePickerTitleLbl.text = datePickerTitle
        }else{
            datePickerTitleView.isHidden = true
            datePickerViewHeightConstant.constant = 0
        }
        datePicker.locale = Locale(identifier: "en_US_POSIX")
        if minDate != nil && minDate! < NSDate().timeIntervalSince1970{
            minDate = NSDate().timeIntervalSince1970
            datePicker.minimumDate = NSDate(timeIntervalSince1970: minDate!) as Date
        }
        else if minDate != nil && minDate! > NSDate().timeIntervalSince1970
        {
            datePicker.minimumDate = NSDate(timeIntervalSince1970: minDate!) as Date
        }
        
        else{
            datePicker.minimumDate = nil
        }
        if maxDate != nil && maxDate! < NSDate().timeIntervalSince1970{
            minDate = NSDate().timeIntervalSince1970
            datePicker.maximumDate = NSDate(timeIntervalSince1970: maxDate!) as Date
        }else{
            datePicker.maximumDate = nil
        }
        
        datePicker.datePickerMode = self.datePickerMode!
        if !isDefaultDateToShow {
            if datePicker.maximumDate != nil {
                defaultDate = maxDate!
            } else if defaultDate < NSDate().timeIntervalSince1970{
                defaultDate = NSDate().timeIntervalSince1970
            }
        }
        
        datePicker.date = NSDate(timeIntervalSince1970: defaultDate) as Date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc func dismissViewTapped(_ gesture : UITapGestureRecognizer){
        dismiss(animated: false, completion: nil)
    }
}
