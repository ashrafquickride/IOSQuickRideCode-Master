//
//  AddPhotosTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MobileCoreServices

protocol AddPhotosTableViewCellDelegate {
    func addedProductPictures(pictures: [UIImage],upadtedPhoto: UIImage?,index: Int)
    func productVideo(videoFile: String?)
}

class AddPhotosTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var titleView: QuickRideCardView!
    @IBOutlet weak var productTitleTextField: UITextField!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var photosCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var addVideoLabel: UILabel!
    @IBOutlet weak var videoSizeORVideoNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: Variables
    private var photos = [UIImage]()
    private var delagate: AddPhotosTableViewCellDelegate?
    private let imagePickerController = UIImagePickerController()
    private var photoSelectionIndex = 0
    func initialisePhotos(product: Product?,videoFileName: String?,photos: [UIImage],delagate: AddPhotosTableViewCellDelegate){
        self.delagate = delagate
        self.photos = photos
        productTitleTextField.delegate = self
        if let title = product?.title{
           productTitleTextField.text = title
        }else{
            productTitleTextField.becomeFirstResponder()
        }
        photosCollectionView.register(UINib(nibName: "AddPhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddPhotosCollectionViewCell")
        handleCollectionViewHeight()
    }
    
    private func handleCollectionViewHeight(){
        if getNumberNoOfRows() > 3{
            photosCollectionViewHeight.constant = 140
        }else{
            photosCollectionViewHeight.constant = 65
        }
        photosCollectionView.reloadData()
    }
    
    @IBAction func addVideoTapped(_ sender: Any){
        selectOrTakeViedoForProduct()
    }
    private func selectOrTakeViedoForProduct(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        sheet.addAction(UIAlertAction(title: Strings.take_video, style:
            UIAlertAction.Style.default, handler: { (action) -> Void in
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    imagePicker.mediaTypes = [(kUTTypeMovie as String)]
                    imagePicker.cameraCaptureMode = .video
                    imagePicker.cameraDevice =  UIImagePickerController.CameraDevice.rear
                    imagePicker.modalPresentationStyle = .overCurrentContext
                    self.parentViewController?.present(imagePicker, animated: false, completion: nil)
                }else{
                    MessageDisplay.displayAlert(messageString: "Sorry, Camera not present.",viewController: self.parentViewController,handler: nil)
                }
                
        }))
        sheet.addAction(UIAlertAction(title: Strings.cancel, style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
        }))
        self.parentViewController?.present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func deleteVideoTapped(_ sender: Any) {
        delagate?.productVideo(videoFile: nil)
        changeVideoTextBasedStatus(videoFileName: nil)
    }
    
    private func changeVideoTextBasedStatus(videoFileName: String?){
        cameraImage.image = cameraImage.image?.withRenderingMode(.alwaysTemplate)
        if let file = videoFileName{
            deleteButton.isHidden = false
            cameraImage.tintColor = .black
            addVideoLabel.text = Strings.video_uploaded
            addVideoLabel.textColor = UIColor.black
            videoSizeORVideoNameLabel.text = file
        }else{
            addVideoLabel.text = Strings.add_video
            videoSizeORVideoNameLabel.text = Strings.video_size_text
            deleteButton.isHidden = true
            addVideoLabel.textColor = Colors.link
            cameraImage.tintColor = Colors.link
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func getNumberNoOfRows() -> Int{
        return photos.count + 1
    }
}

//MARK: UICollectionViewDataSource
extension AddPhotosTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if getNumberNoOfRows() > 5{
            return 5
        }else{
            return getNumberNoOfRows()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotosCollectionViewCell", for: indexPath) as! AddPhotosCollectionViewCell
        cell.cancelButton.tag = indexPath.row
        if indexPath.row < photos.count{
            cell.initialisePhoto(image: photos[indexPath.row])
        }else{
            cell.initialisePhoto(image: nil)
        }
        return cell
    }
}
//MARK: UICollectionViewDelegate
extension AddPhotosTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoSelectionIndex = indexPath.row
        if  indexPath.row < photos.count{
            takePictureOfProductOrChooseFromGallery(isPicExist: true, index: indexPath.row)
        }else{
            takePictureOfProductOrChooseFromGallery(isPicExist: false, index: indexPath.row)
        }
    }
    
    private func takePictureOfProductOrChooseFromGallery(isPicExist: Bool,index: Int){
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isPicExist, viewController: parentViewController,delegate: self) { [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension AddPhotosTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 65)
    }
}
//MARK:UITextFieldDelegate
extension AddPhotosTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: titleView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let title = productTitleTextField.text
        var userInfo = [String: Any]()
        userInfo["productTitle"] = title
        NotificationCenter.default.post(name: .productTitleAdded, object: nil, userInfo: userInfo)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == productTitleTextField{
            threshold = 100
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
}
extension AddPhotosTableViewCell: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if let picture = image{
             let newPhoto = ImageUtils.RBResizeImage(image: picture, targetSize: CGSize(width: 540, height: 540))
            self.photos.append(newPhoto)
        }else{
            if photoSelectionIndex < self.photos.count{
               self.photos.remove(at: photoSelectionIndex)
            }
        }
        self.delagate?.addedProductPictures(pictures: self.photos, upadtedPhoto: image, index: photoSelectionIndex)
    }
}
