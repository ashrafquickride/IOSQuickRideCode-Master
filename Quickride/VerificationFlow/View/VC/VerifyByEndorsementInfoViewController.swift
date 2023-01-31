//
//  VerifyByEndorsementInfoViewController.swift
//  Quickride
//
//  Created by Vinutha on 08/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class VerifyByEndorsementInfoViewController: UIViewController {

    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        SharedPreferenceHelper.setDisplayStatusForEndorsementInfoView(status: true)
        let endorsementListViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorsementListViewController") as! EndorsementListViewController
        self.navigationController?.pushViewController(endorsementListViewController, animated: false)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

}
