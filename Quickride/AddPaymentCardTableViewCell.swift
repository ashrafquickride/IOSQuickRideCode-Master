//
//  AddPaymentCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class AddPaymentCardTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var addPaymentView: UIView!
            
    //MARK: Actions
    @IBAction func addPaymentTapped(_ sender: UIButton) {
        AccountUtils().addLinkWalletSuggestionAlert(title: nil, message: nil, viewController: parentViewController) { (walletAdded, walletType) in
            if walletAdded {
                NotificationCenter.default.post(name: .linkedWalletAdded, object: nil)
            }
        }
    }
}
