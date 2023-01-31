//
//  VersionAndLogoutShowingFooterTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 18/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VersionAndLogoutShowingFooterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var AppVersionShowingLabel: UILabel!
    
    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          AppVersionShowingLabel.text = Strings.version+" "+version
        }
    }
    
}
