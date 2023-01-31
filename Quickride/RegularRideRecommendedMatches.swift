//
//  RegularRideRecommendedMatches.swift
//  Quickride
//
//  Created by Halesh on 17/05/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation

class RegularRideRecommendedMatchesViewController: RegularRideMatchesViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func getRegularRideMathes() {
        if isFromRecommededMatches!{
            getRecommendedMatches()
        }
    }
}
