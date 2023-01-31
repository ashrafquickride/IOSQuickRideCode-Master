//
//  CountryPickerViewController.swift
//  Quickride
//
//  Created by KNM Rao on 12/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MRCountryPicker

typealias contryCodeCompletionHandler = (_ name: String, _ countryCode: String, _ phoneCode: String, _ flag: UIImage) -> Void

class CountryPickerViewController: UIViewController,MRCountryPickerDelegate {
  
  
  @IBOutlet var countryCodePicker: MRCountryPicker!
  var currentCountryCode : String?
  var countryName : String?
  var phoneCode: String?
  var flag: UIImage?
  var handler : contryCodeCompletionHandler?
  
    func initializeDataBeforePresenting(currentCountryCode : String?,handler :@escaping contryCodeCompletionHandler){
    self.currentCountryCode = currentCountryCode
    self.handler = handler
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    countryCodePicker.countryPickerDelegate = self
    countryCodePicker.showPhoneNumbers = true
    
    // set country by its code
    if currentCountryCode != nil{
       countryCodePicker.setCountry(currentCountryCode!)
    }
    else
    {
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        if countryCode != nil{
            countryCodePicker.setCountry(countryCode!)
        }
    }
  }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
    self.countryName = name
    self.phoneCode = phoneCode
    self.currentCountryCode = countryCode
    self.flag = flag
  }
  @IBAction func doneButtonAction(_ sender: Any) {
    if self.countryName == nil ||
    self.phoneCode == nil ||
      self.flag == nil{
      return
    }
    dismiss(animated: false) {
        self.handler?(self.countryName!, self.currentCountryCode!, self.phoneCode!, self.flag!)
    }
    
  }
  
  @IBAction func cancelButtonAction(_ sender: Any) {
    dismiss(animated: false) {
      
    }
  }
  

    
    func countryNamesByCode() -> [String : Country] {
      var countries = [String : Country]()
        let frameworkBundle = Bundle(for: type(of: self))
        guard let jsonPath = frameworkBundle.path(forResource: "SwiftCountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = NSData(contentsOfFile: jsonPath) else {
        return countries
      }
      
      do {
        if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
          
          for jsonObject in jsonObjects {
            
            guard let countryObj = jsonObject as? NSDictionary else {
              return countries
            }
            
            guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
              return countries
            }
            
            let flag = UIImage(named: "SwiftCountryPicker.bundle/Images/\(code.uppercased())", in: Bundle(for: type(of: self)), compatibleWith: nil)
            let country = Country(code: code, name: name, phoneCode: phoneCode, flag: flag)
            countries[code] = country
          }
          
        }
      } catch {
        return countries
      }
      return countries
    }
  
}
class Country {
  var code: String?
  var name: String?
  var phoneCode: String?
  var flag: UIImage?
  
  init(code: String?, name: String?, phoneCode: String?, flag: UIImage?) {
    self.code = code
    self.name = name
    self.phoneCode = phoneCode
    self.flag = flag
  }
}
