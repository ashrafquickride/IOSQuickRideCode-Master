//
//  TaxipoolHowItWorkViewController.swift
//  Quickride
//
//  Created by HK on 27/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxipoolHowItWorkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func gotItTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func cencellationPolicyTapped(_ sender: Any) {
        let urlcomps = URLComponents(string :  AppConfiguration.taxipool_cancel_url)
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.taxipool_cancel_policy, url: urlcomps!.url! , actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }
    }
}
