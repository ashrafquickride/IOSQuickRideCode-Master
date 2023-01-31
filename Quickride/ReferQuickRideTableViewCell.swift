//
//  ReferQuickRideTableViewCell.swift
//  Quickride
//
//  Created by HK on 19/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferQuickRideTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rideTypeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialiseView(ride: Ride?){
        if ride?.rideType == Ride.RIDER_RIDE{
            titleLabel.text = "Want more ride takers?"
            rideTypeImageView.image = UIImage(named: "refer_quickride")
        }else{
            titleLabel.text = "Want more ride givers?"
            rideTypeImageView.image = UIImage(named: "rideGiverImage")
        }
    }
    @IBAction func referQuickRideTapped(_ sender: Any) {
        let myReferralsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController)
        self.parentViewController?.navigationController?.pushViewController(myReferralsViewController, animated: false)
    }
}
