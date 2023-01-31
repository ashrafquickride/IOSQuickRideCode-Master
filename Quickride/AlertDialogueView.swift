//
//  AlertDialogueView.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 16/11/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

typealias AlertDialogueViewCompletionHandler = (_ didTap: Bool) -> Void

import Foundation

class AlertDialogueView: ModelViewController {
    
    @IBOutlet var backGroundView: UIView!
    
    
    @IBOutlet var alertView: UIView!
    
    
    @IBOutlet var imageView: UIImageView!
    
    var imageUri : String?
    var completionHandler: AlertDialogueViewCompletionHandler?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        ImageCache.getInstance()?.getImageFromCache(imageUrl: self.imageUri!, handler: { (image) in
            if image != nil{
                self.imageView.image = image!.roundedCornerImage
            }
        })
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AlertDialogueView.offerImageTapped(_:))))
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AlertDialogueView.backGroundViewTapped(_:))))
    }
    func initializeDataBeforePresenting(imageUri : String?, handler: @escaping AlertDialogueViewCompletionHandler)
    {
        self.imageUri = imageUri
        self.completionHandler = handler
    }
    
    @objc func offerImageTapped(_ gesture : UITapGestureRecognizer)
    {
        completionHandler!(true)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.removeView()
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        self.removeView()
    }
    
    func removeView(){
        completionHandler!(false)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
