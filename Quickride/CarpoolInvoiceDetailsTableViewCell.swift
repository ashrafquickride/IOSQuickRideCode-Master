//
//  CarpoolInvoiceDetailsTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 04/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias invoiceDropDownHandler = (_ result: Bool, _ invoiceDropDownData: [Int : Bool] )-> Void

class CarpoolInvoiceDetailsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var passengerCompanyNameLbl: UILabel!
    @IBOutlet weak var verifiedPassengerImageIcon: UIImageView!
    @IBOutlet weak var startLocationLbl: UILabel!
    @IBOutlet weak var endLocationLbl: UILabel!
    @IBOutlet weak var riderNameLbl: UILabel!
    @IBOutlet weak var ridePointsLbl: UILabel!
    @IBOutlet weak var carpoolSharedNameLbl: UILabel!
    @IBOutlet weak var passengerNameLbl: UILabel!
    @IBOutlet weak var PassengerInvoiceNumberLbl: UILabel!
    @IBOutlet weak var rideDistanceLbl: UILabel!
    @IBOutlet weak var riderInvoiceNumberLbl: UILabel!
    @IBOutlet weak var riderCompanyNameLbl: UILabel!
    @IBOutlet weak var riderDetectedPoints: UILabel!
    @IBOutlet weak var verifiedRiderImageIconView: UIImageView!
    @IBOutlet weak var showInvoiceContantStackView: UIStackView!
    @IBOutlet weak var tapDownArrowView: UIImageView!
    @IBOutlet weak var titlePassengerNameLabel: UILabel!
    @IBOutlet weak var titleridePointsLbl: UILabel!
    @IBOutlet weak var passengerInvoicePointsLbl: UILabel!
    @IBOutlet weak var passengerSeperatorView: UIView!
    @IBOutlet weak var numberOfPassengerView: UIView!
    @IBOutlet weak var riderSeperatorView: UIView!
    @IBOutlet weak var firstDotSeperatorView: UIView!
    
    var delegate: UserDetailsTableViewCellDelegate?
    var invoiceDropDownHandler: invoiceDropDownHandler?
    var invoiceDropDownData = [Int : Bool]()
    var fullUserprofile = UserFullProfile()
    var invoiceIndex: Int = 0
    var verifiedImage = UIImage()
    var companyname = ""
    var  riderImageView = UIImage()
    
    func initialiseData(rideBillingDetails: RideBillingDetails?,companyName: String?, verificationProfile: UIImage?,userDetailsTableViewCellDelegate: UserDetailsTableViewCellDelegate,invoiceIndex: Int, invoiceDropDownData: [Int : Bool],invoiceDropDownHandler: @escaping invoiceDropDownHandler){
        self.invoiceDropDownHandler = invoiceDropDownHandler
        self.invoiceDropDownData = invoiceDropDownData
        self.invoiceIndex = invoiceIndex
        if invoiceDropDownData[invoiceIndex] ?? false {
         
            showInvoiceContantStackView.isHidden = false
            tapDownArrowView.image = UIImage(named: "arrow_up_grey")
        }else {
          
            showInvoiceContantStackView.isHidden = true
            tapDownArrowView.image = UIImage(named: "arrow_down_grey")
        }
       if invoiceDropDownData.count >= 2{
           numberOfPassengerView.isHidden = false
           riderSeperatorView.isHidden = true
           
        }else {
            numberOfPassengerView.isHidden = true
            riderSeperatorView.isHidden = false
            
       }
        delegate = userDetailsTableViewCellDelegate
        riderSeperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        firstDotSeperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        passengerSeperatorView.addDashedView(color: UIColor.darkGray.cgColor)
        let platformFeesWithTaxPoints = (rideBillingDetails?.rideGiverPlatformFeeGst ?? 0) + (rideBillingDetails?.rideGiverPlatformFee ?? 0)
        titleridePointsLbl.text = StringUtils.getPointsInDecimal(points: (rideBillingDetails?.rideFare ?? 0) - platformFeesWithTaxPoints) + " Points"
        self.riderImageView = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: fullUserprofile.userProfile?.profileVerificationData)
        titlePassengerNameLabel.text = rideBillingDetails?.fromUserName
        riderNameLbl.text = rideBillingDetails?.toUserName
        riderDetectedPoints.text = StringUtils.getPointsInDecimal(points: (rideBillingDetails?.rideFare ?? 0) - platformFeesWithTaxPoints) + " Points"
        startLocationLbl.text = rideBillingDetails?.startLocation
        endLocationLbl.text = rideBillingDetails?.endLocation
        carpoolSharedNameLbl.text = "Carpool points earned by " + (rideBillingDetails?.fromUserName ?? "")
        ridePointsLbl.text = StringUtils.getPointsInDecimal(points: rideBillingDetails?.rideFare ?? 0)
        rideDistanceLbl.text = StringUtils.getStringFromDouble(decimalNumber: rideBillingDetails?.distance ?? 0) + "Kms"
        riderInvoiceNumberLbl.text = String(rideBillingDetails?.rideGiverCommissionInvoiceNo ?? 0)
        PassengerInvoiceNumberLbl.text = String(rideBillingDetails?.rideInvoiceNo ?? 0)
        passengerNameLbl.text = rideBillingDetails?.fromUserName ?? ""
        passengerInvoicePointsLbl.text = StringUtils.getPointsInDecimal(points: rideBillingDetails?.rideFare ?? 0)
        riderDetectedPoints.text = "-" + StringUtils.getPointsInDecimal(points: platformFeesWithTaxPoints)
        displayPassengerBasicInfo()
        getUserBasicInfo(rideBillingDetails: rideBillingDetails)
        
        if UserDataCache.getInstance()?.userProfile == nil {
            riderCompanyNameLbl.text = UserDataCache.getInstance()?.userProfile?.companyName?.capitalizingFirstLetter()
        } else {
            riderCompanyNameLbl.text = "Not Verified"
        }
        verifiedRiderImageIconView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: fullUserprofile.userProfile?.profileVerificationData)
    }
    
    
 
    @IBAction func dropDownBtnTapped(_ sender: Any) {
        
        if invoiceDropDownData[invoiceIndex] ?? false {
                   invoiceDropDownData[invoiceIndex] = false
               }else{
                   invoiceDropDownData[invoiceIndex] = true
               }
               if let invoiceDropDownHandler = invoiceDropDownHandler {
                   invoiceDropDownHandler(true, invoiceDropDownData)
               }
    }
        
        private func getUserBasicInfo(rideBillingDetails: RideBillingDetails?) {
        if  let userId = rideBillingDetails?.fromUserId {
            UserDataCache.getInstance()?.getUserBasicInfo(userId: Double(userId) , handler: {(userBasicInfo, responseError, error) in
                self.companyname = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData, companyName: userBasicInfo?.companyName?.capitalized)
                self.verifiedImage =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData)
                self.displayPassengerBasicInfo()
                
            })
        }
    }
    private func displayPassengerBasicInfo(){
        if companyname != "" {
            passengerCompanyNameLbl.isHidden = false
            verifiedPassengerImageIcon.isHidden = false
            verifiedPassengerImageIcon.image = verifiedImage
            passengerCompanyNameLbl.text = companyname
        }else {
            passengerCompanyNameLbl.isHidden = true
            verifiedPassengerImageIcon.isHidden = true
        }
    }

}






  

