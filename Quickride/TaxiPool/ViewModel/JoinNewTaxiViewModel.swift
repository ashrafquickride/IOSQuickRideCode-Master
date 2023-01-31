//
//  JoinNewTaxiViewModel.swift
//  Quickride
//
//  Created by Ashutos on 5/7/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation

class JoinNewTaxiViewModel {

    var taxiPoolNewCardData: [GetTaxiShareMinMaxFare]?
    var numberOfSharingData = [Int]()
    var choosenShareType: String?
    
    init(taxiPoolNewCardData: [GetTaxiShareMinMaxFare]?,choosenShareType: String) {
        self.taxiPoolNewCardData = taxiPoolNewCardData
        self.choosenShareType = choosenShareType
        updateDefaultData()
    }
    
    func updateDefaultData() {
        guard let taxiPoolNewCardData = taxiPoolNewCardData else {return}
        for i in 0..<taxiPoolNewCardData.count {
            if taxiPoolNewCardData[i].shareType == choosenShareType {
                numberOfSharingData = [i]
                break
            }
        }
    }
    
    func getShareType()-> String {
        if numberOfSharingData == [] || taxiPoolNewCardData == []{
            return choosenShareType ?? ""
        }
       return taxiPoolNewCardData?[numberOfSharingData[0]].shareType ?? ""
    }
}
