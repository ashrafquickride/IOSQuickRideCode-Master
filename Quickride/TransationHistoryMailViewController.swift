//
//  TransationHistoryMailViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 18/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit



class TransationHistoryMailViewController: UIViewController, AccountUpdateDelegate {
    
    @IBOutlet weak var monthlyReportTableView: UITableView!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var elementsView: UIView!
    @IBOutlet weak var emaiLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var reportSentLabel: UILabel!
    @IBOutlet weak var showEmailLabel: UILabel!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var reportBackgroundView: UIView!
    @IBOutlet weak var sendEmailButtn: UIButton!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    private var viewModel = TransationHistoryViewModel()
    let datePicker =  UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyReportTableView.dataSource = self
        monthlyReportTableView.delegate = self
        monthlyReportTableView.register(UINib(nibName: "TransationHistoryMailTableViewCell", bundle: nil), forCellReuseIdentifier: "TransationHistoryMailTableViewCell")
        fromDateLabel.layer.masksToBounds = true
        toDateLabel.layer.masksToBounds = true
        fromDateLabel.layer.cornerRadius = 5
        toDateLabel.layer.cornerRadius = 5
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fromDateSelected(_:))))
        toDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toDateSelected(_:))))
        reportBackgroundView.isHidden = true
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if UserDataCache.getInstance()?.getCurrentUserEmail() != "" {
            showEmailLabel.text = UserDataCache.getInstance()?.getCurrentUserEmail()
        }else{
            showEmailLabel.text = "Click on change to configure contact email"
        }
    }
    
    private func setFromAndToDate(){
        
        if let fromDate = viewModel.fromDate {
        fromDateLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: fromDate), format: DateUtils.DATE_FORMAT_yyyy_MM_dd)
        }else{
            fromDateLabel.text = ""
           
        }
        
        if viewModel.fromDate ?? 0 >= viewModel.toDate ?? 0 {
            toDateLabel.text = ""
            UIApplication.shared.keyWindow?.makeToast(Strings.select_date_format)
            return
        }
        
        if let toDate = viewModel.toDate {
        toDateLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: toDate), format: DateUtils.DATE_FORMAT_yyyy_MM_dd)
            sendEmailButtn.backgroundColor = UIColor(netHex: 0x00B557)
        } else {
            toDateLabel.text = ""
        }
        
    }
    
    @IBAction func emailChangeTapped(_ sender: Any) {
        let monthlyreportViewController = UIStoryboard(name: StoryBoardIdentifiers.accountsb_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChangeEmailViewController") as! ChangeEmailViewController
        
        monthlyreportViewController.accountUpdateDelegate = self
        monthlyreportViewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.view.addSubview(monthlyreportViewController.view)
        self.navigationController?.addChild(monthlyreportViewController)
        
    }
    
    @IBAction func backButtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func sendEmailTapped(_ sender: Any) {
        let dateFormatter = DateFormatter()
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        let lastMonthName = dateFormatter.string(from: lastMonthDate!)
        dateFormatter.dateFormat = DateUtils.DATE_FORMAT_yyyy_MM_dd
        if viewModel.fromDate == viewModel.toDate || viewModel.fromDate == nil || viewModel.toDate == nil || toDateLabel.text?.isEmpty == true {
        UIApplication.shared.keyWindow?.makeToast(Strings.please_enter_date_valid_format)
            return
        }
        
        let toDate = Date(timeIntervalSince1970: viewModel.toDate ?? 0)
        let fromDate = Date(timeIntervalSince1970: viewModel.fromDate ?? 0)
        self.getParticularMonthReport(fromDate: dateFormatter.string(from:  fromDate), toDate: dateFormatter.string(from: toDate), monthName: " ")
       
    }
    
    @objc func fromDateSelected(_ gesture: UITapGestureRecognizer){
        viewModel.DateType = TransationHistoryViewModel.FROM_DATE
        self.showDatePicker()
    }
    
    @objc func toDateSelected(_ gesture: UITapGestureRecognizer){
        viewModel.DateType = TransationHistoryViewModel.TO_DATE
        self.showDatePicker()
    }
    
    func showDatePicker(){
        let scheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        scheduleRideViewController.modalPresentationStyle = .overCurrentContext
        scheduleRideViewController.delegate = self
        scheduleRideViewController.initializeDataBeforePresentingView(minDate: nil, maxDate:  NSDate().timeIntervalSince1970, defaultDate: NSDate().timeIntervalSince1970, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        self.present(scheduleRideViewController, animated: false, completion: nil)
    }
    
    func getParticularMonthReport(fromDate: String, toDate: String, monthName: String){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getMonthlyReport(userId: (QRSessionManager.getInstance()?.getUserId())!, fromDate: fromDate, toDate: toDate, viewController: self){ (responseObject, error) in
            self.reportBackgroundView.isHidden = false
            self.reportSentLabel.isHidden = false
            self.changeButton.isHidden = true
            self.showEmailLabel.isHidden = true
            self.emaiLabel.isHidden = true
            QuickRideProgressSpinner.stopSpinner()
           
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.toDateLabel.text = ""
                self.fromDateLabel.text = ""
                self.sendEmailButtn.backgroundColor = UIColor(netHex: 0xAAAAAA)
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.monthly_report_sent_msg, arguments: [monthName]))
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                     self.reportSentLabel.isHidden = true
                    self.reportBackgroundView.isHidden = true
                    self.changeButton.isHidden = false
                    self.showEmailLabel.isHidden = false
                    self.emaiLabel.isHidden = false
            }
                self.viewModel.toDate = nil
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func accountUpdated() {
        self.viewWillAppear(false)
    }
}
    
