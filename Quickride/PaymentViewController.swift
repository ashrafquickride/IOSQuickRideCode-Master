//
//  PaymentViewController.swift
//  PlacesLookup
//
//  Created by Swagat Kumar Bisoyi on 10/22/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Social
import SimplZeroClick

class PaymentViewController: UIViewController, AccountUpdateListener {

    @IBOutlet weak var walletView: UIView!

    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBOutlet weak var earnedView: UIView!

    @IBOutlet weak var rewardsView: UIView!

    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var pastTransactionToolTipView: UIView!

    var currentSegmentIndex : Int?

    var accountPaymentViewController : AccountPaymentViewController?
    var encashPaymentViewController : EncashPaymentViewController?
    var rewardsViewController : RewardsViewController?



    var swipeRecognizerLeft: UISwipeGestureRecognizer!
    var swipeRecognizerRight: UISwipeGestureRecognizer!
    var selectedIndex = 0

    func initializeDataBeforePresenting(selectedIndex : Int){
        self.selectedIndex = selectedIndex
    }

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        definesPresentationContext = true
        super.viewDidLoad()
        swipeRecognizerLeft = UISwipeGestureRecognizer(target: self,action: #selector(PaymentViewController.handleSwipes(_:)))
        swipeRecognizerRight = UISwipeGestureRecognizer(target: self,action: #selector(PaymentViewController.handleSwipes(_:)))

        swipeRecognizerLeft.direction = .left
        swipeRecognizerRight.direction = .right
        swipeRecognizerLeft.numberOfTouchesRequired = 1
        swipeRecognizerRight.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeRecognizerLeft)
        view.addGestureRecognizer(swipeRecognizerRight)

        UserDataCache.getInstance()?.addAccountUpdateListener(key: "PaymentViewController", accountUpdateListener: self)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        earnedView.isHidden = true

        rewardsView.isHidden = true
        segmentControl.selectedSegmentIndex = selectedIndex
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        self.automaticallyAdjustsScrollViewInsets = false
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        moveToSelectedView(index: selectedIndex)
        if SharedPreferenceHelper.getPastTransactionToolTip(){
            pastTransactionToolTipView.isHidden = true
        }else{
            pastTransactionToolTipView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func selectedSegmentAtIndex(index: Int){
        moveToSelectedView(index: index)
        self.currentSegmentIndex = index
    }

    @IBAction func segmentControlSelected(_ sender: Any) {
        self.view.endEditing(false)
        selectedIndex = segmentControl.selectedSegmentIndex
        moveToSelectedView(index: segmentControl.selectedSegmentIndex)
    }

    func moveToSelectedView(index : Int){
        AppDelegate.getAppDelegate().log.debug("moveToSelectedView()")
        if index == 0{
            walletView.isHidden = false
            earnedView.isHidden = true
            rewardsView.isHidden = true
            accountPaymentViewController?.checkWhetherWalletLinkedAndAdjustViews()
        }else if index == 1{
            walletView.isHidden = true
            earnedView.isHidden = false
            rewardsView.isHidden = true
            encashPaymentViewController?.checkWhetherWalletLinkedAndAdjustViews()
        }else if index == 2{
            walletView.isHidden = true
            earnedView.isHidden = true
            rewardsView.isHidden = false
            rewardsViewController?.refreashData()
            if SharedPreferenceHelper.getDisplayStatusForRewardsnfoView(){
                rewardsViewController?.rewardsInfoView.isHidden = true
            }
        }else{
            walletView.isHidden = true
            earnedView.isHidden = true
            rewardsView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("handleSwipes()")
        self.view.endEditing(false)

        if sender.direction == .left{
            AppDelegate.getAppDelegate().log.debug("Swiped Left")
            if segmentControl.selectedSegmentIndex == 2{
                walletView.isHidden = true
                earnedView.isHidden = false
            }
            segmentControl.selectedSegmentIndex += 1

        }else if sender.direction == .right{
            AppDelegate.getAppDelegate().log.debug("Swiped Right")
            if segmentControl.selectedSegmentIndex == 0{
                walletView.isHidden = false
                earnedView.isHidden = true
            }
            segmentControl.selectedSegmentIndex -= 1
        }
        if segmentControl.selectedSegmentIndex < 0{
            segmentControl.selectedSegmentIndex = 0
        }

        segmentControlSelected(segmentControl)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        AppDelegate.getAppDelegate().log.debug("prepareForSegue()")

        if segue.identifier == "AccountPaymentViewController"{

            accountPaymentViewController = segue.destination as? AccountPaymentViewController
            accountPaymentViewController?.topViewController = self

        }else if segue.identifier == "EncashPaymentViewController"{

            encashPaymentViewController = segue.destination as? EncashPaymentViewController
            encashPaymentViewController?.topViewController = self

        }else if segue.identifier == "RewardsViewController"{
            rewardsViewController = segue.destination as? RewardsViewController
        }
    }
    func refreshAccountInformation() {
        encashPaymentViewController?.refreshAccountInfo()
        rewardsViewController?.getAccountInfo()
    }


    @IBAction func transactionsHistoryBtnClicked(_ sender: Any) {

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)



        let actiontrans = UIAlertAction(title: Strings.past_transactions, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            let transactionVC : TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            transactionVC.intialisingData(isFromRewardHistory: false)
            self.navigationController?.pushViewController(transactionVC, animated: false)
        })

        let actionredemp = UIAlertAction(title: Strings.past_redemptions, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            let transactionVC : RedemptionsHistoryViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RedemptionsHistoryViewController") as! RedemptionsHistoryViewController
            self.navigationController?.pushViewController(transactionVC, animated: false)
        })
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateUtils.DATE_FORMAT_MMMM
        let lastMonthName = dateFormatter.string(from: lastMonthDate!)
        let MonthReport = UIAlertAction(title: String(format: Strings.month_report, arguments: [lastMonthName]), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if QRReachability.isConnectedToNetwork() == false{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
                return
            }
            let transactionVC : TransationHistoryMailViewController = UIStoryboard(name: StoryBoardIdentifiers.accountsb_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransationHistoryMailViewController") as! TransationHistoryMailViewController
            self.navigationController?.pushViewController(transactionVC, animated: false)
        })


        optionMenu.addAction(actiontrans)
        optionMenu.addAction(actionredemp)
        optionMenu.addAction(MonthReport)
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)

        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
        pastTransactionToolTipView.isHidden = true
        SharedPreferenceHelper.setPastTransactionToolTip(status: true)
    }


    @IBAction func moreBtnClicked(_ sender: Any) {

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let actionForPayRide = UIAlertAction(title: Strings.pay_for_ride, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                let transferViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransferViewController") as! TransferViewController
                transferViewController.initializeDataBeforePresenting(amountTransferRequest: nil, isFromMissingPayment: false, transferRequestCompletionHandler: nil)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: transferViewController, animated: false)
            })

        optionMenu.addAction(actionForPayRide)

        let actionForMissedPayment = UIAlertAction(title: Strings.missed_payments, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let transferViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransferViewController") as! TransferViewController
            transferViewController.initializeDataBeforePresenting(amountTransferRequest: nil, isFromMissingPayment: true, transferRequestCompletionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: transferViewController, animated: false)
        })
        optionMenu.addAction(actionForMissedPayment)

        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)

        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    @IBAction func pastTransactionToolTipCancelBtnTapped(_ sender: Any) {
        pastTransactionToolTipView.isHidden = true
        SharedPreferenceHelper.setPastTransactionToolTip(status: true)
    }
    func getParticularMonthReport(fromDate: String, toDate: String, monthName: String){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getMonthlyReport(userId: (QRSessionManager.getInstance()?.getUserId())!, fromDate: fromDate, toDate: toDate, viewController: self){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.monthly_report_sent_msg, arguments: [monthName]))
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }

    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

}
