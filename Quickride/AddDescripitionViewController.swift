//
//  AddDescripitionViewController.swift
//  Quickride
//
//  Created by Halesh on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias descriptionAddingCompletionHandler = (_ description: String) -> Void

class AddDescripitionViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var submitButton: QRCustomButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: varibales
    private var handler: descriptionAddingCompletionHandler?
    private var productDescription: String?
    
    func initialiseDescriptionView(description: String?,handler: @escaping descriptionAddingCompletionHandler){
        self.handler = handler
        self.productDescription = description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        prepareUI()
    }
    
    private func prepareUI(){
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        if let description = productDescription{
            descriptionTextView.text = description
            descriptionTextView.delegate = self
            submitButton.isEnabled = true
            submitButton.backgroundColor = Colors.green
        }else{
            descriptionTextView.text =  Strings.type_your_message
            descriptionTextView.delegate = self
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    @IBAction func submitTapped(_ sender: Any) {
        if descriptionTextView.text.isEmpty == false && descriptionTextView.text != nil{
            handler?(descriptionTextView.text)
            closeView()
        }
    }
}
//UITextViewDelegate
extension AddDescripitionViewController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text == nil || descriptionTextView.text.isEmpty || descriptionTextView.text ==  Strings.type_your_message{
            descriptionTextView.text = ""
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }else{
            submitButton.isEnabled = true
            submitButton.backgroundColor = Colors.green
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count < 200 {
            return false;
        }
        return true;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text.isEmpty{
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
            resignFirstResponder()
        }else if (descriptionTextView.text.trimmingCharacters(in: NSCharacterSet.whitespaces)).count == 0{
            submitButton.isEnabled = false
            submitButton.backgroundColor = .lightGray
        }else{
            submitButton.isEnabled = true
            submitButton.backgroundColor = Colors.green
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text.isEmpty == true {
            descriptionTextView.text =  Strings.type_your_message
            submitButton.backgroundColor = .lightGray
        }
        descriptionTextView.endEditing(true)
        resignFirstResponder()
    }
}
