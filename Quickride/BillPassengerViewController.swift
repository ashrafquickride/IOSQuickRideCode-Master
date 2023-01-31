//
//  BillPassengerViewController.swift
//  Quickride
//
//

import UIKit
import ObjectMapper

class BillPassengerViewController: BaseBillPassengerViewController {
    
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var labelRidePoints: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if rideLevelInsuranceViewController != nil{
            rideLevelInsuranceViewController!.displayView()
        }
    }
    override func setDataToView(){
        super.setDataToView()
        let bill = tripReport?.bills?.last
        self.lblDate.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: bill?.startTime, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_MMM_yyyy)
        callRideSharingCommunityContributionGettingTask()
        separatorView1.addDashedView(color: Colors.dottedLineGreenColor.cgColor)
        separatorView2.addDashedView(color: Colors.dottedLineGreenColor.cgColor)
        separatorView3.addDashedView(color: Colors.dottedLineGrayColor.cgColor)
    }
    
    override func handleSetDataBasedOnRole(){
        let bill = tripReport?.bills?.last
        
        if isFromRider == true{
            self.paidViewLayout.isHidden = false
            self.tripInsuranceView.isHidden = true
            self.tripInsuranceViewHeightConstraint.constant = 0
            self.paidLayoutViewHeightConstraint.constant = 150
            self.serviceFeeLblForRider.text = StringUtils.getPointsInDecimal(points: bill!.serviceFee!)
            self.gstLblForRider.text = StringUtils.getPointsInDecimal(points: bill!.tax!)
            self.insuranceClaimedView.isHidden = true
            self.insuranceClaimedViewHeightConstraint.constant = 0
            self.insuranceClaimedViewTopSpaceConstraint.constant = 0
            if isRiderBillFromTransaction{
                self.earnedPoints.text = StringUtils.getStringFromDouble(decimalNumber: bill!.netAmountPaid!)
                self.netAmount.text = StringUtils.getPointsInDecimal(points: bill!.amount!)
            }
            else{
                self.earnedPoints.text = StringUtils.getStringFromDouble(decimalNumber: tripReport!.totalEarnings!)
                self.netAmount.text = StringUtils.getPointsInDecimal(points: tripReport!.netEarnings!)
            }
            self.labelRidePoints.text = self.earnedPoints.text! + " Fuel Points"
            FaceBookEventsLoggingUtils.logAmountCreditsEvent(contentData: "Spent Credits", contentId: "", contentType: "", totalValue: Double(self.earnedPoints.text!)!)
        }else
        {
            if bill!.insurancePoints != 0{
                self.tripInsuranceView.isHidden = false
                self.tripInsuranceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BillPassengerViewController.tripInsuranceViewTapped(_:))))
                self.insurancePointsLbl.text = StringUtils.getPointsInDecimal(points: bill!.insurancePoints)
                self.tripInsuranceViewHeightConstraint.constant = 25
                self.paidLayoutViewHeightConstraint.constant = 180
            }else{
                self.tripInsuranceView.isHidden = true
                self.tripInsuranceViewHeightConstraint.constant = 0
                self.paidLayoutViewHeightConstraint.constant = 150
            }
            self.paidViewLayout.isHidden = false
            self.paidAmount.text = StringUtils.getStringFromDouble(decimalNumber: bill!.netAmountPaid! + bill!.insurancePoints)
            self.riderSharePoint.text = StringUtils.getPointsInDecimal(points: bill!.amount!)
            self.serviceFeeLblForPassenger.text = StringUtils.getPointsInDecimal(points: bill!.serviceFee!)
            self.gstLblForPassenger.text = StringUtils.getPointsInDecimal(points: bill!.tax!)
            self.labelRidePoints.text = self.paidAmount.text! + " Fuel Points"
            FaceBookEventsLoggingUtils.logAmountDebitEvent(amount: bill!.amount!, currency: "INR")
            handleVisibilityOfInsuranceClaimedView(bill: bill)
        }
    }
    
    @objc func tripInsuranceViewTapped(_ gesture : UITapGestureRecognizer){
        if let bill = tripReport?.bills?.last{
            let rideLevelInsuranceViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideLevelInsuranceViewController") as! RideLevelInsuranceViewController
            rideLevelInsuranceViewController.initializeDataBeforePresenting(policyUrl: bill.insurancePolicyUrl, passengerRideId: currentUserRideId, riderId: bill.billByUserId, rideId : self.rideId, isInsuranceClaimed: bill.insuranceClaimed, insurancePoints: nil,dismissHandler: {
                self.rideLevelInsuranceViewController = nil
                self.getPassengerBillAndUpdateView()
            })
            self.rideLevelInsuranceViewController = rideLevelInsuranceViewController
            self.navigationController?.view.addSubview(rideLevelInsuranceViewController.view)
            self.navigationController?.addChild(rideLevelInsuranceViewController)
        }
    }
    
    func callRideSharingCommunityContributionGettingTask()
    {
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if userProfile?.gender == User.USER_GENDER_FEMALE{
            self.co2Image.image = UIImage(named: "icon_leaf_female")
        }
        else{
            self.co2Image.image = UIImage(named: "icon_leaf_male")
        }
        if rideType == Ride.RIDER_RIDE{
            RideManagementUtils.getRideContributionForRide(rideId: StringUtils.getStringFromDouble(decimalNumber : currentUserRideId), viewController: self) { (rideContribution, error) in
                if rideContribution != nil{
                    self.rideContribution = rideContribution
                    self.rideContribution?.userId = Double(QRSessionManager.getInstance()!.getUserId())
                    self.viewRideContribution.isHidden = false
                    self.viewRideContributionHeightConstraint.constant = 70
                    self.viewRideContribution.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BillPassengerViewController.viewRideContributionTapped(_:))))
                    self.labelCo2Reduced.text = String(format: Strings.co2Reduced,arguments:  [String(self.rideContribution!.co2Reduced!.roundToPlaces(places: 1))])
                }
                else{
                    self.viewRideContribution.isHidden = true
                    self.viewRideContributionHeightConstraint.constant = 0
                }
            }
        }
        else{
            var passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: currentUserRideId!)
            if(passengerRide == nil)
            {
                passengerRide = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: currentUserRideId!)
            }
            if passengerRide != nil && passengerRide!.riderId != 0 && Int(passengerRide!.overLappingDistance) > 0
            {
                var co2 = RideContribution.co2ReducedForDistance(distance: passengerRide!.overLappingDistance)
                let fuel = RideContribution.petrolSavedForDistance(distance: passengerRide!.overLappingDistance)
                self.rideContribution = RideContribution()
                rideContribution!.co2Reduced = co2
                rideContribution!.petrolSaved = fuel
                rideContribution?.userId = Double(QRSessionManager.getInstance()!.getUserId())
                self.viewRideContribution.isHidden = false
                self.viewRideContributionHeightConstraint.constant = 70
                self.labelCo2Reduced.text = String(format: Strings.co2Reduced,arguments: [String(co2.roundToPlaces(places: 1))])
                self.viewRideContribution.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BillPassengerViewController.viewRideContributionTapped(_:))))
            }
            else{
                self.viewRideContribution.isHidden = true
                self.viewRideContributionHeightConstraint.constant = 0
            }
        }
        
    }
    
    @objc func viewRideContributionTapped(_ gesture: UITapGestureRecognizer){
        let rideContributionViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideContributionViewController") as! RideContributionViewController
        rideContributionViewController.initializeDataBeforePresenting(rideContribution: rideContribution!, vehiclesRemoved: "1",rideType: rideType)
        self.navigationController?.view.addSubview(rideContributionViewController.view!)
        self.navigationController?.addChild(rideContributionViewController)
    }
    
 
}
