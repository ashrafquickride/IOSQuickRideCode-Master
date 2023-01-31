//
//  LeftMenuViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LeftMenuViewController: UIViewController {

    //MARK: Variables
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var verifiedStatusImage: UIImageView!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!

    private var leftMenuViewModel = LeftMenuViewModel()

    func initialiseMenu(Menutype: String){
        leftMenuViewModel.menuType = Menutype
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionFlipFromLeft],
                       animations: {
                        self.contentView.frame.origin.y = 0
                        self.contentView.frame.origin.x += self.contentView.bounds.width
        }, completion: nil)
        self.backGroundView.backgroundColor = .clear
        UIView.animate(withDuration: 0.3, animations: {
            self.backGroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        })
        setUpUi()
        leftMenuViewModel.getMenuItems()
        menuTableView.reloadData()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(backGroundViewTapped(_:))))
        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self,action: #selector(handleSwipe(_:)))
        swipeRecognizerLeft.direction = .left
        view.addGestureRecognizer(swipeRecognizerLeft)
    }

    private func setUpUi(){
        let userProfile = UserDataCache.getInstance()?.userProfile
        nameLabel.text = userProfile?.userName
        ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl:  userProfile?.imageURI ?? "", gender:  userProfile?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        verifiedStatusImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData:  userProfile?.profileVerificationData)
        contactNumberLabel.text = SharedPreferenceHelper.getLoggedInUserContactNo()
        if ViewCustomizationUtils.hasTopNotch{
            topSpaceConstraint.constant = 44
        }else{
            topSpaceConstraint.constant = 10
        }
    }
    private func closeMenu(){
        UIView.animate(withDuration: 0.3, animations: {
            self.backGroundView.backgroundColor = .clear
        })
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            var frameMenu : CGRect = self.contentView.frame
            frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
            self.contentView.frame = frameMenu
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    @IBAction func profileTapped(_ sender: Any) {
        let vc = self
        closeMenu()
        let profileDisplayViewController  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: (QRSessionManager.getInstance()?.getUserId())!,isRiderProfile: UserRole.None , rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        vc.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }

    @objc func handleSwipe(_ gesture :UISwipeGestureRecognizer)  {
        closeMenu()
    }
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer){
        closeMenu()
    }

}
//MARK: UITableViewDataSource
extension LeftMenuViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        leftMenuViewModel.menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        if leftMenuViewModel.menuItems.endIndex <= indexPath.row{
            return cell
        }
        cell.configureForMenu(menuItem: leftMenuViewModel.menuItems[indexPath.row])
        return cell
    }
}
//MARK: UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            closeMenu()
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                let vc = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.routeViewController) as! BaseRouteViewController
                vc.initializeDataBeforePresenting(ride: Ride())
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: vc, animated: false)
            }
        case 1:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.common_storyboard, viewController: ViewControllerIdentifiers.myRidesDetailViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.taxi_pool_storyboard, viewController: "MyTripsViewController")
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.quickShare_storyboard, viewController: "MyPostsViewController")
            }
        case 2:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.account_storyboard, viewController: ViewControllerIdentifiers.paymentViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.account_storyboard, viewController: ViewControllerIdentifiers.paymentViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.quickShare_storyboard, viewController: "MyOrdersViewController")
            }
        case 3:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.profile_storyboard, viewController: ViewControllerIdentifiers.vehicleListViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.favourites_storyboard, viewController: "MyFavouritesViewController")
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.account_storyboard, viewController: ViewControllerIdentifiers.paymentViewController)
            }
        case 4:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.account_storyboard, viewController: ViewControllerIdentifiers.NewEcoMeterViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                closeMenu()
                let vc = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myOffersViewController) as! MyOffersViewController
                vc.prepareData(selectedFilterString: Strings.all)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: vc, animated: false)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.shareandearn_storyboard, viewController: ViewControllerIdentifiers.myReferralsViewController)
            }
        case 5:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.conversation_storyboard, viewController: ViewControllerIdentifiers.conversationContactsViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.shareandearn_storyboard, viewController: ViewControllerIdentifiers.myReferralsViewController)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.help_storyboard, viewController: ViewControllerIdentifiers.helpViewController)
            }
        case 6:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.favourites_storyboard, viewController: "MyFavouritesViewController")
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.taxi_pool_storyboard, viewController: "TaxiHelpViewController")
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
                mainContentVC.initializeButton(handler: { (result) in
                    if Strings.yes_caps == result{

                UserDataCache.SUBSCRIPTION_STATUS = false
                              LogOutTask(viewController: self).userLogOutTask()
                    }

           })
                self.navigationController?.present( mainContentVC, animated: false, completion: nil)
            }

        case 7:
            closeMenu()
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                let vc = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myOffersViewController) as! MyOffersViewController
                vc.prepareData(selectedFilterString: Strings.all)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: vc, animated: false)
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU {
                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
                mainContentVC.initializeButton(handler: { (result) in
                    if Strings.yes_caps == result{

                UserDataCache.SUBSCRIPTION_STATUS = false
                              LogOutTask(viewController: self).userLogOutTask()
                    }

           })
                self.navigationController?.present( mainContentVC, animated: false, completion: nil)
                
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.BAZAARY_MENU{
                showSelectedScreen(storyBoard: "SystemFeedback", viewController: "FeedbackViewController")
            }
        case 8:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.shareandearn_storyboard, viewController: ViewControllerIdentifiers.myReferralsViewController)
            }

        case 9:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.settings_storyboard, viewController: "MyPreferencesViewController")
            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU {

                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
                mainContentVC.initializeButton(handler: { (result) in
                    if Strings.yes_caps == result{

                UserDataCache.SUBSCRIPTION_STATUS = false
                              LogOutTask(viewController: self).userLogOutTask()
                    }

           })
                mainContentVC .modalPresentationStyle = .overFullScreen

                self.navigationController?.present( mainContentVC, animated: false, completion: nil)
            }

        case 10:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: StoryBoardIdentifiers.help_storyboard, viewController: ViewControllerIdentifiers.helpViewController)

            }else if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.TAXI_MENU {
                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
                mainContentVC.initializeButton(handler: { (result) in
                    if Strings.yes_caps == result{

                UserDataCache.SUBSCRIPTION_STATUS = false
                              LogOutTask(viewController: self).userLogOutTask()
                    }

           })

                self.navigationController?.present( mainContentVC, animated: false, completion: nil)

            }
        case 11:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{

                let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
                mainContentVC.initializeButton(handler: { (result) in
                    if Strings.yes_caps == result{

                UserDataCache.SUBSCRIPTION_STATUS = false
                              LogOutTask(viewController: self).userLogOutTask()
                    }

           })
              

                self.navigationController?.present( mainContentVC, animated: false, completion: nil)

            }
        case 12:
            if leftMenuViewModel.menuItems[indexPath.row].menuType == MenuItem.CARPOOL_MENU{
                showSelectedScreen(storyBoard: "SystemFeedback", viewController: "FeedbackViewController")
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    private func showSelectedScreen(storyBoard: String,viewController: String){
        let vc = self
        closeMenu()
        let controller = UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: viewController)
        vc.navigationController?.pushViewController(controller, animated: false)
    }
}
