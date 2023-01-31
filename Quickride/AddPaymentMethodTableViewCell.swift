//
//  AddPaymentMethodTableViewCell.swift
//  Quickride
//
//  Created by HK on 29/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddPaymentMethodTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func cellButtonTapped(_ sender: Any) {
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        self.parentViewController?.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }
}
