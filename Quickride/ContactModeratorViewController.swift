//
//  ContactModeratorViewController.swift
//  Quickride
//
//  Created by Vinutha on 03/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ContactModeratorViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var rideStatusAndArrivalTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupChatView: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var callToRiderButton: UIButton!
    @IBOutlet weak var moderatorCountLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    //MARK: Properties
    private var contactModeratorViewModel: ContactModeratorViewModel?
    private var isExpanded = false
    
    //MARK: Initialization
    func initialiseView(rideStatusText: String?, rideParticipant: RideParticipant, riderRideId: Double, rideModerators: [RideParticipant], rideType: String) {
        contactModeratorViewModel = ContactModeratorViewModel(rideStatusText: rideStatusText, rideParticipant: rideParticipant, riderRideId: riderRideId, rideModerators: rideModerators, rideType: rideType)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    //MARK: Methods
    private func setupUI() {
        tableViewHeightConstraint.constant = 0
        callView.isUserInteractionEnabled = true
        groupChatView.isUserInteractionEnabled = true
        self.groupChatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactModeratorViewController.groupChatViewTapped(_:))))
        ViewCustomizationUtils.addBorderToView(view: callView, borderWidth: 1, color: UIColor(netHex: 0x9ba3b1))
        ViewCustomizationUtils.addBorderToView(view: groupChatView, borderWidth: 1, color: UIColor(netHex: 0x9ba3b1))
        rideStatusAndArrivalTimeLabel.text = contactModeratorViewModel?.rideStatusText
        if let fullName = contactModeratorViewModel?.getFullName() {
            let nameText = String(format: Strings.started_ride, arguments: [fullName])
            let attributedString = NSMutableAttributedString(string: nameText)
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor.black, textSize: 14), range: (nameText as NSString).range(of: fullName))
            nameLabel.attributedText = attributedString
            callToRiderButton.setTitle(String(format: Strings.continue_calling, arguments: [fullName]), for: .normal)
        }
        if let text = contactModeratorViewModel?.getSubTitleBasedOnGender() {
            subTitleLabel.text = text
        }
        if let moderatorCount = contactModeratorViewModel?.rideModerators.count {
            moderatorCountLabel.text = "\(String(describing: moderatorCount)) Ride Moderator(s)"
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:))))
    }
    
    @objc func groupChatViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
        moveToGroupChatView()
    }
    
    private func moveToGroupChatView(){
        guard let riderRideId = contactModeratorViewModel?.riderRideId else { return }
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.group_chat_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
        destViewController.initailizeGroupChatView(riderRideID: riderRideId, isFromCentralChat: false)
        if RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller != nil{
            RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller?.dismiss(animated: false, completion: {
                DispatchQueue.main.async(){
                    ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                    RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
                }
            })
        }else{
            DispatchQueue.main.async(){
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
                RidesGroupChatCache.getInstance()?.currentlyDisplayingGroupChatViewContrller = destViewController
            }
        }
    }
    
    //MARK: Actions
    @IBAction func callRiderButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()

        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: contactModeratorViewModel!.rideParticipant!.userId), refId: Strings.moderator_contact_view, name: contactModeratorViewModel?.rideParticipant?.name ?? "" , targetViewController: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc private func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func arrowDownTapped(_ sender: UIButton) {
        if isExpanded {
            isExpanded = false
            tableViewHeightConstraint.constant = 0
        }else{
            isExpanded = true
            tableViewHeightConstraint.constant = CGFloat(contactModeratorViewModel!.rideModerators.count * 45)
        }
    }
}

extension ContactModeratorViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactModeratorViewModel?.rideModerators.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactModeratorTableViewCell", for: indexPath) as! ContactModeratorTableViewCell
        if contactModeratorViewModel!.rideModerators.endIndex <= indexPath.row {
            return cell
        }
        cell.initaialiseView(rideModerator: contactModeratorViewModel!.rideModerators[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rideModerators = contactModeratorViewModel!.rideModerators
        if rideModerators.endIndex <= indexPath.row {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        AppUtilConnect.callNumber(receiverId:  StringUtils.getStringFromDouble(decimalNumber: rideModerators[indexPath.row].userId), refId: Strings.moderator_contact_view, name: rideModerators[indexPath.row].name ?? "", targetViewController: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
