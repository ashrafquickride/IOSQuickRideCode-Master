//
//  SendInviteBaseViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 5/24/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import MaterialComponents.MaterialButtons
import Lottie
import DropDown
import UIKit

class SendInviteBaseViewController: UIViewController {
    
    @IBOutlet weak var iboTableView: UITableView!
    @IBOutlet weak var rideRequestAckView: UIView!
    @IBOutlet weak var progressSpinnerView: UIProgressView!
    @IBOutlet weak var rideRequestAckLabel: UILabel!
    
    @IBOutlet weak var filterOptionCollectionView: UICollectionView!
    @IBOutlet weak var filterOptionCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeRangeDropDownView: UIView!
    @IBOutlet weak var filterAppliedCountView: UIView!
    @IBOutlet weak var filterAppliedCountViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterMatchesCountLabel: UILabel!
    
    //MARK: Header View
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var searchButton: CustomUIButton!
    @IBOutlet weak var inviteAll: UIButton!
    @IBOutlet weak var matchingUserLabel: UILabel!
    @IBOutlet weak var menuButton: CustomUIButton!
    @IBOutlet weak var menuAnchorView: UIView!
    
    @IBOutlet weak var taxiView: UIView!
    @IBOutlet weak var taxiOrTaxipoolStackView: UIStackView!
    @IBOutlet weak var taxiStartsAmountLabel: UILabel!
    @IBOutlet weak var verifyProfileView: UIView!
    @IBOutlet weak var verifyProfilelabel: UILabel!
    @IBOutlet weak var requestSentInfoView: UIView!
    @IBOutlet weak var requestSentInfoStackView: UIStackView!
    
    private var isKeyBoardVisible = false
    private var routeMatchDropDown = DropDown()
    private var quickRideProgressBar : QuickRideProgressBar?
    private var joinFlowUI: NewJoinShimmerViewController?
    private var hidingNavBarManager: HidingNavigationBarManager?
    private var menuDropDown = DropDown()
    private var menuOptions = [Strings.invite_by_contacts]
    
    var sendInviteViewModel = SendInviteViewModel()
    