extension TransationHistoryMailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransationHistoryMailTableViewCell", for: indexPath) as! TransationHistoryMailTableViewCell
        
        func monthlyReport(value: Int){
            let MonthDate = Calendar.current.date(byAdding: .month, value: value, to: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_MMMM
            let MonthName = dateFormatter.string(from: MonthDate!)
            cell.monthlyReportLabel.text = String(format: Strings.monthly_report, arguments: [MonthName])
        }
        
        switch indexPath.section {
        case 0:
            monthlyReport(value: -1)
            return cell
        case 1:
            monthlyReport(value: -2)
            return cell
        case 2:
            monthlyReport(value: -3)
            return cell
        default:
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_MMMM
            let lastMonthName = dateFormatter.string(from: lastMonthDate!)
            
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_yyyy_MM_dd
            self.getParticularMonthReport(fromDate: dateFormatter.string(from: lastMonthDate!.startOfMonth()), toDate: dateFormatter.string(from: lastMonthDate!.endOfMonth()), monthName: lastMonthName)
            
        }
        
        if indexPath.section == 1{
            let secondLastMontDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_MMMM
            let secondLastMonthName = dateFormatter.string(from: secondLastMontDate!)
            
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_yyyy_MM_dd
            self.getParticularMonthReport(fromDate: dateFormatter.string(from: secondLastMontDate!.startOfMonth()), toDate: dateFormatter.string(from: secondLastMontDate!.endOfMonth()), monthName: secondLastMonthName)
            
        }
        
        if indexPath.section == 2 {
            let thirdLastMonthDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_MMMM
            let thirdLastMonthName = dateFormatter.string(from: thirdLastMonthDate!)
            
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            dateFormatter.dateFormat = DateUtils.DATE_FORMAT_yyyy_MM_dd
            self.getParticularMonthReport(fromDate: dateFormatter.string(from: thirdLastMonthDate!.startOfMonth()), toDate: dateFormatter.string(from: thirdLastMonthDate!.endOfMonth()), monthName: thirdLastMonthName)
            
        }
        reportBackgroundView.isHidden = false
        reportSentLabel.isHidden = false
        changeButton.isHidden = true
        showEmailLabel.isHidden = true
        emaiLabel.isHidden = true
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
    
extension TransationHistoryMailViewController: SelectDateDelegate{
    func getTime(date: Double) {
        if viewModel.DateType == TransationHistoryViewModel.FROM_DATE {
            viewModel.fromDate = date
            viewModel.DateType = nil
        }
        
        if viewModel.DateType == TransationHistoryViewModel.TO_DATE {
            viewModel.toDate = date
            viewModel.DateType = nil
        }
        setFromAndToDate()
    }
}

