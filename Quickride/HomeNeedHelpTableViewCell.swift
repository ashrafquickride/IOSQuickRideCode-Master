
//  HomeNeedHelpTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 8/3/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
class HomeNeedHelpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var needHelpView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var viewController : UIViewController?
    
    func initializeViews(viewController : UIViewController){
        self.viewController = viewController
    }
    
    @IBAction func goToHelpTapped(_ sender: Any) {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.helpViewController)
        viewController?.navigationController?.pushViewController(destViewController, animated: true)
    }
}
