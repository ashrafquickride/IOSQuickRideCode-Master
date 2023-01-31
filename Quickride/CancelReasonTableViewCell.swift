//
//  CancelReasonTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 27/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol CancelReasonTableViewCellDelegate: class{
    func alternateActinTapped(action: String?)
    func callButtonTapped()
    func chatButtonTapped()
}

class CancelReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var reasonLbl: UILabel!
    
    @IBOutlet weak var radioImage: UIImageView!
    
    @IBOutlet weak var alternateActionButton: UIButton!
    
    @IBOutlet weak var alternateActionButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var callChatView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    weak var delegate: CancelReasonTableViewCellDelegate?
    
    func initializeCell(selectedIndex: Int,index: Int,reasonText: String,isCallOptionAvailable: Bool,isChatOPtionAvailable: Bool){
        if selectedIndex == index{
            let image = UIImage(named: "ic_radio_button_checked")?.withRenderingMode(.alwaysTemplate)
            self.radioImage.image = image
            self.radioImage.tintColor = UIColor(netHex:0x000000)
            reasonLbl.text = reasonText
        }else{
            reasonLbl.text = reasonText
            radioImage.image = UIImage(named: "radio_button_1")
        }
        if !isCallOptionAvailable{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
        if !isChatOPtionAvailable{
            chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    @IBAction func cancelRideTapped(_ sender: Any){
        delegate?.alternateActinTapped(action: alternateActionButton.titleLabel?.text)
    }
    
    @IBAction func callButtonTapped(_ sender: Any){
        delegate?.callButtonTapped()
    }
    
    @IBAction func chatButtonTapped(_ sender: Any){
        delegate?.chatButtonTapped()
    }
}
