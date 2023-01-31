//
//  MenuItem.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct MenuItem {
  
  let menuLabel: String
  let menuImage: UIImage?
  let menuType: String?
  
    static let CARPOOL_MENU = "CARPOOL_MENU"
    static let TAXI_MENU = "TAXI_MENU"
    static let BAZAARY_MENU = "BAZAARY_MENU"
    
    
    init(menuLabel: String, menuImage: UIImage?,menuType: String){
    self.menuLabel = menuLabel
    self.menuImage = menuImage
    self.menuType = menuType
  }
}
