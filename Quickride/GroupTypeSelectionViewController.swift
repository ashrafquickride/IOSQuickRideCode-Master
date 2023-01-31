//
//  GroupTypeSelectionViewController.swift
//  Quickride
//
//  Created by rakesh on 3/8/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation

typealias GroupTypePickerDelegate = (_ groupType:String) -> Void

class GroupTypeSelectionViewController : UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var groupTypePicker: UIPickerView!
    
    var viewController : UIViewController?
    
    var pickerDefaultValue : String?
    var delegate : GroupTypePickerDelegate?
    var elements = ["GENERAL","COMMUNITY","CORPORATE"]
    var selectedNumber = 1
    
    func initializeDataBeforePresenting(viewController : UIViewController,pickerDefaultValue : String,delegate : @escaping GroupTypePickerDelegate){
        self.viewController =  viewController
        
        self.pickerDefaultValue = pickerDefaultValue
        self.delegate = delegate
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: pickerView, cornerRadius: 5.0)
        groupTypePicker.delegate = self
        groupTypePicker.dataSource = self
        groupTypePicker.reloadInputViews()
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupTypeSelectionViewController.backGroundTapped(_:))))
        
        self.perform(#selector(GroupTypeSelectionViewController.selectRow), with: nil, afterDelay: 0.5)
    }
    
    func backGroundTapped(_ gesture : UITapGestureRecognizer){
        view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    func selectRow(){
        if(pickerDefaultValue == "GENERAL"){
            groupTypePicker.selectRow(0, inComponent: 0, animated: false)
        }else if(pickerDefaultValue == "COMMUNITY"){
            groupTypePicker.selectRow(1, inComponent: 0, animated: false)
        }else{
            groupTypePicker.selectRow(2, inComponent: 0, animated: false)
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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let selectedRow = groupTypePicker.selectedRow(inComponent: 0)
        if(elements[selectedRow] == "GENERAL"){
            delegate!(elements[selectedRow])
        }else if(elements[selectedRow] == "COMMUNITY"){
            delegate!(elements[selectedRow])
        }else{
            delegate!(elements[selectedRow])
        }
        
        view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    
}
