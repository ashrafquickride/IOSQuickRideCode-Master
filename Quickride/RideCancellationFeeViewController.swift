//
//  RideCancellationFeeViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideCancellationFeeViewController: UIViewController,UICollectionViewDataSource{
    
    //MARK: Outlets
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var dontCancel: UIButton!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelInfoLabel: UILabel!
    @IBOutlet weak var penaltyImage: UIImageView!
    @IBOutlet weak var freeCancellationRidesCollectionView: UICollectionView!
    @IBOutlet weak var freeCancellationtCollectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var waiveOffView: UIView!
    @IBOutlet weak var waiveOffButton: UIButton!
    @IBOutlet weak var waiveOffViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables?
    var rideCancellationFeeViewModel = RideCancellationFeeViewModel()
    
    
    func initializeCancelRideVIew(ride: Ride?, rideType: String,isFromCancelRide: Bool,compensation: [Compensation], reason: String, riderRideId : Double?,unjoiningUserRideId : Double?,unjoiningUserId : Double?, unjoiningUserRideType : String?,completionHandler : rideCancellationCompletionHandler?){
        rideCancellationFeeViewModel.initialiseData(ride: ride, rideType: rideType, isFromCancelRide: isFromCancelRide, compensation: compensation, reason: reason, riderRideId: riderRideId, unjoiningUserRideId: unjoiningUserRideId, unjoiningUserId: unjoiningUserId, unjoiningUserRideType: unjoiningUserRideType, completionHandler: completionHandler)
    }
    
    //MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        rideCancellationFeeViewModel.assignOppositeUserRideType()
        rideCancellationFeeViewModel.preapreApplicableFeeData()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        waiveOffView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(waivedOffViewTapped(_:))))
        waiveOffView.isHidden = true
        waiveOffViewHeightConstraint.constant = 0
        setUpUI()
        cancleBtn.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        cancleBtn.layer.shadowOffset = CGSize(width: 0,height: 1)
        cancleBtn.layer.shadowRadius = 3
        cancleBtn.layer.shadowOpacity = 1
        dontCancel.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        dontCancel.layer.shadowOffset = CGSize(width: 0,height: 1)
        dontCancel.layer.shadowRadius = 3
        dontCancel.layer.shadowOpacity = 1
        if rideCancellationFeeViewModel.isFromCancelRide{
            cancleBtn.setTitle(Strings.cancel_ride.uppercased(), for: .normal)
            dontCancel.setTitle(Strings.dont_cancel, for: .normal)
        }else{
            cancleBtn.setTitle(Strings.unjoin_ride, for: .normal)
            dontCancel.setTitle(Strings.dont_unjoin, for: .normal)
        }
        if rideCancellationFeeViewModel.compensations[0].totalFreeCancellations*66 > Int(self.view.frame.width - 70){
            freeCancellationtCollectionViewWidthConstraint.constant = self.view.frame.width - 70
        }else{
            freeCancellationtCollectionViewWidthConstraint.constant = CGFloat(rideCancellationFeeViewModel.compensations[0].totalFreeCancellations*66)
        }
    }
    
    private func setUpUI(){
        if StringUtils.getStringFromDouble(decimalNumber: rideCancellationFeeViewModel.compensations[0].payingUser) == UserDataCache.getInstance()?.userId{
            if rideCancellationFeeViewModel.noOfSeatCancellation < rideCancellationFeeViewModel.noOfFreeCancellation{
                titleLabel.text = String(format: Strings.penalty_free_cancel, arguments: [String(rideCancellationFeeViewModel.noOfSeatCancellation)])
                let  validate = NSDate().addDays(daysToAdd: rideCancellationFeeViewModel.validityOfFreeCancellations)
                let lastDate = DateUtils.getDateStringFromNSDate(date: validate, dateFormat: DateUtils.DATE_FORMAT_dd_MMM)
                cancelInfoLabel.text = String(format: Strings.penalty_free_cancel_info, arguments: [String(rideCancellationFeeViewModel.noOfFreeCancellation - 1), lastDate ?? ""])
                freeCancellationRidesCollectionView.dataSource = self
                freeCancellationRidesCollectionView.reloadData()
                freeCancellationRidesCollectionView.isHidden = false
            }else if rideCancellationFeeViewModel.noOfSeatCancellation  == rideCancellationFeeViewModel.noOfFreeCancellation{
                titleLabel.text = String(format: Strings.penalty_free_cancel, arguments: [String(rideCancellationFeeViewModel.noOfSeatCancellation)])
                cancelInfoLabel.text = Strings.no_free_cancellation
                freeCancellationRidesCollectionView.dataSource = self
                freeCancellationRidesCollectionView.reloadData()
                freeCancellationRidesCollectionView.isHidden = false
            }else if rideCancellationFeeViewModel.noOfFreeCancellation != 0 && rideCancellationFeeViewModel.noOfSeatCancellation > rideCancellationFeeViewModel.noOfFreeCancellation{
                titleLabel.text = String(format: Strings.penalty_free_cancel_and_amount, arguments: [String(rideCancellationFeeViewModel.noOfSeatCancellation),String(rideCancellationFeeViewModel.cancellationAmount)])
                cancelInfoLabel.text = String(format: Strings.penalty_free_cancel_and_amount_info, arguments: [rideCancellationFeeViewModel.oppositeUserRideType ])
                freeCancellationRidesCollectionView.dataSource = self
                freeCancellationRidesCollectionView.reloadData()
                freeCancellationRidesCollectionView.isHidden = false
            }else if rideCancellationFeeViewModel.noOfFreeCancellation == 0{
                titleLabel.text = String(format: Strings.penalty_amount, arguments: [String(rideCancellationFeeViewModel.cancellationAmount)])
                cancelInfoLabel.text = String(format: Strings.penalty_amount_info, arguments: [rideCancellationFeeViewModel.oppositeUserRideType])
                penaltyImage.isHidden = false
                penaltyImage.image = UIImage(named: "cancel_ride_amount")
                freeCancellationRidesCollectionView.isHidden = true
            }
        }else{
            if rideCancellationFeeViewModel.noOfSeatCancellation < rideCancellationFeeViewModel.noOfFreeCancellation{
                titleLabel.text = String(format: Strings.penalty_on_oppsite_user, arguments: [rideCancellationFeeViewModel.oppositeUserRideType])
                cancelInfoLabel.text = String(format: Strings.penalty_on_opposite, arguments: [rideCancellationFeeViewModel.oppositeUserRideType])
            }else{
                titleLabel.text = String(format: Strings.penalty_on_oppsite_user, arguments: [rideCancellationFeeViewModel.oppositeUserRideType])
                cancelInfoLabel.text = String(format: Strings.penalty_amount_on_opposite_info, arguments: [String(rideCancellationFeeViewModel.cancellationAmount),rideCancellationFeeViewModel.oppositeUserRideType])
            }
            freeCancellationRidesCollectionView.isHidden = true
            penaltyImage.isHidden = false
            penaltyImage.image = UIImage(named: "penality_on_rideTaker")
            waiveOffView.isHidden = false
            waiveOffViewHeightConstraint.constant = 40
        }
    }
    
    //MARK: collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rideCancellationFeeViewModel.compensations[0].totalFreeCancellations
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FreeCancellationCollectionViewCell", for: indexPath) as! FreeCancellationCollectionViewCell
        if indexPath.row < rideCancellationFeeViewModel.noOfFreeCancellation - 1{
            cell.freeCancellation.image = UIImage(named: "free_cancel")
        }else{
            cell.freeCancellation.image = UIImage(named: "free_cancel_not_available")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 20)/3, height: collectionView.bounds.height)
    }
    
    //MARK: Actions
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    @objc func waivedOffViewTapped(_ gesture :UITapGestureRecognizer){
        if rideCancellationFeeViewModel.isUserSelectWaiveOff{
            rideCancellationFeeViewModel.isUserSelectWaiveOff = false
            waiveOffButton.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
        }else{
            rideCancellationFeeViewModel.isUserSelectWaiveOff = true
            waiveOffButton.setImage(UIImage(named: "insurance_tick"), for: .normal)
        }
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
    
    @IBAction func cancellationPolicyTapped(_ sender: Any){
        AppDelegate.getAppDelegate().log.debug("cancellation policy)")
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.cancellationPolicy_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    @IBAction func cancelRideTapped(_ sender: Any){
        if rideCancellationFeeViewModel.isFromCancelRide{
            rideCancellationFeeViewModel.cancelRide(viewController: self, delegate: self)
        }else{
            rideCancellationFeeViewModel.unJoinRide(viewController: self, delegate: self)
        }
    }
    
    @IBAction func dontCancelButtonTapped(_ sender: Any){
        closeView()
    }
}

extension RideCancellationFeeViewController: RideCancellationFeeViewModelDelegate{
    func handleSuccessResponse(){
        rideCancellationFeeViewModel.completionHandler?()
        closeView()
    }
}

