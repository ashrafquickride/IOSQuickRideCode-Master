//
//  CancelRideBillViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class CancelRideBillViewController: UIViewController {
    
    @IBOutlet weak var helpIcon: UIImageView!
    @IBOutlet weak var needHelpView: UIView!
    @IBOutlet weak var tabelView: UITableView!
    
    private var cancelRideBillViewModel = CancelRideBillViewModel()
    
    func initializeCancelRideRepoet(ride: Ride,rideCancellationReport: [RideCancellationReport]){
        cancelRideBillViewModel.ride = ride
        cancelRideBillViewModel.rideCancellationReports = rideCancellationReport
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cancelRideBillViewModel.rideCancellationReports.isEmpty{
            setUpUI()
        }else{
            if cancelRideBillViewModel.ride?.rideType == Ride.PASSENGER_RIDE{
                cancelRideBillViewModel.getLimitedWalletTransactions(delegate: self)
            }
            cancelRideBillViewModel.getInvoiceForCancelledRide(delegate: self)
            cancelRideBillViewModel.getUserBasicInfo(delegate: self)
            helpIcon.image = helpIcon.image?.withRenderingMode(.alwaysTemplate)
            helpIcon.tintColor = UIColor(netHex: 0x007AFF)
            needHelpView.addShadow()
        }
    }
    
    private func setUpUI(){
        tabelView.dataSource = self
        tabelView.reloadData()
        tabelView.estimatedRowHeight = 160
        tabelView.rowHeight = UITableView.automaticDimension
        tabelView.register(UINib(nibName: "BillHeaderCardTableViewCell", bundle: nil), forCellReuseIdentifier: "BillHeaderCardTableViewCell")
        tabelView.register(UINib(nibName: "ReferralTableViewCell", bundle: nil), forCellReuseIdentifier: "ReferralTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func needHelpTapped(_ sender: UIButton) {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: "", toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
}

extension CancelRideBillViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cancelRideBillViewModel.getNoOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cancelRideBillViewModel.rideCancellationReports.isEmpty || cancelRideBillViewModel.compensetionNotApplied{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
                cell.initializeHeaderView(rideType: cancelRideBillViewModel.ride?.rideType ?? "", rideDate: cancelRideBillViewModel.ride?.startTime ?? 0, seats: "", isFromClosedRidesOrTransaction: true, isTaxiShareRide: false, isCancelRide: true, isOutStationTaxi: false, delegate: self, rideTackerName: nil)
                return cell
            }else if indexPath.row == 1{
                if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                    let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReferralTableViewCell", for: indexPath) as! ReferralTableViewCell
                    
                    let referalPoints = String(pointsAfterVerification + pointsAfterFirstRide)
                   let percentageNumber = String(clientConfiguration.percentCommissionForReferredUser)
                                    
                    cell.updateCellData(referralPoints: referalPoints, percentageNumber: percentageNumber, delegate: self)
                    cancelRideBillViewModel.prepareOfferListAndUpdateUI()
                    return cell
                }else{
                    return UITableViewCell()
                }
            }
        }
        if cancelRideBillViewModel.ride?.rideType == Ride.PASSENGER_RIDE{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
                cell.initializeHeaderView(rideType: cancelRideBillViewModel.ride?.rideType ?? "", rideDate: cancelRideBillViewModel.ride?.startTime ?? 0, seats: "", isFromClosedRidesOrTransaction: true, isTaxiShareRide: false, isCancelRide: true, isOutStationTaxi: false, delegate: self, rideTackerName: nil)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideBillRideDetailsTableViewCell", for: indexPath) as! CancelRideBillRideDetailsTableViewCell
                cell.initailizeRideDetails(from: cancelRideBillViewModel.ride?.startAddress ?? "", to: cancelRideBillViewModel.ride?.endAddress ?? "")
                return cell
            case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideParticipantTableViewCell", for: indexPath) as! CancelRideParticipantTableViewCell
                    cell.initializeCell(oppositeUser: cancelRideBillViewModel.oppositeUsers[cancelRideBillViewModel.shownReports])
                    cancelRideBillViewModel.shownReports += 1
                    return cell
            case 3:
                if cancelRideBillViewModel.rideTakerWalletAmounts.keys.count > 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideBillAmountDetailsTableViewCell", for: indexPath) as! CancelRideBillAmountDetailsTableViewCell
                    cell.initailizeRideAmountDetails(reservedPoints: cancelRideBillViewModel.reservedPoints ?? "", cancellationFee: cancelRideBillViewModel.cancellationFee ?? "", totalRefundPoints: cancelRideBillViewModel.totalRefundPoints ?? "")
                    return cell
                }else{
                  let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideSupportTableViewCell", for: indexPath) as! CancelRideSupportTableViewCell
                    cell.initailizeRideRefundSupportDetails(rideType: cancelRideBillViewModel.ride?.rideType ?? "",delegate: self)
                    return cell
                }
                
            default:
                
                if cancelRideBillViewModel.showedWallets < cancelRideBillViewModel.rideTakerWalletAmounts.keys.count{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideRefundDetailsTableViewCell", for: indexPath) as! CancelRideRefundDetailsTableViewCell
                    let wallets = Array(cancelRideBillViewModel.rideTakerWalletAmounts.keys)
                    let amount = StringUtils.getStringFromDouble(decimalNumber: cancelRideBillViewModel.rideTakerWalletAmounts[wallets[cancelRideBillViewModel.showedWallets]])
                    cell.initailizeRideRefundDetails(paymentType: wallets[cancelRideBillViewModel.showedWallets], points: amount)
                    cancelRideBillViewModel.showedWallets += 1
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideSupportTableViewCell", for: indexPath) as! CancelRideSupportTableViewCell
                    cell.initailizeRideRefundSupportDetails(rideType: cancelRideBillViewModel.ride?.rideType ?? "",delegate: self)
                    return cell
                }
            }
        }else{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
                cell.initializeHeaderView(rideType: cancelRideBillViewModel.ride?.rideType ?? "", rideDate: cancelRideBillViewModel.ride?.startTime ?? 0, seats: "", isFromClosedRidesOrTransaction: true, isTaxiShareRide: false, isCancelRide: true, isOutStationTaxi: false, delegate: self, rideTackerName: nil)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideBillRideDetailsTableViewCell", for: indexPath) as! CancelRideBillRideDetailsTableViewCell
                cell.initailizeRideDetails(from: cancelRideBillViewModel.ride?.startAddress ?? "", to: cancelRideBillViewModel.ride?.endAddress ?? "")
                return cell
            default:
                if cancelRideBillViewModel.shownReports < cancelRideBillViewModel.oppositeUsers.count{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideParticipantTableViewCell", for: indexPath) as! CancelRideParticipantTableViewCell
                    cell.initializeCell(oppositeUser: cancelRideBillViewModel.oppositeUsers[cancelRideBillViewModel.shownReports])
                    cancelRideBillViewModel.shownReports += 1
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CancelRideSupportTableViewCell", for: indexPath) as! CancelRideSupportTableViewCell
                    cell.initailizeRideRefundSupportDetails(rideType: cancelRideBillViewModel.ride?.rideType ?? "",delegate: self)
                    return cell
                }
            }
            
        }
    }
}

