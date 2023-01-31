//
//  MyFavouritesViewController.swift
//  Quickride
//
//  Created by KNM Rao on 27/08/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit

class MyFavouritesViewController: UIViewController{
  
  @IBOutlet weak var locationsView: UIView!
 
  @IBOutlet weak var ridePartnersView: UIView!
    
  @IBOutlet weak var routesView: UIView!
    
  @IBOutlet weak var favouritesSegmentedControl: UISegmentedControl!
  
   var segmentControllerValue : Int?
    
    func initializeView(segmentControllerValue : Int){
        self.segmentControllerValue = segmentControllerValue
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    handleBrandingChanges()
    
    addSwipeGestures()
    if segmentControllerValue != nil{
       favouritesSegmentedControl.selectedSegmentIndex = segmentControllerValue!
    }else{
        favouritesSegmentedControl.selectedSegmentIndex = 0
    }
    
     segmentedControllerValueChanged(favouritesSegmentedControl)
     self.automaticallyAdjustsScrollViewInsets = false
  }
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
  }
  
    func handleBrandingChanges()
    {
        favouritesSegmentedControl.tintColor = Colors.tabViewTintColor
    }
  
  @IBAction func segmentedControllerValueChanged(_ sender: UISegmentedControl) {
    if favouritesSegmentedControl.selectedSegmentIndex == 0{
      locationsView.isHidden = false
      ridePartnersView.isHidden = true
      routesView.isHidden = true
      
    }else if favouritesSegmentedControl.selectedSegmentIndex == 1{
      locationsView.isHidden = true
      ridePartnersView.isHidden = false
      routesView.isHidden = true
    }else{
        locationsView.isHidden = true
        ridePartnersView.isHidden = true
        routesView.isHidden = false
    }
    
  }
  
  func addSwipeGestures(){
    AppDelegate.getAppDelegate().log.debug("addSwipeGestures()")
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(MyFavouritesViewController.handleSwipes(_:)))
    leftSwipeGesture.direction = .left
    self.view.addGestureRecognizer(leftSwipeGesture)
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(MyFavouritesViewController.handleSwipes(_:)))
    rightSwipeGesture.direction = .right
    self.view.addGestureRecognizer(rightSwipeGesture)
  }
    @objc func handleSwipes(_ gesture:UISwipeGestureRecognizer){
    AppDelegate.getAppDelegate().log.debug("handleSwipes()")
    if gesture.direction == .left{
      if favouritesSegmentedControl.selectedSegmentIndex == 2{
        return
      }
      favouritesSegmentedControl.selectedSegmentIndex += 1
    }else if gesture.direction == .right{
      if favouritesSegmentedControl.selectedSegmentIndex == 0{
        return
      }
      favouritesSegmentedControl.selectedSegmentIndex -= 1
    }
    segmentedControllerValueChanged(favouritesSegmentedControl)
  }
    @IBAction func backBtnClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
   }

}
