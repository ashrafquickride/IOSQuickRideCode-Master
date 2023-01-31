//
//  RecurringRideSettingsViewController.swift
//  Quickride
//
//  Created by Halesh on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias editWeekDaysTimeCompletionHandler = (_ weekdays : [Int : String?],_ dayType: String, _ startTime: Double?) -> Void

class RecurringRideSettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SelectDateDelegate {
    
    @IBOutlet weak var rideDateLabel: UILabel!
    
    @IBOutlet weak var rideTimeLabel: UILabel!
    
    @IBOutlet weak var daysTableView: UITableView!
    
    @IBOutlet weak var oddEvenButton: UIButton!
    
    @IBOutlet weak var oddAndEvenDaysOptionView: UIView!
    
    @IBOutlet weak var oddEvenView: UIView!
    
    @IBOutlet weak var oddAndEvenDaysOptionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var oddDaysOptionButton: UIButton!
    
    @IBOutlet weak var evenDaysOptionButton: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    private var ride: Ride?
    private var weekdays :[Int : String?] = [Int : String?]()
    private var editWeekDaysTimeCompletionHandler : editWeekDaysTimeCompletionHandler?
    private var isWeekDaysEdited = false
    private var dayType = Ride.ALL_DAYS
    
    func initailizeRecurringRideSettingView(ride: Ride,dayType: String,weekdays: [Int : String?],editWeekDaysTimeCompletionHandler: @escaping editWeekDaysTimeCompletionHandler){
        self.ride = ride
        self.weekdays = weekdays
        self.editWeekDaysTimeCompletionHandler = editWeekDaysTimeCompletionHandler
        self.dayType = dayType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         definesPresentationContext = true
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        daysTableView.delegate = self
        daysTableView.dataSource = self
        daysTableView.reloadData()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecurringRideSettingsViewController.backGroundViewTapped)))
        oddEvenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecurringRideSettingsViewController.oddEvenViewTapped)))
        showOddandEvenOption()
        getStartDateAndTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func showOddandEvenOption(){
        if dayType == Ride.ALL_DAYS{
            oddEvenButton.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
            oddAndEvenDaysOptionView.isHidden = true
            oddAndEvenDaysOptionViewHeightConstraint.constant = 0
        }else{
            oddEvenButton.setImage(UIImage(named: "insurance_tick"), for: .normal)
            oddAndEvenDaysOptionView.isHidden = false
            oddAndEvenDaysOptionViewHeightConstraint.constant = 50
            if dayType == Ride.ODD_DAYS{
                oddDaysOptionTapped()
            }else{
                evenDaysOptionTapped()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DaysTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as! DaysTableViewCell
        var dayIsDisable = false
        if weekdays[indexPath.row] != nil{
            dayIsDisable = false
        }else{
            dayIsDisable = true
        }
        cell.initailizeDayCell(day: getDayForWeekDay(weekDayIndex: indexPath.row), daytime: getDayTime(dayTime: weekdays[indexPath.row] ?? nil), dayIsDisable: dayIsDisable)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath()")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if let time = self.weekdays[indexPath.row]{
            editRemoveAction(indexPath: indexPath, dayTime: time!, alertController: alertController)
        }else{
            addAction(indexPath: indexPath, alertController: alertController)
        }
        
        let cancleAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert :UIAlertAction!) in
            self.view.isUserInteractionEnabled = true
        })
        
        alertController.addAction(cancleAction)
        
        alertController.view.tintColor = Colors.alertViewTintColor
        present(alertController, animated: false, completion: {
            alertController.view.tintColor = Colors.alertViewTintColor
        })
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(netHex: 0xe9e9e9)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
    private func getDayTime(dayTime: String?) -> String?{
        if let timeForDay = dayTime{
            return DateUtils.getTimeStringFromTime(time: timeForDay, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        } else {
            return DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride!.startTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        }
    }
    func getDayForWeekDay(weekDayIndex : Int) -> String{
        AppDelegate.getAppDelegate().log.debug("getTimeForWeekDay() \(weekDayIndex)")
        switch weekDayIndex{
        case 0:
            return Strings.monday
            
        case 1:
            return Strings.tuesday
            
        case 2:
            return Strings.wednesday
            
        case 3:
            return Strings.thursday
            
        case 4:
            return Strings.friday
            
        case 5:
            return Strings.saturday
            
        case 6:
            return Strings.sunday
            
        default :
            return Strings.monday
        }
    }
    func addAction(indexPath: IndexPath, alertController: UIAlertController){
        let starttime = DateUtils.getTimeStampFromString(dateString: rideTimeLabel.text, dateFormat: DateUtils.TIME_FORMAT_hhmm_a)
        let addTimeAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: {(alert :UIAlertAction!) in
            let indexPath = IndexPath(row: indexPath.row,section: 0)
            self.weekdays[indexPath.row] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: starttime, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
            self.daysTableView.reloadRows(at: [indexPath], with: .none)
            self.isWeekDaysEdited = true
        })
        alertController.addAction(addTimeAction)
    }
    
    func editRemoveAction(indexPath: IndexPath,dayTime: String, alertController: UIAlertController){
        let editTimeAction = UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {(alert :UIAlertAction!) in
            
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            let storyboard = UIStoryboard(name: "Common", bundle: nil)
            let selectDateTimeViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
            
            let date = DateUtils.getTimStampFromTimeString(timeString: dayTime , timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
            
            selectDateTimeViewController.initializeDataBeforePresentingView(minDate: nil, maxDate: nil, defaultDate: date.timeIntervalSince1970, isDefaultDateToShow: false, delegate: nil, datePickerMode: UIDatePicker.Mode.time, datePickerTitle: nil) { (date) in
                self.weekdays[indexPath.row] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date.getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
                self.daysTableView.reloadRows(at: [indexPath], with: .none)
                self.isWeekDaysEdited = true
            }
            selectDateTimeViewController.modalPresentationStyle = .overCurrentContext
            ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: selectDateTimeViewController, animated: false, completion: nil)
        })
        alertController.addAction(editTimeAction)
        
        let removeAction = UIAlertAction(title: "Remove", style: UIAlertAction.Style.destructive, handler: {(alert :UIAlertAction!) in
            let cell = self.daysTableView.cellForRow(at: indexPath as IndexPath) as! DaysTableViewCell
            AppDelegate.getAppDelegate().log.debug(cell.dayLabel.text)
            self.weekdays[indexPath.row] = nil
            self.daysTableView.reloadRows(at: [indexPath], with: .none)
            self.isWeekDaysEdited = true
        })
        alertController.addAction(removeAction)
    }
    
    @objc func oddEvenViewTapped(_ sender:UITapGestureRecognizer){
        if oddAndEvenDaysOptionView.isHidden{
            oddEvenButton.setImage(UIImage(named: "insurance_tick"), for: .normal)
            oddAndEvenDaysOptionView.isHidden = false
            oddAndEvenDaysOptionViewHeightConstraint.constant = 50
            oddEvenOptions()
        }else{
            oddEvenButton.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
            oddAndEvenDaysOptionView.isHidden = true
            oddAndEvenDaysOptionViewHeightConstraint.constant = 0
            dayType = Ride.ALL_DAYS
            isWeekDaysEdited = true
        }
    }
    private func oddEvenOptions(){
        ViewCustomizationUtils.addBorderToView(view: oddDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0xa8a8a8))
        oddDaysOptionButton.setTitleColor(UIColor(netHex: 0xa8a8a8), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: evenDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0xa8a8a8))
        evenDaysOptionButton.setTitleColor(UIColor(netHex: 0xa8a8a8), for: .normal)
    }
    
    @IBAction func oddDaysTapped(_ sender: Any) {
        isWeekDaysEdited = true
        dayType = Ride.ODD_DAYS
        oddDaysOptionTapped()
    }
    private func oddDaysOptionTapped(){
        ViewCustomizationUtils.addBorderToView(view: oddDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0x2196F3))
        oddDaysOptionButton.setTitleColor(UIColor(netHex: 0x2196F3), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: evenDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0xa8a8a8))
        evenDaysOptionButton.setTitleColor(UIColor(netHex: 0xa8a8a8), for: .normal)
    }
    @IBAction func evenDaysTapped(_ sender: Any) {
        isWeekDaysEdited = true
        dayType = Ride.EVEN_DAYS
        evenDaysOptionTapped()
    }
    private func evenDaysOptionTapped(){
        ViewCustomizationUtils.addBorderToView(view: oddDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0xa8a8a8))
        oddDaysOptionButton.setTitleColor(UIColor(netHex: 0xa8a8a8), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: evenDaysOptionButton, borderWidth: 1, color: UIColor(netHex: 0x2196F3))
        evenDaysOptionButton.setTitleColor(UIColor(netHex: 0x2196F3), for: .normal)
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        if isWeekDaysEdited{
            editWeekDaysTimeCompletionHandler!(weekdays,dayType,ride?.startTime)
        }
        closeView()
    }
    
    @objc func backGroundViewTapped(_ sender:UITapGestureRecognizer){
        closeView()
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
    func getStartDateAndTime(){
        var date : NSDate?
        date = DateUtils.getNSDateFromTimeStamp(timeStamp: (ride?.startTime)!)
        date = date!.addDays(daysToAdd: 1)
        if date!.isLessThanDate(dateToCompare: NSDate()){
            date = NSDate()
        }
        rideDateLabel.text =  DateUtils.getDateStringFromNSDate(date: date!, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)!
        rideTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride!.startTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let selectDateTimeViewController :ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        selectDateTimeViewController.initializeDataBeforePresentingView(minDate: (ride?.startTime)!/1000,maxDate: nil, defaultDate: (ride?.startTime)!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        selectDateTimeViewController.modalPresentationStyle = .overCurrentContext
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: selectDateTimeViewController, animated: false, completion: nil)
    }
    
    func getTime(date: Double){
        AppDelegate.getAppDelegate().log.debug("getTime")
        ride!.startTime = date * 1000
        rideDateLabel.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: date), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let timeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date * 1000, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        rideTimeLabel.text = timeString
        let timeToStore = DateUtils.getTimeStringFromTimeInMillis(timeStamp: date * 1000, timeFormat: DateUtils.DATE_FORMAT_HH_mm_ss)
        if self.weekdays[0] != nil
        {
            self.weekdays[0] = timeToStore
        }
        if self.weekdays[1] != nil
        {
            self.weekdays[1] = timeToStore
        }
        if self.weekdays[2] != nil
        {
            self.weekdays[2] = timeToStore
        }
        if self.weekdays[3] != nil
        {
            self.weekdays[3] = timeToStore
        }
        if self.weekdays[4] != nil
        {
            self.weekdays[4] = timeToStore
        }
        if self.weekdays[5] != nil
        {
            self.weekdays[5] = timeToStore
        }
        if self.weekdays[6] != nil
        {
            self.weekdays[6] = timeToStore
        }
        if ride == nil{
            return
        }
        daysTableView.reloadData()
        isWeekDaysEdited = true
    }
}
