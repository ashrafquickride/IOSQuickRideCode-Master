//
//  EndorsementRequestViewController.swift
//  Quickride
//
//  Created by Vinutha on 08/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsementRequestViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var verificationImageView: UIImageView!
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var totalRidesLabel: UILabel!
    @IBOutlet weak var totalRidesTextLabel: UILabel!
    @IBOutlet weak var totalRidesView: UIView!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var noOfRidesTableView: UITableView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var userActionView: UIView!
    
    //MARK: Properties
    var viewModel = EndorsementRequestViewModel()
    
    //MARK: Initializer
    func initializeData(userProfile: UserProfile, endorsementRequestNotificationData: EndorsementRequestNotificationData, notication: UserNotification) {
        viewModel.initializeData(userProfile: userProfile, endorsementRequestNotificationData: endorsementRequestNotificationData, notication: notication)
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
        dataView.addShadow()
        userActionView.addShadow()
        noOfRidesTableView.isHidden = true
        totalRidesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(totalRidesViewTapped(_:))))
        let numberOfRidesAsPassenger = String(describing: NSNumber(value: viewModel.userProfile.numberOfRidesAsPassenger))
        let numberOfRidesAsRider = String(describing: NSNumber(value: viewModel.userProfile.numberOfRidesAsRider))
        totalRidesLabel.text = String(describing: NSNumber(value: viewModel.userProfile.numberOfRidesAsPassenger + viewModel.userProfile.numberOfRidesAsRider))
        viewModel.listOfRides.append(totalRidesLabel.text!)
        viewModel.listOfRides.append(numberOfRidesAsPassenger)
        viewModel.listOfRides.append(numberOfRidesAsRider)
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: viewModel.userProfile.imageURI, gender: viewModel.userProfile.gender ?? "U", imageSize: ImageCache.DIMENTION_LARGE)
        userNameLabel.text = viewModel.userProfile.userName
        handleVerifiedView()
    }
    
    private func handleVerifiedView(){
        verificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: viewModel.userProfile.profileVerificationData)
        
        verificationStatusLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: viewModel.userProfile.profileVerificationData, companyName: nil)
        if verificationStatusLabel.text == Strings.not_verified {
            verificationStatusLabel.textColor = UIColor.black
        }else{
            verificationStatusLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if verificationStatusLabel.text == Strings.not_verified {
            verificationStatusLabel.textColor = UIColor.black
        }else{
            verificationStatusLabel.textColor = UIColor(netHex: 0x24A647)
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(endorsementRequestRejected(_:)), name: .endorsementRequestRejected, object: nil)
    }
    
    @objc func endorsementRequestRejected(_ notification : NSNotification){
        removeView()
    }
    
    @objc private func totalRidesViewTapped(_ sender :UITapGestureRecognizer){
        if !dropDownButton.isHidden {
            if !noOfRidesTableView.isHidden {
                noOfRidesTableView.isHidden = true
                noOfRidesTableView.dataSource = nil
                hideNoOfRidesTableViewAndRemoveDelegate()
            } else {
                noOfRidesTableView.isHidden = false
                noOfRidesTableView.delegate = self
                noOfRidesTableView.dataSource = self
                noOfRidesTableView.reloadData()
            }
        }
    }
    
    private func hideNoOfRidesTableViewAndRemoveDelegate(){
        noOfRidesTableView.isHidden = true
        noOfRidesTableView.dataSource = nil
        noOfRidesTableView.delegate = nil
    }
    
    
    private func removeView() {
        if self.navigationController == nil {
            self.dismiss(animated: false, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    //MARK: Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        removeView()
    }
    
    @IBAction func endorseButtonTapped(_ sender: UIButton) {
        let endorseCofirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorseCofirmationViewController") as! EndorseCofirmationViewController
            endorseCofirmationViewController.initializeData(endorsementRequestNotiifcationData: viewModel.endorsementRequestNotificationData, notication: viewModel.notication!, handler: { (action) in
                if action == Strings.success {
                    self.removeView()
                }
            })
        ViewControllerUtils.addSubView(viewControllerToDisplay: endorseCofirmationViewController)
    }
    
    @IBAction func declineButtonTapped(_ sender: UIButton) {
        let refundRejectReasonsViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RefundRejectReasonsViewController") as! RefundRejectReasonsViewController
        refundRejectReasonsViewController.initializeReasons(reasons: Strings.endorsement_reject_reason, actionName: Strings.decline_action_caps) { (rejectReason) in
            self.viewModel.rejectEndorsementRequest(rejectReason: rejectReason, viewController: self)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: refundRejectReasonsViewController)
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        if let callDisableMsg = viewModel.getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
        let userProfile = viewModel.userProfile
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: userProfile.userId), refId: "",  name: userProfile.userName ?? "", targetViewController: self ?? UIViewController())
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        if let chatDisableMsg = viewModel.getErrorMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast(chatDisableMsg )
            return
        }
        let userProfile = viewModel.userProfile
        let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatConversationDialogue.initializeDataBeforePresentingView(ride: nil, userId: userProfile.userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: chatConversationDialogue, animated: false)
    }
    
}
//MARK: Table view datasource
extension EndorsementRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listOfRides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! NoOfRidesCompletedTableViewCell
        if viewModel.listOfRides.endIndex <= indexPath.row {
            return cell
        }
        cell.setUpUI(row: indexPath.row, noOfRides: viewModel.listOfRides[indexPath.row])
        return cell
    }
}

//MARK: Table view delegate
extension EndorsementRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        totalRidesLabel.text = viewModel.listOfRides[indexPath.row]
        if indexPath.row == 0{
            totalRidesTextLabel.text = NoOfRidesCompletedTableViewCell.totalRides
        }else if indexPath.row == 1{
            totalRidesTextLabel.text = NoOfRidesCompletedTableViewCell.asRider
        }else{
            totalRidesTextLabel.text = NoOfRidesCompletedTableViewCell.asPassenger
        }
        hideNoOfRidesTableViewAndRemoveDelegate()
    }
}
