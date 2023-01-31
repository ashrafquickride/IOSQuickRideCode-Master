//
//  OutStationReviewViewController.swift
//  Quickride
//
//  Created by Ashutos on 9/24/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import ObjectMapper

public typealias ComplitionHandler = (_ bookBtnTapped: Bool,_ selectedPaymentType: Int) -> Void

class OutStationReviewViewController: UIViewController {

    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var createExClusiveTaxiView: QuickRideCardView!
    @IBOutlet weak var bookNowbutton: QRCustomButton!
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var loaderView: AnimatedControl!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var applyCouponView: UIView!
    @IBOutlet weak var appliedCouponView: UIView!
    @IBOutlet weak var couponCodeLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var extraPickupView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var expiredTag: UIButton!
    @IBOutlet weak var tollIncludedView: UIView!
    @IBOutlet weak var minAmountLabel: UILabel!

    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    private var reviewScreenViewModel: ReviewScreenViewModel?
    private var handler: ComplitionHandler?

    private var joinFlowUI: NewJoinShimmerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        registerCell()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func prepareDataForView(fareForVehicleClass: FareForVehicleClass,startLocation: Location?,endLocation: Location?, startTime: Double,selectedTaxiIndex: Int,journeyType: String,endTime: Double?,isFromLiveRide: Bool, selectedRouteId: Double?, refRequestId : Double?, commuteContactNo: String?, commutePassengerName: String?) {
        reviewScreenViewModel = ReviewScreenViewModel(fareForVehiceClass: fareForVehicleClass, selectedTaxiIndex: selectedTaxiIndex, journeytype: journeyType, endTime: endTime, isFromLiveRide: isFromLiveRide, startLocation: startLocation, endLocation: endLocation, startTime: startTime, selectedRouteId: selectedRouteId, refRequestId : refRequestId, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName)
    }