    func initializeDataBeforePresenting(scheduleRide : Ride,isFromCanceRide: Bool, isFromRideCreation: Bool){
        sendInviteViewModel = SendInviteViewModel(scheduleRide: scheduleRide, isFromCanceRide: isFromCanceRide, isFromRideCreation: isFromRideCreation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpUI()
        quickRideProgressBar?.startProgressBar()
        sendInviteViewModel.getMatchingOptions(matchedUsersDataReceiver: self)
        verifyProfileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(verifyProfile(_:))))
        taxiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToTaxiBookingScreen(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        confirmNSNotification()
        self.navigationController?.isNavigationBarHidden = true
        iboTableView.reloadData()
        validateAndDisplayJoinButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func confirmNSNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(cancelRideInvitationSuccess(_:)), name: .cancelRideInvitationSuccess, object: sendInviteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelRideInvitationFailed(_:)), name: .cancelRideInvitationFailed, object: sendInviteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(bestMatchAlertCreated(_:)), name: .bestMatchAlertCreated, object: sendInviteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(bestMatchAlertCreationFailed(_:)), name: .bestMatchAlertCreationFailed, object: sendInviteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(clearFilters(_:)), name: .clearFilters, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRelayRides(_:)), name: .receivedRelayRides, object: sendInviteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(loadMore(_:)), name: .loadMore, object: nil)
    }
    
    private func setUpUI(){
        taxiOrTaxipoolStackView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        searchBar.delegate = self
        backButton.changeBackgroundColorBasedOnSelection()
        searchButton.changeBackgroundColorBasedOnSelection()
        quickRideProgressBar = QuickRideProgressBar(progressBar: progressSpinnerView)
        getTaxiOptions()
        NotificationCenter.default.addObserver(self, selector: #selector(SendInviteBaseViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendInviteBaseViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func getTaxiOptions(){
        if sendInviteViewModel.scheduleRide?.rideType == Ride.PASSENGER_RIDE {
            sendInviteViewModel.getTaxiOptions { [weak self](result) in
                    self?.iboTableView.reloadData()
                self?.showTaxiCardIfRequired()
            }
        }
    }
    
    private func showTaxiCardIfRequired(){
        if let detailEstimatedFare = sendInviteViewModel.detailEstimatedFare, detailEstimatedFare.serviceableArea, sendInviteViewModel.matchedTaxipool == nil, !sendInviteViewModel.isOutstationRide(),(!sendInviteViewModel.matchedUsers.isEmpty || !sendInviteViewModel.readyToGoMatches.isEmpty || !sendInviteViewModel.relayRides.isEmpty) {
           taxiView.isHidden = false
            initialiseTaxiView(detailEstimatedFare: detailEstimatedFare)
        }else{
            taxiView.isHidden = true
        }
    }
    
    private func registerCell() {
        iboTableView.estimatedRowHeight = 240
        iboTableView.rowHeight = UITableView.automaticDimension
        iboTableView.register(UINib(nibName: "MatchedUserTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchedUserTableViewCell")
        iboTableView.register(UINib(nibName: "CreateRideTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateRideTableViewCell")
        iboTableView.register(UINib(nibName: "InviteByContactTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteByContactTableViewCell")
        iboTableView.register(UINib(nibName: "NoMatchesTableViewCell", bundle: nil), forCellReuseIdentifier: "NoMatchesTableViewCell")
        iboTableView.register(UINib(nibName: "NoMatchesAfterFilteringTableViewCell", bundle: nil), forCellReuseIdentifier: "NoMatchesAfterFilteringTableViewCell")
        iboTableView.register(UINib(nibName: "RelayRideMatchTableViewCell", bundle: nil), forCellReuseIdentifier: "RelayRideMatchTableViewCell")
        iboTableView.register(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
        iboTableView.register(UINib(nibName: "FooterTableViewCell", bundle: nil), forCellReuseIdentifier: "FooterTableViewCell")
        iboTableView.register(UINib(nibName: "JobPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "JobPromotionTableViewCell")
        iboTableView.register(UINib(nibName: "JobPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "JobPromotionTableViewCell")
        iboTableView.register(UINib(nibName: "MatchingOptionOutstationTaxiTableViewCell", bundle : nil),forCellReuseIdentifier: "MatchingOptionOutstationTaxiTableViewCell")
        iboTableView.register(UINib(nibName: "ReferQuickRideTableViewCell", bundle : nil),forCellReuseIdentifier: "ReferQuickRideTableViewCell")
        iboTableView.register(UINib(nibName: "InActiveMatchesTableViewCell", bundle : nil),forCellReuseIdentifier: "InActiveMatchesTableViewCell")
        iboTableView.register(UINib(nibName: "MatchingTaxipoolTableViewCell", bundle : nil),forCellReuseIdentifier: "MatchingTaxipoolTableViewCell")
        iboTableView.register(UINib(nibName: "InstantRideMatchedUserDetailTableViewCell", bundle : nil),forCellReuseIdentifier: "InstantRideMatchedUserDetailTableViewCell")
    }
    
    //MARK: Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchBar.isHidden = false
        searchBar.showsCancelButton = true
        navigationView.isHidden = true
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        setupMenuhDropDown()
    }
    
    @IBAction func bookTaxiButtonTapped(_ sender: Any) {
        naviateToTaxiBooking()
    }
    
    func setupMenuhDropDown() {
        menuDropDown.anchorView = menuAnchorView
        menuDropDown.dataSource = menuOptions
        menuDropDown.show()
        menuDropDown.selectionAction = { (index, item) in
            if item == Strings.invite_by_contacts {
                if let ride = self.sendInviteViewModel.scheduleRide {
                    let inviteContactsAndGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteContactsAndGroupViewController") as! InviteContactsAndGroupViewController
                    inviteContactsAndGroupViewController.initailizeView(ride: ride,taxiRide: nil)
                    self.navigationController?.pushViewController(inviteContactsAndGroupViewController, animated: true)
                }
            }
        }
    }
    
    @objc func bestMatchAlertTapped(_ notification: Notification) {
        sendInviteViewModel.changeBestMatchAlertStatus()
    }
    
    @objc func loadMore(_ notification: Notification) {
        sendInviteViewModel.isLoadMoreTapped = true
        iboTableView.reloadData()
        sendInviteViewModel.loadMoreViewTapped(matchedUsersDataReceiver: self)
        
    }
    
    @IBAction func inviteAllTapped(_ sender: UIButton) {
        sendInviteViewModel.inviteSelelctedUsers(viewController: self)
    }
    
    @IBAction func requestSentRemoveButtonTapped(_ sender: Any) {
        self.requestSentInfoView.isHidden = true
    }
    
    @objc func clearFilters(_ notification: Notification) {
        clearAppliedFilters()
    }
    
    @objc func bestMatchAlertCreated(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        self.iboTableView.reloadData()
    }
    
    @objc func bestMatchAlertCreationFailed(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func receivedRelayRides(_ notification: Notification) {
        self.iboTableView.reloadData()
    }
    
    func goToProfile(index:Int,isFromReadyToGo: Bool){
        guard let ride = sendInviteViewModel.scheduleRide else { return }
        var matchedUsersList = [MatchedUser]()
        if !sendInviteViewModel.readyToGoMatches.isEmpty {
            matchedUsersList = sendInviteViewModel.readyToGoMatches
        }
        if !sendInviteViewModel.matchedUsers.isEmpty {
            matchedUsersList.append(contentsOf: sendInviteViewModel.matchedUsers)
        }
        if matchedUsersList.isEmpty || matchedUsersList.endIndex <= index{
            return
        }
        var row = index
        if !isFromReadyToGo{
            row = index + sendInviteViewModel.readyToGoMatches.count
        }
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride, matchedUserList: matchedUsersList, viewType: DetailViewType.RideDetailView, selectedIndex: row, startAndEndChangeRequired: false, selectedUserDelegate: nil)
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(mainContentVC, animated: false)
    }
    
    
//    private func gotoTaxiPoolRideDetailsView(index:Int) {
//        if sendInviteViewModel.matchedShareTaxi.isEmpty {
//            return
//        }
//        let taxiPoolMapDetailViewViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolMapDetailViewViewController") as! TaxiPoolMapDetailViewViewController
//               taxiPoolMapDetailViewViewController.getDataForTheSharedTaxi(selectedIndex: index, matchedShareTaxis: sendInviteViewModel.matchedShareTaxi,ride: sendInviteViewModel.scheduleRide!, analyticNotificationHandlerModel: nil, taxiInviteData: nil)
//               ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiPoolMapDetailViewViewController, animated: false)
//    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
    }
    
    private func checkNewReadyToGoMatchesAndReload(matchedRiders: [MatchedRider]) -> [MatchedRider] {
        if matchedRiders.isEmpty {
            sendInviteViewModel.readyToGoMatches.removeAll()
            return matchedRiders
        } else {
            guard let ride = sendInviteViewModel.scheduleRide else { return matchedRiders}
            let newReadyToGoMatches = RideViewUtils.getFilteredMatchedRiderBasedOnMatchPercentage(rideObj: ride, matchedRiders: matchedRiders)
            sendInviteViewModel.readyToGoMatches.removeAll()
            if !newReadyToGoMatches.isEmpty {
                sendInviteViewModel.readyToGoMatches = newReadyToGoMatches
                iboTableView.reloadData()
            } else {
                sendInviteViewModel.readyToGoMatches.removeAll()
                iboTableView.reloadData()
            }
            return newReadyToGoMatches
        }
        
    }
    
    func checkMatchedUsersAndDisplayNoRidesView(){
        if sendInviteViewModel.matchedUsers.isEmpty == true{
            iboTableView.reloadData()
            filterOptionCollectionView.isHidden = true
            filterOptionCollectionViewHeight.constant = 0
            filterAppliedCountView.isHidden = true
            filterAppliedCountViewHeightConstraint.constant = 0
            searchButton.isHidden = true
        }else{
            searchButton.isHidden = false
            if sendInviteViewModel.matchedUsers.count > 5{
                filterOptionCollectionView.isHidden = false
                filterOptionCollectionViewHeight.constant = 50
            }else{
                filterAppliedCountView.isHidden = true
                filterAppliedCountViewHeightConstraint.constant = 0
            }
            setupRoutMatchDropDown()
            let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().copy() as? SecurityPreferences
            if let shareRidesWithUnVeririfiedUsers = securityPreferences?.shareRidesWithUnVeririfiedUsers,!shareRidesWithUnVeririfiedUsers{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_USERS_VERIFIED
                DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, dynamicStatus: sendInviteViewModel.sortAndFilterStatus, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "")
            }
            sendInviteViewModel.matchedUsers = DynamicFiltersCache.getInstance().sortAndFilterMatchingListForRide(matchedUsers: sendInviteViewModel.matchedUsers, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0)
            if sendInviteViewModel.matchedUsers.isEmpty{
                iboTableView.reloadData()
                filterAppliedCountView.isHidden = true
                filterAppliedCountViewHeightConstraint.constant = 0
                sendInviteViewModel.isFilterApplied = true
            }else{
                let filterCount = DynamicFiltersCache.getInstance().getApplyedFiltersToCurrentRide(filterStatus: sendInviteViewModel.sortAndFilterStatus)
                if filterCount > 0{
                    filterAppliedCountView.isHidden = false
                    filterAppliedCountViewHeightConstraint.constant = 35
                }else{
                    filterAppliedCountView.isHidden = true
                    filterAppliedCountViewHeightConstraint.constant = 0
                }
                filterMatchesCountLabel.text = String(format: Strings.filter_match_count, arguments: [String(sendInviteViewModel.matchedUsers.count)])
                setupRoutMatchDropDown()
                iboTableView.reloadData()
                iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
            }
            validateAndDisplayJoinButton()
            if sendInviteViewModel.isFromCanceRide{
                guard let rideId = sendInviteViewModel.scheduleRide?.rideId, let rideType = sendInviteViewModel.scheduleRide?.rideType else { return }
                var status = [String : String]()
                status[DynamicFiltersCache.VEHICLE_CRITERIA] = DynamicFiltersCache.PREFERRED_VEHICLE_CAR
                DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: rideId, dynamicStatus: status, rideType: rideType)
            }
            sendInviteViewModel.matchedUsers = DynamicFiltersCache.getInstance().sortAndFilterMatchingListForRide(matchedUsers: sendInviteViewModel.matchedUsers, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0)
            getSortAndFilterStatus()
            iboTableView.reloadData()
            iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
            displayProfileVerificationViewIfRequired()
        }
    }
    
    private func displayProfileVerificationViewIfRequired(){
        if let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData,!profileVerificationData.profileVerified,let displayStatus = UserDataCache.getInstance()?.getEntityDisplayStatus(key:  UserDataCache.VERIFICATION_VIEW),!displayStatus,SharedPreferenceHelper.getCountForVerificationViewDisplay() < 3,
              (SharedPreferenceHelper.getNewCompanyAddedStatus() == nil || !SharedPreferenceHelper.getNewCompanyAddedStatus()!) {
                  verifyProfileView.isHidden = false
            populateData(profileVerificationData: profileVerificationData)
        }else {
            verifyProfileView.isHidden = true
        }
        
    }
    
    private func populateData(profileVerificationData : ProfileVerificationData){
        if !profileVerificationData.imageVerified && !profileVerificationData.emailVerified{
           verifyProfilelabel.text = Strings.profile_unverified_text
        }else if !profileVerificationData.imageVerified {
            verifyProfilelabel.text = Strings.image_unverified_text
        }else{
            verifyProfilelabel.text = Strings.org_unverified_text
        }
    }
    
    func displayAckForRideRequest(matchedUser : MatchedUser){
        if matchedUser.name == nil{
            rideRequestAckLabel.text = Strings.invite_sent_to_selected_user
        }else{
            if matchedUser.userRole == MatchedUser.RIDER{
                requestSentInfoView.isHidden = false
            }else{
                rideRequestAckLabel.text = String(format: Strings.invite_sent_to_selected_passengers, matchedUser.name ?? "")
                rideRequestAckView.isHidden = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            self.rideRequestAckView.isHidden = true
            self.requestSentInfoView.isHidden = true
        })
        iboTableView.reloadData()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPaths = iboTableView.indexPathsForVisibleRows{
            for indexPath in indexPaths{
                if let cell = iboTableView.cellForRow(at: indexPath as IndexPath) as? MatchedUserTableViewCell {
                    cell.setContactImage()
                }
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()

        return true
    }
    private func getSortAndFilterStatus(){
        if let rideId = sendInviteViewModel.scheduleRide?.rideId,let rideType = sendInviteViewModel.scheduleRide?.rideType, let statusFromCache = DynamicFiltersCache.getInstance().getDynamicFiltersStatusForRide(rideId: rideId, rideType: rideType){
            sendInviteViewModel.sortAndFilterStatus = statusFromCache
        }
        filterOptionCollectionView.reloadData()
    }
    
    private func applyFilterToMatchingList(){
        guard let rideId = sendInviteViewModel.scheduleRide?.rideId, let rideType = sendInviteViewModel.scheduleRide?.rideType else { return }
        DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: rideId,dynamicStatus : sendInviteViewModel.sortAndFilterStatus, rideType: rideType)
        sendInviteViewModel.matchedUsers = DynamicFiltersCache.getInstance().sortAndFilterMatchingListForRide(matchedUsers: sendInviteViewModel.allMatchedUsers, rideType: rideType, rideId: rideId)
        checkMatchingOptionAndReload()
    }
    
    func setupRoutMatchDropDown() {
        routeMatchDropDown.anchorView = timeRangeDropDownView
        routeMatchDropDown.dataSource = DynamicFiltersCache.timeRangeList
        routeMatchDropDown.selectionAction = { (index, item) in
            let routeMatchTime : [String] = item.components(separatedBy: " ")
            let time = routeMatchTime[0]
            self.sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.TIME_RANGE_CRITERIA] = time
            self.filterOptionCollectionView.reloadData()
            guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
            if let thresholdTime = Int(time), thresholdTime > ridePreferences.rideMatchTimeThreshold{
                ridePreferences.rideMatchTimeThreshold = thresholdTime
                SaveRidePreferencesTask(ridePreferences: ridePreferences, viewController: self, receiver: nil).saveRidePreferences()
            }
        }
    }
    
    private func checkMatchingOptionAndReload(){
        if sendInviteViewModel.matchedUsers.isEmpty {
            sendInviteViewModel.isFilterApplied = true
            filterAppliedCountView.isHidden = true
            filterAppliedCountViewHeightConstraint.constant = 0
        } else  {
            let filterCount = DynamicFiltersCache.getInstance().getApplyedFiltersToCurrentRide(filterStatus: sendInviteViewModel.sortAndFilterStatus)
            if filterCount > 0{
                filterAppliedCountView.isHidden = false
                filterAppliedCountViewHeightConstraint.constant = 35
            }else{
                filterAppliedCountView.isHidden = true
                filterAppliedCountViewHeightConstraint.constant = 0
            }
            filterMatchesCountLabel.text = String(format: Strings.filter_match_count, arguments: [String(sendInviteViewModel.matchedUsers.count)])
        }
        iboTableView.reloadData()
        iboTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func clearFilterTapped(_ sender: UIButton) {
        filterAppliedCountViewHeightConstraint.constant = 0
        filterAppliedCountView.isHidden = true
        clearAppliedFilters()
    }
    
    private func clearAppliedFilters(){
        guard let rideId = sendInviteViewModel.scheduleRide?.rideId, let rideType = sendInviteViewModel.scheduleRide?.rideType else { return }
        sendInviteViewModel.sortAndFilterStatus.removeAll()
        DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: rideId, dynamicStatus: sendInviteViewModel.sortAndFilterStatus, rideType: rideType)
        sendInviteViewModel.matchedUsers = sendInviteViewModel.allMatchedUsers
        iboTableView.reloadData()
        filterOptionCollectionView.reloadData()
    }
    
    func initialiseTaxiView(detailEstimatedFare : DetailedEstimateFare){
        let points = TaxiUtils.getTaxiPoints(detailedEstimatedFare: detailEstimatedFare,taxiType: TaxiPoolConstants.TAXI_TYPE_CAR)
        if points != 0{
            taxiStartsAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: points)])
        }
    }
    
    @objc func verifyProfile(_ gesture : UITapGestureRecognizer) {
        let verifyProfileVC = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyProfileVC.intialData(isFromSignUpFlow: false)
        self.navigationController?.pushViewController(verifyProfileVC, animated: false)
    }
    @objc func moveToTaxiBookingScreen(_ gesture : UITapGestureRecognizer) {
        naviateToTaxiBooking()
        
    }
    
    
    
}
//MARK: MatchedUserTableViewCellProfileVerificationViewDelegate
extension SendInviteBaseViewController : MatchedUserTableViewCellProfileVerificationViewDelegate{
    func hideProfileVerificationView() {
        ProfileVerificationUtils.removeView()
    }
}
//MARK: TableViewDataSource
extension SendInviteBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if !sendInviteViewModel.readyToGoMatches.isEmpty{
               return 1
            }else{
                return 0
            }
        }else if section == 1{
            if !progressSpinnerView.isHidden{
                return 10 // loading cells
            }else{
                return 0
            }
        }else if section == 2{
            if sendInviteViewModel.matchedUsers.isEmpty && sendInviteViewModel.readyToGoMatches.isEmpty && sendInviteViewModel.relayRides.isEmpty{
                return 1 // no matches for current ride
            }else{
                return 0 //new cell
            }
        }else if section == 3{
            if sendInviteViewModel.matchedUsers.isEmpty && sendInviteViewModel.isFilterApplied{
                return 1 // filter applied no match cell
            }else{
                return 0 //new cell
            }
        }else if section == 4{
            if sendInviteViewModel.matchedUsers.count > 2 &&
                !sendInviteViewModel.relayRides.isEmpty && !sendInviteViewModel.isRequiredToShowAllMatatches{
                return 2 // only two matches if relay rides available
            }else if sendInviteViewModel.matchedUsers.count > 8 &&
                !sendInviteViewModel.isRequiredToShowAllMatatches{
                return 8
            }else if !sendInviteViewModel.matchedUsers.isEmpty{
                return sendInviteViewModel.matchedUsers.count
            }else{
                return 0
            }
        }else if section == 5{
            if !sendInviteViewModel.isRequiredToShowAllMatatches && sendInviteViewModel.matchedUsers.count > 2 && !sendInviteViewModel.relayRides.isEmpty{
                return 1
            }else if !sendInviteViewModel.isRequiredToShowAllMatatches && sendInviteViewModel.matchedUsers.count > 8{
                return 1
            }else{
                return 0
            }
        }else if section == 6{
            if !sendInviteViewModel.matchedUsers.isEmpty && sendInviteViewModel.currentMatchBucket != MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH && sendInviteViewModel.isRequiredToShowAllMatatches{
                return 1
            }else{
                return 0
            }
        }else if section == 7{
            if !sendInviteViewModel.relayRides.isEmpty && !sendInviteViewModel.isRequiredToShowAllRelayRides{
                return 1
            }else{
                return sendInviteViewModel.relayRides.count
            }
        }else if section == 8{
            if sendInviteViewModel.relayRides.count > 1 && !sendInviteViewModel.isRequiredToShowAllRelayRides{
                return 1
            }else{
                return 0
            }
        }else if section == 9{// Taxi if matches availalble
            if let _ = sendInviteViewModel.matchedTaxipool{
                return 1
            }else if let detailEstimatedFare = sendInviteViewModel.detailEstimatedFare, detailEstimatedFare.serviceableArea{
                if sendInviteViewModel.isOutstationRide(){
                    return 1
                }else{
                    return 0
                }
            }else{
                return 0
            }
        }else if section == 10{ // inactive
            if !sendInviteViewModel.inActiveMatches.isEmpty{
                return 1
            }else{
                return 0
            }
        }else if section == 11{//Invite by contcact
            return 1
        }else if section == 12{// refer QR
            return 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        iboTableView.isScrollEnabled = true
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstantRideMatchedUserDetailTableViewCell", for: indexPath) as! InstantRideMatchedUserDetailTableViewCell
            cell.initialiseData(viewModel: sendInviteViewModel, viewController: self)
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "row_empty", for: indexPath) as! EmptyRowTableViewCell
            cell.setUpUI(matchedUsertype: sendInviteViewModel.scheduleRide?.rideType ?? Ride.PASSENGER_RIDE)
            cell.isUserInteractionEnabled = false
            iboTableView.isScrollEnabled = false
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoMatchesTableViewCell", for: indexPath) as! NoMatchesTableViewCell
            cell.noMatchesLabel.text = Strings.no_rides_avaialble_try_below_options
            return cell
        }else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoMatchesAfterFilteringTableViewCell", for: indexPath) as! NoMatchesAfterFilteringTableViewCell
            return cell
        }else if indexPath.section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchedUserTableViewCell", for: indexPath) as! MatchedUserTableViewCell
            if sendInviteViewModel.matchedUsers.endIndex <= indexPath.row{
                return cell
            }
            cell.initialiseUIWithData(rideId: sendInviteViewModel.scheduleRide?.rideId,rideType : sendInviteViewModel.scheduleRide?.rideType,matchUser:  sendInviteViewModel.matchedUsers[indexPath.row], isSelected : sendInviteViewModel.selectedMatches[sendInviteViewModel.matchedUsers[indexPath.row].rideid ?? 0],matchedUserSelectionDelegate: self,viewController : self, row: indexPath.row,ride : sendInviteViewModel.scheduleRide,rideInviteActionCompletionListener: self, userSelectionDelegate: self)
            cell.delegate = self
            if !sendInviteViewModel.isRequiredToShowAllMatatches && sendInviteViewModel.matchedUsers.count > 2 && !sendInviteViewModel.relayRides.isEmpty && indexPath.row == 1{
                    cell.viewAllButtonExtendedView.isHidden = false
                }else if !sendInviteViewModel.isRequiredToShowAllMatatches && sendInviteViewModel.matchedUsers.count > 8 && indexPath.row == 7{
                    cell.viewAllButtonExtendedView.isHidden = false
                }else {
                    cell.viewAllButtonExtendedView.isHidden = true
                }
            if !sendInviteViewModel.readyToGoMatches.isEmpty && !sendInviteViewModel.matchedUsers.isEmpty && indexPath.row == 0 {
                cell.sectionHeaderLabel.isHidden = false
            } else {
                cell.sectionHeaderLabel.isHidden = true
            }
            return cell
        }else if indexPath.section == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterTableViewCell",for: indexPath) as! FooterTableViewCell
            cell.footerButton.tag = indexPath.section
            cell.initailizeFooter(footerTitle: Strings.view_all_matches, delegate: self)
            return cell
        }else if indexPath.section == 6{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTableViewCell", for: indexPath) as! LoadMoreTableViewCell
            cell.inisalizeLoadMoreView(isLoadMoreTapped: sendInviteViewModel.isLoadMoreTapped)
            return cell
        }else if indexPath.section == 7{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelayRideMatchTableViewCell", for: indexPath) as! RelayRideMatchTableViewCell
            cell.initializeRelayRideMatch(relayRideMatch: sendInviteViewModel.relayRides[indexPath.row], ride: sendInviteViewModel.scheduleRide ?? Ride())
            if sendInviteViewModel.relayRides.count > 1 && !sendInviteViewModel.isRequiredToShowAllRelayRides{
                cell.viewAllButtonExtendedView.isHidden = false
            }else{
                cell.viewAllButtonExtendedView.isHidden = true
            }
            return cell
        }else if indexPath.section == 8{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterTableViewCell", for: indexPath) as! FooterTableViewCell
            cell.footerButton.tag = indexPath.section
            cell.initailizeFooter(footerTitle: Strings.view_all_relay_rides, delegate: self)
            return cell
        }else if indexPath.section == 9{
            if let matchedTaxipool = sendInviteViewModel.matchedTaxipool{
                let taxiCell = tableView.dequeueReusableCell(withIdentifier: "MatchingTaxipoolTableViewCell", for: indexPath) as! MatchingTaxipoolTableViewCell
                taxiCell.showMatchedTaxiUserInfo(taxiMatchedGroup: matchedTaxipool,ride: self.sendInviteViewModel.scheduleRide!)
                return taxiCell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingOptionOutstationTaxiTableViewCell", for: indexPath) as! MatchingOptionOutstationTaxiTableViewCell
                cell.topView.isHidden = true
                cell.initialiseOutstationCard(ride: sendInviteViewModel.scheduleRide!,detailedEstimatedFare: sendInviteViewModel.detailEstimatedFare!, isFromSendInvite: true)
                return cell
            }
        }else if indexPath.section == 10{
            let cell = tableView.dequeueReusableCell(withIdentifier: "InActiveMatchesTableViewCell", for: indexPath) as! InActiveMatchesTableViewCell
            cell.initialiseUIWithData(rideId: sendInviteViewModel.scheduleRide?.rideId,rideType : sendInviteViewModel.scheduleRide?.rideType,inactiveMatchUser: sendInviteViewModel.inActiveMatches, isSelected: false,matchedUserSelectionDelegate: self,row: indexPath.row,ride: sendInviteViewModel.scheduleRide,rideInviteActionCompletionListener: self, userSelectionDelegate: self)
            cell.delegate = self
            return cell
        }else if indexPath.section == 11{
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteByContactTableViewCell", for: indexPath) as! InviteByContactTableViewCell
            cell.initializeInviteByContactView(ride: sendInviteViewModel.scheduleRide ?? Ride(),isFromLiveride: false, viewContoller: self,taxiRide: nil)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReferQuickRideTableViewCell", for: indexPath) as! ReferQuickRideTableViewCell
            cell.initialiseView(ride: sendInviteViewModel.scheduleRide)
            return cell
        }
    }
    
    private func presentTaxiPoolIntroductionScreen(taxiSharedRide: TaxiShareRide?) {
        let taxiPoolIntroduction = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiPoolIntroductionViewController") as! TaxiPoolIntroductionViewController
        taxiPoolIntroduction.initialisationBeforeShowing(ride: sendInviteViewModel.scheduleRide, taxiSharedRide: taxiSharedRide)
        self.navigationController?.pushViewController(taxiPoolIntroduction, animated: false)
    }
    
    private func validateAndDisplayJoinButton(){
        AppDelegate.getAppDelegate().log.debug("validateAndDisplayJoinButton()")
        if sendInviteViewModel.selectedMatches.values.contains(true){
            inviteAll.isHidden = false
            inviteAll.setTitle(sendInviteViewModel.getInviteButtonTitle(), for: .normal)
        }else{
            inviteAll.isHidden = true
        }
    }
}
extension SendInviteBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 7 && !sendInviteViewModel.relayRides.isEmpty{
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        if section == 7{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
            headerView.backgroundColor = UIColor(netHex: 0xF6F6F6)
            let titleLabel = UILabel(frame: CGRect(x: 15, y: 10, width: tableView.frame.size.width - 10, height: 35))
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            titleLabel.text = Strings.relay_rides.uppercased()
            let subTitleLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.frame.size.width - 10, height: 35))
            subTitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            subTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
            subTitleLabel.text = Strings.relay_info
            headerView.addSubview(titleLabel)
            headerView.addSubview(subTitleLabel)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 && !sendInviteViewModel.matchedUsers.isEmpty && indexPath.row < sendInviteViewModel.matchedUsers.endIndex{
            goToProfile(index: indexPath.row, isFromReadyToGo: false)
        }else if indexPath.section == 7 && indexPath.row < sendInviteViewModel.relayRides.endIndex{
            
            let relayRideDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RelayRideDetailViewController") as! RelayRideDetailViewController
            relayRideDetailViewController.initailiseRelayRideDetailView(ride: sendInviteViewModel.scheduleRide ?? Ride(), relayRideMatchs: sendInviteViewModel.relayRides, selectedIndex: indexPath.row)
            self.navigationController?.pushViewController(relayRideDetailViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    private func naviateToTaxiBooking(){
        if let passengerRide = sendInviteViewModel.scheduleRide as? PassengerRide {
            let taxiPoolVC = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiRideCreationMapViewController") as! TaxiRideCreationMapViewController
            taxiPoolVC.initialiseData(passengerRide: passengerRide)
            self.navigationController?.pushViewController(taxiPoolVC, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 4{
            return .delete
        }else{
            return .none
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("()")
        if editingStyle == UITableViewCell.EditingStyle.delete{
            if sendInviteViewModel.scheduleRide == nil || sendInviteViewModel.matchedUsers.isEmpty || sendInviteViewModel.matchedUsers.endIndex <= indexPath.row{
                return
            }
            MatchedUsersCache.getInstance().addUsersToDeletedMatchedUsersList(ignoredRideId: sendInviteViewModel.matchedUsers[indexPath.row].rideid ?? 0, rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0)
            sendInviteViewModel.matchedUsers.remove(at: indexPath.row)
            iboTableView.reloadData()
            iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
        }
    }
}
//MARK: MatchedUserTableViewCellUserSelectionDelegate
extension SendInviteBaseViewController: MatchedUserTableViewCellUserSelectionDelegate{
    func userUnSelectedAtIndex(row: Int, matchedUser: MatchedUser) {
        sendInviteViewModel.selectedMatches[matchedUser.rideid ?? 0] = false
        validateAndDisplayJoinButton()
    }
    func userSelectedAtIndex(row: Int, matchedUser: MatchedUser) {
        sendInviteViewModel.selectedMatches[matchedUser.rideid!] = true
        validateAndDisplayJoinButton()
    }
    func cancelSelectedUserPressed(invitation: RideInvitation, status: Int) {
        if status == 0 {
            QuickRideProgressSpinner.startSpinner()
            sendInviteViewModel.cancelSelectedUser(invitation: invitation, viewController: self)
        }
    }
    
    @objc func cancelRideInvitationSuccess(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        iboTableView.reloadData()
    }
    
    @objc func cancelRideInvitationFailed(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
}
//MARK: UpdateRide Status
extension SendInviteBaseViewController {
    @objc func rideInvitationStatusUpdated(_ notification: Notification) {
        iboTableView.reloadData()
    }
}

//MRAK:  MatchingListOptimizationReceive
extension SendInviteBaseViewController: MatchingListOptimizationReceiver {
    func receivedMatchingList(matchedUsers: [MatchedUser],status: [String : String]) {
        sendInviteViewModel.matchedUsers = matchedUsers
        sendInviteViewModel.sortAndFilterStatus = status
        checkMatchingOptionAndReload()
        filterOptionCollectionView.reloadData()
    }
    func clearSortAndFilters(){
        sendInviteViewModel.sortAndFilterStatus.removeAll()
        sendInviteViewModel.matchedUsers = sendInviteViewModel.allMatchedUsers
        checkMatchingOptionAndReload()
        filterOptionCollectionView.reloadData()
    }
}

//MARK: UICollectionViewDataSource
extension SendInviteBaseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sendInviteViewModel.scheduleRide?.rideType == Ride.RIDER_RIDE{
            return 6
        }else{
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchedUserCollectionViewCell", for: indexPath) as! MatchedUserCollectionViewCell
        cell.initializeFilterOptionsCell(index: indexPath.row, status: sendInviteViewModel.sortAndFilterStatus, rideType: sendInviteViewModel.scheduleRide?.rideType)
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension SendInviteBaseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().copy() as? SecurityPreferences
        switch indexPath.row {
        case 0:
            guard let rideId = sendInviteViewModel.scheduleRide?.rideId, let rideType = sendInviteViewModel.scheduleRide?.rideType else { return }
            let filterBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideFilterBaseViewController") as! RideFilterBaseViewController
            filterBaseViewController.initializeRideFilterBaseViewController(matchedUsers: sendInviteViewModel.allMatchedUsers, rideId: rideId, rideType: rideType, delegate: self)
            self.navigationController?.pushViewController(filterBaseViewController, animated: false)
        case 1:
            showRouteMatchWindow()
        case 2:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA], value == DynamicFiltersCache.PREFERRED_USERS_VERIFIED{
                if let shareRidesWithUnVeririfiedUsers = securityPreferences?.shareRidesWithUnVeririfiedUsers,!shareRidesWithUnVeririfiedUsers{
                    MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.change_settings, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                        if Strings.yes_caps == result,let scuritySettings = securityPreferences{
                            self.sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
                            securityPreferences?.shareRidesWithUnVeririfiedUsers = true
                            SecurityPreferencesUpdateTask(viewController: self, securityPreferences: scuritySettings, securityPreferencesUpdateReceiver: self).updateSecurityPreferences()
                            self.applyFilterToMatchingList()
                        }
                    })
                }else{
                    sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
                }
            }else{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA] = DynamicFiltersCache.PREFERRED_USERS_VERIFIED
            }
            applyFilterToMatchingList()
        case 3:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.EXISTANCE_CRITERIA], value == DynamicFiltersCache.ACTIVE_USERS{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.EXISTANCE_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }else{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.EXISTANCE_CRITERIA] = DynamicFiltersCache.ACTIVE_USERS
            }
            applyFilterToMatchingList()
        case 4:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.PARTNERS_CRITERIA], value == DynamicFiltersCache.FAVOURITE_PARTNERS{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.PARTNERS_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }else{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.PARTNERS_CRITERIA] = DynamicFiltersCache.FAVOURITE_PARTNERS
            }
            applyFilterToMatchingList()
        case 5:
            if sendInviteViewModel.scheduleRide?.rideType == Ride.RIDER_RIDE{
                routeMatchDropDown.show()
            }else{
                if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_POINT_CRITERIA], value == DynamicFiltersCache.VIA_START_POINT{
                    sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_POINT_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
                }else{
                    sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_POINT_CRITERIA] = DynamicFiltersCache.VIA_START_POINT
                }
            }
            applyFilterToMatchingList()
        case 6:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.VEHICLE_CRITERIA], value == DynamicFiltersCache.PREFERRED_VEHICLE_CAR{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.VEHICLE_CRITERIA] = DynamicFiltersCache.PREFERRED_ALL
            }else{
                sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.VEHICLE_CRITERIA] = DynamicFiltersCache.PREFERRED_VEHICLE_CAR
            }
            applyFilterToMatchingList()
        case 7:
            routeMatchDropDown.show()
        default:
            break
        }
        if indexPath.row != 0 || indexPath.row != 7{
            filterOptionCollectionView.reloadData()
        }
    }
    
    private func showRouteMatchWindow(){
        var currentRouteMatch = 0
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
        if let routeMatchStr = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_MATCH_CRITERIA], let routeMatch = Int(routeMatchStr){
            currentRouteMatch = routeMatch
        }else{
            if sendInviteViewModel.scheduleRide?.rideType == Ride.RIDER_RIDE{
                currentRouteMatch = ridePreferences.rideMatchPercentageAsRider
            }else{
                currentRouteMatch = ridePreferences.rideMatchPercentageAsPassenger
            }
        }
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: Strings.route_match, firstValue: 0,lastValue: 100, minValue: 5, currentValue: currentRouteMatch){ (value) in
            if value < 5{
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: ["5"]),duration: 2.0, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
            }else{
                self.sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_MATCH_CRITERIA] = String(value)
                self.applyFilterToMatchingList()
                self.filterOptionCollectionView.reloadData()
                self.sendInviteViewModel.upadteRouteMatchPercentage(value: value, viewController: self)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
}
//MARK: UICollectionViewDelegateFlowLayout
extension SendInviteBaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = Strings.sortAndFilterList[indexPath.item]
        label.sizeToFit()
        switch indexPath.row {
        case 0:
            return CGSize(width: label.frame.size.width + 10, height: 30)
        case 1:
            return CGSize(width: label.frame.size.width + 10, height: 30)
        case 2:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.USERS_CRITERIA], value == DynamicFiltersCache.PREFERRED_USERS_VERIFIED{
                return CGSize(width: label.frame.size.width + 10, height: 30)
            }else{
                return CGSize(width: label.frame.size.width + 5, height: 30)
            }
        case 3:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.EXISTANCE_CRITERIA], value == DynamicFiltersCache.ACTIVE_USERS{
                return CGSize(width: label.frame.size.width + 14, height: 30)
            }else{
                return CGSize(width: label.frame.size.width + 6, height: 30)
            }
        case 4:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.PARTNERS_CRITERIA], value == DynamicFiltersCache.FAVOURITE_PARTNERS{
                return CGSize(width: label.frame.size.width + 10, height: 30)
            }else{
                return CGSize(width: label.frame.size.width + 4, height: 30)
            }
        case 5:
            if sendInviteViewModel.scheduleRide?.rideType == Ride.RIDER_RIDE{
                return CGSize(width: label.frame.size.width - 10, height: 30)
            }else{
                if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.ROUTE_POINT_CRITERIA], value == DynamicFiltersCache.VIA_START_POINT{
                    return CGSize(width: label.frame.size.width, height: 30)
                }else{
                    return CGSize(width: label.frame.size.width - 5, height: 30)
                }
            }
        case 6:
            if let value = sendInviteViewModel.sortAndFilterStatus[DynamicFiltersCache.VEHICLE_CRITERIA], value == DynamicFiltersCache.PREFERRED_VEHICLE_CAR{
                return CGSize(width: label.frame.size.width + 18, height: 30)
            }else{
                return CGSize(width: label.frame.size.width + 10, height: 30)
            }
        case 7:
            return CGSize(width: label.frame.size.width - 20, height: 30)
        default:
            return CGSize(width: label.frame.size.width + 10, height: 30)
        }
    }
}

