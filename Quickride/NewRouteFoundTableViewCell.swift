//
//  NewRouteFoundTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NewRouteFoundTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var setAsDefaultRoute: UIButton!
    
    //MARK: Properties
    private var newRouteFoundTableViewCellModel = NewRouteFoundTableViewCellModel()
    private var handler: clickActionCompletionHandler?
    
    //MARK: Initialiser
    func initialiseData(newRoute: RideRoute?, riderRide: RiderRide?, handler: @escaping clickActionCompletionHandler) {
        newRouteFoundTableViewCellModel.initialiseData(newRoute: newRoute, riderRide: riderRide)
        self.handler = handler
        setupUI()
    }
    
    private func setupUI() {
        setAsDefaultRoute.dropShadow(color: .lightGray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: setAsDefaultRoute.frame.height / 2, scale: true, cornerRadius: setAsDefaultRoute.frame.height / 2)
        ViewCustomizationUtils.addBorderToView(view: setAsDefaultRoute, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        
    }
    
    //MARK: Actions
    @IBAction func setAsDefaultRouteTapped(_ sender: UIButton) {
        guard let riderRide = newRouteFoundTableViewCellModel.riderRide, let newRoute = newRouteFoundTableViewCellModel.newRoute  else {
            self.handler?(Strings.failed)
            return
        }
        let saveRouteUtilsInstance = SaveRouteViewUtils()
        if let preferredRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: riderRide.startLatitude, startLongitude: riderRide.startLongitude, endLatitude: riderRide.endLatitude ?? 0, endLongitude: riderRide.endLongitude ?? 0){
            
            MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: false, message1: Strings.do_you_want_update_preferred_route, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, viewController: self.parentViewController) { (action) in
                if Strings.yes_caps == action {
                    QuickRideProgressSpinner.startSpinner()
                    saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: riderRide.rideType)).CustomRoute.NewRouteFoundView", ride: riderRide, preferredRoute: preferredRoute, viaPointString: newRoute.waypoints, routeName: nil) { (route, preferredRoute, responseError, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if route != nil{
                            UIApplication.shared.keyWindow?.makeToast( "Route Updated")
                            self.handler?(Strings.success)
                        }else{
                            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                            self.handler?(Strings.failed)
                        }
                    }
                }
            }
        }else{
            let saveCustomizedRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SaveCustomizedRouteViewController") as! SaveCustomizedRouteViewController
            let suggestedRouteName = saveRouteUtilsInstance.getSuggestingNameForRoute(ride: riderRide, wayPoints: nil)
            saveCustomizedRouteViewController.initializeDataBeforePresenting(suggestedRouteName: suggestedRouteName, handler: { [unowned self] (routeName) in
                QuickRideProgressSpinner.startSpinner()
                saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: riderRide.rideType)).CustomRoute.NewRouteFoundView", ride: riderRide, preferredRoute: nil, viaPointString: newRoute.waypoints, routeName: routeName) { (route, preferredRoute, responseError, error)  in
                    QuickRideProgressSpinner.stopSpinner()
                    if route != nil {
                        if preferredRoute != nil {
                            UIApplication.shared.keyWindow?.makeToast( "Route Updated")
                            self.handler?(Strings.success)
                        } else {
                            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                            self.handler?(Strings.failed)
                        }
                    } else {
                        self.handler?(Strings.failed)
                    }
                }
            })
            self.parentViewController?.view.addSubview(saveCustomizedRouteViewController.view)
            self.parentViewController?.addChild(saveCustomizedRouteViewController)
            
        }
    }
    
    @IBAction func checkRouteTapped(_ sender: UIButton) {
        if let riderRide = newRouteFoundTableViewCellModel.riderRide, let newRoute = newRouteFoundTableViewCellModel.newRoute {
            let travelledRouteSavingViewController = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "TravelledRouteSavingViewController") as! TravelledRouteSavingViewController
            travelledRouteSavingViewController.initialiseData(riderRide: riderRide, newRoute: newRoute) { (action) in
                if action == Strings.success {
                    self.handler?(Strings.success)
                } else {
                    self.handler?(Strings.failed)
                }
            }
            ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: travelledRouteSavingViewController, animated: false)
        } else {
            self.handler?(Strings.failed)
        }
    }
}
