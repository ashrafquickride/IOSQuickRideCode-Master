//
//  MinimumFareSildeViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 21/09/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation
typealias ReceiveMinimumFare = (_ minPoints :Int) -> Void
class MinimumFareSildeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var alertView: UIView!
   
    @IBOutlet weak var sliderValueTextField: UITextField!

    @IBOutlet weak var firstValue: UILabel!
    
    @IBOutlet weak var secondValue: UILabel!
    
    @IBOutlet weak var thirdValue: UILabel!
    
    @IBOutlet weak var fourthValue: UILabel!
    
    @IBOutlet weak var fifthValue: UILabel!
    
    @IBOutlet weak var sixthValue: UILabel!
    
    @IBOutlet weak var firstValueCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondValueCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var thirdValueCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fourthValueCenterXConstraint: NSLayoutConstraint!
    
    var currentValue : String?
    var handler : ReceiveMinimumFare?
    var viewController : UIViewController?
    var isKeyBoardVisible = false

    func initializeDataBeforePresentingView(currentValue: String,viewController: UIViewController, handler: @escaping ReceiveMinimumFare)
    {
        self.handler = handler
        self.currentValue = currentValue
        self.viewController = viewController
    
        
        if viewController.navigationController != nil{
            viewController.navigationController?.view.addSubview(self.view!)
            viewController.navigationController?.addChild(self)
        }else{
            viewController.view.addSubview(self.view!)
            viewController.addChild(self)
        }
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if(clientConfiguration == nil){
            clientConfiguration = ClientConfigurtion()
        }
        slider.minimumValue = Float(ClientConfigurtion().MIN_MIN_FARE_FOR_RIDE)
        slider.maximumValue = Float(clientConfiguration!.maxMinFareForRide)
        slider.value = Float(currentValue)!
   
    }
   
    override func viewDidLoad() {
        #if MYRIDE
            firstValue.text = "2.5"
            secondValue.text = "5"
            thirdValue.text = "7.5"
            fourthValue.text = "10"
            fifthValue.isHidden = true
            sixthValue.isHidden = true
            firstValueCenterXConstraint.constant = -65
            secondValueCenterXConstraint.constant = 0
            thirdValueCenterXConstraint.constant = 60
            fourthValueCenterXConstraint.constant = 120
        #else
            firstValue.text = "5"
            secondValue.text = "10"
            thirdValue.text = "15"
            fourthValue.text = "20"
            fifthValue.text = "25"
            sixthValue.text = "30"
        #endif
        sliderValueTextField.delegate = self
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MinimumFareSildeViewController.backgroundTapped(_:))))
          slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MinimumFareSildeViewController.sliderTapped(_:))))
        sliderValueTextField.text = currentValue!
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func sliderMoved(_ sender: Any) {
        sliderValueTextField.text = String(Int(slider.value))
    }
    
    @objc func sliderTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: alertView)
        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        sliderValueTextField.text = String(Int(newValue))

        slider.setValue(Float(newValue), animated: true)
    }
    
    @objc func backgroundTapped(_ gesture : UITapGestureRecognizer){
        self.view?.removeFromSuperview()
        self.removeFromParent()
        if sliderValueTextField.text?.isEmpty == true {
            handler!(Int(slider.value))
        }
        else{
            handler!(Int(slider.value))
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sliderValueTextField{
            addDoneButton(textField: sliderValueTextField)
        }
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true{
            slider.setValue(Float(slider.minimumValue), animated: true)
            return
        }
        let value  = textField.text!
        let intValue = Int(value)
        if intValue == nil {
            slider.setValue(Float(slider.minimumValue), animated: true)
            return
        }
        else if intValue! > 30 {
            self.slider.setValue(Float(slider.maximumValue), animated: true)
            return
        }
        slider.setValue(Float(intValue!), animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == sliderValueTextField{
            threshold = 2
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
        
    }
}
