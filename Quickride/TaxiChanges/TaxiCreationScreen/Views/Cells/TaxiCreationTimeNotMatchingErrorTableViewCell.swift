//
//  TaxiCreationTimeNotMatchingErrorTableViewCell.swift
//  Quickride
//
//  Created by HK on 10/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiCreationTimeNotMatchingErrorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func initialiseError(error: String){
        errorLabel.text = error
    }
    
    @IBAction func updateTimeTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .upadteTaxiStartTime, object: nil)
    }
    
}
