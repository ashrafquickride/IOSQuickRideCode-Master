//
//  RideContributionTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 14/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class RideContributionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ridesShareAndCo2Label: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var ecometerView: QuickRideCardView!
    
    @IBOutlet weak var contributionLevelView: UIView!
    var viewController : UIViewController?
    
    func updateUI(rideSharingCommunityContribution: RideSharingCommunityContribution,viewController : UIViewController) {
        self.viewController = viewController
        ViewCustomizationUtils.addCornerRadiusToView(view: ecometerView, cornerRadius: 10)
        ecometerView.addShadow()
        ViewCustomizationUtils.addCornerRadiusToView(view: contributionLevelView, cornerRadius: 12)
        ridesShareAndCo2Label.text = String(format: Strings.ride_shared_and_co2, arguments: [String(rideSharingCommunityContribution.numberOfRidesShared ?? 0), StringUtils.getStringFromDouble(decimalNumber: rideSharingCommunityContribution.co2Reduced)])
        setTitleAndContentBasedOnCategory(category: rideSharingCommunityContribution.category)
        ecometerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ecometerViewTapped(_:))))
    }
    @objc func ecometerViewTapped(_ gesture : UITapGestureRecognizer){
        
        guard let userProfile = UserDataCache.sharedInstance?.getLoggedInUserProfile() else {
            return
        }
        let ecoMeterVC : NewEcoMeterViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewEcoMeterViewController") as! NewEcoMeterViewController
        
        ecoMeterVC.initializeDataBeforePresenting(userId: StringUtils.getStringFromDouble(decimalNumber:  userProfile.userId), userName: userProfile.userName!,imageUrl: userProfile.imageURI, gender: userProfile.gender!)
        viewController?.navigationController?.pushViewController(ecoMeterVC, animated: false)
    }
    func setTitleAndContentBasedOnCategory(category: String?){
        if category == RideSharingCommunityContribution.USER_CATEGORY_SILVER {
            categoryLabel.text = Strings.category_level_bamboo
            categoryImageView.image = UIImage(named: "bamboo")
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_GOLD{
            categoryLabel.text = Strings.category_level_bonsai
            categoryImageView.image = UIImage(named: "bonsai")
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_DIAMOND{
            categoryLabel.text = Strings.category_level_ashoka
            categoryImageView.image = UIImage(named: "ashoka")
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_PLATINUM{
            categoryLabel.text = Strings.category_level_banyan
            categoryImageView.image = UIImage(named: "banyan")
        }else{
            categoryImageView.image = UIImage(named: "no_category_eco_meter")
            contributionLevelView.isHidden = true
        }
    }
}
