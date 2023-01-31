//
//  UploadImageUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 5/29/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import AVFoundation

public typealias alertControllerImageSelectionActionHandler = (_ isUpdated : Bool, _ imageURI : String?, _ image : UIImage?) -> Void
 class UploadImageUtils: NSObject {
    
    var imagePicker = UIImagePickerController()
    var viewController : UIViewController?
    var isRemoveOptionApplicable : Bool?
    var completionHandler : alertControllerImageSelectionActionHandler?
    var delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    init(isRemoveOptionApplicable : Bool, viewController: UIViewController?,delegate:(UIImagePickerControllerDelegate & UINavigationControllerDelegate),completionHandler : @escaping alertControllerImageSelectionActionHandler) {
        self.isRemoveOptionApplicable = isRemoveOptionApplicable
        self.viewController = viewController
        self.delegate = delegate
        self.completionHandler = completionHandler
    }
    
    func handleImageSelection(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = true
        sheet.addAction(UIAlertAction(title: Strings.take_new_photo, style:
                                        UIAlertAction.Style.default, handler: { [self] (action) -> Void in
                                            
                                            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized { //already authorized
                                                takePhoto()
                                            }else if AVCaptureDevice.authorizationStatus(for: .video) ==  .notDetermined{ // notDetermined
                                                showCameraPermissionReason(isRequiredToGoSettings: false)
                                            }else if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted{ //denied
                                                showCameraPermissionReason(isRequiredToGoSettings: true)
                                            }
                                        }))
        sheet.addAction(UIAlertAction(title: Strings.choose_existing, style: UIAlertAction.Style.default, handler: { [self] (action) -> Void in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.modalPresentationStyle = .overCurrentContext
            viewController?.present(imagePicker, animated: false, completion: nil)
        }))
        
        if (isRemoveOptionApplicable!) {
            sheet.addAction(UIAlertAction(title: Strings.remove_photo, style: UIAlertAction.Style.default, handler: { [self] (action) -> Void in
                self.completionHandler?(true, nil, nil)
                viewController?.dismiss(animated: true, completion: nil)
            }))
        }
        
        sheet.addAction(UIAlertAction(title: Strings.cancel, style: UIAlertAction.Style.cancel, handler: {  (action) -> Void in
        }))
        viewController?.present(sheet, animated: true, completion: nil)
    }
    
    private func showCameraPermissionReason(isRequiredToGoSettings: Bool){
        let permissionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AppPermissionsConfirmationViewController") as! AppPermissionsConfirmationViewController
        permissionVC.showConfirmationView(permissionType: .Camera,isRequiredToGoSettings: isRequiredToGoSettings) { [self] (isConfirmed) in
            if isConfirmed{
                self.takePhoto()
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if !granted {//access denied
                        DispatchQueue.main.async{ () -> Void in
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: permissionVC)
    }
    
    private func takePhoto(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice =  UIImagePickerController.CameraDevice.rear
            imagePicker.modalPresentationStyle = .overCurrentContext
            viewController?.present(imagePicker, animated: false, completion: nil)
        }else{
            MessageDisplay.displayAlert(messageString: "Sorry, Camera not present.",viewController: viewController,handler: nil)
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    static func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
