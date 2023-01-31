//
//  PersonalIdVerificationDetailsViewController.swift
//  Quickride
//
//  Created by Vinutha on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

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
    @IBOutlet weak var verifyingDocumentLabel: UILabel!
    @IBOutlet weak var loadingAnimationView: AnimationView!
    @IBOutlet weak var continueToVerifyDocumentButton: UIButton!
    
    //MARK: Properties
    var viewModel = PersonalIdVerificationDetailsViewModel()
    var handler: actionCompletionHandler?
    var isFromSignUpFlow = true

    //MARK: Initialisers
    func initialiseData(personalIdDetail: PersonalIdDetail, handler: @escaping actionCompletionHandler) {
        self.handler = handler
        viewModel.initialiseData(personalIdDetail: personalIdDetail)
    }
    
    func intialiseDataInDetail(isFromSignUpFlow: Bool){
    self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    private func setupUI() {
        if let personalIdDetail = viewModel.personalIdDetail {
            if let imageUri = personalIdDetail.faceImageUri, let image = UIImage(contentsOfFile: imageUri) {
                userImageView.image = image
            }
            documentNoLabel.text = personalIdDetail.documentId ?? "-"
            userNameLabel.text = personalIdDetail.name ?? "-"
            fatherNameLabel.text = personalIdDetail.fatherName ?? "-"
            dobLabel.text = personalIdDetail.dob ?? "-"
            addressLabel.text = personalIdDetail.address ?? "-"
            verificationStatusLabel.text = String(format: Strings.personal_id_verified_successfully, arguments: [personalIdDetail.documentType!.lowercased().capitalizingFirstLetter()])
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(personalIdDetailsStored(_:)), name: .personalIdDetailStored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(personalIdDetailsStoringFailed(_:)), name: .personalIdDetailStoringFailed, object: nil)
    }
    
    @objc func personalIdDetailsStored(_ notification : NSNotification) {
        scrollView.isHidden = true
        loadingAnimationView.stop()
        loadingAnimationView.isHidden = true
        verifyingDocumentLabel.isHidden = true
        verificationStatusLabel.isHidden = false
        statusImageView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else {
                return
            }
            if self.isFromSignUpFlow {
                let pledgeVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickridePledgeViewController") as! QuickridePledgeViewController
                pledgeVC.initializeDataBeforePresenting(titles: Strings.pledge_titles, messages: Strings.pledge_details_ride_giver, images: Strings.pledgeImages, actionName: Strings.i_agree_caps, heading: Strings.pledge_title_text) { () in
                    let userProfile = UserDataCache.getInstance()?.userProfile
                    if userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
                        SharedPreferenceHelper.setDisplayStatusForRideGiverPledge(status: true)
                    }else{
                        SharedPreferenceHelper.setDisplayStatusForRideTakerPledge(status: true)
                    }
                    RideManagementUtils.updateStatusAndNavigate(isFromSignupFlow: true, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
                    
                }
                
                self.navigationController?.pushViewController(pledgeVC , animated: false)
            } else {
                
                self.navigationController?.popViewController(animated: false)
                
            }
            self.handler?()
        }
    }
        
    
    
    
    @objc func personalIdDetailsStoringFailed(_ notification : NSNotification) {
        scrollView.isHidden = true
        loadingAnimationView.stop()
        loadingAnimationView.isHidden = true
        verifyingDocumentLabel.isHidden = true
        verificationStatusLabel.isHidden = false
        verificationStatusLabel.text = "Verification Failed"
        statusImageView.isHidden = false
        statusImageView.image = UIImage(named: "Red_Exclamation_Dot")
    }
    
    //MARK: Actions
    @IBAction func continueToVerifyDocumentTapped(_ sender: UIButton) {
        scrollView.isHidden = true
        loadingAnimationView.animation = Animation.named("loading_otp")
        loadingAnimationView.isHidden = false
        loadingAnimationView.play()
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.isHidden = false
        verifyingDocumentLabel.isHidden = false
        continueToVerifyDocumentButton.isHidden = true
        viewModel.saveDocumentImage()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        self.handler?()
    }
    
}