    private func registerCell() {
        reviewTableView.register(UINib(nibName: "OutstationTaxiTripDataTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationTaxiTripDataTableViewCell")
        reviewTableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderTableViewCell")
        reviewTableView.register(UINib(nibName: "TaxiDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiDetailsTableViewCell")
        reviewTableView.register(UINib(nibName: "OptionHeadersTableViewCell", bundle: nil), forCellReuseIdentifier: "OptionHeadersTableViewCell")
        reviewTableView.register(UINib(nibName: "OutstationTaxiDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationTaxiDetailsTableViewCell")
        reviewTableView.register(UINib(nibName: "OutstationTaxiInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationTaxiInfoTableViewCell")
        reviewTableView.register(UINib(nibName: "OutstationCustomerCareTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationCustomerCareTableViewCell")
        reviewTableView.estimatedRowHeight  = 200
        reviewTableView.rowHeight = UITableView.automaticDimension
        self.reviewTableView.reloadData()
    }

    private func setUpUI() {
        if reviewScreenViewModel?.isFromLiveRide ?? false {
            createExClusiveTaxiView.isHidden = true
        }else{
            createExClusiveTaxiView.isHidden = false
            createExClusiveTaxiView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        }
        setUpPaymentAndBookingUI()
        contentView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        guard let estimateFare = self.reviewScreenViewModel?.fareForVehicleClass?.minTotalFare else{ return }
        let minAmount = (Double(reviewScreenViewModel?.advaceAmountPercentageForOutstation ?? 0)/100) * estimateFare
        if minAmount > 0{
            minAmountLabel.text = "₹\(Int(minAmount.rounded()))"
            let buttonTitle = String(format: Strings.pay_amount, arguments: [String(Int(minAmount.rounded()))]) + " & " + Strings.book_taxi
            bookNowbutton.setTitle(buttonTitle, for: .normal)
        }else {
            bookNowbutton.setTitle(Strings.book_taxi, for: .normal)
            minAmountLabel.text = ""
        }

    }

    func setUpPaymentAndBookingUI() {
        walletView.isHidden = false
        if let paymentMode = self.reviewScreenViewModel?.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            walletNameLabel.text = Strings.payment_type_cash
            walletTypeImageView.image = UIImage(named: "payment_type_cash")
            loaderView.isHidden = true
            availableBalanceLabel.isHidden = true
            expiredTag.isHidden = true
            return
        }
        if  let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() {
            setTitleAndImage(type: linkedWallet.type!)
            if linkedWallet.status == LinkedWallet.EXPIRED{
                expiredTag.isHidden = false
                availableBalanceLabel.isHidden = true
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
                expiredTag.isHidden = true
                availableBalanceLabel.isHidden = true
            }else{
                expiredTag.isHidden = true
                getDefaultLinkedWalletBalance()
            }
        }else{
            walletNameLabel.text = Strings.add_wallet
            walletTypeImageView.image = UIImage(named: "qr_wallet")
            availableBalanceLabel.isHidden = true
            loaderView.isHidden = true
        }
    }

    private func getDefaultLinkedWalletBalance() {
        showLOTAnimation(isShow: true)
        guard let defaultLinkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {return}
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), types: defaultLinkedWallet.type!,viewController: self, handler: { [weak self] (responseObject, error) in
            self?.showLOTAnimation(isShow: false)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
                if let wallet = linkedWalletBalances.first(where: {$0.type == defaultLinkedWallet.type}){
                    UserDataCache.getInstance()?.getDefaultLinkedWallet()?.balance = wallet.balance
                    self?.availableBalanceLabel.isHidden = false
                    self?.availableBalanceLabel.text = StringUtils.getPointsInDecimal(points: wallet.balance)
                }
            }else{
                self?.availableBalanceLabel.isHidden = false
                self?.availableBalanceLabel.text = StringUtils.getPointsInDecimal(points: defaultLinkedWallet.balance ?? 0)
            }
        })
    }


    func validateAndGetAvailableTaxiDetails() {
        if let fareForVehicls = self.reviewScreenViewModel?.fareForVehicleClass {
            self.bottomView.isHidden = false
            self.bookNowbutton.setTitle(String(format: Strings.book_taxi_name, arguments: [(fareForVehicls.vehicleClass ?? "")]).uppercased(), for: .normal)
            if ((self.reviewScreenViewModel?.fareForVehicleClass?.extraPickUpChargesCanBeApplied) != nil){
                self.extraPickupView.isHidden = false
            }else{
                self.extraPickupView.isHidden = true
            }
            if let includedTollCharges = fareForVehicls.tollChargesForTaxi,includedTollCharges != 0{
                self.tollIncludedView.isHidden = false
            }else{
                self.tollIncludedView.isHidden = true
            }
        }else{
            self.bottomView.isHidden = true
            self.extraPickupView.isHidden = true
            self.tollIncludedView.isHidden = true
        }
    }

    private func showLOTAnimation(isShow: Bool) {
        if isShow {
            loaderView.isHidden = false
            loaderView.animationView.animation = Animation.named("simple-dot-loader")
            loaderView.animationView.play()
            loaderView.animationView.loopMode = .loop
        } else {
            loaderView.isHidden = true
            loaderView.animationView.stop()
        }
    }

    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletTypeImageView.image = UIImage(named: "paytm_new")
            walletNameLabel.text = Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletTypeImageView.image = UIImage(named: "lazypay_logo")
            walletNameLabel.text = Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletTypeImageView.image = UIImage(named: "simpl_new")
            walletNameLabel.text = Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletTypeImageView.image = UIImage(named: "tmw_new")
            walletNameLabel.text = Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletTypeImageView.image = UIImage(named: "mobikwik_logo")
            walletNameLabel.text = Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletTypeImageView.image = UIImage(named: "frecharge_logo")
            walletNameLabel.text = Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletTypeImageView.image = UIImage(named : "apay_linked_wallet")
            walletNameLabel.text = Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletTypeImageView.image = UIImage(named : "upi")
            walletNameLabel.text = Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletTypeImageView.image = UIImage(named : "gpay_icon_with_border")
            walletNameLabel.text = Strings.gpay
        default:
            walletTypeImageView.isHidden = true
            walletNameLabel.text = ""
        }
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func bookBtnPressed(_ sender: UIButton) {
        self.checkLinkedWalletBalanceAndBookTaxi()
    }
    private func checkLinkedWalletBalanceAndBookTaxi(){
        if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(),linkedWallet.status == LinkedWallet.EXPIRED{
            relinkWallet()
        }else if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(), linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            if let isUserHasInSufficieantAmountToBook = reviewScreenViewModel?.checkUserHasInSufficieantAmountToBook(), isUserHasInSufficieantAmountToBook {
                let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
                addMoneyViewController.initializeView(errorMsg: Strings.add_money_for_product){ (result) in
                    if result == .addMoney {
                        self.setUpPaymentAndBookingUI()
                        self.bookTaxi()
                    }else if result == .changePayment {
                        self.showPaymentDrawer()
                    }
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: addMoneyViewController)
            }else{
                bookTaxi()
            }
        }else{
            bookTaxi()
        }
    }
    private func bookTaxi() {
        var routeId: Double?
        if reviewScreenViewModel?.selectedRouteId != -1 {
            routeId = reviewScreenViewModel?.selectedRouteId
        }
        addJoinViewAsSubView()
        let createTaxiDetails = CreateTaxiPoolHandler(startLocation: reviewScreenViewModel?.startlocation, endLocation: reviewScreenViewModel?.endlocation, tripType: reviewScreenViewModel?.rideType, routeId: routeId, startTime: reviewScreenViewModel?.startTime, selectedVehicleDetails: reviewScreenViewModel?.fareForVehicleClass, endTime: reviewScreenViewModel?.endTime, journeyType: reviewScreenViewModel?.journeytype , advancePercentageForOutstation: reviewScreenViewModel?.advaceAmountPercentageForOutstation, refRequestId: reviewScreenViewModel?.refRequestId, viewController: self, couponCode: reviewScreenViewModel?.userCouponCode?.couponCode, paymentMode: reviewScreenViewModel?.paymentMode, taxiGroupId: nil, refInviteId: nil,commuteContactNo: reviewScreenViewModel?.commuteContactNo, commutePassengerName: reviewScreenViewModel?.commutePassengerName)
        createTaxiDetails.createTaxiPool  { [weak self](data, error) in
            self?.removeJoinViewFromSuperView()
            if let data = data,let taxiRidePassenger = data.taxiRidePassenger {
                TaxiRideDetailsCache.getInstance().setTaxiRideDetailsToCache(rideId: taxiRidePassenger.id ?? 0, taxiRidePassengerDetails: data)
                MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)
                self?.moveToLiveRideTaxiPool(rideId: taxiRidePassenger.id ?? 0.0)
            }
        }
    }

    private func moveToLiveRideTaxiPool(rideId: Double) {
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: rideId)
        self.navigationController?.popToRootViewController(animated: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: taxiLiveRide, animated: true)
    }

    private func removeJoinViewFromSuperView() {
        if  joinFlowUI == nil {return}
        self.navigationController?.popViewController(animated: false)
        joinFlowUI = nil
    }

    private func addJoinViewAsSubView() {
        joinFlowUI = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewJoinShimmerViewController") as? NewJoinShimmerViewController
        var isOldTaxiRide = false
        if reviewScreenViewModel?.rideType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION {
            isOldTaxiRide = true
        }
        if let taxiType = reviewScreenViewModel?.fareForVehicleClass?.taxiType {
        joinFlowUI!.initLiseData(shareType: reviewScreenViewModel?.fareForVehicleClass?.shareType, startTime: reviewScreenViewModel?.startTime, isOldTaxiRide: isOldTaxiRide,taxiType: taxiType)
        self.navigationController?.pushViewController(joinFlowUI!, animated: false)
        }
    }

    @IBAction func extraPickupFeeInfoTapped(_ sender: UIButton) {
        MessageDisplay.displayInfoViewAlert(title: Strings.extra_pickup_fare, titleColor: nil, message: Strings.extra_pickup_fare_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {}
    }

    @IBAction func relinkTapped(_ sender: Any) {
        relinkWallet()
    }

    private func relinkWallet(){
        guard let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {return}
        AccountUtils().linkRequestedWallet(walletType: linkedWallet.type ?? "") { [weak self] (walletAdded, walletType) in
            if walletAdded{
                self?.setUpPaymentAndBookingUI()
            }
        }
    }

    @IBAction func changeWalletOptionPressed(_ sender: UIButton) {
        showPaymentDrawer()
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        var isDefaultPaymentModeCash = false
        if let paymentMode = self.reviewScreenViewModel?.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            isDefaultPaymentModeCash = true
        }
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: isDefaultPaymentModeCash, isRequiredToShowCash: true, isRequiredToShowCCDC: nil) {(data) in
            if data == .cashSelected {
                self.reviewScreenViewModel?.paymentMode = TaxiRidePassenger.PAYMENT_MODE_CASH
            }else {
                self.reviewScreenViewModel?.paymentMode = nil
            }
            self.setUpPaymentAndBookingUI()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }

    @IBAction func applyPromoCodeClicked(_ sender: UIButton) {
        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
        applyPromoCodeView?.initializeDataBeforePresentingView(title: Strings.apply_coupon, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: nil, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.coupon, promoCodeAppliedMsg: nil, handler: { (text, result) in
            if let code = text,Strings.apply_caps == result{
                self.verifyPromoCode(promoCode: code)
            }else{
                self.applyPromoCodeView = nil
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
    }
    private func verifyPromoCode(promoCode : String){
        QuickRideProgressSpinner.startSpinner()
        reviewScreenViewModel?.verifyAppliedPromoCode(promoCode: promoCode, handler: { [weak self] responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self?.reviewScreenViewModel?.userCouponCode = Mapper<UserCouponCode>().map(JSONObject: responseObject?["resultData"])
                self?.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.promo_code_applied, arguments: [promoCode]))
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                self?.reviewScreenViewModel?.userCouponCode = nil
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]) {
                    self?.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
                } else {
                    self?.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
                }
            } else{
                self?.reviewScreenViewModel?.userCouponCode = nil
                self?.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
            }
            self?.setPromoCodeView()
        })
    }
    private func setPromoCodeView(){
        if let couponCode = reviewScreenViewModel?.userCouponCode{
            appliedCouponView.isHidden = false
            applyCouponView.isHidden = true
            couponCodeLabel.text = "\(couponCode.couponCode) Applied"
            savedAmountLabel.text = String(format: Strings.saved_amount, arguments: [StringUtils.getStringFromDouble(decimalNumber: couponCode.maxDiscount)])
        } else {
            appliedCouponView.isHidden = true
            applyCouponView.isHidden = false
        }
    }

    @IBAction func removeAppliedCouponTapped(_ sender: Any) {
        reviewScreenViewModel?.userCouponCode = nil
        applyCouponView.isHidden = false
        appliedCouponView.isHidden = true
        couponCodeLabel.text = ""
    }
}

