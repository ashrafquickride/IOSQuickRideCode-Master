//
//  VerifyProfileViewController.swift
//  Quickride
//
//  Created by Vinutha on 04/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI


class VerifyProfileViewController: UIViewController {
    
    //MARK: Outlets
  
    @IBOutlet weak var verifyProfileTableView: UITableView!
  
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonBorderView: UIView!
    
    @IBOutlet weak var skipButtn: UIButton!
    
    @IBOutlet weak var continueBttn: UIButton!
    
    var isFromSignUpFlow = false
   
    @IBOutlet weak var continueButtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var skipButtnConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var verifyProfileViewModel = VerifyProfileViewModel()
    
    
    func intialData(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    

    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyProfileTableView.dataSource = self
        setupUI()
        intialitionView()
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.verifyProfileTableView.reloadData()
        getCompanyIdVerificationDataAndSetupUI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func intialitionView() {
    if isFromSignUpFlow == false{
        backButton.isHidden = false
        skipButtn.isHidden = true
        continueBttn.isHidden = true
        continueButtnConstraint.constant = 0
        skipButtnConstraint.constant = 0
    } else {
        
        backButton.isHidden = true
        buttonBorderView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        skipButtn.isHidden = false
        continueBttn.isHidden = true
        continueButtnConstraint.constant = 0
        skipButtnConstraint.constant = 50
        
    }
}
    
    //MARK: Methods
    private func setupUI() {
       verifyProfileTableView.rowHeight = UITableView.automaticDimension
        
        verifyProfileTableView.register(UINib(nibName: "headTableViewCell", bundle: nil), forCellReuseIdentifier: "headTableViewCell")
        
        verifyProfileTableView.register(UINib(nibName: "EmailTableViewCell", bundle: nil), forCellReuseIdentifier: "EmailTableViewCell")
         verifyProfileTableView.register(UINib(nibName: "PersonalIdTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalIdTableViewCell")
         verifyProfileTableView.register(UINib(nibName: "ReferenceRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "ReferenceRequestTableViewCell")
        verifyProfileTableView.register(UINib(nibName: "RequestPendingTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestPendingTableViewCell")
       
        verifyProfileTableView.rowHeight = UITableView.automaticDimension
                
        verifyProfileTableView .register(UINib(nibName: "PendingVerifyTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingVerifyTableViewCell")
        verifyProfileTableView.estimatedRowHeight = 70
        verifyProfileTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    private func updateUI() {
        if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified,(profileVerificationData.profVerifSource == 1 || profileVerificationData.profVerifSource == 2 || profileVerificationData.profVerifSource == 4) {

        } else {

            getCompanyIdVerificationDataAndSetupUI()
            
        }
        
    }
    private func getCompanyIdVerificationDataAndSetupUI() {
        if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified, profileVerificationData.profVerifSource == 3 {

        } else {
            UserDataCache.getInstance()?.getCompanyIdVerificationData(handler: {(companyIdVerificationData) in

                self.getEndorsementVerificationInfoAndSetupUI()
            })
        }
    }
    
    private func getEndorsementVerificationInfoAndSetupUI() {
        UserDataCache.getInstance()?.getEndorsementVerificationInfo(userId: QRSessionManager.getInstance()?.getUserId() ?? "0",handler: { (endorsementVerificationInfo) in
            
            
          self.verifyProfileViewModel.filterOnlyEndorsementVerifiedUser(endorsementVerificationInfo: endorsementVerificationInfo)
//            if let noOfEndorsers =  UserDataCache.getInstance()?.getLoggedInUserProfile()?.profileVerificationData?.noOfEndorsers, noOfEndorsers > 0 {

//               } else {

//                  self.verifyProfileTableView.reloadData()

              self.verifyProfileViewModel.endorsementVerificationInfo = endorsementVerificationInfo

                   self.verifyProfileTableView.reloadData()

         //}

        })
//        self.verifyProfileTableView.reloadData()
    }

    //MARK: Actions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
  }
    
    
    @IBAction func continueButtnTapped(_ sender: Any) {
        
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
    }
        
        
    @IBAction func skipBttnTapped(_ sender: Any) {
    
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
        
    }
    
}

//MARK:TAbleViewDataSource
extension VerifyProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

       switch section {
     case 0:
           return 1
       case 1:
            return 1
        case 2:
            return 1
       case 3:
           return 1
           
       case 4 :
           return verifyProfileViewModel.endorsementVerificationInfo.count > 0 ? 1 : 0
           
       case 5:
           
           return verifyProfileViewModel.endorsementVerificationInfo.count
        default:
            return 0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "headTableViewCell", for: indexPath) as! headTableViewCell
            
            
            return cell
            
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmailTableViewCell", for: indexPath) as! EmailTableViewCell
            cell.intialiseData(isFromSignUpFlow: isFromSignUpFlow)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalIdTableViewCell", for: indexPath) as! PersonalIdTableViewCell
            cell.intialiseData(isFromSignUpFlow: isFromSignUpFlow)
            return cell
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReferenceRequestTableViewCell", for: indexPath) as! ReferenceRequestTableViewCell
            return cell
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestPendingTableViewCell", for: indexPath) as! RequestPendingTableViewCell
            return cell
            
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingVerifyTableViewCell", for: indexPath) as! PendingVerifyTableViewCell
            
            let endorsementVerificationInfo = verifyProfileViewModel.endorsementVerificationInfo[indexPath.row]
            cell.initializeData(endorsableUser: nil, endorsementVerificationInfo: endorsementVerificationInfo, viewController: self)
            if isFromSignUpFlow == true{
                continueBttn.isHidden = false
                continueButtnConstraint.constant = 50
            }
            return cell
            
        default :
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
            
        }
        
    }
}
//MARK: MFMailComposerDelegate
extension VerifyProfileViewController : MFMailComposeViewControllerDelegate{
    private func sendEmailToSupport(){
        AppDelegate.getAppDelegate().log.debug("sendEmailToSupport()")
        if MFMailComposeViewController.canSendMail() {
            let userProfile = UserDataCache.getInstance()?.userProfile
            let mailComposeViewController = MFMailComposeViewController()
            var subject = ""
            if userProfile?.userName != nil{
                subject = subject+(userProfile?.userName)!
            }
            subject = subject + " - " + QRSessionManager.getInstance()!.getCurrentSession().contactNo
            if let communicationEmail = userProfile?.emailForCommunication {
                subject = subject + " - \(communicationEmail)"
            }
            if userProfile?.userId != nil{
                subject = subject + " - UserId - \(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId))"
            }
            let modelName = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            subject = subject + " - Device Information : "+modelName+","+systemVersion+"- QR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            subject = subject + " - Issue Type: Company ID card Verification"
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self
            var recepients = [String]()
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            recepients.append(clientConfiguration!.verificationSupportMail)
            mailComposeViewController.setToRecipients(recepients)
            if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
            }
            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast(Strings.cant_send_mail)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}



