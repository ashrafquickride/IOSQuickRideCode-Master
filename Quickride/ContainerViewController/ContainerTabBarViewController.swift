
//
//  ContainerTabBarViewController.swift
//  Quickride
//
//  Created by Ashutos on 4/9/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ContainerTabBarViewController: UITabBarController {

    static var indexToSelect = 0
    static var data: Any?
    static var previousFrame : CGRect?
    static var isHotSpotEnabled = false

    static var fromPopRooController = false
    static var isRideCompleted = false

    var centerNavigationController : UINavigationController!
    private var urlString: String?
    
    private var shapeLayer: CALayer?
    private var carpoolSelectedShapeLayer = CAShapeLayer()
    private var taxiSelectedShapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         definesPresentationContext = true
        self.viewControllers?.forEach({
                    $0.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14.0, weight: .regular)], for: .normal)
                })
        if UserDataCache.getInstance() != nil{
            UserDataCache.getInstance()!.addUserStatusUpdateReceiver(userStatusUpdateReceiver: self)
        }
        self.delegate = self
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        carpoolSelectedShapeLayer.path = createPathIfCarpoolSelected()
        taxiSelectedShapeLayer.path = createPathIfTaxiSelected()
        self.tabBar.barStyle = .black
    }

    func setNavigationBar() {
        if self.navigationController != nil{
        centerNavigationController = self.navigationController
        }else{
            centerNavigationController = UINavigationController(rootViewController: self)
        }
    }
    
    func createPathIfCarpoolSelected() -> CGPath {
        let path = UIBezierPath()
        let centerWidth = self.tabBar.frame.width / 2
        path.addArc(withCenter: CGPoint(x: 10, y: 0), radius: 10, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi/2 * 3), clockwise: true)
        path.addLine(to: CGPoint(x: centerWidth - 10, y: -10))
        path.addArc(withCenter: CGPoint(x: centerWidth - 10, y: 0), radius: 10, startAngle: CGFloat(Double.pi/2 * 3), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: centerWidth, y: self.tabBar.frame.height + 5))
        path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height + 5))
        path.close()
        return path.cgPath
        
    }
    
    func createPathIfTaxiSelected() -> CGPath {
        let path = UIBezierPath()
        let centerWidth = self.tabBar.frame.width / 2
        
        path.addArc(withCenter: CGPoint(x: centerWidth + 10, y: 0), radius: 10, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi/2 * 3), clockwise: true)
        path.addLine(to: CGPoint(x: self.tabBar.frame.width - 10, y: -10))
        path.addArc(withCenter: CGPoint(x: self.tabBar.frame.width - 10, y: 0), radius: 10, startAngle: CGFloat(Double.pi/2 * 3), endAngle: 0, clockwise: true)
        
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height + 5))
        path.addLine(to: CGPoint(x: centerWidth, y: self.tabBar.frame.height + 5))
        path.close()
        return path.cgPath
        
    }
    
    func setUrlToLoad(urlString: String?) {
        self.urlString = urlString
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpDataToTabBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateTabbarIndicatorBySelectedTabIndex(index: ContainerTabBarViewController.indexToSelect)
    }
    private func setUpDataToTabBar() {
        switch ContainerTabBarViewController.indexToSelect{
//        case 2:
//            if let vc = self.children[2] as? QuickJobsViewController {
//                if let urlString = urlString {
//                    vc.initialiseQuickJob(urlString: urlString)
//                    self.urlString = nil
//                }
//            }
        default:
            break
        }
        self.selectedIndex = ContainerTabBarViewController.indexToSelect
    }
    
    func updateTabbarIndicatorBySelectedTabIndex(index: Int){
        if index == 0 {
            taxiSelectedShapeLayer.fillColor = UIColor(netHex: 0xE9E9E9).cgColor
            carpoolSelectedShapeLayer.fillColor =  UIColor(netHex: 0xF9A829 ).cgColor
            self.tabBar.tintColor = UIColor.black
            taxiSelectedShapeLayer.shadowOffset = .zero
            taxiSelectedShapeLayer.shadowOpacity = 1
            taxiSelectedShapeLayer.shadowRadius = 1
            taxiSelectedShapeLayer.shadowColor = UIColor.gray.cgColor
        }else {
            taxiSelectedShapeLayer.fillColor = UIColor(netHex: 0x00AC52).cgColor
            carpoolSelectedShapeLayer.fillColor = UIColor(netHex: 0xE9E9E9).cgColor
            self.tabBar.tintColor = UIColor.white
            carpoolSelectedShapeLayer.shadowOffset = .zero
            carpoolSelectedShapeLayer.shadowOpacity = 1
            carpoolSelectedShapeLayer.shadowRadius = 1
            carpoolSelectedShapeLayer.shadowColor = UIColor.gray.cgColor
            var params = [String: String]()
            
            params["tabSelected"] = "taxi"
            params["userId"] = String(UserDataCache.getCurrentUserId())
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiTabClicked, params: params, uniqueField: User.FLD_USER_ID)
        }
        self.tabBar.unselectedItemTintColor = UIColor.systemGray
        var tabBarShapeLayer = CAShapeLayer()
        tabBarShapeLayer.addSublayer(carpoolSelectedShapeLayer)
        tabBarShapeLayer.addSublayer(taxiSelectedShapeLayer)
        if let oldShapeLayer = self.shapeLayer {
            self.tabBar.layer.replaceSublayer(oldShapeLayer, with: tabBarShapeLayer)
        }else{
            self.tabBar.layer.insertSublayer(tabBarShapeLayer, at: 0)
        }
        self.shapeLayer = tabBarShapeLayer
    }

}

extension ContainerTabBarViewController: UserStatusUpdateReceiver {
    func userStatusLocked() {
        LogOutTask(viewController: self).userLogOutTask()
    }
}

extension ContainerTabBarViewController : UITabBarControllerDelegate{
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setUpDataToTabBar()
        let index = self.tabBar.items?.firstIndex(of: item) ?? 0
        SharedPreferenceHelper.storeRecentTabBarIndex(tabBarIndex: index)
        updateTabbarIndicatorBySelectedTabIndex(index: index)
    }
}
