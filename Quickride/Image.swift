//
//  Image.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class Image:NSObject,Mappable {
  
    private var image: [UInt8]?
    private var imageURI:String?
    
    static let USER_PHOTO_STRING = "photo"
    static let IMAGE_URI="imageURI"
    required public init(map:Map){
        
    }
  
    public func mapping(map:Map){
        image <- map["image"]
        imageURI <- map["imageURI"]
    }
    public override var description: String {
        return "image: \(String(describing: self.image))," + "imageURI: \(String(describing: self.imageURI)),"
    }
}

