//
//  WalkPathView.swift
//  Quickride
//
//  Created by Vinutha on 3/27/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import UIKit

class WalkPathView : UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var startToPickupLabel: UILabel!
    
    @IBOutlet weak var dropToEndLabel: UILabel!
    
    @IBOutlet weak var startToPickupArrowIcon: UIImageView!
    
    @IBOutlet weak var carIcon: UIImageView!
    
    @IBOutlet weak var dropToEndArrow: UIImageView!
    
    
    
    @IBOutlet weak var startToPickupView: UIView!
    
    @IBOutlet weak var startToPickupViewDistanceLabel: UILabel!
    
    @IBOutlet weak var startToPickupViewArrowIcon: UIImageView!
    
    @IBOutlet weak var startToPickupViewCarIcon: UIImageView!
    
    
    @IBOutlet weak var walkPathView: UIView!
    
    @IBOutlet weak var dropToEndView: UIView!
    
    @IBOutlet weak var dropToEndViewDistanceLabel: UILabel!
    
    @IBOutlet weak var dropToEndViewArrowIcon: UIImageView!
    
    @IBOutlet weak var dropToEndViewCarIcon: UIImageView!

    
    func initialiseViews(distance : CummulativeTravelDistance){
        
        
        
        if distance.passengerStartToPickup > 0.01 && distance.passengerDropToEnd > 0.01{
            ViewCustomizationUtils.addCornerRadiusToView(view: backgroundView, cornerRadius: 5)
            setTintedIcon(origImage: UIImage(named: "arrow_right_green")!, imageView: startToPickupArrowIcon)
            setTintedIcon(origImage: UIImage(named: "arrow_right_green")!, imageView: dropToEndArrow)
            setTintedIcon(origImage: UIImage(named: "icon_schedule")!, imageView: carIcon)
            startToPickupLabel.text = getReadableDistance(distance: distance.passengerStartToPickup)
            dropToEndLabel.text = getReadableDistance(distance: distance.passengerDropToEnd)
            dropToEndView.isHidden = true
            startToPickupView.isHidden = true
            backgroundView.isHidden = false
            
        }else if distance.passengerStartToPickup > 0.01{
            ViewCustomizationUtils.addCornerRadiusToView(view: startToPickupView, cornerRadius: 5)
            setTintedIcon(origImage: UIImage(named: "arrow_right_green")!, imageView: startToPickupViewArrowIcon)
            setTintedIcon(origImage: UIImage(named: "icon_schedule")!, imageView: startToPickupViewCarIcon)
            startToPickupViewDistanceLabel.text = getReadableDistance(distance: distance.passengerStartToPickup)
            dropToEndView.isHidden = true
            startToPickupView.isHidden = false
            backgroundView.isHidden = true

        }else if distance.passengerDropToEnd > 0.01{
           ViewCustomizationUtils.addCornerRadiusToView(view: dropToEndView, cornerRadius: 5)
            setTintedIcon(origImage: UIImage(named: "arrow_right_green")!, imageView: dropToEndViewArrowIcon)
            setTintedIcon(origImage: UIImage(named: "icon_schedule")!, imageView: dropToEndViewCarIcon)
            dropToEndViewDistanceLabel.text = getReadableDistance(distance: distance.passengerDropToEnd)
            dropToEndView.isHidden = false
            startToPickupView.isHidden = true
            backgroundView.isHidden = true
        }
    }
    func getReadableDistance( distance : Double) -> String{
        let distanceInMts = distance*1000
        if distanceInMts < 1000{
            return StringUtils.getStringFromDouble(decimalNumber: distanceInMts) + " Mts"
        }else{
            var distanceInKM = distance
            let string = distanceInKM.roundToPlaces(places: 2)
            return String(string) + " KM"
        }
    }
    func setTintedIcon(origImage : UIImage, imageView : UIImageView){
        let tintedImage = origImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.image = tintedImage
        imageView.tintColor = UIColor.white
    }
}
