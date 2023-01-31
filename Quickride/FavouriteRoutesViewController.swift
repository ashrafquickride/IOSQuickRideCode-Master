//
//  ViewController.swift
//  Quickride
//
//  Created by Admin on 07/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FavouriteRoutesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RouteSelectionDelegate {
    
    
    @IBOutlet weak var routesTableView: UITableView!
    
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noRoutesView: UIView!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var menuButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuButtonTrailingSpaceConstraint: NSLayoutConstraint!
    
    
    
    private var routes = [UserPreferredRoute]()
    private var isFromFavTab = false
    private var routeSelectionDelegate : RouteSelectionDelegate?
    private var ride : Ride?
    
    func initializeDataBeforePresenting(ride : Ride?,routeSelectionDelegate : RouteSelectionDelegate?){
        self.ride = ride
        self.routeSelectionDelegate = routeSelectionDelegate
    }
    
    fileprivate func reloadRoutesTableView() {
        self.routes.removeAll()
        let routes = UserDataCache.getInstance()!.getUserPreferredRoutes()
        for preferredRoute in routes {
            if preferredRoute.routeName != nil, preferredRoute.fromLocation != nil, preferredRoute.toLocation != nil {
                self.routes.append(preferredRoute)
            }
        }
        
        if routes.isEmpty{
            routesTableView.isHidden = true
            noRoutesView.isHidden = false
        }else{
            routesTableView.isHidden = false
            noRoutesView.isHidden = true
            routesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         definesPresentationContext = true
        if routeSelectionDelegate == nil{
            navBar.isHidden = true
            navBarHeightConstraint.constant = 0
        }else{
            navBar.isHidden = false
            navBarHeightConstraint.constant = 50
        }
        reloadRoutesTableView()
        
   }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListLocationTableViewCell)!
        if indexPath.row >= routes.count{
            return cell
        }
        let customRoute = routes[indexPath.row]
        cell.iboTitleLabel.text = customRoute.routeName
        cell.iboIcon.image = UIImage(named: "ic_pin_drop")
        cell.iboSubTitleLabel.text = customRoute.fromLocation!.prefix(25) + " " + Strings.to + " " + customRoute.toLocation!.prefix(25)
        cell.menuBtn.tag = indexPath.row
        if routeSelectionDelegate == nil{
            cell.menuBtn.isHidden = false
            cell.menuBtnWidthConstraint.constant = 40
            cell.menuBtnTrailingSpaceConstraint.constant = 15
        }else{
            cell.menuBtn.isHidden = true
            cell.menuBtnWidthConstraint.constant = 0
            cell.menuBtnTrailingSpaceConstraint.constant = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let customRoute = routes[indexPath.row]
        
        if routeSelectionDelegate != nil{
            self.navigationController?.popViewController(animated: false)
            self.routeSelectionDelegate?.recieveSelectedPreferredRoute(ride: ride, preferredRoute: customRoute)
        }else{
            moveToRouteSelection(preferredRoute: customRoute)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    @IBAction func menuButtonClicked(_ sender: UIButton) {
        
        let preferredRoute = routes[sender.tag]
        displayPopUpMenu(preferredRoute: preferredRoute, index: sender.tag)
    }
    
    private func displayPopUpMenu(preferredRoute : UserPreferredRoute,index : Int)
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: Strings.edit_route, style: .default) { [unowned self](action) in
            self.moveToRouteSelection(preferredRoute: preferredRoute)
        }
        let deleteAction = UIAlertAction(title: Strings.delete, style: .destructive) { [unowned self](action) in
            self.deleteUserPreferredRoute(preferredRoute: preferredRoute, index: index)
        }
        let removeUIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(removeUIAlertAction)
        ViewControllerUtils.getCenterViewController().present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    
    private func moveToRouteSelection(preferredRoute : UserPreferredRoute){
        guard let userId = QRSessionManager.getInstance()?.getUserId(),let fromLatitude = preferredRoute.fromLatitude,let fromLongitude = preferredRoute.fromLongitude,let fromLocation = preferredRoute.fromLocation,let toLocation = preferredRoute.toLocation,let toLatitude = preferredRoute.toLatitude,let toLongitude = preferredRoute.toLongitude else{
            return
        }
        ride = Ride(userId: userId.toDouble(), rideType: "", startAddress: fromLocation, startLatitude: fromLatitude, startLongitude: fromLongitude, endAddress: toLocation, endLatitude: toLatitude, endLongitude: toLongitude, startTime: 0)
        guard let rideRoute = MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId) else { return }
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: ride!, rideRoute: rideRoute, routeSelectionDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: routeSelectionViewController, animated: false)
    }
    
    private func deleteUserPreferredRoute(preferredRoute : UserPreferredRoute,index : Int){
        QuickRideProgressSpinner.startSpinner()
        RoutePathServiceClient.deleteUserPreferredRoute(id: preferredRoute.id!, userId: preferredRoute.userId!, viewController: self) {[weak self] (responseObject, error) in
            
            guard let self = `self` else{
                return
            }
            
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                UserDataCache.getInstance()?.deleteUserPreferredRoute(userPreferredRoute: preferredRoute)
                self.reloadRoutesTableView()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self,handler: nil)
            }
        }
    }
    
    func receiveSelectedRoute(ride: Ride?, route: RideRoute){
        reloadRoutesTableView()
    }
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        routes = routes.filter { $0.routeName != preferredRoute.routeName}
        routes.append(preferredRoute)
        routesTableView.reloadData()
        routeSelectionDelegate?.recieveSelectedPreferredRoute(ride: ride, preferredRoute: preferredRoute)
    }
    
    private func handlesVisibilityOfRoutesView(){
        if self.routes.isEmpty{
            self.routesTableView.isHidden = true
            self.noRoutesView.isHidden = false
        }else{
            self.routesTableView.isHidden = false
            self.noRoutesView.isHidden = true
            self.routesTableView.reloadData()
        }
    }
    
    
    
}
