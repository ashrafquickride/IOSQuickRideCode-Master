//
//  ImageCache.swift
//  Quickride
//
//  Created by KNM Rao on 24/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import SDWebImage
import UIKit
import GoogleMaps


public class ImageCache {
    
    static let DIMENTION_TINY = "tiny_" //60*60
    static let DIMENTION_SMALL = "small_" //90*90
    static let DIMENTION_LARGE = "large_" //320*320
    static let ORIGINAL_IMAGE = "original_image"
    
    private static var singleCacheInstance : ImageCache?
    private var default_male_image_30_30 : UIImage?
    private var default_female_image_30_30 : UIImage?
    private var person_default_30_30 : UIImage?
    private var default_male_image: UIImage?
    private var default_female_image: UIImage?
    private var person_default : UIImage?
    public typealias ImageRetrievalCompletionHandler = (_ image :UIImage) -> Void
    public typealias ImageRetrievalHandler = (_ image : UIImage?, _ imageURI : String) -> Void
    private init(){
        
    }
    
    public static func getInstance() -> ImageCache{
        AppDelegate.getAppDelegate().log.debug("getInstance()")
        if self.singleCacheInstance == nil {
            self.singleCacheInstance = ImageCache()
        }
        
        return self.singleCacheInstance!
    }
    
    public func setVehicleImage(imageView : UIImageView, imageUrl : String?,model : String?,imageSize: String){
        AppDelegate.getAppDelegate().log.debug("setVehicleImage()")
        if imageUrl == nil || imageUrl?.isEmpty == true  {
            
            imageView.image = getDefaultVehicleImage(model: model)
        }else{
            let imageUrlWithSize = insertAndGetImageSizeInImageUrl(imageUrl: imageUrl!, imageSize: imageSize)
            let URL = NSURL(string: imageUrlWithSize)
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imageView.sd_setImage(with: URL! as URL, placeholderImage: self.getDefaultVehicleImage(model: model), options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                if image != nil{
                    self.checkAndSetCircularImage(imageView: imageView, image: image)
                }else{
                    let URL = NSURL(string: imageUrl!)
                    imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    imageView.sd_setImage(with: URL! as URL, placeholderImage: self.getDefaultVehicleImage(model: model), options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                        self.checkAndSetCircularImage(imageView: imageView, image: image)
                    }
                }
            }
            
        }
        
    }

    func getDefaultVehicleImage(model : String?) -> UIImage {
        AppDelegate.getAppDelegate().log.debug("getDefaultVehicleImage()")
            if model == nil{
                return UIImage(named: "icon_hatchback")!
            }
            switch model! {
            case Vehicle.VEHICLE_MODEL_HATCHBACK:
                return UIImage(named: "icon_hatchback")!
            case Vehicle.VEHICLE_MODEL_SEDAN:
                return UIImage(named: "icon_sedan")!
            case Vehicle.VEHICLE_MODEL_SUV:
                return UIImage(named: "icon_suv")!
            case Vehicle.VEHICLE_MODEL_PREMIUM:
                return UIImage(named: "icon_premium")!
            case Vehicle.VEHICLE_MODEL_KOMBI:
                return UIImage(named: "kombi_default")!
            case Vehicle.BIKE_MODEL_SCOOTER:
              return UIImage(named: "icon_scooter")!
            default:
                return UIImage(named: "icon_bike")!
            }
        
    }
    public func setImageToView(imageView : UIImageView, imageUrl : String?,gender : String,imageSize: String){
        AppDelegate.getAppDelegate().log.debug("setImageToView() \(gender)")
        if imageUrl == nil || imageUrl?.isEmpty == true || QRSessionManager.getInstance()?.getUserId() == nil || QRSessionManager.getInstance()?.getUserId().isEmpty == true {
            imageView.image = getDefaultUserImage(gender: gender)
            return
        }
        let imageUrlWithSize = insertAndGetImageSizeInImageUrl(imageUrl: imageUrl!, imageSize: imageSize)
        guard  let url = URL(string: imageUrlWithSize) else {
            imageView.image = getDefaultUserImage(gender: gender)
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: getDefaultUserImage(gender: gender), options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
            if let image = image{
                self.checkAndSetCircularImage(imageView: imageView, image: image)
            }else{
                guard  let url = URL(string: imageUrl!) else {
                    imageView.image = self.getDefaultUserImage(gender: gender)
                    return
                }
                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                imageView.sd_setImage(with: url, placeholderImage: self.getDefaultUserImage(gender: gender), options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                    self.checkAndSetCircularImage(imageView: imageView, image: image)
                    
                }
            }
        }
    }
    
