//
//  UserGenderSelectionController.swift
//  Quickride
//
//  Created by KNM Rao on 25/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias UserGenderPickerDelegate = (_ gender:String, _ genderIdentifier :String) -> Void

class UserGenderSelectionController: ModelViewController,UIPickerViewDelegate,UIPickerViewDataSource {
  
  @IBOutlet weak var pickerView: UIView!
  @IBOutlet weak var numberPicker: UIPickerView!
  
  @IBOutlet var backgrounView: UIView!
  
  
  var viewController : UIViewController?
  
  var pickerDefaultValue : String?
  var delegate : UserGenderPickerDelegate?
  var elements = ["Male","Female","Skip"]
  var selectedNumber = 1
  
  func initializeDataBeforePresenting(viewController : UIViewController,pickerDefaultValue : String,delegate : @escaping UserGenderPickerDelegate){
    self.viewController =  viewController
    
    self.pickerDefaultValue = pickerDefaultValue
    self.delegate = delegate
    
  }
  override func viewDidLoad() {
    
    super.viewDidLoad()
    ViewCustomizationUtils.addCornerRadiusToView(view: pickerView, cornerRadius: 5.0)
    numberPicker.delegate = self
    numberPicker.dataSource = self
    numberPicker.reloadInputViews()
    backgrounView.isUserInteractionEnabled = true
    backgrounView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserGenderSelectionController.backGroundTapped(_:))))
    
    self.perform(#selector(UserGenderSelectionController.selectRow), with: nil, afterDelay: 0.5)
  }
    @objc func backGroundTapped(_ gesture : UITapGestureRecognizer){
    view.removeFromSuperview()
    self.removeFromParent()
  }
  
    @objc func selectRow(){
    if(pickerDefaultValue == "Male"){
      numberPicker.selectRow(0, inComponent: 0, animated: false)
    }else if(pickerDefaultValue == "Female"){
      numberPicker.selectRow(1, inComponent: 0, animated: false)
    }else{
      numberPicker.selectRow(2, inComponent: 0, animated: false)
    }
    
  }
  
     func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return elements.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return elements[row]
 }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
  

  @IBAction func confirmButtonClicked(_ sender: Any) {
    let selectedRow = numberPicker.selectedRow(inComponent: 0)
    if(elements[selectedRow] == "Male"){
      delegate!(elements[selectedRow], User.USER_GENDER_MALE)
    }else if(elements[selectedRow] == "Female"){
      delegate!(elements[selectedRow], User.USER_GENDER_FEMALE)
    }else{
      delegate!(elements[selectedRow], User.USER_GENDER_UNKNOWN)
    }
    view.removeFromSuperview()
    self.removeFromParent()
  }

  
}
