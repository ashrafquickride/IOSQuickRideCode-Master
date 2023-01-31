//
//  MoreDetailViewController.swift
//  Quickride
//
//  Created by Vinutha on 13/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MoreDetailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet var rideEtiquettesCollectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var labelRideEtiquettesTitle: UILabel!
    
    var rideObj: Ride?
    var rideEtiquettes = [String]()
    
    func initializeView(rideObj: Ride){
        self.rideObj = rideObj
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if rideObj!.rideType == Ride.RIDER_RIDE{
            rideEtiquettes = clientConfiguration!.rideEtiquettesImagesForRider
        }
        else{
            rideEtiquettes = clientConfiguration!.rideEtiquettesImagesForPassenger
        }
        if rideEtiquettes.isEmpty{
            labelRideEtiquettesTitle.isHidden = true
            rideEtiquettesCollectionView.isHidden = true
        }
        else{
            rideEtiquettesCollectionView.isHidden = false
            labelRideEtiquettesTitle.isHidden = false
            rideEtiquettesCollectionView.delegate = self
            rideEtiquettesCollectionView.dataSource = self
            rideEtiquettesCollectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rideEtiquettes.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! RideEtiquettesCollectionViewCell
        if rideEtiquettes.endIndex <= indexPath.row{
            return cell
        }
        let rideEtiquette = rideEtiquettes[indexPath.row]
        ImageCache.getInstance().getImageFromCache(imageUrl: rideEtiquette, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image) in
            cell.imageView.image = image?.roundedCornerImage
        })
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:1,height: 1)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        return cell
        
    }
    
    @IBAction func downArrowTapped(_ sender: Any){
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        goBackToCallingViewController()
    }
    
    func goBackToCallingViewController(){
        self.navigationController?.popViewController(animated: false)
    }
}
