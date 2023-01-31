//
//  SelectValueFromSliderViewController.swift
//  Quickride
//
//  Created by Halesh on 31/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias receiveSelectedValue = (_ value :Int) -> Void

class SelectValueFromSliderViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var titeLbl: UILabel!
    
    @IBOutlet weak var sliderFirstValue: UILabel!
    
    @IBOutlet weak var sliderThirdValue: UILabel!
    
    @IBOutlet weak var sliderFifthValue: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var backGroundView: UIView!
    
    var titleText: String?
    var firstValue : Int?
    var lastValue : Int?
    var minValue : Int?
    var currentValue : Int?
    var handler : receiveSelectedValue?
    var isKeyBoardVisible : Bool = false
    
    func initializeViewWithData(title: String, firstValue: Int,lastValue: Int, minValue: Int, currentValue: Int,handler : receiveSelectedValue?){
        self.titleText = title
        self.firstValue = firstValue
        self.lastValue = lastValue
        self.minValue = minValue
        self.currentValue = currentValue
        self.handler = handler
    }
    
    override func viewDidLoad() {
        slider.minimumValue = Float(firstValue!)
        slider.maximumValue = Float(lastValue!)
        textField.delegate = self
        setValues()
        ViewCustomizationUtils.addCornerRadiusToView(view: contentView, cornerRadius: 10)
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func setValues(){
        titeLbl.text = titleText
        sliderFirstValue.text = String(firstValue!)
        sliderFifthValue.text = String(lastValue!)
        sliderThirdValue.text = String((firstValue! + lastValue!)/2)
        textField.text = String(currentValue!)
        slider.setValue(Float(currentValue!),animated: false)
    }
    @objc private func sliderTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if let slider = gestureRecognizer.view as? UISlider {
            if slider.isHighlighted { return }
            let point = gestureRecognizer.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let newValue = slider.minimumValue + delta
            slider.setValue(Float(newValue), animated: true)
            textField.text = String(Int(newValue))
        }
    }
    
    @IBAction func sliderMoved(_ sender: Any) {
        textField.text = String(Int(slider.value))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
    }
    
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == nil || textField.text?.isEmpty == true{
            slider.setValue(Float(slider.minimumValue), animated: true)
            return
        }
        let value  = textField.text!
        let intValue = Int(value)
        if intValue == nil {
            slider.setValue(Float(slider.minimumValue), animated: true)
            return
        }
        slider.setValue(Float(intValue!), animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == self.textField{
            threshold = 3
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
        
    }
    
    @objc func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer){
        handler!(Int(slider.value))
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
