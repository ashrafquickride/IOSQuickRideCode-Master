//
//  LeftMenuViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LeftMenuViewModel{
    
    var menuItems = [MenuItem]()
    var menuType = MenuItem.CARPOOL_MENU
    
    func getMenuItems(){
        menuItems.removeAll()
        if menuType == MenuItem.CARPOOL_MENU{
            menuItems.append(MenuItem(menuLabel: "Post Ride", menuImage: UIImage(named: "post_ride_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Rides", menuImage: UIImage(named: "calendar_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "Carpool Payments", menuImage: UIImage(named: "my_payments_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Vehicle", menuImage: UIImage(named: "my_vehicles_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Contribution", menuImage: UIImage(named: "contribution_my"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Community", menuImage: UIImage(named: "chat_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Favorites", menuImage: UIImage(named: "my_favourites"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "My Offers", menuImage: UIImage(named: "my_offers_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "Refer and Rewards", menuImage: UIImage(named: "refer_and_rewards_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "Carpool Settings", menuImage: UIImage(named: "settings_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "Help", menuImage: UIImage(named: "help_icon"), menuType: MenuItem.CARPOOL_MENU))
            menuItems.append(MenuItem(menuLabel: "Logout", menuImage: UIImage(named: "LogOut_img"), menuType: MenuItem.CARPOOL_MENU))
        }else if menuType == MenuItem.TAXI_MENU{
            menuItems.append(MenuItem(menuLabel: "Book Taxi", menuImage: UIImage(named: "post_ride_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "My Trips", menuImage: UIImage(named: "calendar_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "Taxi Payments", menuImage: UIImage(named: "my_payments_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "My Favorites", menuImage: UIImage(named: "my_favourites"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "My Offers", menuImage: UIImage(named: "my_offers_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "Refer and Rewards", menuImage: UIImage(named: "refer_and_rewards_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "Help", menuImage: UIImage(named: "help_icon"), menuType: MenuItem.TAXI_MENU))
            menuItems.append(MenuItem(menuLabel: "Logout", menuImage: UIImage(named: "LogOut_img"), menuType: MenuItem.TAXI_MENU))
            
        }else if menuType == MenuItem.BAZAARY_MENU{
            menuItems.append(MenuItem(menuLabel: "Home", menuImage: UIImage(named: "Bazaary_home"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "My Posts", menuImage: UIImage(named: "my_posts"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "My Orders", menuImage: UIImage(named: "my_orders"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "My Payments", menuImage: UIImage(named: "my_payments_icon"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "Refer and Rewards", menuImage: UIImage(named: "refer_and_rewards_icon"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "Help", menuImage: UIImage(named: "help_icon"), menuType: MenuItem.BAZAARY_MENU))
            menuItems.append(MenuItem(menuLabel: "Logout", menuImage: UIImage(named: "LogOut_img"), menuType: MenuItem.BAZAARY_MENU))
        }

    }
}

