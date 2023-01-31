//
//  UserFeedbackViewController.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/21/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Foundation
import ObjectMapper

protocol  saveFeedBackVCDelegate: class {
    func saveBtnPressed(feedBackData: UserFeedback)
}

class UserFeedbackViewController: UIViewController,UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var viewSubmit: UIView!

    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet var labelUserName : UILabel!

    @IBOutlet var imageViewRating: UIImageView!

    @IBOutlet var labelTitleBasedOnStart: UILabel!

    @IBOutlet var labelFeedBackTitle: UILabel!

    @IBOutlet var commentsTextField: UITextField!

    @IBOutlet weak var oneStar: UIImageView!

    @IBOutlet weak var twoStar: UIImageView!

    @IBOutlet weak var threeStar: UIImageView!

    @IBOutlet weak var fourStar: UIImageView!

    @IBOutlet weak var fiveStar: UIImageView!

    @IBOutlet weak var starSelectedView: UIView!

    @IBOutlet weak var dontShowBtn: UIButton!

    @IBOutlet weak var dontShowAgainView: UIView!

    @IBOutlet weak var dontShowLabel: UILabel!

    @IBOutlet weak var viewRating: UIView!

    @IBOutlet weak var collectionView: UICollectionView!


    @IBOutlet weak var categoryCollectionView: UICollectionView!

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var dataView: UIView!

    @IBOutlet weak var viewStarForNextUser: UIView!

    @IBOutlet weak var oneStarFromNextUserRating: UIImageView!

    @IBOutlet weak var twoStarFromNextUserRating: UIImageView!

    @IBOutlet weak var threeStarFromNextUserRating: UIImageView!

    @IBOutlet weak var fourStarFromNextUserRating: UIImageView!

    @IBOutlet weak var fiveStarFromNextUserRating: UIImageView!

    @IBOutlet weak var starSelectedViewFromNextUserRating: UIView!

    @IBOutlet weak var labelNextUserRatingTitle: UILabel!

    @IBOutlet weak var nextUserImageView: UIImageView!

    @IBOutlet weak var nextUserView: UIView!

    @IBOutlet weak var nextUserRidePoints: UILabel!

    @IBOutlet weak var nextUserName: UILabel!

    @IBOutlet weak var backButton: CustomUIButton!

    var rideId : Double = 0
    var userFeedbackMap:  UserFeedback?
    var isKeyBoardVisible = false
    var riderType: String?
    var isFromClosedRidesOrTransaction = false
    var selectedUsers : [Int : Bool] = [Int : Bool]()
    var dontShowList : [Int : Bool] = [Int : Bool]()
    var isFeedbackRequiredLabelDisplayed = false
    var clientConfiguration : ClientConfigurtion?
    var selectedIndex = 0
    var selectedCategory :String?
    var rideEtiquettesCategories = [String]()
    var rideEtiquettes = [String :[RideEtiquette]]()
    var selectedFeedBackComments = [Double: RideEtiquette]()
    var tripReport : TripReport?
    weak var delegate: saveFeedBackVCDelegate?
    func initializeDataBeforePresenting(rideId : Double, isFromClosedRidesOrTransaction : Bool, userFeedbackMap : UserFeedback, riderType : String)  {
        self.isFromClosedRidesOrTransaction = isFromClosedRidesOrTransaction
        self.rideId = rideId
        self.userFeedbackMap = userFeedbackMap
        self.riderType = riderType
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isScrollEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: viewStarForNextUser, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        commentsTextField.delegate = self
        ViewCustomizationUtils.addCornerRadiusToView(view: submitButton, cornerRadius: 7.0)
        NotificationCenter.default.addObserver(self, selector: #selector(UserFeedbackViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserFeedbackViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: "FeedbackReasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedbackReasonCollectionViewCell")
        categoryCollectionView.register(UINib(nibName: "FeedbackCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedbackCategoryCollectionViewCell")
        userRatingIntialize(rating: Int(userFeedbackMap?.rating ?? 1))
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(UserFeedbackViewController.starSelectedViewTapped(_:)))
        starSelectedView.addGestureRecognizer(tapGestureRecognizer)
        starSelectedView.isUserInteractionEnabled = true
        dontShowAgainView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(UserFeedbackViewController.dontShowViewTapped(_:))))
    }

    override func viewDidAppear(_ animated: Bool) {
        viewSubmit.addShadow()
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: dataView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryCollectionView {
            return rideEtiquettesCategories.count
        }else {
            if let selectedCategory = self.selectedCategory, let subList = rideEtiquettes[selectedCategory] {
                return subList.count
            }
            return 0
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCategoryCollectionViewCell", for: indexPath) as! FeedbackCategoryCollectionViewCell
            if rideEtiquettesCategories.endIndex <= indexPath.row{
                return cell
            }
            let category = rideEtiquettesCategories[indexPath.row]
            cell.categoryIV.image = FeedbackCategorySegregator.categoryImageMap[category]
            cell.categoryLbl.text = category
//            let selectedReasons = [RideEtiquette](selectedFeedBackComments.values)
//            if !selectedReasons.isEmpty {
//                var selected = false
//
//                let itemsInCategory = rideEtiquettes[category]
//                for item in itemsInCategory! {
//                    let contains = selectedReasons.contains(where: { element in
//                        return element.feedbackMsg == item.feedbackMsg
//                    })
//                    if contains {
//                        selected = true
//                        break
//                    }
//                }
//                cell.backGroundView.alpha = selected ? 1 : 0.5
//            }else{
//                cell.backGroundView.alpha = 1
//            }
            if let selectedCategory = selectedCategory {
                cell.backGroundView.alpha = category == selectedCategory ? 1 : 0.5
            }else {
                cell.backGroundView.alpha = 1
            }


            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackReasonCollectionViewCell", for: indexPath) as! FeedbackReasonCollectionViewCell
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = rideEtiquettes[selectedCategory] else {
                return cell
            }
            let etiquette = reasonForCategory[indexPath.row]
            cell.reasonLabel.text = etiquette.feedbackMsg
            cell.reasonView.backgroundColor = selectedFeedBackComments[etiquette.id!] != nil ? UIColor(netHex: 0x000000).withAlphaComponent(0.2) : UIColor(netHex: 0xF7F7F7)
            cell.reasonView.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
            cell.reasonView.layer.shadowRadius = 1
            cell.reasonView.layer.shadowOffset = CGSize(width: 0,height: 1)
            cell.reasonView.layer.shadowOpacity = 1
            ViewCustomizationUtils.addCornerRadiusToView(view: cell.reasonView, cornerRadius: 15)
            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: 65, height : 75)
        }else {
            guard let selectedCategory = self.selectedCategory, let reasonForCategory = rideEtiquettes[selectedCategory] else {
                return CGSize(width: 120, height : 40)
            }
            let label = UILabel(frame: CGRect.zero)
            label.text = reasonForCategory[indexPath.item].feedbackMsg
            label.sizeToFit()
            return CGSize(width: label.frame.width + 25, height: 40)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if rideEtiquettesCategories.endIndex <= indexPath.row{
                return
            }
            let category = rideEtiquettesCategories[indexPath.row]
            if category != selectedCategory{
                self.selectedCategory = category
                self.collectionView.isHidden = false
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.collectionView.reloadData()
                self.categoryCollectionView.reloadData()

            }
        }else{
            guard let selectedCategory = selectedCategory, let subList = rideEtiquettes[selectedCategory] else {
                return
            }
            if subList.endIndex <= indexPath.row{
                return
            }
            let selected  = subList[indexPath.row]
            guard let id = selected.id , id != 0 else {
                return
            }
            if let _ = selectedFeedBackComments[id] {
                selectedFeedBackComments.removeValue(forKey: id)
            }else {
                selectedFeedBackComments[id] = selected
            }
            categoryCollectionView.reloadData()
            self.collectionView.reloadData()
        }


    }

