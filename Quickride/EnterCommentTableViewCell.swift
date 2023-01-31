//
//  EnterCommentTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class EnterCommentTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBOutlet weak var commentingUserImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var comment: String?
    private var listingId: String?
    private var type: String?
    func initialiseCommentView(listingId: String,commentsCount: Int,type: String){
        self.listingId = listingId
        self.type = type
        let userProfile = UserDataCache.getInstance()?.userProfile
        ImageCache.getInstance().setImageToView(imageView: commentingUserImageView, imageUrl:  userProfile?.imageURI ?? "", gender:  userProfile?.gender ?? "" , imageSize: ImageCache.DIMENTION_SMALL)
        commentsCountButton.setTitleColor(Colors.link, for: .normal)
        if commentsCount == 1{
            commentsCountButton.setTitle(String(format: Strings.no_of_comment, arguments: [String(commentsCount)]), for: .normal)
        }else if commentsCount > 1{
            commentsCountButton.setTitle(String(format: Strings.no_of_comments, arguments: [String(commentsCount)]), for: .normal)
        }else{
            commentsCountButton.setTitle(Strings.no_comments, for: .normal)
            commentsCountButton.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .normal)
        }
        textView.delegate = self
        textView.textColor = UIColor.black.withAlphaComponent(0.4)
    }
    @IBAction func sendButtonTapped(_ sender: Any) {
        textView.endEditing(true)
        comment = textView.text
        textView.textColor = UIColor.black.withAlphaComponent(0.4)
        textView.text =  Strings.add_comment_here
        sendButton.isHidden = true
        QuickRideProgressSpinner.startSpinner()
        QuickShareRestClient.addCommentToProduct(listingId: listingId ?? "", commentId: nil, userId: UserDataCache.getInstance()?.userId ?? "", comment: comment ?? "", parentId: nil,type: type ?? ""){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var productComment = Mapper<ProductComment>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : Any]()
                self.comment = nil
                let userProfile = UserDataCache.getInstance()?.userProfile
                let userBasicInfo = UserBasicInfo(userId: userProfile?.userId ?? 0, gender: userProfile?.gender, userName: userProfile?.userName ?? "", imageUri: userProfile?.imageURI, callSupport: userProfile?.supportCall ?? "")
                productComment?.userBasicInfo = userBasicInfo
                userInfo["productComment"] = productComment
                NotificationCenter.default.post(name: .newCommentAdded, object: nil, userInfo: userInfo)
            } else {
                self.textView.text = self.comment
                self.sendButton.isHidden = false
                self.textView.textColor = .black
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    @IBAction func commentsTapped(_ sender: Any) {
       NotificationCenter.default.post(name: .showAllComments, object: nil)
    }
}
//UITextViewDelegate
extension EnterCommentTableViewCell: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text == nil || textView.text.isEmpty || textView.text ==  Strings.add_comment_here{
            textView.text = ""
            sendButton.isHidden = true
            textView.textColor = .black
        }else{
            sendButton.isHidden = false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text.isEmpty || (textView.text.trimmingCharacters(in: NSCharacterSet.whitespaces)).count == 0{
            sendButton.isHidden = true
        }else{
            sendButton.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if textView.text.isEmpty == true {
            textView.textColor = UIColor.black.withAlphaComponent(0.4)
            textView.text =  Strings.add_comment_here
            sendButton.isHidden = true
        }
        textView.endEditing(true)
        resignFirstResponder()
    }
}
