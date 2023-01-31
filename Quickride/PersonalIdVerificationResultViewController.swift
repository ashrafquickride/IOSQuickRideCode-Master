//
//  PersonalIdVerificationResultViewController.swift
//  Quickride
//
//  Created by Vinutha on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PersonalIdVerificationDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var documentNoLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fatherNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    //MARK: Properties
    var documnetType = ""
    
    //MARK: Initialiser
    func initialiseData(documnetType: String) {
        self.documnetType = documnetType
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: Methods
    private func setupUI() {
        verificationStatusLabel.text = String(format: Strings.personal_id_verified_successfully, arguments: [documnetType])
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
    }

}
