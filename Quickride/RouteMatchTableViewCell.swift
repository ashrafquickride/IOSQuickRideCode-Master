//
//  RouteMatchTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 17/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol RouteMatchTableViewCellDelegate: class {
    func selectedRouteMatchPercentage(precentage: String)
    func routeMatchViaPoint(routeMatchPoint: String?)
}

class RouteMatchTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var routeMatchPercentageLabel: UILabel!
    @IBOutlet weak var viaStartPointButton: UIButton!
    @IBOutlet weak var viaEndPointButton: UIButton!
    @IBOutlet weak var routeMatchViaPointView: UIView!
    @IBOutlet weak var routeMatchViaPointViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Property
    weak var delegate: RouteMatchTableViewCellDelegate?
    private var percentage: String?
    private var routeMatchPoint: String?
    private var view: UIView?
    
    func iniatializeRouteMatch(percentage: String?,routeMatchPoint: String?,rideType: String?,view: UIView){
        self.routeMatchPoint = routeMatchPoint
        self.view = view
        if let routeMatchPer = percentage{
            routeMatchPercentageLabel.text = routeMatchPer
        }else{
            guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()else { return }
            if rideType == Ride.RIDER_RIDE{
                routeMatchPercentageLabel.text = String(ridePreferences.rideMatchPercentageAsRider)
            }else{
                routeMatchPercentageLabel.text = String(ridePreferences.rideMatchPercentageAsPassenger)
            }
        }
        if rideType == Ride.RIDER_RIDE{
            routeMatchViaPointView.isHidden = true
            routeMatchViaPointViewHeightConstraint.constant = 0
        }else{
            routeMatchViaPointView.isHidden = false
            routeMatchViaPointViewHeightConstraint.constant = 35
            if routeMatchPoint == DynamicFiltersCache.VIA_START_POINT{
                viaStartPointTapped()
            }else if routeMatchPoint == DynamicFiltersCache.VIA_END_POINT{
                viaEndPointTapped()
            }else{
                routeMatchPointsNotSelected()
            }
        }
    }
    
    private func viaStartPointTapped(){
        viaStartPointButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaStartPointButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        viaEndPointButton.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaEndPointButton, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
    }
    
    private func viaEndPointTapped(){
        viaEndPointButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaEndPointButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        viaStartPointButton.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaStartPointButton, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
    }
    
    private func routeMatchPointsNotSelected(){
        viaStartPointButton.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaStartPointButton, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
        viaEndPointButton.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .normal)
        ViewCustomizationUtils.addBorderToView(view: viaEndPointButton, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
    }
    
    //MARK: Actions
    @IBAction func dropDownButtonTapped(_ sender: UIButton) {
        let routeMatchPercentageAndTimeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectValueFromSliderViewController") as! SelectValueFromSliderViewController
        routeMatchPercentageAndTimeSelectionViewController.initializeViewWithData(title: Strings.route_match_per, firstValue: 0,lastValue: 100, minValue: 5, currentValue: Int(routeMatchPercentageLabel.text ?? "") ?? 0) { (value) in
            if value < 5 {
                UIApplication.shared.keyWindow?.makeToast(String(format: Strings.min_range_alert, arguments: ["5"]),duration: 2.0, point: CGPoint(x: (self.view?.frame.size.width)!/2, y: (self.view?.frame.size.height)!-300), title: nil, image: nil, completion: nil)
            }else{
                self.routeMatchPercentageLabel.text = "\(value)"
                self.delegate?.selectedRouteMatchPercentage(precentage: String(value))
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: routeMatchPercentageAndTimeSelectionViewController)
    }
    
    @IBAction func viaStartPointTapped(_ sender: UIButton) {
        if routeMatchPoint == DynamicFiltersCache.VIA_START_POINT{
            routeMatchPointsNotSelected()
            delegate?.routeMatchViaPoint(routeMatchPoint: DynamicFiltersCache.PREFERRED_ALL)
            routeMatchPoint = DynamicFiltersCache.PREFERRED_ALL
        }else{
            viaStartPointTapped()
            delegate?.routeMatchViaPoint(routeMatchPoint: DynamicFiltersCache.VIA_START_POINT)
            routeMatchPoint = DynamicFiltersCache.VIA_START_POINT
        }
    }
    
    @IBAction func viaEndPointTapped(_ sender: UIButton) {
        if routeMatchPoint == DynamicFiltersCache.VIA_END_POINT{
            routeMatchPointsNotSelected()
            delegate?.routeMatchViaPoint(routeMatchPoint: DynamicFiltersCache.PREFERRED_ALL)
            routeMatchPoint = DynamicFiltersCache.PREFERRED_ALL
        }else{
            viaEndPointTapped()
            delegate?.routeMatchViaPoint(routeMatchPoint: DynamicFiltersCache.VIA_END_POINT)
            routeMatchPoint = DynamicFiltersCache.VIA_END_POINT
        }
    }
}

