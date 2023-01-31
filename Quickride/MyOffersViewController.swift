//
//  MyOffersViewController.swift
//  Quickride
//
//  Created by Vinutha on 4/9/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import WebKit

typealias rideAssuredIncentiveActivationCompletionHandler = (_ rideAssuredIncentive : RideAssuredIncentive) -> Void

class MyOffersViewController: UIViewController{
    
    @IBOutlet weak var myOffersTableView: UITableView!
    @IBOutlet weak var noOffersView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var couponCodeSuccessMessageView: UIView!
    @IBOutlet weak var couponCodeSuccessMessageLbl: UILabel!
    @IBOutlet weak var couponCodeSuccessMessageDesc: UILabel!
    @IBOutlet weak var assuredCommuteView: UIView!
    @IBOutlet weak var assuredCommuteViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var activatedView: UIView!
    @IBOutlet weak var assuredAmountLbl: UILabel!
    @IBOutlet weak var assuredCommuteViewTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var noOfDaysLbl: UILabel!
    @IBOutlet weak var webViewBackGround: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    private var offerViewModel: MyOfferViewModel?
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offerViewModel?.delegate = self
        registerCells()
    }
    
    func prepareData(selectedFilterString: String?) {
        offerViewModel = MyOfferViewModel(selectedFilterString: selectedFilterString ?? Strings.all)
    }
    
    //MARK: All UI Updates while Loading the VC
    private func setUpUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        ViewCustomizationUtils.addCornerRadiusToView(view: activatedView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: moreView, cornerRadius: 8.0)
        
        if (offerViewModel?.getFilterData()) != nil {
            myOffersTableView.isHidden = false
            filterCollectionView.isHidden = false
            noOffersView.isHidden = true
            backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTapped(_:))))
            self.myOffersTableView.reloadData()
            filterCollectionView.reloadData()
        } else {
            myOffersTableView.isHidden = true
            filterCollectionView.isHidden = true
            noOffersView.isHidden = false
        }
        backGroundView.isHidden = true
        getRideAssuredIncentive()
        self.assuredCommuteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyOffersViewController.assuredCommuteViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: assuredCommuteView, cornerRadius: 5.0)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.OFFER_TAB_VIEWED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
    }
    
    private func registerCells() {
        filterCollectionView.register(UINib(nibName: "OfferFilterViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OfferFilterViewCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        setUpUI()
    }
    
    func getRideAssuredIncentive(){
        offerViewModel?.rideAssuredIncentive = SharedPreferenceHelper.getRideAssuredIncentive()
        if offerViewModel?.rideAssuredIncentive == nil{
            offerViewModel?.getRideAssuredIncentiveFromServer(vc: self)
            return
        }
        if offerViewModel?.rideAssuredIncentive!.status == RideAssuredIncentive.INCENTIVE_STATUS_ACTIVE{
            handleRideAssuredIncentiveViews()
            offerViewModel?.getRideAssuredIncentiveFromServer(vc: self)
            return
        }
        if DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: NSDate(timeIntervalSince1970:  (offerViewModel?.rideAssuredIncentive!.lastFetchedTime ?? 0)/1000)) > 24*60{
            offerViewModel?.getRideAssuredIncentiveFromServer(vc: self)
            return
        }
        handleRideAssuredIncentiveViews()
    }
    
    @objc func dismissTapped(_ gesture : UITapGestureRecognizer){
        webView.isHidden = true
        myOffersTableView.isHidden = false
        filterCollectionView.isHidden = false
        backGroundView.isHidden = true
    }
    
    @IBAction func applyCouponBtnClicked(_ sender: Any) {
        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
        
        applyPromoCodeView!.initializeDataBeforePresentingView(title: Strings.apply_coupon, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: nil, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.coupon, promoCodeAppliedMsg: nil, handler: { (text, result) in
            if Strings.apply_caps == result{
                if text != nil{
                    self.offerViewModel?.applyCouponCode(appliedCoupon: text!, vc: self)
                }
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
    }
    
    
    private func handleRideAssuredIncentiveViews(){
        if offerViewModel?.rideAssuredIncentive!.userId == 0{
            self.assuredCommuteView.isHidden = true
            self.assuredCommuteViewHeightConstraint.constant = 0
            self.assuredCommuteViewTopSpaceConstraint.constant = 0
            if offerViewModel?.offerLists == nil || offerViewModel?.offerLists!.isEmpty ?? true{
                self.noOffersView.isHidden = false
            }else{
                self.noOffersView.isHidden = true
            }
            return
        }
        self.noOffersView.isHidden = true
        self.assuredCommuteView.isHidden = false
        self.assuredCommuteViewHeightConstraint.constant = 150
        self.assuredCommuteViewTopSpaceConstraint.constant = 20
        
        if offerViewModel?.rideAssuredIncentive?.status == RideAssuredIncentive.INCENTIVE_STATUS_ACTIVE{
            self.activatedView.isHidden = false
            self.moreView.isHidden = true
        }else{
            self.activatedView.isHidden = true
            self.moreView.isHidden = false
        }
        self.assuredAmountLbl.text = String(format: Strings.ride_assured_incentive_amount, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: offerViewModel?.rideAssuredIncentive?.amountAssured)])
        noOfDaysLbl.text = "/"+String(DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (offerViewModel?.rideAssuredIncentive!.validTo ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (offerViewModel?.rideAssuredIncentive!.validFrom ?? 0)/1000)))+" "+Strings.days
    }
    
    @objc private func assuredCommuteViewTapped(_ gesture : UITapGestureRecognizer) {
        
        if offerViewModel?.rideAssuredIncentive?.userId == 0{
            return
        }
        
        let rideAssuredIncentiveDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAssuredIncentiveDetailViewController") as! RideAssuredIncentiveDetailViewController
        rideAssuredIncentiveDetailViewController.initializeDataBeforePresenting(rideAssuredIncentive: offerViewModel?.rideAssuredIncentive, handler: { (rideAssuredIncentive) in
            self.offerViewModel?.rideAssuredIncentive = rideAssuredIncentive
            self.handleRideAssuredIncentiveViews()
        })
        self.navigationController?.pushViewController(rideAssuredIncentiveDetailViewController, animated: false)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func setupWebView() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewBackGround.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: webViewBackGround.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: webViewBackGround.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: webViewBackGround.rightAnchor)
        ])
    }
}