//MARK: ReadyToGo match table view cell action delegate
extension SendInviteBaseViewController: RideDetailTableViewCellUserSelectionDelegate {
    func updateRideStatusView() {
        iboTableView.reloadData()
    }
    func gotItAction() { }
    func changePlanAction() { }
    func selectedUserDelegate() { }
    
    func declineInviteAction(rideInvitation: RideInvitation?) {
        if let rideInvitation = rideInvitation {
            var rideType :  String?
            if rideInvitation.rideType == Ride.RIDER_RIDE{
                rideType = Ride.PASSENGER_RIDE
            }else{
                rideType = Ride.RIDER_RIDE
            }
            let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
            rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: rideType) { (text, result) in
                if result == Strings.confirm_caps{
                    self.sendInviteViewModel.completeRejectAction(rejectReason: text, rideInvitation: rideInvitation, rideType: rideType ?? "", viewController: self, rideInvitationActionCompletionListener: self)
                }
            }
        }
    }
}

//MARK: UserSelection delegate from profile
extension SendInviteBaseViewController: UserSelectedDelegate {
    func userSelected() {
        if sendInviteViewModel.selectedUserIndex < 0 || sendInviteViewModel.selectedUserIndex >= sendInviteViewModel.matchedUsers.count {
            return
        }
        selectedUser(selectedUser: sendInviteViewModel.matchedUsers[sendInviteViewModel.selectedUserIndex])
    }
    func userNotSelected() { }
}