extension OutStationReviewViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            reviewScreenViewModel?.getFareBrakeUpData()
            return (reviewScreenViewModel?.estimateFareData.count ?? 0) + 1
        case 3:
            if let isRequiredToShowInfo = reviewScreenViewModel?.isRequiredToShowInfo, !isRequiredToShowInfo {
               return 1
            }
            if let data =  reviewScreenViewModel?.getDataForFacilitiesAndInclusionAndExclusion() {
                if data.count == 0{
                    return 0
                } else {
                    if reviewScreenViewModel?.selectedOptionTabIndex == 3{
                        return data.count + 2
                    }else {
                        return data.count + 1
                    }
                }
            } else {
                return 0
            }
        case 4:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let outstationTaxiDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OutstationTaxiDetailsTableViewCell", for: indexPath) as! OutstationTaxiDetailsTableViewCell
            if let taxiDetails = self.reviewScreenViewModel?.fareForVehicleClass {
                outstationTaxiDetailsTableViewCell.setupUI(fareForVehicleClass: taxiDetails, destinationCity: reviewScreenViewModel?.endlocation?.address, tripType: reviewScreenViewModel?.journeytype) { completed in
                    if completed {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            }
            return outstationTaxiDetailsTableViewCell
        case 1:
            let rideDetailCell = tableView.dequeueReusableCell(withIdentifier: "OutstationTaxiTripDataTableViewCell", for: indexPath as IndexPath) as! OutstationTaxiTripDataTableViewCell
            rideDetailCell.setUpUI(startAddress: self.reviewScreenViewModel?.startlocation?.address ?? "", endAddress: self.reviewScreenViewModel?.endlocation?.address ?? "", startTime: self.reviewScreenViewModel?.startTime ?? NSDate().getTimeStamp(), endTime: self.reviewScreenViewModel?.endTime ?? NSDate().getTimeStamp(), journeyType: self.reviewScreenViewModel?.journeytype ?? TaxiPoolConstants.JOURNEY_TYPE_ONE_WAY, estimateFare: nil, taxiRidePassenger: nil)
            return rideDetailCell
        case 2:
            switch indexPath.row {
            case 0:
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
                guard let fareForVehicleClass = self.reviewScreenViewModel?.fareForVehicleClass else {
                    return  headerCell
                }
                let numberOfDays = Int(fareForVehicleClass.timeDuration/(60*24))
                var subTitleString = "\(fareForVehicleClass.distance) KM, \(1) day"
                if numberOfDays > 1{
                    subTitleString = "\(fareForVehicleClass.distance) KM, \(numberOfDays) days"
                }
                headerCell.setUpUI(headerString: Strings.estimate_fare, rightDetailString: "₹\(Int(self.reviewScreenViewModel?.fareForVehicleClass?.minTotalFare ?? 0.0))", subTitleString: subTitleString)
                headerCell.contentview.backgroundColor = UIColor(netHex: 0xEFEFEF)
                return headerCell
            default:
                let fareDetailCell = tableView.dequeueReusableCell(withIdentifier: "TaxiDetailsTableViewCell", for: indexPath) as! TaxiDetailsTableViewCell
                let currentData = reviewScreenViewModel!.estimateFareData[indexPath.row - 1]
                fareDetailCell.updateUIForFare(title: currentData.key!  , price: currentData.value!)
                fareDetailCell.contentview.backgroundColor = UIColor(netHex: 0xEFEFEF)
                fareDetailCell.separatorView.isHidden = true
                return fareDetailCell
            }
        case 3:
            switch indexPath.row {
            case 0:
                let tabHeaderCell = tableView.dequeueReusableCell(withIdentifier: "OptionHeadersTableViewCell", for: indexPath) as! OptionHeadersTableViewCell
                tabHeaderCell.updatDataAsPerUI(selectedIndex: reviewScreenViewModel?.selectedOptionTabIndex ?? 0, screenWidth: Double(self.view.frame.size.width), isRequiredToShowInfo: reviewScreenViewModel?.isRequiredToShowInfo, isFromLiveRide: false) { showInfo in
                    if showInfo {
                        self.reviewScreenViewModel?.isRequiredToShowInfo = true
                        self.reviewTableView.reloadData()
                    } else {
                        self.reviewScreenViewModel?.isRequiredToShowInfo = false
                        self.reviewTableView.reloadData()
                    }
                }
                tabHeaderCell.delegate = self
                return tabHeaderCell
            default:

                let outstationTaxiInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OutstationTaxiInfoTableViewCell", for: indexPath) as! OutstationTaxiInfoTableViewCell
                var imageUri: String?
                if reviewScreenViewModel?.selectedOptionTabIndex != 3{
                    imageUri = reviewScreenViewModel?.getDataForFacilitiesAndInclusionAndExclusion()[indexPath.row - 1].imageUri
                    outstationTaxiInfoTableViewCell.facilitiesUI(data: reviewScreenViewModel?.getDataForFacilitiesAndInclusionAndExclusion()[indexPath.row - 1].desc ?? "", imageUrl: imageUri)
                } else {
                    if  indexPath.row == ((self.reviewScreenViewModel?.fareForVehicleClass?.taxiTnCSummary?.extras.count ?? 0) + 1) {
                        outstationTaxiInfoTableViewCell.updateUIForInterCityRules(data: Strings.cancel_policy)
                    }else{
                        outstationTaxiInfoTableViewCell.facilitiesUI(data: reviewScreenViewModel?.getDataForFacilitiesAndInclusionAndExclusion()[indexPath.row - 1].desc ?? "", imageUrl: nil)
                    }
                }
                return outstationTaxiInfoTableViewCell

            }
        case 4:
            let outstationCustomerCareTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OutstationCustomerCareTableViewCell", for: indexPath) as! OutstationCustomerCareTableViewCell
            return outstationCustomerCareTableViewCell
        default:
            return UITableViewCell()
        }
    }
}

extension OutStationReviewViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reviewScreenViewModel?.selectedOptionTabIndex == 3{
            if indexPath.row == (reviewScreenViewModel?.fareForVehicleClass?.taxiTnCSummary?.extras.count ?? 0) + 1 {
                openCancellationPolicy()
            }else{
                return
            }
        }else{
            return
        }
    }

    private func openCancellationPolicy() {
        let urlcomps = URLComponents(string :  PaymentPopUPViewModel.refundAndCancelOutstationURL)
        let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.initializeDataBeforePresenting(titleString: "", url: urlcomps!.url!, actionComplitionHandler: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
    }
}

extension OutStationReviewViewController: OptionHeadersTableViewCellDelegate {
    func selectedTab(selectedIndex: Int) {
        self.reviewScreenViewModel?.selectedOptionTabIndex = selectedIndex
        self.reviewTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 4:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor(netHex: 0xEDEDED)
        return footerCell
    }
}
