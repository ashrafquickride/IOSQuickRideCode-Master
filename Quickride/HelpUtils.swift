//
//  HelpUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 10/2/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI
import Zip

typealias supportCategorySelectionHandler = (_ issue : String) -> Void


class HelpUtils: UIViewController {

static let Attachment = "Attachment.Zip"
    
    
    
    static func sendEmailToSupport(viewController : UIViewController, image : UIImage?,listOfIssueTypes : [String]){
            AppDelegate.getAppDelegate().log.debug("sendEmailToSupport()")
        let vc = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "sendEmailToSupportViewController") as! sendEmailToSupportViewController
        vc.intialisingListofIssues(listOfIssueTypes: Strings.list_of_issue_types, image: image)
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: false, completion: nil)
        }


    static func sendEmailToSupportWithSubject(delegate : MFMailComposeViewControllerDelegate,viewController : UIViewController, messageBody : String?,image : UIImage?,listOfIssueTypes : [String],subject : String,reciepients : [String]?){
        sendMailAfterSubjectPrepIfSubNotPresent(delegate: delegate, viewController: viewController, messageBody: nil, image: image, listOfIssueTypes: listOfIssueTypes,subject:subject, recipients: reciepients, isZipFileRequired: false)
    }

    static func sendMailAfterSubjectPrepIfSubNotPresent(delegate : MFMailComposeViewControllerDelegate,viewController : UIViewController, messageBody : String?,image : UIImage?,listOfIssueTypes : [String],subject : String?,recipients : [String]?,isZipFileRequired: Bool){
        if MFMailComposeViewController.canSendMail() {

            HelpUtils.displayTypesForIssue(viewController: viewController,image : image, listOfIssueTypes: listOfIssueTypes,handler: { (issue) in

                let userProfile = UserDataCache.getInstance()?.userProfile
                let mailComposeViewController = MFMailComposeViewController()

                if subject == nil{

                    mailComposeViewController.setSubject(getSubjectContentForSupportMail(subject: "", issue: issue, userProfile: userProfile, contactNo: nil))
                    if messageBody != nil &&  messageBody?.isEmpty == false
                    {
                        mailComposeViewController.setMessageBody(messageBody!, isHTML: false)
                    }

                }else{
                    var sub = subject
                    sub = sub! + issue
                    mailComposeViewController.setSubject(sub!)
                }

                mailComposeViewController.mailComposeDelegate = delegate

                if recipients == nil{
                    var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
                    if clientConfiguration == nil{
                        clientConfiguration = ClientConfigurtion()
                    }
                    var recepients = [String]()
                    recepients.append(clientConfiguration!.emailForSupport)
                    mailComposeViewController.setToRecipients(recepients)
                }else{
                    mailComposeViewController.setToRecipients(recipients!)
                }
                AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.HELP_SUPPORT_RAISED, params: [
                    "time of click" : DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa) ?? "",
                    "userId" : userProfile?.userId ?? ""], uniqueField: User.FLD_USER_ID)

                var filePaths = [URL]()


                if image != nil{


                    if let data = image!.jpegData(compressionQuality: 1.0){
                        do {
                            let libraryDirectory = FileManager.default.urls(for: .libraryDirectory , in: .userDomainMask).first
                            let fileName = "image.jpg"
                            let fileURL = libraryDirectory?.appendingPathComponent(fileName)
                            try data.write(to: fileURL!)
                            filePaths.append(fileURL!)
                            let imageData = (image ?? UIImage()).pngData()
                            mailComposeViewController.addAttachmentData(imageData ?? Data(), mimeType: "image/png", fileName: "image.png")
                        } catch {
                            AppDelegate.getAppDelegate().log.debug("Image Saving failed")
                        }
                    }


                }else{

                    let logPath = AppDelegate.getAppDelegate().logPath
                    if logPath != nil{

                        filePaths.append(logPath!)
                    }

                    let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
                    if logPathBackup != nil{
                        filePaths.append(logPathBackup!)
                    }
                }


                if isZipFileRequired{
                    do{
                        let zipFilePath = try Zip.quickZipFiles(filePaths, fileName: "LogFiles")
                        if let fileData = NSData(contentsOf: zipFilePath as URL){
                            mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "application/zip", fileName: Attachment)

                        }
                    }catch{
                        AppDelegate.getAppDelegate().log.debug("Zipping failed")
                    }
                }

                ViewControllerUtils.presentViewController(currentViewController: viewController, viewControllerToBeDisplayed : mailComposeViewController, animated : false, completion:nil)
            })
        } else {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
        }
    }

    static func getSubjectContentForSupportMail(subject : String,issue : String?,userProfile : UserProfile?,contactNo : String?) -> String{
        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion

        var subj = subject

        if issue != nil{
           subj = subj + issue! + " - "
        }
        if userProfile?.userName != nil{
            subj = subj+(userProfile?.userName)!
        }
        if userProfile?.userId != nil{
            let currentSession = QRSessionManager.getInstance()!.getCurrentSession()
            subj = subj + " - \(currentSession.contactNo)"
        }else if contactNo != nil{
            subj = subj + " - mobile - \(contactNo!)"
        }

        if userProfile?.emailForCommunication != nil{
            subj = subj + " - "+(userProfile?.emailForCommunication)!
        }else if userProfile?.email != nil{
            subj = subj + " - "+(userProfile?.email)!
        }
        let currentSession = QRSessionManager.getInstance()!.getCurrentSession()
        if !currentSession.userId.isEmpty && Int64(currentSession.userId) != 0{
            let currentSession = QRSessionManager.getInstance()!.getCurrentSession()
            subj = subj + " User Id - "+currentSession.userId
        }
        subj = subj + " - Device Information : "+modelName+","+systemVersion+"- QR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO

        return subj
    }

    static func sendMailToSupportWithSubject(delegate : MFMailComposeViewControllerDelegate,viewController : UIViewController, messageBody : String?,subject : String,contactNo : String?, image: UIImage?){
        let userProfile = UserDataCache.getInstance()?.userProfile
        let mailComposeViewController = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.setSubject(getSubjectContentForSupportMail(subject: subject, issue: nil, userProfile: userProfile, contactNo: contactNo))
            if messageBody != nil &&  messageBody?.isEmpty == false
            {
                mailComposeViewController.setMessageBody(messageBody!, isHTML: false)
            }
            mailComposeViewController.mailComposeDelegate = delegate
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            var recepients = [String]()
            recepients.append(clientConfiguration!.emailForSupport)
            mailComposeViewController.setToRecipients(recepients)
            if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
            }
            var filePaths = [URL]()
            if image != nil{

                if let data = image!.jpegData(compressionQuality: 1.0){
                    do {
                        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory , in: .userDomainMask).first
                        let fileName = "image.jpg"
                        let fileURL = libraryDirectory?.appendingPathComponent(fileName)
                        try data.write(to: fileURL!)
                        filePaths.append(fileURL!)
                        let imageData = (image ?? UIImage()).pngData()
                        mailComposeViewController.addAttachmentData(imageData ?? Data(), mimeType: "image/png", fileName: "image.png")
                    } catch {
                        AppDelegate.getAppDelegate().log.debug("Image Saving failed")
                    }
                }


            }else{

                let logPath = AppDelegate.getAppDelegate().logPath
                if logPath != nil{

                    filePaths.append(logPath!)
                }

                let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
                if logPathBackup != nil{
                    filePaths.append(logPathBackup!)
                }
            }

            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            ViewControllerUtils.presentViewController(currentViewController: viewController, viewControllerToBeDisplayed : mailComposeViewController, animated : false, completion:nil)
        }else {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
        }

    }

    static func displayTypesForIssue(viewController : UIViewController,image : UIImage?,listOfIssueTypes : [String], handler : @escaping supportCategorySelectionHandler){

        let optionMenu = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 18.0)!]

        var titleAttrString : NSMutableAttributedString?
        if image == nil{
            titleAttrString = NSMutableAttributedString(string: Strings.select_issue_type, attributes: messageFont)
        }else{
            titleAttrString = NSMutableAttributedString(string: Strings.select_report_type, attributes: messageFont)
        }
         optionMenu.setValue(titleAttrString, forKey: "attributedTitle")

        for issue in listOfIssueTypes
        {
            let action = UIAlertAction(title: issue, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                handler(issue)
            })
            optionMenu.addAction(action)
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        let height : NSLayoutConstraint = NSLayoutConstraint(item: optionMenu.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: viewController.view.frame.height * 0.50)
        optionMenu.view.addConstraint(height)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        viewController.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor

        })
    }

    static func displayMailStatusAndDismiss(controller: MFMailComposeViewController, result: MFMailComposeResult){
        switch result {
        case .cancelled :
            UIApplication.shared.keyWindow?.makeToast(Strings.email_sending_cancelled)

        case .failed :
            UIApplication.shared.keyWindow?.makeToast(Strings.email_sending_failed)

        case .saved :
            UIApplication.shared.keyWindow?.makeToast(Strings.email_sending_saved)

        case .sent :
            UIApplication.shared.keyWindow?.makeToast(Strings.email_sent)
        }
        controller.dismiss(animated: false, completion: nil)
    }

    static func sendMailToSpecifiedAddress(delegate : MFMailComposeViewControllerDelegate,viewController : UIViewController,subject : String?,toRecipients : [String],ccRecipients: [String],mailBody: String){
         if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = delegate
            if subject != nil{
                mailComposeViewController.setSubject(subject!)
            }
            mailComposeViewController.setToRecipients(toRecipients)
            mailComposeViewController.setCcRecipients(ccRecipients)
            mailComposeViewController.setMessageBody(mailBody, isHTML: false)
            mailComposeViewController.modalPresentationStyle = .overCurrentContext
            ViewControllerUtils.presentViewController(currentViewController: viewController, viewControllerToBeDisplayed : mailComposeViewController, animated : false, completion:nil)
         }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
         }
    }
    static func getRecentBlogToDisplay() -> Blog?{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        var blogs = clientConfiguration.blogList
        if blogs.isEmpty{
            return nil
        }
        else{
            blogs.sort(by: {if $0.lastDisplayedTime == nil{
                return true
            }else if $1.lastDisplayedTime == nil{
                return false
            }
                return $0.lastDisplayedTime! < $1.lastDisplayedTime!
            })
            let blog = blogs[0]
            clientConfiguration.updateLastDisplayedTimeOfBlogInSharedPreference(time: NSDate().getTimeStamp(), blogId: blog.id)
            return blog
        }
    }
}