//MARK: SecurityPreferencesUpdateReceiver
extension SendInviteBaseViewController: SecurityPreferencesUpdateReceiver{
    func securityPreferenceUpdated() {
        filterOptionCollectionView.reloadData()
    }
}


//MARK: UISearchBarDelegate
extension SendInviteBaseViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        AppDelegate.getAppDelegate().log.debug("searchBar() textDidChange() \(searchText)")
        let filteredmatches = DynamicFiltersCache.getInstance().sortAndFilterMatchingListForRide(matchedUsers: sendInviteViewModel.allMatchedUsers, rideType: sendInviteViewModel.scheduleRide!.rideType!, rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0)
        if searchText.isEmpty{
            sendInviteViewModel.matchedUsers = filteredmatches
            iboTableView.reloadData()
            iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
        }else{
            sendInviteViewModel.matchedUsers.removeAll()
            for matchedUser in filteredmatches{
                if matchedUser.name!.localizedCaseInsensitiveContains(searchText){
                    sendInviteViewModel.matchedUsers.append(matchedUser)
                }
            }
            iboTableView.reloadData()
            iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        dismissSearchbar()
    }
    
    func dismissSearchbar(){
        searchBar.isHidden = true
        navigationView.isHidden = false
        sendInviteViewModel.matchedUsers = sendInviteViewModel.allMatchedUsers
        iboTableView.reloadData()
    }
}
//MARK: MatchedUsersDataReceiver
extension SendInviteBaseViewController: MatchedUsersDataReceiver{
    func receiveMatchedRidersList(requestSeqId : Int, matchedRiders : [MatchedRider],currentMatchBucket : Int){
        quickRideProgressBar?.stopProgressBar()
        sendInviteViewModel.currentMatchBucket = currentMatchBucket
        sendInviteViewModel.isLoadMoreTapped = false
        sendInviteViewModel.matchedUsers.removeAll()
        sendInviteViewModel.selectedMatches.removeAll()
        sendInviteViewModel.relayRides.removeAll()
        sendInviteViewModel.checkRideIsEligiableToGetRelayRides(matchedUsersList: matchedRiders)
        getTaxiOptions()
        var updatedMatchedRiders = [MatchedRider]()
        for rider in matchedRiders {
            var rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", matchedUserRideId: rider.rideid ?? 0, matchedUserTaxiRideId: nil)
            
            if rideInvite == nil{
                rideInvite = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: rider.rideid!, passengerRideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", userId: rider.userid ?? 0)
            }
            if rideInvite != nil{
                rider.newFare = rideInvite!.newFare
            }else{
                rider.newFare = -1
            }
            updatedMatchedRiders.append(rider)
        }
        sendInviteViewModel.matchedUsers = sendInviteViewModel.putFavouritePartnersOnTop(actualMatchedUsers: updatedMatchedRiders)
        let readyToGoMatches = checkNewReadyToGoMatchesAndReload(matchedRiders: updatedMatchedRiders)
        if !readyToGoMatches.isEmpty {
            for readyToGoMatch in readyToGoMatches {
                sendInviteViewModel.matchedUsers = sendInviteViewModel.matchedUsers.filter() { $0.userid != readyToGoMatch.userid }
            }
            sendInviteViewModel.allMatchedUsers = sendInviteViewModel.matchedUsers
            if sendInviteViewModel.isFromRideCreation {
                goToProfile(index: sendInviteViewModel.readyToGoMatchIndex, isFromReadyToGo: true)
            }
        }
        sendInviteViewModel.allMatchedUsers = sendInviteViewModel.matchedUsers
        iboTableView.reloadData()
        iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewModel.contentOffset), animated: true)
        checkMatchedUsersAndDisplayNoRidesView()
        iboTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func receiveMatchedPassengersList( requestSeqId: Int, matchedPassengers : [MatchedPassenger],currentMatchBucket : Int){
        quickRideProgressBar?.stopProgressBar()
        sendInviteViewModel.currentMatchBucket = currentMatchBucket
        sendInviteViewModel.isLoadMoreTapped = false
        sendInviteViewModel.matchedUsers.removeAll()
        sendInviteViewModel.selectedMatches.removeAll()
        getTaxiOptions()
        for passenger in matchedPassengers{
            var rideInvite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", matchedUserRideId: passenger.rideid ?? 0, matchedUserTaxiRideId: nil)
            
            if rideInvite == nil{
                rideInvite = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, passengerRideId: passenger.rideid!, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", userId: passenger.userid ?? 0)
            }
            if rideInvite != nil{
                passenger.newFare = rideInvite!.newRiderFare
            }
        }
        
        sendInviteViewModel.matchedUsers = sendInviteViewModel.putFavouritePartnersOnTop(actualMatchedUsers: matchedPassengers)
        sendInviteViewModel.allMatchedUsers = sendInviteViewModel.matchedUsers
        checkMatchedUsersAndDisplayNoRidesView()
        iboTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func matchingRidersRetrievalFailed( requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        quickRideProgressBar?.stopProgressBar()
        sendInviteViewModel.isLoadMoreTapped = false
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        sendInviteViewModel.matchedUsers.removeAll()
        sendInviteViewModel.selectedMatches.removeAll()
        iboTableView.reloadData()
        checkMatchedUsersAndDisplayNoRidesView()
    }
    
    func matchingPassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        quickRideProgressBar?.stopProgressBar()
        sendInviteViewModel.isLoadMoreTapped = false
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        sendInviteViewModel.matchedUsers.removeAll()
        sendInviteViewModel.selectedMatches.removeAll()
        checkMatchedUsersAndDisplayNoRidesView()
    }
    func receiveInactiveMatchedPassengers(requestSeqId: Int, matchedPassengers: [MatchedPassenger], currentMatchBucket: Int) {
        sendInviteViewModel.inActiveMatches = matchedPassengers
        iboTableView.reloadData()
    }
    func receiveInactiveMatchedRidersList(requestSeqId: Int, matchedRiders: [MatchedRider], currentMatchBucket: Int) {
        sendInviteViewModel.inActiveMatches = matchedRiders
        iboTableView.reloadData()
    }
}
//MARK: SelectedUserDelegate
extension SendInviteBaseViewController: SelectedUserDelegate{
    func selectedUser(selectedUser: MatchedUser) {
        DispatchQueue.main.async(execute: { () -> Void in
            if self.sendInviteViewModel.selectedUserIndex == -1{
                return
            }
            let invitation = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: self.sendInviteViewModel.scheduleRide?.rideId ?? 0, rideType: self.sendInviteViewModel.scheduleRide?.rideType ?? "", matchedUserRideId: selectedUser.rideid ?? 0,matchedUserTaxiRideId: nil)
            if let cell = self.iboTableView.cellForRow(at: IndexPath(row: self.sendInviteViewModel.selectedUserIndex, section: 1)) as? MatchedUserTableViewCell{
                var newFare: Double = 0
                if invitation?.rideType == Ride.PASSENGER_RIDE || invitation?.rideType == Ride.REGULAR_PASSENGER_RIDE {
                    newFare = invitation?.newRiderFare ?? 0
                }else{
                    newFare = invitation?.newFare ?? 0
                }
                if invitation != nil && newFare == selectedUser.newFare {
                    cell.multiInvitePressed(matchedUser: selectedUser, invitation: invitation!, status: 1)
                }else{
                    cell.multiInvitePressed(matchedUser: selectedUser, invitation: invitation, status: 2)
                }
            }
        })
    }
    
    func rejectUser(selectedUser: MatchedUser) {
        var rideType :  String?
        var incomingInvitation = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: sendInviteViewModel.scheduleRide?.rideId ?? 0, rideType: sendInviteViewModel.scheduleRide?.rideType ?? "", matchedUserRideId: selectedUser.rideid ?? 0,matchedUserTaxiRideId: nil)
        guard let invitation = incomingInvitation else { return }
        if invitation.rideType == Ride.RIDER_RIDE{
            rideType = Ride.PASSENGER_RIDE
        }else{
            rideType = Ride.RIDER_RIDE
        }
        let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
        rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: rideType) { (text, result) in
            if result == Strings.confirm_caps{
                self.sendInviteViewModel.completeRejectAction(rejectReason: text, rideInvitation: invitation, rideType: rideType ?? "", viewController: self, rideInvitationActionCompletionListener: self)
            }
        }
    }
}

extension SendInviteBaseViewController: RideInvitationActionCompletionListener{
    func rideInviteAcceptCompleted(rideInvitationId : Double){
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationId)
    }
    func rideInviteRejectCompleted(rideInvitation : RideInvitation){
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED, rideInvitation: rideInvitation)
        UIApplication.shared.keyWindow?.makeToast( Strings.ride_invite_rejected)
        sendInviteViewModel.getMatchingOptions(matchedUsersDataReceiver: self)
    }
    func removeInvitationAndRefreshData(status : String, rideInvitation : RideInvitation){
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
        rideInvitation.invitationStatus = status
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
    }
    func rideInviteActionFailed(rideInvitationId: Double,responseError: ResponseError?,error:NSError?, isNotificationRemovable : Bool){
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationId)
    }
    
    func rideInviteActionCancelled() {}
}
//MARK:FooterTableViewCellDelegate
extension SendInviteBaseViewController: FooterTableViewCellDelegate{
    func userTappedOnFooter(section: Int){
        if section == 5{
            sendInviteViewModel.isRequiredToShowAllMatatches = true
        }else if section == 8{
            sendInviteViewModel.isRequiredToShowAllRelayRides = true
        }
        iboTableView.reloadData()
    }
}
