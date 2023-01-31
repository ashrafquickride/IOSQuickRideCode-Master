//
//  ShowingAddingPaymentMethodTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 02/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol ShowingAddingPaymentMethodTableViewCellDelegate {
    func updateUI()
}
class ShowingAddingPaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: QRCustomButton!
    var delagate: ShowingAddingPaymentMethodTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) { 
        AccountUtils().addLinkWalletSuggestionAlert(title: nil, message: nil, viewController: parentViewController) { [weak self] (walletAdded, walletType) in
            if walletAdded {
                self?.delagate?.updateUI()
            }
        }
    }
}
