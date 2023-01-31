//
//  PersonalIdVerificationViewController.swift
//  Quickride
//
//  Created by Vinutha on 10/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class PersonalIdVerificationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var loaderAnimationView: AnimationView!
    @IBOutlet weak var progressLabel: UILabel!
    
    //MARK: Properties
    private var viewModel = PersonalIdVerificationViewModel()
    private var handler: actionCompletionHandler?
    var isFromSignUpFlow = false
    
    //MARK: Initialiser
    func initialiseData(isFromProfile: Bool, verificationType: String, handler: @escaping actionCompletionHandler) {
        viewModel.isFromProfile = isFromProfile
        viewModel.verificationType = verificationType
        self.handler = handler
    }
    
    func IntialDateHidding(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        if viewModel.isFromProfile {
            viewModel.launchFaceCaptureScreen(verificationType: viewModel.verificationType!, viewController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func moveToSuccessView(verificationType: String) {
        if let personalIdDetail = viewModel.getPersonalIdDetailsBasedOnType(verificationType: verificationType) {
            let personalIdVerificationDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationDetailsViewController") as! PersonalIdVerificationDetailsViewController
            personalIdVerificationDetailsViewController.initialiseData(personalIdDetail: personalIdDetail) {
                self.popViewControllerIfIsFromProfile()
            }
            personalIdVerificationDetailsViewController.intialiseDataInDetail(isFromSignUpFlow: isFromSignUpFlow)
            
            self.navigationController?.pushViewController(personalIdVerificationDetailsViewController, animated: false)
        }
        
    }
    
    //MARK: Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

    private func popViewControllerIfIsFromProfile() {
        if viewModel.isFromProfile {
            self.navigationController?.popViewController(animated: false)
            handler?()
        }
    }
}
//MARK: UITableViewDataSource
extension PersonalIdVerificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.personal_id_verification_categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalIdVerificationTableViewCell", for: indexPath) as! PersonalIdVerificationTableViewCell
        if viewModel.personal_id_verification_categories.endIndex <= indexPath.row {
            return cell
        }
        cell.initialiseView(type: viewModel.personal_id_verification_categories[indexPath.row])
        return cell
    }
    
}
//MARK: UITableView delegate
extension PersonalIdVerificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let verificationType = viewModel.personal_id_verification_categories[indexPath.row]
        let persVerifSource = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()?.persVerifSource
        if persVerifSource == nil || !persVerifSource!.contains(verificationType) {
            viewModel.launchFaceCaptureScreen(verificationType: verificationType, viewController: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
//MARK: PersonalIdVerificationViewModelDelegate model delegate
extension PersonalIdVerificationViewController: PersonalIdVerificationViewModelDelegate {
    
    func documentCaptureFailed(errorMessage: String?) {
        UIApplication.shared.keyWindow?.makeToast(errorMessage ?? "")
        popViewControllerIfIsFromProfile()
    }
    
    func documentScanningCompleted(verificationType: String) {
        tableView.isHidden = true
        progressView.isHidden = false
        loaderAnimationView.isHidden = false
        loaderAnimationView.animation = Animation.named("loading_otp")
        loaderAnimationView.play()
        loaderAnimationView.loopMode = .loop
        progressLabel.text = "Matching Picture"
        viewModel.makeFaceMatchCallForFrontDocImage(verificationType: verificationType)
    }
    
    func faceMatchCallStatus(status: String, errorMessage: String?, verificationType: String) {
        if status == PersonalIdVerificationViewModel.SUCCESS {
            progressLabel.text = "Fetching Details"
            viewModel.makeOCRCallForFrontDoc(verificationType: verificationType)
        } else {
            tableView.isHidden = false
            progressView.isHidden = true
            loaderAnimationView.stop()
            UIApplication.shared.keyWindow?.makeToast(errorMessage ?? "")
            popViewControllerIfIsFromProfile()
        }
    }
    
    func OCRCallFailed(errorMessage: String?) {
        tableView.isHidden = false
        progressView.isHidden = true
        loaderAnimationView.stop()
        UIApplication.shared.keyWindow?.makeToast(errorMessage ?? "")
        popViewControllerIfIsFromProfile()
    }
    
    func OCRCallSucceeded(verificationType: String) {
        tableView.isHidden = false
        progressView.isHidden = true
        loaderAnimationView.stop()
        moveToSuccessView(verificationType: verificationType)
    }
    
}