extension MyOffersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerViewModel?.offerLists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerCell") as! MyOffersTableViewCell
        guard let offerLists = offerViewModel?.offerLists else {
            return UITableViewCell()
        }
        if offerLists.endIndex <= indexPath.row {
            return cell
        }
        cell.reloadData(index: indexPath.row, data: offerLists[indexPath.row])
        return cell
    }
}

//MARK: UITableViewDelegate
extension MyOffersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = offerViewModel?.offerLists![indexPath.row]
        if let id = offer?.id {
            OfferImpressionHandler.sharedInstance.offerClicked(offerId: StringUtils.getStringFromDouble(decimalNumber: id))
        }
        self.offerClicked(offer: offer)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //TODO : For impression save
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if tableView.visibleCells.contains(cell) {
                if let indexPaths = self.myOffersTableView.indexPathsForVisibleRows{
                    for index in indexPaths {
                        if let offerId = self.offerViewModel?.offerLists?[index.row].id , let impressionSaved = self.offerViewModel?.offerLists?[index.row].isImpressionSaved, !impressionSaved {
                            self.offerViewModel?.offerLists?[index.row].isImpressionSaved = true
                            OfferImpressionHandler.sharedInstance.addOffersForImpressionSaving(offerIdString: StringUtils.getStringFromDouble(decimalNumber: offerId))
                        }
                    }
                }
            }
        }
    }
    
    private func offerClicked(offer: Offer?) {
        let offerMessage = "TMW"
        let userId = QRSessionManager.getInstance()?.getUserId()
        if offer?.offerMessage == offerMessage {
            backGroundView.isHidden = false
            if let weburl = offerViewModel?.getTMWRegURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                setupWebView()
                webView.isHidden = false
                let tmwUrl = URL(string: weburl)
                let request = URLRequest(url:tmwUrl! as URL)
                webView.load(request)
            }
        } else {
            if let offerLinkURL = offer?.linkUrl {
                let queryItems = URLQueryItem(name: "&isMobile", value: "true")
                var urlcomps = URLComponents(string: offerLinkURL)
                var existingQueryItems = urlcomps?.queryItems ?? []
                if !existingQueryItems.isEmpty {
                    existingQueryItems.append(queryItems)
                }else {
                    existingQueryItems = [queryItems]
                }
                urlcomps?.queryItems = existingQueryItems
                if urlcomps?.url != nil{
                    let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                    webViewController.initializeDataBeforePresenting(titleString: Strings.offers, url: urlcomps!.url!, actionComplitionHandler: nil)
                    self.navigationController?.pushViewController(webViewController, animated: false)
                    UserRestClient.saveOfferStatus(userId: userId, offerId: offer?.id, viewController: self, handler: { (responseObject, error) in})
                } else {
                    UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
                }
            }
        }
    }
}

extension MyOffersViewController: MyOfferViewModelDelegate {
    func couponApplied(systemCouponCode: SystemCouponCode?, responseError: ResponseError?, responseObject: NSDictionary?, error: NSError?) {
        if let systemCouponCode = systemCouponCode {
            self.applyPromoCodeView?.view.removeFromSuperview()
            self.applyPromoCodeView?.removeFromParent()
            self.applyPromoCodeView = nil
            self.couponCodeSuccessMessageLbl.text = String(format: Strings.coupon_code_success_msg, arguments: [(systemCouponCode.couponCode)])
            self.couponCodeSuccessMessageDesc.text = systemCouponCode.offerName
            self.couponCodeSuccessMessageView.isHidden = true
            self.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.coupon_code_applied, arguments: [systemCouponCode.couponCode]))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                self.couponCodeSuccessMessageView.isHidden = true
            })
        }else{
            self.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
        }
    }
    
    
    func updateDataAfterFetchingRideIncentive() {
         self.handleRideAssuredIncentiveViews()
    }
}

extension MyOffersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offerViewModel?.categoryList.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferFilterViewCollectionViewCell", for: indexPath) as! OfferFilterViewCollectionViewCell
        filterCell.categoryLabel.text = offerViewModel?.categoryList[indexPath.row]
        if  offerViewModel?.selectedFilterString == offerViewModel?.categoryList[indexPath.row] {
            filterCell.backGroundView.backgroundColor = UIColor(netHex: 0x00B557)
            filterCell.categoryLabel.textColor = .white
        } else{
            filterCell.backGroundView.backgroundColor = .white
            filterCell.categoryLabel.textColor = UIColor(netHex: 0x010101).withAlphaComponent(0.5)
        }
        return filterCell
    }
}

extension MyOffersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        offerViewModel?.selectedFilterString = offerViewModel?.categoryList[indexPath.row] ?? Strings.all
        _ = offerViewModel?.getFilterData()
        filterCollectionView.reloadData()
        myOffersTableView.reloadData()
    }
}
