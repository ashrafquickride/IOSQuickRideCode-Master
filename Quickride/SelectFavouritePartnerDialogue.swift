//
// SelectFavouritePartnerDialogue.swift
//  Quickride
//
//  Created by rakesh on 2/5/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import UIKit

 typealias successActionCompletionHandler = () -> Void

class SelectFavouritePartnerDialogue:UIViewController,UITableViewDelegate,UITableViewDataSource,AddFavPartnerReceiver{
 
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var favouritePartnerTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    var userWithFiveStarRating = [UserFeedback]()
    var selectedUsers : [Int : Bool] = [Int : Bool]()
    var favouritePartnerCompletionHandler : successActionCompletionHandler?
    
    func initializeDataBeforePresenting(userWithFiveStarRating: [UserFeedback],favouritePartnerCompletionHandler:@escaping successActionCompletionHandler){
        self.userWithFiveStarRating = userWithFiveStarRating
        self.favouritePartnerCompletionHandler = favouritePartnerCompletionHandler
    }
    
    override func viewDidLoad() {
        handleBrandingChanges()
        ViewCustomizationUtils.addCornerRadiusToView(view: doneButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10.0)
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectFavouritePartnerDialogue.backGroundViewTapped(_:))))
        favouritePartnerTableView.delegate = self
        favouritePartnerTableView.dataSource = self
        favouritePartnerTableView.reloadData()
        
        
    }
    func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        favouritePartnerCompletionHandler?()

    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        favouritePartnerCompletionHandler?()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func handleBrandingChanges(){
        doneButton.backgroundColor = Colors.mainButtonColor
    }
    

    
    @IBAction func selectUserButtonTapped(_ sender: UIButton) {
    
        let cell = favouritePartnerTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! PreferredRidePartnersCell
        
        if selectedUsers[sender.tag] == nil{
            selectedUsers[sender.tag] = true
        }else if selectedUsers[sender.tag] == false{
            selectedUsers[sender.tag] = true
        }else{
            selectedUsers[sender.tag] = false
        }
        setSelectButtonBasedOnSelection(isSelected: selectedUsers[sender.tag],button: cell.selectFavoritePartner)
  
    }
    
    func setSelectButtonBasedOnSelection(isSelected : Bool?,button : UIButton){
        if isSelected != nil && isSelected == true{
            
         button.setImage(UIImage(named: "group_tick_icon"), for: .normal)
            
        }else{
         button.setImage(UIImage(named: "tick_icon"), for: .normal)
            
        }
     
    }
    
    
    @IBAction func positiveActionButtonTapped(_ sender: Any) {
        if self.selectedUsers.values.contains(true){
            self.addSelctedUsersAsRidePartners()
        }
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            favouritePartnerCompletionHandler?()
    }
    func addSelctedUsersAsRidePartners(){
        var feedbackToIds = [Double]()
        for index in 0...userWithFiveStarRating.count-1{
            if selectedUsers[index] == true{
            feedbackToIds.append(userWithFiveStarRating[index].feedbacktophonenumber!)
            }
        }
    AddFavouritePartnerTask.addFavoritePartner(userId: (QRSessionManager.getInstance()?.getUserId())!, favouritePartnerUserIds: feedbackToIds, receiver: self, viewController: self)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritePartnerCell", for: indexPath as IndexPath) as! PreferredRidePartnersCell
        let userWithFiveStarRating = self.userWithFiveStarRating[indexPath.row]
        
        if let image = ImageCache.getInstance()?.getUserImage(imageUrl: userWithFiveStarRating.feebBackToImageURI,gender: userWithFiveStarRating.feedBackToUserGender){
            cell.favoritePartnerImage.image = image
        }else{
            ImageCache.getInstance()?.getUserImage(imageUrl: userWithFiveStarRating.feebBackToImageURI, gender: userWithFiveStarRating.feedBackToUserGender, imageRetrievalHandler: { (image) in
                self.favouritePartnerTableView.reloadData()
            })
        }
        cell.favoritePartnerName.text = userWithFiveStarRating.feebBackToName
        setSelectButtonBasedOnSelection(isSelected: selectedUsers[indexPath.row],button: cell.selectFavoritePartner)
        cell.selectFavoritePartner.tag = indexPath.row
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userWithFiveStarRating.count
    }
    
    func favPartnerAdded() {
  
    }
    
    func favPartnerAddingFailed(responseError: ResponseError) {
        
    }
    
}
