//
//  QuickRideProgressSwinner.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 28/07/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickRideProgressSpinner : UIViewController{
    
    
    @IBOutlet weak var swinnerImages: UIImageView!
    @IBOutlet weak var dissmissView: UIView!
    var timer : Timer?
    let imagesForSwinner : [UIImage] = [
        UIImage(named : "progress_bar_share")!,
        UIImage(named : "progress_bar_save")!,
        UIImage(named : "smile")!]
    
    static var spinner : QuickRideProgressSpinner?
    var index = 0
    
    override func viewDidLoad() {

      DispatchQueue.main.async() {
        self.swinnerImages.image = self.imagesForSwinner[0]
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(QuickRideProgressSpinner.moveToNextImage), userInfo: nil, repeats: true)
      }
    }

    @objc func moveToNextImage()
    {
      if timer == nil {
        return
      }
        if index >= imagesForSwinner.count{
          index = 0
        }
        swinnerImages.image = imagesForSwinner[index]
        index += 1
      
    }
    
    static func startSpinner(){
        DispatchQueue.main.async() {
        if spinner != nil{
            return
        }
        spinner = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "QuickRideProgressSpinner") as? QuickRideProgressSpinner
        UIApplication.shared.keyWindow?.addSubview(spinner!.view)
        }
    }
    static func stopSpinner(){
      DispatchQueue.main.async() { 
        if spinner != nil{
            if spinner!.timer != nil{
                spinner!.timer!.invalidate()
                spinner!.timer = nil
            }
            spinner!.view.removeFromSuperview()
            spinner = nil
        }
      }
    }
}
