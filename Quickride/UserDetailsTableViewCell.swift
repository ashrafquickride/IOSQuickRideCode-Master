//
//  UserDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol UserDetailsTableViewCellDelegate {
    func viewFareDetailsPressed()
    func viewMapPressed(data: Bool)
    func paynowBtnPressed(rideBillingDetails: RideBillingDetails)
    func addOrRemoveFavoritePartner(userId: Double,status: Int)
    func showInsuranceView()
}

class UserDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var pointsShowingLabel: UILabel!
    @IBOutlet weak var viewFareBreakUpBtn: UIButton!
    @IBOutlet weak var fareDetailsTableView: UITableView!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var fareDetailsTableViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var walletNameButton: UIButton!
    @IBOutlet weak var drapUpAndDownImageView: UIImageView!
    
    var rideBillingDetails: RideBillingDetails?
    var tripReport: TripReport?
    var delegate: UserDetailsTableViewCellDelegate?
    var riderType: String?
    private var randomIndex = 0
    private var taxiShareInfoForInvoice: TaxiShareInfoForInvoice?
    private var isTaxiRide = false
    private var isOutStationTaxi = false
    private var journeyTypeId = 0
    private var currentRide: Ride?
    private var estimateFareData = [fareDetailsOutStatioonTaxi]()

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }

    private func setUpUI() {
        fareDetailsTableView.register(UINib(nibName: "FareDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "FareDetailsTableViewCell")
        fareDetailsTableView.register(UINib(nibName: "TaxiPoolFareDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolFareDetailsTableViewCell")
        //ForOutStation
        fareDetailsTableView.register(UINib(nibName: "OutstationRideDataTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "OutstationRideDataTaxiTableViewCell")
        fareDetailsTableView.register(UINib(nibName: "DetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailsTableViewCell")
        fareDetailsTableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderTableViewCell")
        
    }

    func initializeRiderDetails(isExpandable: Bool,riderDetails: RideParticipant?,rideBillingDetails: RideBillingDetails? ,riderType: String,isFromClosedRide: Bool,taxiShareInfoForInvoice:TaxiShareInfoForInvoice?,isTaxiRide: Bool,isOutStationTaxi: Bool,currentRide: Ride?,delegate: UserDetailsTableViewCellDelegate?) {
        self.rideBillingDetails = rideBillingDetails
        self.riderType = riderType
        self.delegate = delegate
        self.taxiShareInfoForInvoice = taxiShareInfoForInvoice
        self.isTaxiRide = isTaxiRide
        self.isOutStationTaxi = isOutStationTaxi
        self.currentRide =  currentRide
       
        viewFareBreakUpBtn.setTitle(Strings.view_fare, for: .normal)
        setJourneyId()
        if isExpandable, rideBillingDetails == nil {
            if rideBillingDetails?.insurancePoints == 0.0 {
                fareDetailsTableViewHeightConstraints.constant = 365
            }else{
                fareDetailsTableViewHeightConstraints.constant = 395
            }
        }else{
            fareDetailsTableViewHeightConstraints.constant = 0
        }
        if isExpandable {
            drapUpAndDownImageView.image = UIImage(named: "up_arrow_blue")
            
        }else {
            drapUpAndDownImageView.image = UIImage(named: "down_arrow_blue")
        }
        if rideBillingDetails?.status == RideBillingDetails.bill_status_pending && isFromClosedRide {
            pointsShowingLabel.text = String(format: Strings.points_status, arguments: [StringUtils.getStringFromDouble(decimalNumber: ((rideBillingDetails?.rideTakerTotalAmount ?? 0) + (rideBillingDetails?.insurancePoints ?? 0))), RideBillingDetails.bill_status_pending])
            pointsShowingLabel.textColor = .red
            payNowButton.isHidden = false
        } else {
            pointsShowingLabel.text = String(format: Strings.points_shared, arguments: [StringUtils.getStringFromDouble(decimalNumber: ((rideBillingDetails?.rideTakerTotalAmount ?? 0) + (rideBillingDetails?.insurancePoints ?? 0)))])
            pointsShowingLabel.textColor = .black
            payNowButton.isHidden = true
        }
        if let rideBillingDetails = rideBillingDetails, let paymentType = rideBillingDetails.paymentType,
           let paymentBy = formatPaymentTypeString(paymentType: paymentType) {
            walletNameButton.setTitle(paymentBy, for: .normal)
        }else {
            walletNameButton.isHidden = true
        }

    }

    private func formatPaymentTypeString( paymentType:  String) -> String?
    {
        let paymentTypeList : [String] = paymentType.components(separatedBy: ",")
        if paymentTypeList.count <= 0{
            return nil
        }
        var returnText = ""
        var paidByQRWallet = false
        for (index,type) in paymentTypeList.enumerated() {
            if AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP != type{
                returnText = returnText + type
                if index < paymentTypeList.count-1{
                    returnText = returnText + ", "
                }
            }else{
                paidByQRWallet = true
            }
        }
        if !paidByQRWallet{
            return returnText
        }
        return paymentTypeList.count == 1 ? "QuickRide wallet" : returnText + " and QuickRide wallet"
    }

    @IBAction func payNowBtnPressed(_ sender: UIButton) {
        if let rideBillingDetails = rideBillingDetails{
            delegate?.paynowBtnPressed(rideBillingDetails: rideBillingDetails)
        }
    }

    @IBAction func viewfarePressed(_ sender: UIButton) {
       
        delegate?.viewFareDetailsPressed()
        fareDetailsTableView.reloadData()
    }
    @IBAction func walletNameButtonTapped(_ sender: Any) {
        let transactionVC:TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionVC.intialisingData(isFromRewardHistory: false)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: transactionVC, animated: false)
    }
    
    private func setJourneyId() {
        if let taxiShareInfoForInvoice = taxiShareInfoForInvoice {
            if taxiShareInfoForInvoice.journeyType == TaxiShareRide.ROUND_TRIP {
                journeyTypeId = 1
            }
        }
    }

    private func getFareBrakeUpData() {
        estimateFareData.removeAll()
        let estimateData = taxiShareInfoForInvoice
        if estimateData?.advanceAmount != 0 {
            let advanceAmount = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.ADVANCE_AMOUNT, value: "₹\(Int(estimateData?.advanceAmount ?? 0.0))")
            estimateFareData.append(advanceAmount)
        }
        if estimateData?.distanceBasedFare != 0 {
            var key = ReviewScreenViewModel.DISTANCE_BASED_FARE
            if self.journeyTypeId == 1 {
                key = key + " - ₹\(Int(estimateData?.baseKmFare ?? 0.0))" + "/KM"
            }
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(Int(estimateData?.distanceBasedFare ?? 0.0))")
            estimateFareData.append(distanceBasedFare)
        }
        if estimateData?.driverAllowance != 0 {
            let driverAllowance = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DRIVER_ALLOWANCE, value: "₹\(Int(estimateData?.driverAllowance ?? 0.0))")
            estimateFareData.append(driverAllowance)
        }
        if estimateData?.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(Int(estimateData?.nightCharges ?? 0.0))")
            estimateFareData.append(nightCharges)
        }
        if estimateData?.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(Int(estimateData?.tollCharges ?? 0.0))")
            estimateFareData.append(parkingCharges)
        }

        if estimateData?.serviceTax != 0 {
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: "₹\(Int(estimateData?.serviceTax ?? 0.0))")
            estimateFareData.append(serviceTax)
        }
        if let estimateData = estimateData {
            var platformFeeWithTax = estimateData.platformFee + estimateData.platformFeeTax
            if platformFeeWithTax > 0 {
                let key = "₹\(platformFeeWithTax.roundToPlaces(places: 1))"
                let platformFeeWithTaxes = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: key)
                estimateFareData.append(platformFeeWithTaxes)
            }
        }
        if estimateData?.stateTaxCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(Int(estimateData?.stateTaxCharges ?? 0.0))")
            estimateFareData.append(stateTaxCharges)
        }
        if estimateData?.interStateTaxCharges != 0 {
            let interStateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.INTERCITY_CHARGES, value: "₹\(Int(estimateData?.interStateTaxCharges ?? 0.0))")
            estimateFareData.append(interStateTaxCharges)
        }
        if estimateData?.extraKmFare != 0 {
            let extraKmFare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.EXTRA_KM_FARE, value: "₹\(Int(estimateData?.extraKmFare ?? 0.0))")
            estimateFareData.append(extraKmFare)
        }
        if estimateData?.totalVendorFare != 0 {
            let totalVendorFare = fareDetailsOutStatioonTaxi(key: Strings.ride_points, value: "₹\(Int(estimateData?.totalVendorFare ?? 0.0))")
            estimateFareData.append(totalVendorFare)
        }
    }
}

