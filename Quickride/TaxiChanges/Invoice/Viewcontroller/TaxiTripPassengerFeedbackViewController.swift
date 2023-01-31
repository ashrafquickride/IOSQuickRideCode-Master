//
//  TaxiTripPassengerFeedbackViewController.swift
//  Quickride
//
//  Created by Rajesab on 27/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripPassengerFeedbackViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var taxiTripPassengerFeedbackTableView: UITableView!
    @IBOutlet weak var passengerFeedbackTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var oneRatingBtn: UIButton!
    @IBOutlet weak var twoRatingBtn: UIButton!
    @IBOutlet weak var threeRatingBtn: UIButton!
    @IBOutlet weak var fourRatingBtn: UIButton!
    @IBOutlet weak var fiveRatingBtn: UIButton!
    @IBOutlet weak var ratingTitleLAbel: UILabel!
    @IBOutlet weak var rideDetailInfoLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var tripStartTimeLabel: UILabel!
    @IBOutlet weak var feedbackTopView: UIView!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    private var taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel()
    private var ratingButtonArray = [UIButton]()
    private var isKeyBoardVisible = false
    
    func initializeData(taxiRideInvoice:TaxiRideInvoice?, rating: Double, taxiRidePassenger: TaxiRidePassenger?){
        taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel(rating: rating, taxiRideInvoice: taxiRideInvoice, taxiRidePassenger: taxiRidePassenger)
    }
    
    func initialiseData(rating: Double?, taxiFeedBackNotification: TaxiFeedBackNotification?, isFromNotification: Bool){
        taxiTripPassengerFeedbackViewModel = TaxiTripPassengerFeedbackViewModel(rating: rating, taxiFeedBackNotification: taxiFeedBackNotification, isFromNotification: isFromNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        collectDataBeforePresentingView(isFromNotification: taxiTripPassengerFeedbackViewModel.isFromNotification)
        alterTableViewHeight()
        taxiTripPassengerFeedbackTableView.delegate = self
        taxiTripPassengerFeedbackTableView.dataSource = self
        taxiTripPassengerFeedbackTableView.reloadData()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        addObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        NotificationCenter.default.removeObserver(self)
    }
    func collectDataBeforePresentingView(isFromNotification: Bool){
        ratingButtonArray = [oneRatingBtn,twoRatingBtn,threeRatingBtn,fourRatingBtn,fiveRatingBtn]
        if isFromNotification{
            initialiseNotificationData()
        }else {
            initialiseDriverData()
        }
    }
    func initialiseDriverData() {
        ratingTitleLAbel.text = String(format: Strings.rate_your_ride_with, arguments: [taxiTripPassengerFeedbackViewModel.taxiRideInvoice?.toUserName ?? ""])
        rideDetailInfoLabel.text = String(format: Strings.your_trip_to, arguments: [taxiTripPassengerFeedbackViewModel.taxiRideInvoice?.endLocation ?? ""])
        tripStartTimeLabel.text = String(format: Strings.on_time, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiTripPassengerFeedbackViewModel.taxiRideInvoice?.startTimeMs, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!])
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  taxiTripPassengerFeedbackViewModel.taxiRideInvoice?.driverImageURI ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
            setRating(selestedRating: Int(taxiTripPassengerFeedbackViewModel.rating))
    }
    func initialiseNotificationData() {
        ratingTitleLAbel.text = String(format: Strings.rate_your_ride_with, arguments: [taxiTripPassengerFeedbackViewModel.taxiFeedBackNotification?.driverName ?? ""])
        rideDetailInfoLabel.text = String(format: Strings.your_trip_to, arguments: [taxiTripPassengerFeedbackViewModel.taxiFeedBackNotification?.endAddress ?? ""])
        tripStartTimeLabel.text = String(format: Strings.on_time, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double((taxiTripPassengerFeedbackViewModel.taxiFeedBackNotification?.endTimeInMs) ?? ""), timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!])
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  (taxiTripPassengerFeedbackViewModel.taxiFeedBackNotification?.driverImgUri ?? "") , placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
            setRating(selestedRating: Int(taxiTripPassengerFeedbackViewModel.rating))
    }
 
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        if taxiTripPassengerFeedbackViewModel.rating >= 4{
            taxiTripPassengerFeedbackViewModel.submitRatingAndFeedBack(feedback: nil)
        }
        closeView()
    }
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    private func setGivenRating(selectedRating: Int) {
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
    }
    private func registerCells(){
        taxiTripPassengerFeedbackTableView.rowHeight = UITableView.automaticDimension
        taxiTripPassengerFeedbackTableView.register(UINib(nibName: "TaxiTripRatingReasonSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripRatingReasonSelectTableViewCell")
        taxiTripPassengerFeedbackTableView.register(UINib(nibName: "TaxiTripPassengerFeedbackFourRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripPassengerFeedbackFourRatingTableViewCell")
        taxiTripPassengerFeedbackTableView.register(UINib(nibName: "TaxiTripPassengerFeedbackFiveRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiTripPassengerFeedbackFiveRatingTableViewCell")
    }
    
    private func alterTableViewHeight() {
        if taxiTripPassengerFeedbackViewModel.rating == 1 || taxiTripPassengerFeedbackViewModel.rating == 2{
            self.passengerFeedbackTableViewHeightConstraint.constant = 170
        }else if taxiTripPassengerFeedbackViewModel.rating == 3 {
            self.passengerFeedbackTableViewHeightConstraint.constant = 170
        }else if taxiTripPassengerFeedbackViewModel.rating == 4 {
            self.passengerFeedbackTableViewHeightConstraint.constant = 200
        }else if taxiTripPassengerFeedbackViewModel.rating == 5 {
            self.passengerFeedbackTableViewHeightConstraint.constant = 150
        }
    }
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(removeSubVIew), name: .ratingGivenForDriver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaxiTripPassengerFeedbackViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaxiTripPassengerFeedbackViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc func removeSubVIew(_ notification:Notification) {
      closeView()
    }
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 0
    }
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        setRating(selestedRating: sender.tag + 1)
        taxiTripPassengerFeedbackTableView.reloadData()
        alterTableViewHeight()
    }
    
    private func setRating(selestedRating: Int){
        for (index,data) in ratingButtonArray.enumerated() {
            if index < selestedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
        taxiTripPassengerFeedbackViewModel.rating = Double(selestedRating)
    }
    
}
extension TaxiTripPassengerFeedbackViewController: UITableViewDataSource,TaxiTripRatingReasonSelectTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // reason card
            return 1
        case 1: //appstore rating card
               return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if  taxiTripPassengerFeedbackViewModel.rating >= 1 && taxiTripPassengerFeedbackViewModel.rating <= 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripRatingReasonSelectTableViewCell", for: indexPath) as! TaxiTripRatingReasonSelectTableViewCell
                cell.prepareBadRatingReasons(taxiTripPassengerFeedbackViewModel: taxiTripPassengerFeedbackViewModel, delegate: self)
                return cell
            }else  if taxiTripPassengerFeedbackViewModel.rating == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripPassengerFeedbackFourRatingTableViewCell", for: indexPath) as! TaxiTripPassengerFeedbackFourRatingTableViewCell
                cell.initializeData(taxiTripPassengerFeedbackViewModel: taxiTripPassengerFeedbackViewModel)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiTripPassengerFeedbackFiveRatingTableViewCell", for: indexPath) as! TaxiTripPassengerFeedbackFiveRatingTableViewCell
                cell.initializeData(taxiTripPassengerFeedbackViewModel: taxiTripPassengerFeedbackViewModel)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    func reasonsListOpen(noOfReasons: Int) {
        passengerFeedbackTableViewHeightConstraint.constant = 455
    }
    func reasonsListClosed() {
        passengerFeedbackTableViewHeightConstraint.constant = 150
    }
}