extension CancelRideBillViewController: BillHeaderCardTableViewCellDelegate{
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func menuButtonTapped() {
    }
}

extension CancelRideBillViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}

extension CancelRideBillViewController: CancelRideSupportTableViewCellDelegate{
    func supportMailTapped() {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: String(format: Strings.cancel_ride_support_subject, arguments: [UserDataCache.getInstance()?.getUserName() ?? "",StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.getUser()?.contactNo),UserDataCache.getInstance()?.userId ?? "",StringUtils.getStringFromDouble(decimalNumber: cancelRideBillViewModel.ride?.rideId)]) , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
}
//MARK: ReferralTableViewCellDelegate
extension CancelRideBillViewController: ReferralTableViewCellDelegate{
    func referNowButtonpressed() {
        AppDelegate.getAppDelegate().log.debug("referThroughThroughWhatsApp()")
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                let referralURL = String(format: Strings.share_and_earn_msg, arguments: [(UserDataCache.getInstance()?.getReferralCode() ?? ""),url,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
                let urlStringEncoded = StringUtils.encodeUrlString(urlString: referralURL)
                let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded)")
                if UIApplication.shared.canOpenURL(url! as URL) {
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }else{
                    MessageDisplay.displayAlert(messageString: Strings.can_not_find_whatsup, viewController: self,handler: nil)
                }
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
    
    func howItWorksPressed() {
        if cancelRideBillViewModel.shareAndEarnOffers.isEmpty{
            return
        }
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HowItWorkPopUpForShareAndEarnViewController") as! HowItWorkPopUpForShareAndEarnViewController
        showTermsAndConditionsViewController.initializeView(shareAndEarnOffer: cancelRideBillViewModel.shareAndEarnOffers[0])
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
    
    func shareButtonPressed() {
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String) {
        let message = String(format: Strings.share_and_earn_msg, arguments: [UserDataCache.getInstance()?.getReferralCode() ?? "",urlString,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
        let activityItem: [AnyObject] = [message as AnyObject]
        let vc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            vc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        vc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}
extension CancelRideBillViewController: GetOppositeUser{
    func preparedOppositeUserList() {
        setUpUI()
    }
}

