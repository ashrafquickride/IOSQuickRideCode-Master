//
//  TabBarProfileViewController.swift
//  Quickride
//
//  Created by Ashutos on 27/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class TabBarProfileViewController: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var myAccountTableView: UITableView!

    private var accountDetailsViewModel = AccountDetailsViewModel()
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        myAccountTableView.register(UINib(nibName: "MyAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "MyAccountTableViewCell")
        myAccountTableView.register(UINib(nibName: "AccountSectionProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountSectionProfileTableViewCell")
        myAccountTableView.register(UINib(nibName: "VersionAndLogoutShowingFooterTableViewCell", bundle: nil), forCellReuseIdentifier: "VersionAndLogoutShowingFooterTableViewCell")
        myAccountTableView.estimatedRowHeight = 70
        myAccountTableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleUnreadChatCountAndDisplay()
        handleNotificationCountAndDisplay()
        myAccountTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func handleUnreadChatCountAndDisplay() {
        let count = MessageUtils.getUnreadCountOfChat()
        if count > 0 {
            chatView.isHidden = false
            chatCountLabel.text = String(count)
        } else {
            chatView.isHidden = true
        }
    }

    private func handleNotificationCountAndDisplay() {
        let pendingNotificationCount = NotificationStore.getInstance().getActionPendingNotificationCount()
        if pendingNotificationCount > 0 {
            notificationView.isHidden = false
            notificationCountLabel.text = String(pendingNotificationCount)
        } else {
            notificationView.isHidden = true
        }
    }

    private func getProfileDetails() -> UserProfile? {
        return UserDataCache.getInstance()?.getUserProfile(userId: QRSessionManager.getInstance()!.getUserId())
    }

    @IBAction func notioficationBtnPressed(_ sender: UIButton) {
        let notificationViewController = UIStoryboard(name: StoryBoardIdentifiers.notifications_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationViewController, animated: false)
    }

    @IBAction func chatButtonPressed(_ sender: UIButton) {
        let centralChatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.centralChatViewController)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: centralChatViewController, animated: false)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK:TAbleViewDataSource
extension TabBarProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountDetailsViewModel.numberOfRowsForSection(indexPath: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountTableViewCell", for: indexPath) as! MyAccountTableViewCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "AccountSectionProfileTableViewCell", for: indexPath) as! AccountSectionProfileTableViewCell
            if let profileData = getProfileDetails() {
                profileCell.initialiseData(viewController: self)
                profileCell.setUpUI(userProfileObject: profileData)
            }
            profileCell.delegate = self
            return profileCell

        } else if indexPath.section == 1 {
            let profileData = getProfileDetails()
            cell.updateUI(profileData: profileData!, title: accountDetailsViewModel.titleArrayFor2ndSection[indexPath.row], subtitle: accountDetailsViewModel.subtitleArrayFor2ndSection[indexPath.row], imageString: accountDetailsViewModel.ImageArrayForSecondSection[indexPath.row], section: indexPath.section, row: indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let footerCell = tableView.dequeueReusableCell(withIdentifier: "VersionAndLogoutShowingFooterTableViewCell") as! VersionAndLogoutShowingFooterTableViewCell
            footerCell.viewController = self
            return footerCell
        } else {
            let view = UIView()
            view.backgroundColor = UIColor(netHex: 0xECF0F5)
            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 121
        } else {
            return 10
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

//MARK: TableViewDelegate
extension TabBarProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                openViewControllerBasedOnIdentifier(storyBoardIdentifier: StoryBoardIdentifiers.verifcation_storyboard, strIdentifier: "VerifyProfileViewController")
                break
            case 1://My payments
                openViewControllerBasedOnIdentifier(storyBoardIdentifier: StoryBoardIdentifiers.account_storyboard, strIdentifier: ViewControllerIdentifiers.paymentViewController)
                break
            case 2: //refer
                openViewControllerBasedOnIdentifier(storyBoardIdentifier: StoryBoardIdentifiers.shareandearn_storyboard, strIdentifier: ViewControllerIdentifiers.myReferralsViewController)
                break
            case 3: //offers
                let offerVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myOffersViewController) as! MyOffersViewController
                offerVC.prepareData(selectedFilterString: nil)
                self.navigationController?.pushViewController(offerVC, animated: true)
                break
            case 4:
                openViewControllerBasedOnIdentifier(storyBoardIdentifier: StoryBoardIdentifiers.settings_storyboard, strIdentifier: "MyPreferencesViewController")
            default:
                break
            }
            break
        default:
            break
        }
    }
}

//MARK: CellDelegates
extension TabBarProfileViewController: AccountSectionProfileTableViewCellDelegate {
    func viewProfilePressed() {
        if (QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus == .User) {
            let profileVC = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController

            profileVC.initializeDataBeforePresentingView(profileId: (QRSessionManager.getInstance()?.getUserId())!, isRiderProfile: UserRole.None, rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView: false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)

            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }

    private func openViewControllerBasedOnIdentifier(storyBoardIdentifier: String, strIdentifier: String) {
        let destViewController: UIViewController = UIStoryboard(name: storyBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: strIdentifier)
        self.navigationController?.pushViewController(destViewController, animated: true)

    }
}
