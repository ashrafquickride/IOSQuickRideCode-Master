//
//  AccountSectionProfileTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 18/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol AccountSectionProfileTableViewCellDelegate: class {
    func viewProfilePressed()
}

class AccountSectionProfileTableViewCell: UITableViewCell {
    //MARK: OUTLET
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifiedStatusImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    //Verification Category
    @IBOutlet weak var profileCompletenessView: UIView!
    @IBOutlet weak var profileCompletenessViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var verificationCollectionView: UICollectionView!
    @IBOutlet weak var verificationProgressView: UIProgressView!
    @IBOutlet weak var percentagePendingLabel: UILabel!

    weak var delegate: AccountSectionProfileTableViewCellDelegate?
    private var accountSectionProfileTableViewModel = AccountSectionProfileTableViewModel()
    weak var viewController: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: Initializer
    func initialiseData(viewController: UIViewController) {
        self.viewController = viewController
    }

    func setUpUI(userProfileObject: UserProfile) {
        accountSectionProfileTableViewModel.verificationCategoryList = UserVerificationUtils.getProfileVerificationCategories()
        verificationCollectionView.register(UINib(nibName: "VerificationCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VerificationCategoryCollectionViewCell")
        verificationCollectionView.reloadData()
        let verificationCompletionProgress = UserVerificationUtils.getProfileVerificationProgress()
        verificationProgressView.progress = Float(verificationCompletionProgress)
        let percentagePending = 100 - (verificationCompletionProgress * 100)
        if percentagePending <= 0 {
            profileCompletenessView.isHidden = true
            profileCompletenessViewHeightConstraint.constant = 0
        } else {
            profileCompletenessView.isHidden = false
            profileCompletenessViewHeightConstraint.constant = 160
            percentagePendingLabel.text = StringUtils.getStringFromDouble(decimalNumber: percentagePending) + "% pending"
        }
        nameLabel.text = UserDataCache.getInstance()?.getUserName().capitalized
        verifiedStatusImage.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userProfileObject.profileVerificationData)
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userProfileObject.profileVerificationData, companyName: userProfileObject.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        } else {
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        ImageCache.getInstance().setImageToView(imageView: self.profileImageView, imageUrl: userProfileObject.imageURI, gender: userProfileObject.gender!, imageSize: ImageCache.DIMENTION_SMALL)
    }

    @IBAction func viewProfileOptionPressed(_ sender: UIButton) {
        delegate?.viewProfilePressed()
    }

}

extension AccountSectionProfileTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountSectionProfileTableViewModel.verificationCategoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerificationCategoryCollectionViewCell", for: indexPath) as! VerificationCategoryCollectionViewCell
        cell.setupUI(verificationCategory: accountSectionProfileTableViewModel.verificationCategoryList[indexPath.row])
        return cell
    }
}

extension AccountSectionProfileTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let verificationCategory = accountSectionProfileTableViewModel.verificationCategoryList[indexPath.row].type
        let categoryName = accountSectionProfileTableViewModel.verificationCategoryList[indexPath.row].name
        if verificationCategory == Strings.type_verify_profile {
            let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
           verifyProfileViewController.intialData(isFromSignUpFlow: false)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: verifyProfileViewController, animated: true)
        } else if verificationCategory == Strings.type_upload_photo {
            let profileEditViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditingViewController") as! ProfileEditingViewController
            profileEditViewController.initializeView(setProfileImage: true, setDesignation: false)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profileEditViewController, animated: true)
        } else if verificationCategory == Strings.add_professional_profile {
            if categoryName == Strings.add_skills {
                let hobbiesAndSkillsViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HobbiesAndSkillsViewController") as! HobbiesAndSkillsViewController
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: hobbiesAndSkillsViewController, animated: true)
            } else {
                let profileEditViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditingViewController") as! ProfileEditingViewController
                profileEditViewController.initializeView(setProfileImage: false, setDesignation: true)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profileEditViewController, animated: true)
            }
        } else if verificationCategory == Strings.add_personal_profile {
            let hobbiesAndSkillsViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HobbiesAndSkillsViewController") as! HobbiesAndSkillsViewController
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: hobbiesAndSkillsViewController, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension AccountSectionProfileTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = accountSectionProfileTableViewModel.verificationCategoryList[indexPath.item].name
        let cellWidth = text!.size(withAttributes: [.font: UIFont(name: "Helvetica Neue", size: 12) as Any]).width + 35.0
        return CGSize(width: cellWidth + 35, height: 35.0)
    }
}