    public func setImageToViewFromURL(imageView : UIImageView, imageUrl : String?){
        AppDelegate.getAppDelegate().log.debug("setImageToView()")
        if imageUrl == nil || imageUrl?.isEmpty == true || QRSessionManager.getInstance()?.getUserId() == nil || QRSessionManager.getInstance()?.getUserId().isEmpty == true {
            imageView.isHidden = true
            return
        }
        guard  let url = URL(string: imageUrl ?? "") else {
            imageView.isHidden = true
            return
        }
        imageView.isHidden = false
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: url, placeholderImage: nil)
    }
    
    public func setImageToView(imageView : UIImageView, imageUrl : String,placeHolderImg : UIImage?,imageSize: String){
        var imageUrlWithSize = imageUrl
        if imageSize != ImageCache.ORIGINAL_IMAGE{
            imageUrlWithSize = insertAndGetImageSizeInImageUrl(imageUrl: imageUrl, imageSize: imageSize)
        }
         guard let url = URL(string: imageUrlWithSize) else { return }
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: url, placeholderImage: placeHolderImg, options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
            if image != nil{
                self.checkAndSetCircularImage(imageView: imageView, image: image)
            }else{
                let URL = NSURL(string: imageUrl)
                if URL == nil{
                    return
                }
                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                imageView.sd_setImage(with: URL! as URL, placeholderImage: placeHolderImg, options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                    self.checkAndSetCircularImage(imageView: imageView, image: image)
                }
            }
        }
    }
    
    public func getImageFromCache(imageUrl : String,imageSize: String,handler: @escaping ImageRetrievalHandler){
        var imageUrlWithSize = imageUrl
        if imageSize != ImageCache.ORIGINAL_IMAGE{
            imageUrlWithSize = insertAndGetImageSizeInImageUrl(imageUrl: imageUrl, imageSize: imageSize)
        }
        let URL = NSURL(string: imageUrlWithSize)
        
        if URL == nil{
            return handler(nil,imageUrl)
        }
        
        SDWebImageManager.shared.loadImage(with: URL! as URL, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, data, error, cacheType, finished, url) in
            if image != nil{
                handler(image,imageUrl)
            }else{
                let URL = NSURL(string: imageUrl)
                if URL == nil{
                    return handler(nil,imageUrl)
                }
                SDWebImageManager.shared.loadImage(with: URL! as URL, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, data, error, cacheType, finished, url) in
                    if image != nil{
                        handler(image,imageUrl)
                    }else{
                        handler(nil,imageUrl)
                    }
                }
            }
        }
    }
    
    public func setImagetoMarker(imageUrl : String?,gender : String, marker : GMSMarker, isCircularImageRequired: Bool, imageSize: String){
        AppDelegate.getAppDelegate().log.debug("setImagetoMarker() \(gender)")
        if imageUrl == nil || imageUrl?.isEmpty == true || QRSessionManager.getInstance()?.getUserId() == nil || QRSessionManager.getInstance()?.getUserId().isEmpty == true{
            marker.icon = self.getDefaultUserImage_30_30(gender: gender)
        }else{
            var imageUrlWithSize = imageUrl
            if imageSize != ImageCache.ORIGINAL_IMAGE{
                imageUrlWithSize = insertAndGetImageSizeInImageUrl(imageUrl: imageUrl!, imageSize: imageSize)
            }
            guard let URL = NSURL(string: imageUrlWithSize!) else {
                marker.icon = self.getDefaultUserImage_30_30(gender: gender)
                return
            }
            SDWebImageManager.shared.loadImage(with: URL as URL, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, data, error, cacheType, finished, url) in
                if image != nil{
                    if isCircularImageRequired{
                        marker.icon = ImageUtils.RBResizeImage(image: image!, targetSize: CGSize(width: 30,height: 30)).circle
                    }
                    else{
                        marker.icon = ImageUtils.RBResizeImage(image: image!, targetSize: CGSize(width: 30,height: 30))
                    }

                }else{
                    marker.icon = self.getDefaultUserImage_30_30(gender: gender)
                }
            }
        }
        
    }
    
    func getDefaultUserImage(gender : String) -> UIImage{
        AppDelegate.getAppDelegate().log.debug("getDefaultUserImage() \(gender)")
        switch gender {
        case "M":
            if default_male_image == nil{
                default_male_image = UIImage(named: "default_male")!
            }
            return default_male_image!
        case "F":
            if default_female_image == nil{
                default_female_image = UIImage(named: "default_female_image")!
            }
            return default_female_image!
        case "U":
            if person_default == nil{
                person_default = UIImage(named: "default_contact")!
            }
            return person_default!
        default:
            if person_default == nil{
                person_default = UIImage(named: "default_contact")!
            }
            return person_default!
        }
    }
    func getDefaultUserImage_30_30(gender : String) -> UIImage{
        AppDelegate.getAppDelegate().log.debug("getDefaultUserImage_40_40() \(gender)")
        switch gender {
        case "M":
            if default_male_image_30_30 == nil{
                default_male_image_30_30 = ImageUtils.RBResizeImage(image: getDefaultUserImage(gender: gender), targetSize: CGSize(width: 30,height: 30))
            }
            return default_male_image_30_30!
        case "F":
            if default_female_image_30_30 == nil{
                default_female_image_30_30 = ImageUtils.RBResizeImage(image: getDefaultUserImage(gender: gender), targetSize: CGSize(width: 30,height: 30))
            }
            return default_female_image_30_30!
        case "U":
            if person_default_30_30 == nil{
                person_default_30_30 = ImageUtils.RBResizeImage(image: getDefaultUserImage(gender: gender), targetSize: CGSize(width: 30,height: 30))
            }
            return person_default_30_30!
        default:
            if person_default_30_30 == nil{
                person_default_30_30 = ImageUtils.RBResizeImage(image: getDefaultUserImage(gender: gender), targetSize: CGSize(width: 30,height: 30))
            }
            return person_default_30_30!
        }
    }
    func checkAndSetCircularImage(imageView : UIImageView,image : UIImage?){
        
        if image != nil && imageView.isKind(of: CircularImageView.self){
            imageView.image = image!.circle
        }
        
    }
    
    func storeImageToCache(imageUrl : String,image : UIImage){
        SDImageCache.shared.store(image, forKey: imageUrl, completion: nil)
    }
    
    func getGifImageFromCache(gifUrl: String, handler: @escaping ImageRetrievalHandler) {
        self.getImageFromCache(imageUrl: gifUrl, imageSize: ImageCache.ORIGINAL_IMAGE) { (image,imageURI) in
            if image != nil {
                handler(image,gifUrl)
            } else {
                if let bundleURL = URL(string: gifUrl) {
                    guard let imageData = try? Data(contentsOf: bundleURL) else {
                        handler(nil,gifUrl)
                        return
                    }
                    if let image = ImageUtils.gifImageWithData(imageData) {
                        ImageCache.getInstance().storeImageToCache(imageUrl: gifUrl, image: image)
                    }
                    handler(image,gifUrl)
                    return
                }
                handler(nil,gifUrl)
            }
        }
    }
    private func insertAndGetImageSizeInImageUrl(imageUrl: String,imageSize: String) -> String{
        var imageUrlArray : [String] = imageUrl.components(separatedBy: "/")
        guard let imageName = imageUrlArray.last else { return "" }
        _ = imageUrlArray.removeLast()
        let s3Path = imageUrlArray.joined(separator: "/")
            return s3Path + "/" + imageSize + imageName
    }
}
