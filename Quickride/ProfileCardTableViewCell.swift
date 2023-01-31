//
//  ProfileCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 13/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProfileCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileCompleteStatusLabel: UILabel!
    @IBOutlet weak var pendingStatusLabel: UILabel!
    @IBOutlet weak var pendingItemCollectionView: UICollectionView!
    @IBOutlet weak var pendingItemCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    //MARK: User statistics
    @IBOutlet weak var userStatsView: UIView!
    @IBOutlet weak var userStatsCollectionView: UICollectionView!
    @IBOutlet weak var userStatsViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    private var verificationCategoryList = [ProfileVerificationCategory]()
    weak var viewController: UIViewController?
    private var userStatistics = [UserStatistic]()
    
    func initialiseViews(viewController: UIViewController) {
        self.viewController = viewController
        setProfileVerificationProgress()
        getUserStatistic()
        if let userProfile = UserDataCache.getInstance()?.getUserProfile(userId: QRSessionManager.getInstance()!.getUserId()) {
            ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: userProfile.imageURI, gender: userProfile.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: progressView, cornerRadius: 3)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileViewTapped(_:))))
        pendingItemCollectionView.register(UINib(nibName: "VerificationCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VerificationCategoryCollectionViewCell")
        userStatsCollectionView.register(UINib(nibName: "UserStatisticsCollectionViewCell", bundle : nil),forCellWithReuseIdentifier: "UserStatisticsCollectionViewCell")
    }
    
    func getUserStatistic() {
        userStatistics.removeAll()
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let noOfRides = UserDataCache.getInstance()?.getTotalCompletedRides() ?? 0
        if let rating = userProfile?.rating, noOfRides > 0{
            userStatistics.append(UserStatistic(imageName: "ic_ratingbar_star_light", title: Strings.ratings, value1: String(rating), value2: " ("+String(userProfile!.noOfReviews)+")"))
        }
                
        if let onTimeComplianceRating = userProfile?.onTimeComplianceRating, onTimeComplianceRating != 0 ,Int(userProfile!.numberOfRidesAsRider) >= ConfigurationCache.getObjectClientConfiguration().totalNoOfRiderRideSharedToShowOnTimeCompliance {
            userStatistics.append(UserStatistic(imageName: "ontime_icon", title: Strings.onTime, value1: String(onTimeComplianceRating)+Strings.percentage_symbol, value2: nil))
        }
        if userStatistics.isEmpty {
            userStatsCollectionView.isHidden = true
            userStatsViewHeightConstraint.constant = 0
        } else {
            userStatsCollectionView.isHidden = false
            userStatsViewHeightConstraint.constant = 100
            userStatsCollectionView.reloadData()
        }
    }
    
    @objc func profileViewTapped(_ gesture : UITapGestureRecognizer){
        if (QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus == .User) {
            let profileVC  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
            
            profileVC.initializeDataBeforePresentingView(profileId: (QRSessionManager.getInstance()?.getUserId())!,isRiderProfile: UserRole.None , rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
            
            parentViewController?.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    //MARK: Methods
    private func setProfileVerificationProgress() {
        let verificationCompletionProgress = UserVerificationUtils.getProfileVerificationProgress()
        progressView.progress = Float(verificationCompletionProgress)
        let percentagePending = 100 - (verificationCompletionProgress * 100)
        if percentagePending <= 0 {
            let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
            progressView.isHidden = true
            profileCompleteStatusLabel.text = userProfile?.userName
            pendingStatusLabel.text = "Your profile is 100% completed"
            pendingItemCollectionView.isHidden = true
            pendingItemCollectionViewHeightConstraint.constant = 0
            profileViewHeightConstraint.constant = 90
        } else {
            pendingStatusLabel.text = "Add details to complete now"
            progressView.isHidden = false
            profileCompleteStatusLabel.text = StringUtils.getStringFromDouble(decimalNumber: percentagePending) + "% pending"
            verificationCategoryList.removeAll()
            verificationCategoryList = UserVerificationUtils.getProfileVerificationCategories()
            pendingItemCollectionView.isHidden = false
            pendingItemCollectionViewHeightConstraint.constant = 40
            profileViewHeightConstraint.constant = 150
            pendingItemCollectionView.reloadData()
        }
    }
}
extension ProfileCardTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pendingItemCollectionView {
            return verificationCategoryList.count
        } else if collectionView == userStatsCollectionView {
            return userStatistics.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pendingItemCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerificationCategoryCollectionViewCell", for: indexPath) as! VerificationCategoryCollectionViewCell
            if verificationCategoryList.endIndex <= indexPath.row {
                return cell
            }
            cell.setupUI(verificationCategory: verificationCategoryList[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserStatisticsCollectionViewCell", for: indexPath) as! UserStatisticsCollectionViewCell
            if userStatistics.endIndex <= indexPath.row {
                return cell
            }
            cell.initialiseData(userStatistic: userStatistics[indexPath.row])
            return cell
        }
    }
}
extension ProfileCardTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pendingItemCollectionView {
            let verificationCategory = verificationCategoryList[indexPath.row].type
            let categoryName = verificationCategoryList[indexPath.row].name
            if verificationCategory == Strings.type_verify_profile {
                let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: verifyProfileViewController, animated: true)
                verifyProfileViewController.intialData(isFromSignUpFlow: false)
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
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
extension ProfileCardTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == pendingItemCollectionView {
            let text = verificationCategoryList[indexPath.item].name
            let cellWidth = text!.size(withAttributes:[.font: UIFont(name: "Helvetica Neue", size: 12) as Any]).width + 35.0
            return CGSize(width: cellWidth + 35, height: 35.0)
        } else {
            if userStatistics[indexPath.item].title == Strings.ratings{
                let label = UILabel(frame: CGRect.zero)
                label.text = userStatistics[indexPath.item].title
                label.sizeToFit()
                return CGSize(width: label.bounds.size.width + 50, height: 65)
            }else{
                let label = UILabel(frame: CGRect.zero)
                label.text = userStatistics[indexPath.item].title
                label.sizeToFit()
                return CGSize(width: label.bounds.size.width + 35, height: 65)
            }
        }
    }
}
