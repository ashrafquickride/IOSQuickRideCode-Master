//
//  ScrollViewUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 14/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ScrollViewUtils {
    
    static func scrollToPoint(scrollView : UIScrollView,point : CGPoint){
        scrollView.contentOffset = point
    }
}