//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        if collectionView == self.collectionView {
//            collectionView.deselectItem(at: indexPath, animated: true)
//            let selected  = subList[indexPath.row]
//            guard let id = selected.id , id != 0 else {
//                return
//            }
//            selectedFeedBackComments.removeValue(forKey: id)
//            return false
//        }
//
//        return true
//    }

    @objc func keyBoardWillShow(notification : NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("")
            return
        }

        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{

            self.bottomSpaceConstraint.constant = keyBoardSize.height
            isKeyBoardVisible = true

        }
    }

    @objc func keyBoardWillHide(notification: NSNotification)
    {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("")
            return
        }
        isKeyBoardVisible = false
        self.bottomSpaceConstraint.constant = 0
    }


    @IBAction func btnSubmitFeedbackTapped(_ sender: Any) {
        self.view.endEditing(false)
        var extraInfo = ""
        var feedBackCommentIds = ""
        if !selectedFeedBackComments.isEmpty{
            let keysArray = selectedFeedBackComments.keys.map({StringUtils.getStringFromDouble(decimalNumber: $0)})
            feedBackCommentIds = keysArray.joined(separator: ",")
            var valuesArray = selectedFeedBackComments.values.map { (rideEtiqette) -> String in
                rideEtiqette.feedbackMsg!
            }
            if let comment = commentsTextField.text , comment.isEmpty{
                valuesArray.append(comment)
            }
            extraInfo = valuesArray.joined(separator: ",")
        }


        userFeedbackMap?.extrainfo = extraInfo
        userFeedbackMap?.feedBackCommentIds = feedBackCommentIds
        submitFeedBackAndMoveToNextPage()

    }

    func submitFeedBackAndMoveToNextPage(){
        self.view.endEditing(true)
        AppDelegate.getAppDelegate().log.debug("")
        MyActiveRidesCache.getRidesCacheInstance()?.removeRideDetailInformationForRiderRide(riderRideId: rideId)

        validateSelectedUsersListAndPerformTask()
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.saveUserDirectFeedback(targetViewController: self, body: userFeedbackMap!.getParams(), completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: nil, viewController: self, handler: nil)
                return
            }
            self.checkIfNewUserAndCreditBonusPoints()

        })
    }

    func validateSelectedUsersListAndPerformTask(){

        if dontShowList.values.contains(true)
        {
            self.addUserIDsInPersistence()
        }
    }

    func checkIfNewUserAndCreditBonusPoints(){
        if self.clientConfiguration!.enableFirstRideBonusPointsOffer && RideManagementUtils.retrieveCurrentUserAndCheckWhetherNewUser() {
            RideServicesClient.creditBonusPointsToOldUser(rideType: self.riderType ?? "", rideId: self.rideId, userId: QRSessionManager.getInstance()!.getUserId(), viewController: self, handler: { (responseObject, error) in
            })
            delegate?.saveBtnPressed(feedBackData: userFeedbackMap!)
         self.dismiss(animated: false, completion: nil)
        }else{
          delegate?.saveBtnPressed(feedBackData: userFeedbackMap!)
          self.dismiss(animated: false, completion: nil)
        }
    }

    func addUserIDsInPersistence() {
        SharedPreferenceHelper.storeUserIDInFeedbackGivenList(id: userFeedbackMap?.feedbacktophonenumber! ?? 0.0)
    }

    @objc func starSelectedViewTapped(_ recognizer: UITapGestureRecognizer)
    {
        let tappedPoint: CGPoint = recognizer.location(in: self.starSelectedView!)
        let xpoint: CGFloat = tappedPoint.x
        oneStar.image = UIImage(named: "ratingbar_star_dark_big")
        twoStar.image = UIImage(named: "ratingbar_star_dark_big")
        threeStar.image = UIImage(named: "ratingbar_star_dark_big")
        fourStar.image = UIImage(named: "ratingbar_star_dark_big")
        fiveStar.image = UIImage(named: "ratingbar_star_dark_big")

        let rating = userRatingTaking(xpoint: xpoint)
        userRatingIntialize(rating: rating)

        userFeedbackMap?.rating = Float(rating)
    }

    func userRatingTaking(xpoint: CGFloat) -> Int {
        var userRating:Int?
        if xpoint>170
        {
            userRating = 5

        }
        else if xpoint>127
        {
            userRating = 4
        }
        else if xpoint>86
        {
            userRating = 3
        }
        else if xpoint>46
        {
            userRating = 2
        }
        else if xpoint>=10
        {
            userRating = 1
        }
        else
        {
            userRating = 1
        }
        return userRating!

    }

    func userRatingIntialize(rating: Int) {
        submitButton.setTitle("SUBMIT", for: .normal)
        scrollView.isUserInteractionEnabled = true
        viewRating.isHidden = false
        dataView.isHidden = false
        nextUserView.isHidden = true
        viewStarForNextUser.isHidden = true
        var ratingBackgroundColor : UIColor?
        var title : String?
        var image : UIImage?
        var feedbackCommentsTitle: String?
        if rating == 1
        {
            oneStar.image = UIImage(named: "ratingbar_star_light_big")
            twoStar.image = UIImage(named: "ratingbar_star_dark_big")
            threeStar.image = UIImage(named: "ratingbar_star_dark_big")
            fourStar.image = UIImage(named: "ratingbar_star_dark_big")
            fiveStar.image = UIImage(named: "ratingbar_star_dark_big")
            ratingBackgroundColor = UIColor(netHex: 0xC37474)
            title = "Very Bad Ride!"
            image = UIImage(named: "one_rating_icon")
            feedbackCommentsTitle = "Not expected? Let us know"
        }

        if rating == 2
        {
            oneStar.image = UIImage(named: "ratingbar_star_light_big")
            twoStar.image = UIImage(named: "ratingbar_star_light_big")
            threeStar.image = UIImage(named: "ratingbar_star_dark_big")
            fourStar.image = UIImage(named: "ratingbar_star_dark_big")
            fiveStar.image = UIImage(named: "ratingbar_star_dark_big")
            ratingBackgroundColor = UIColor(netHex: 0x9FC374)
            title = "Bad Ride!"
            image = UIImage(named: "two_rating_icon")
            feedbackCommentsTitle = "Didn't like it?"
        }

        if rating == 3
        {
            oneStar.image = UIImage(named: "ratingbar_star_light_big")
            twoStar.image = UIImage(named: "ratingbar_star_light_big")
            threeStar.image = UIImage(named: "ratingbar_star_light_big")
            fourStar.image = UIImage(named: "ratingbar_star_dark_big")
            fiveStar.image = UIImage(named: "ratingbar_star_dark_big")
            ratingBackgroundColor = UIColor(netHex: 0x67AED3)
            title = "Ok Ok Ride!"
            image = UIImage(named: "three_rating_icon")
            feedbackCommentsTitle = "Not a Good Ride?"
        }

        if rating == 4
        {
            oneStar.image = UIImage(named: "ratingbar_star_light_big")
            twoStar.image = UIImage(named: "ratingbar_star_light_big")
            threeStar.image = UIImage(named: "ratingbar_star_light_big")
            fourStar.image = UIImage(named: "ratingbar_star_light_big")
            fiveStar.image = UIImage(named: "ratingbar_star_dark_big")
            ratingBackgroundColor = UIColor(netHex: 0xD39D67)
            title = "Smooth Ride!"
            image = UIImage(named: "four_rating_icon")
            feedbackCommentsTitle = "Something is missing?"
        }

        if rating == 5
        {
            oneStar.image = UIImage(named: "ratingbar_star_light_big")
            twoStar.image = UIImage(named: "ratingbar_star_light_big")
            threeStar.image = UIImage(named: "ratingbar_star_light_big")
            fourStar.image = UIImage(named: "ratingbar_star_light_big")
            fiveStar.image = UIImage(named: "ratingbar_star_light_big")
            ratingBackgroundColor = UIColor(netHex: 0x67D3C4)
            title = "DelightFul Ride!"
            image = UIImage(named: "five_rating_icon")
            feedbackCommentsTitle = "Give a Compliment?"
            if !UserDataCache.getInstance()!.isFavouritePartner(userId: userFeedbackMap?.feedbacktophonenumber ?? 0.0){
                selectedUsers[selectedIndex] = false
            }
        }

        if rating == 0 {
            scrollView.isUserInteractionEnabled = false
            oneStar.image = UIImage(named: "ic_ratingbar_star_dark")
            twoStar.image = UIImage(named: "ic_ratingbar_star_dark")
            threeStar.image = UIImage(named: "ic_ratingbar_star_dark")
            fourStar.image = UIImage(named: "ic_ratingbar_star_dark")
            fiveStar.image = UIImage(named: "ic_ratingbar_star_dark")
            viewRating.isHidden = true
            dataView.isHidden = true
            viewStarForNextUser.isHidden = false
            labelNextUserRatingTitle.text = "How was your ride with \(String(userFeedbackMap?.feebBackToName ?? ""))"
            commentsTextField.text = nil
            nextUserView.isHidden = false
            dontShowList[selectedIndex] = false
            setDontShowBtnBasedOnSelection(isSelected: dontShowList[selectedIndex],button: self.dontShowBtn)
            nextUserName.text = String(format: Strings.thanks_for_riding, userFeedbackMap?.feebBackToName ?? "")
            ImageCache.getInstance().setImageToView(imageView: nextUserImageView, imageUrl: userFeedbackMap?.feebBackToImageURI, gender: userFeedbackMap?.feedBackToUserGender ?? "",imageSize: ImageCache.DIMENTION_SMALL)

            }

        if riderType == Ride.RIDER_RIDE{
             let list = clientConfiguration!.getRideEtiquetteBasedOnRoleAndRating(role: Ride.PASSENGER_RIDE, rating: String(rating))
            let segregator = FeedbackCategorySegregator()
            self.rideEtiquettes = segregator.segregate(etiquette: list,rideType :riderType!)
            self.rideEtiquettesCategories = segregator.sortFeedbackCategories([String](rideEtiquettes.keys))

        }
        else{
             let list = clientConfiguration!.getRideEtiquetteBasedOnRoleAndRating(role: Ride.RIDER_RIDE, rating: String(rating))
            let segregator = FeedbackCategorySegregator()
            self.rideEtiquettes = segregator.segregate(etiquette: list,rideType :riderType!)
            self.rideEtiquettesCategories = segregator.sortFeedbackCategories([String](rideEtiquettes.keys))

        }
        if rideEtiquettesCategories.isEmpty{
            labelFeedBackTitle.isHidden = true
            collectionView.isHidden = true
            categoryCollectionView.isHidden = true
        }
        else{
            labelFeedBackTitle.isHidden = false

            categoryCollectionView.isHidden = false
            categoryCollectionView.delegate = self
            categoryCollectionView.dataSource = self
            collectionView.isHidden = true
            selectedFeedBackComments = [Double: RideEtiquette]()
            selectedCategory = nil
            categoryCollectionView.reloadData()

        }
        initializeViewBasedOnRating(color: ratingBackgroundColor, ratingTitle: title, ratingImage: image, feedbackCommentsTitle: feedbackCommentsTitle)
    }

    func initializeViewBasedOnRating(color: UIColor?, ratingTitle: String?, ratingImage: UIImage?, feedbackCommentsTitle: String?){
        viewRating.backgroundColor = color
        labelTitleBasedOnStart.text = ratingTitle
        imageViewRating.image = ratingImage
        labelUserName.text = userFeedbackMap?.feebBackToName
        labelFeedBackTitle.text = feedbackCommentsTitle
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let threshold = 512

        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold
    }

    @objc func dontShowViewTapped(_ recognizer: UITapGestureRecognizer)
    {
        if dontShowList[selectedIndex] == nil{
            dontShowList[selectedIndex] = true
        }else if dontShowList[selectedIndex] == false{
            dontShowList[selectedIndex] = true
        }else{
            dontShowList[selectedIndex] = false
        }
        setDontShowBtnBasedOnSelection(isSelected: dontShowList[selectedIndex],button: self.dontShowBtn)
    }

    func setDontShowBtnBasedOnSelection(isSelected : Bool?,button : UIButton)
    {
        if isSelected != nil && isSelected == true
        {
            button.setImage(UIImage(named: "group_tick_icon"), for: .normal)
        }
        else
        {
            button.setImage(UIImage(named: "tick_icon"), for: .normal)
        }
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        if let rating = userFeedbackMap?.rating, rating > 3 {
            UserRestClient.saveUserDirectFeedback(targetViewController: self, body: userFeedbackMap!.getParams(), completionHandler: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: nil, viewController: self, handler: nil)
                    return
                }
                self.checkIfNewUserAndCreditBonusPoints()
                self.dismiss(animated: true, completion: nil)
            })
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
