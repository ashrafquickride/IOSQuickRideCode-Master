//
//  addRequirementDetailsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class addRequirementDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var bothView: QuickRideCardView!
    @IBOutlet weak var bothLabel: UILabel!
    
    //MARK: Variables
    private var requestProduct: RequestProduct?
    
    func initialiseView(requestProduct: RequestProduct){
        self.requestProduct = requestProduct
        rentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rentViewTapped(_:))))
        sellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sellViewTapped(_:))))
        bothView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bothViewTapped(_:))))
        if let tradeType = requestProduct.tradeType{
            productAvailableFor(type: tradeType)
        }else{
            productAvailableFor(type: Product.SELL)
        }
    }
    
    @objc func rentViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.RENT)
    }
    
    @objc func sellViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.SELL)
    }
    
    @objc func bothViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.BOTH)
    }
    
    private func productAvailableFor(type: String?){
        switch type {
        case Product.RENT:
            rentView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            sellView.backgroundColor = .white
            bothView.backgroundColor = .white
            rentLabel.textColor = .white
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.SELL:
            rentView.backgroundColor = .white
            sellView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            bothView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = .white
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.BOTH:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            bothView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = .white
        default:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            bothView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        var userInfo = [String: Any]()
        userInfo["requestingTradeType"] = type
        NotificationCenter.default.post(name: .requestingTradeType, object: nil, userInfo: userInfo)
    }
}
