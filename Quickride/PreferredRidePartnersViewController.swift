//
//  PreferredRidePartnersViewController.swift
//  Quickride
//
//  Created by rakesh on 2/1/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

class PreferredRidePartnersViewController : UIViewController, UITableViewDelegate, UITableViewDataSource,ContactSelectionReceiver,AddFavPartnerReceiver,RemoveFavouritePartnerReciever{
    
    @IBOutlet weak var noPreferredPartnerView: UIView!
    
    @IBOutlet weak var preferredPartnerTableView: UITableView!
    
    @IBOutlet weak var addFavoritePartnerBtn: UIButton!
    
    @IBOutlet weak var favoritePartnerImageView: UIImageView!
    
    var preferredRidePartnersList : [PreferredRidePartner] = [PreferredRidePartner]()
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        if self.navigationController != nil{
            AppDelegate.getAppDelegate().log.debug("navigation bar displayed")
            self.navigationController!.isNavigationBarHidden = false
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: addFavoritePartnerBtn, cornerRadius: addFavoritePartnerBtn.bounds.size.width/2.0)
        favoritePartnerImageView.image = favoritePartnerImageView.image!.withRenderingMode(.alwaysTemplate)
        favoritePartnerImageView.tintColor = UIColor.white
        preferredRidePartnersList = UserDataCache.getInstance()!.preferredRidePartners
        if preferredRidePartnersList.isEmpty
        {
            self.noPreferredPartnerView.isHidden = false
            self.preferredPartnerTableView.isHidden = true
        }else{
            self.noPreferredPartnerView.isHidden = true
            self.preferredPartnerTableView.isHidden = false
            preferredPartnerTableView.delegate = self
            preferredPartnerTableView.dataSource = self
            preferredPartnerTableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initializeView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : PreferredRidePartnersCell = tableView.dequeueReusableCell(withIdentifier: "PreferredRidePartnersCell", for: indexPath as IndexPath) as! PreferredRidePartnersCell
        if self.preferredRidePartnersList.endIndex <= indexPath.row{
            return cell
        }
        let preferredRidePartner = self.preferredRidePartnersList[indexPath.row]
        cell.menuOptnBtn.tag = indexPath.row
        cell.initializeViews(preferredRidePartner: preferredRidePartner, viewController: self)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToFavouritePartnerProfile(index: indexPath.row)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.preferredRidePartnersList.count
    }
    
    
    @IBAction func addPreferredPartnerButtonTapped(_ sender: Any) {
        
        let conversationContactsViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ConversationContactSelectViewController") as! ConversationContactSelectViewController
        conversationContactsViewController.initializeDataBeforePresentingView(requireConversationContacts: false, requireRidePartners: true, isNavBarRequired: true, moveToContacts: true, receiver: self)
        self.navigationController?.pushViewController(conversationContactsViewController, animated: false)
    }
    
    func contactSelected(contact : Contact)
    {
        var contactIds = [Double]()
        contactIds.append(Double(contact.contactId!)!)
        
        if (UserDataCache.getInstance()?.isFavouritePartner(userId: Double(contact.contactId!)!))!{
            UIApplication.shared.keyWindow?.makeToast( Strings.already_preferred_ride_partner)
        }else{
            
            let displayMessage = String(format: Strings.add_as_favorite_Partner, arguments: [contact.contactName])
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: displayMessage, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
                if Strings.yes_caps == result{
                    QuickRideProgressSpinner.startSpinner()
                    AddFavouritePartnerTask.addFavoritePartner(userId: (QRSessionManager.getInstance()?.getUserId())!, favouritePartnerUserIds: contactIds, receiver: self, viewController: self)
                    self.navigationController?.popViewController(animated: false)
                }
            })
        }
    }
    func displayPopUpMenu(preferredRidePartner : PreferredRidePartner)
    {
        let alertController : PreferredRidePartnerAlertController = PreferredRidePartnerAlertController(viewController: self) { (result) -> Void in
            if result == Strings.remove{
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.favdel_confirm, message2: nil, positiveActnTitle: Strings.no_caps,negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
                    if Strings.yes_caps == result{
                        QuickRideProgressSpinner.startSpinner()
                        RemoveFavouritePartnerTask.removeFavouritePartner(phoneNumber: preferredRidePartner.favouritePartnerUserId!, viewController: self, receiver: self)
                    }
                })
            }
        }
        alertController.removeAlertAction()
        alertController.cancelAlertAction()
        alertController.showAlertController()
    }
    
    @IBAction func menuOptnBtnTapped(_ sender: Any) {
        let contact = self.preferredRidePartnersList[(sender as AnyObject).tag]
        displayPopUpMenu(preferredRidePartner : contact)
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        if self.navigationController == nil{
            self.dismiss(animated: false, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func favPartnerAdded() {
        self.initializeView()
    }
    
    func favPartnerAddingFailed(responseError: ResponseError) {
        
        MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self,handler: nil)
    }
    func favouritePartnerRemoved() {
        self.initializeView()
    }
    
    func initializeView()
    {
        preferredPartnerTableView.delegate = nil
        preferredPartnerTableView.dataSource = nil
        self.preferredRidePartnersList = UserDataCache.getInstance()!.getAllPreferredRidePartners()
        
        if(self.preferredRidePartnersList.isEmpty)
        {
            self.noPreferredPartnerView.isHidden = false
            self.preferredPartnerTableView.isHidden = true
        }
        else{
            self.noPreferredPartnerView.isHidden = true
            self.preferredPartnerTableView.isHidden = false
            preferredPartnerTableView.delegate = self
            preferredPartnerTableView.dataSource = self
            self.preferredPartnerTableView.reloadData()
            preferredPartnerTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        }
    }
    func navigateToFavouritePartnerProfile(index: Int){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: preferredRidePartnersList[index].favouritePartnerUserId!, handler: { (userBasicInfo, responseError, error) in
            if userBasicInfo != nil{
                let supportCall : CommunicationType?
                if UserProfile.SUPPORT_CALL_ALWAYS == userBasicInfo!.callSupport{
                    supportCall = CommunicationType.Call
                }
                else if UserProfile.SUPPORT_CALL_AFTER_JOINED == userBasicInfo!.callSupport{
                    supportCall = CommunicationType.Call
                }
                else{
                    supportCall = CommunicationType.Chat
                }
                let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
                
                profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: self.preferredRidePartnersList[index].favouritePartnerUserId),isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(),rideVehicle : nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
            }
        })
        
    }
}