extension UserDetailsTableViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isOutStationTaxi {
            return 3
        }else if isTaxiRide {
            return 1
        }else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOutStationTaxi {
            if section == 2 {
                return estimateFareData.count + 1
            }
            return 2
        }else if isTaxiRide {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isOutStationTaxi {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
                    var headerString = ""
                    if journeyTypeId == 1 {
                        headerString = String(format: Strings.round_trip_to, arguments: [(taxiShareInfoForInvoice?.endCity ?? currentRide?.endAddress) ?? ""])
                    }else{
                        headerString = String(format: Strings.one_way_trip_to, arguments: [(taxiShareInfoForInvoice?.startCity ?? currentRide?.startAddress) ?? ""])
                    }
                    headerCell.setUpUI(headerString: headerString, rightDetailString: "", subTitleString: "")
                    return headerCell

                default:
                    let rideDetailCell = tableView.dequeueReusableCell(withIdentifier: "OutstationRideDataTaxiTableViewCell", for: indexPath as IndexPath) as! OutstationRideDataTaxiTableViewCell
                    rideDetailCell.setUpUI(startAddress: (taxiShareInfoForInvoice?.startCity ?? currentRide?.startAddress) ?? "", endAddress: (taxiShareInfoForInvoice?.endCity ?? currentRide?.endAddress) ?? "", startTime: currentRide?.startTime, endTime: taxiShareInfoForInvoice?.toTime,journeyType: journeyTypeId, isViewAllVisiable: false, estimateFare: nil, taxiShareRide: nil, currentRide: nil, outstationTaxiAvailabilityInfo: nil)
                    return rideDetailCell
                }
            case 1:
                switch indexPath.row {
                case 0:
                    let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
                    headerCell.setUpUI(headerString: Strings.booking_type, rightDetailString: "", subTitleString: "")
                    return headerCell
                default:
                    let taxiChoosenCell = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell", for: indexPath) as! DetailsTableViewCell
                    if let taxiShareInfoForInvoice = taxiShareInfoForInvoice {
                        taxiChoosenCell.setDataForTripDetails(taxiShareInfoForInvoice: taxiShareInfoForInvoice)
                    }
                    return taxiChoosenCell
                }
            case 2:
                switch indexPath.row {
                case 0:
                    let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
                    headerCell.setUpUI(headerString: Strings.payment_caps.capitalizingFirstLetter(), rightDetailString: "", subTitleString: "")
                    return headerCell
                default:
                    let fareDetailCell = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell", for: indexPath) as! DetailsTableViewCell
                    let currentData = estimateFareData[indexPath.row - 1]
                    fareDetailCell.updateUIForFare(title: currentData.key ?? "" , price: currentData.value ?? "")
                    if indexPath.row == estimateFareData.count{
                        fareDetailCell.separatorView.isHidden = true
                    }else{
                        fareDetailCell.separatorView.isHidden = false
                    }
                    return fareDetailCell
                }
            default:
                return UITableViewCell()
            }
        }else{
            let taxiBillCell = tableView.dequeueReusableCell(withIdentifier: "TaxiPoolFareDetailsTableViewCell", for: indexPath) as! TaxiPoolFareDetailsTableViewCell
            taxiBillCell.delegate = self
            taxiBillCell.updateUIWithData(rideBillingDetails: rideBillingDetails, taxiShareInfoForInvoice: taxiShareInfoForInvoice)
            return taxiBillCell
        }
    }
}
extension UserDetailsTableViewCell: FareDetailsTableViewCellDelegate, TaxiPoolFareDetailsTableViewCellDelegate {
    func insuranceInfoTapped() {
        delegate?.showInsuranceView()
    }
    func routeMapButtonTapped(data: Bool) {
        delegate?.viewMapPressed(data: data)
    }

}
