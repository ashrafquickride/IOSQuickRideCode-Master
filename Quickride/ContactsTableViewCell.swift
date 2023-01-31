//
//  ContactsTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol ContactSelectionDelegate{
    func contactSelectedAtIndex(row :Int,contact : Contact)
    func contactUnSelectedAtIndex(row : Int,contact : Contact)
}

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactId: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    
    @IBOutlet weak var quickRideBadge: UIImageView!
    
    
    @IBOutlet weak var inviteButton: UIButton!
    
    var userContact : Contact?
    var contactSelectionDelegate : ContactSelectionDelegate?
    var userSelected = false
    var row : Int?
    var contactUIImage :UIImage?
    
    func initializeViews(contact : Contact, image : UIImage? ,row: Int){
        self.userContact = contact
        self.row = row
        self.contactUIImage = image?.circle
      
        self.contactName.text = contact.contactName
        
        if let appStartUpData = SharedPreferenceHelper.getAppStartUpData(),!appStartUpData.enableNumberMasking{
           self.contactId.text = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
        }
        setContactImage()
      
        if contact.contactType == Contact.RIDE_PARTNER{
          self.quickRideBadge.isHidden = false
        }else{
          self.quickRideBadge.isHidden = true
        }
    
      self.contactImage.isUserInteractionEnabled = false
    }
  func initializeMultipleSelection(contactSelectionDelegate : ContactSelectionDelegate,isSelected : Bool?){
    if isSelected != nil{
      self.userSelected = isSelected!
    }else{
      self.userSelected = false
    }
    self.contactSelectionDelegate = contactSelectionDelegate
    self.contactImage.isUserInteractionEnabled = true
    setContactImage()
    self.contactImage.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(ContactsTableViewCell.tapped(_:))))
    
  }
    @objc func tapped(_ sender:UITapGestureRecognizer) {
        userSelected = !userSelected
        userImageTapped()
    }
    
    func setContactImage(){
        if userSelected == true{
            self.contactImage.image = UIImage(named: "rider_select")
        }else if contactUIImage != nil{
            self.contactImage.image = contactUIImage
        }else if userContact!.contactType == Contact.RIDE_PARTNER{
            ImageCache.getInstance().setImageToView(imageView: self.contactImage, imageUrl: userContact!.contactImageURI, gender: userContact!.contactGender,imageSize: ImageCache.DIMENTION_TINY)
        }else{
            self.contactImage.image = UIImage(named: "default_contact")
        }
    }
    func userImageTapped(){
        if (userSelected) {
            UIImageView.transition(with: contactImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            contactSelectionDelegate?.contactSelectedAtIndex(row: row!, contact: userContact!)
        } else {
            UIImageView.transition(with: contactImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            contactSelectionDelegate?.contactUnSelectedAtIndex(row: row!,contact: userContact!)
        }
    }

}
