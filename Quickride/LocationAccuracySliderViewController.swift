//
//  LocationAccuracySliderViewController.swift
//  Quickride
//
//  Created by rakesh on 1/22/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
typealias locationAccuracyValueHandler = (_ accuracyValue : Float) -> Void
class LocationAccuracySliderViewController : UIViewController{
    

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    var currentValue : String?
    var viewController : UIViewController?
    var handler : locationAccuracyValueHandler?


    
    func initializeDataBeforePresentingView(currentValue: String,viewController: UIViewController,handler : locationAccuracyValueHandler?)
    {
        self.currentValue = currentValue
        self.viewController = viewController
        self.handler = handler
        
       
        
        
        if viewController.navigationController != nil{
            viewController.navigationController?.view.addSubview(self.view!)
            viewController.navigationController?.addChild(self)
        }else{
            viewController.view.addSubview(self.view!)
            viewController.addChild(self)
        }
        if self.currentValue == "Off"{
              slider.value = 0
        }else if self.currentValue == "Balanced"{
              slider.value = 1
        }else if self.currentValue == "High"{
              slider.value = 2
        }
        
    }
    
    
    override func viewDidLoad() {
    
    ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
    slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationAccuracySliderViewController.sliderTapped(_:))))
    backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationAccuracySliderViewController.backgroundTapped(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func sliderValueChanges(_ sender: Any) {
        let SliderValue = restrictSliderToFixedValue(sliderValue: slider.value)
        slider.setValue(Float(SliderValue), animated: true)
        handler?(Float(SliderValue))
        
    }
    
    @objc func sliderTapped(_ gestureRecognizer: UITapGestureRecognizer) {

    }
    
    @objc func backgroundTapped(_ gesture : UITapGestureRecognizer){
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    func restrictSliderToFixedValue(sliderValue:Float)->Int{
        var setValueOfSliderToFixedValue : Int?
        if sliderValue < 0.5{
           setValueOfSliderToFixedValue = 0
        }else if sliderValue < 1.5{
            setValueOfSliderToFixedValue = 1
        }else{
            setValueOfSliderToFixedValue = 2
        }
        return setValueOfSliderToFixedValue!
    }


}
