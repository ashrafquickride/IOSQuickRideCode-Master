//
//  TaxiSharingShowingTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 4/23/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class TaxiSharingShowingTableViewCell: UITableViewCell {

    @IBOutlet weak var radiobuttonImageView: UIImageView!
    
    @IBOutlet weak var numberOfSharingShowingLabel: UILabel!
    
    @IBOutlet weak var priceShowingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(data: GetTaxiShareMinMaxFare?) {
        if let dataForTaxi = data {
            numberOfSharingShowingLabel.text = dataForTaxi.shareType
            priceShowingLabel.text = "₹\(dataForTaxi.minFare!)"
        } else {
            numberOfSharingShowingLabel.text = ""
            priceShowingLabel.text = ""
        }
    }

}
