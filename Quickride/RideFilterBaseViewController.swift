//
//  RideFilterBaseViewController.swift
//  Quickride
//
//  Created by Halesh K on 18/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol MatchingListOptimizationReceiver: class {
    func receivedMatchingList(matchedUsers : [MatchedUser],status: [String : String])
    func clearSortAndFilters()
}

class RideFilterBaseViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var closeButton: CustomUIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var clearFilterButton: UIButton!
    
    //MARK: Variables
    private var matchedUsers = [MatchedUser]()
    var rideType: String?
    var rideId: Double?
    private weak var delegate: MatchingListOptimizationReceiver?
    var status = [String: String]()
    private var swipeRecognizerLeft: UISwipeGestureRecognizer!
    private var swipeRecognizerRight: UISwipeGestureRecognizer!
    private var rideFilterViewController: RideFilterViewController?
    private var rideSortByViewController: RideSortByViewController?

    func initializeRideFilterBaseViewController(matchedUsers: [MatchedUser], rideId: Double,  rideType: String, delegate: MatchingListOptimizationReceiver){
        self.matchedUsers = matchedUsers
        self.rideType = rideType
        self.rideId = rideId
        self.delegate = delegate
    }
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizerLeft = UISwipeGestureRecognizer(target: self,action: #selector(PaymentViewController.handleSwipes(_:)))
        swipeRecognizerRight = UISwipeGestureRecognizer(target: self,action: #selector(PaymentViewController.handleSwipes(_:)))
        
        swipeRecognizerLeft.direction = .left
        swipeRecognizerRight.direction = .right
        swipeRecognizerLeft.numberOfTouchesRequired = 1
        swipeRecognizerRight.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeRecognizerLeft)
        view.addGestureRecognizer(swipeRecognizerRight)
        prepareSegmentViewController()
        moveToSelectedView(index: 0)
        showClearFilterButtonIfFilterApplied()
    }
    override func viewWillAppear(_ animated: Bool) {
      self.navigationController?.isNavigationBarHidden = true
    }
    
    private func prepareSegmentViewController(){
        segmentControl.backgroundColor = .clear
        segmentControl.tintColor = .clear
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)

        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .selected)
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.backgroundColor = UIColor(netHex: 0x007AFF)
        view.addSubview(bottomBarView)
        bottomBarView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
        bottomBarView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bottomBarView.leftAnchor.constraint(equalTo: segmentControl.leftAnchor).isActive = true
        bottomBarView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments)).isActive = true
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.view.endEditing(false)
        moveToSelectedView(index: segmentControl.selectedSegmentIndex)
    }
    
    private func moveToSelectedView(index : Int){
        AppDelegate.getAppDelegate().log.debug("moveToSelectedView()")
        UIView.animate(withDuration: 0.2) {
            self.bottomBarView.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
        }
        if index == 0{
            sortView.isHidden = false
            filterView.isHidden = true
        }else{
            sortView.isHidden = true
            filterView.isHidden = false
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer){
      AppDelegate.getAppDelegate().log.debug("handleSwipes()")
        if sender.direction == .left{
          AppDelegate.getAppDelegate().log.debug("Swiped Left")
          if segmentControl.selectedSegmentIndex == 1{
            filterView.isHidden = false
            sortView.isHidden = true
          }else{
            moveToSelectedView(index: 1)
            }
        }else if sender.direction == .right{
          AppDelegate.getAppDelegate().log.debug("Swiped Right")
          if segmentControl.selectedSegmentIndex == 0{
            sortView.isHidden = false
            filterView.isHidden = true
          }else{
            moveToSelectedView(index: 0)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        AppDelegate.getAppDelegate().log.debug("prepareForSegue()")
        if segue.identifier == "RideFilterViewController"{
            rideFilterViewController = segue.destination as? RideFilterViewController
            rideFilterViewController?.topViewController = self
        }else if segue.identifier == "RideSortByViewController"{
            rideSortByViewController = segue.destination as? RideSortByViewController
            rideSortByViewController?.topViewController = self
        }
    }
    
    func showClearFilterButtonIfFilterApplied(){
        let count = DynamicFiltersCache.getInstance().getApplyedFiltersToCurrentRide(filterStatus: status)
        let sortStatus = status[DynamicFiltersCache.SORT_CRITERIA]
        if count > 0 || sortStatus != nil{
            clearFilterButton.isHidden = false
        }else{
            clearFilterButton.isHidden = true
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        guard let ridetype = rideType, let rideid = rideId else { return }
        DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: rideid, dynamicStatus: status,rideType: ridetype)
        let filteredList = DynamicFiltersCache.getInstance().sortAndFilterMatchingListForRide(matchedUsers: matchedUsers, rideType: ridetype, rideId: rideid)
        delegate?.receivedMatchingList(matchedUsers: filteredList, status: status)
     self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        status.removeAll()
        DynamicFiltersCache.getInstance().updateDynamicFiltersStatus(rideId: rideId!, dynamicStatus: status, rideType: rideType ?? "")
        delegate?.clearSortAndFilters()
       self.navigationController?.popViewController(animated: false)
    }
}
