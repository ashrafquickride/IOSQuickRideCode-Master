//
//  RideEtiquetImageViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import AVKit

class RideEtiquetImageViewController: UIViewController {
    

    @IBOutlet weak var rideEtiqueCollectionView: UICollectionView!
   
    
    var rideObj: Ride?
    var imageUrl: String?
    var indexNumber: Int?
    var isTapped = true
    
    private var rideEtiquetteImages = [UserRideEtiquetteMedia]()

    func initializingView(rideObject: Ride?, countNumber: Int){
        self.rideObj = rideObject
        self.indexNumber = countNumber
        if let rideType = rideObj?.rideType {
            rideEtiquetteImages = LiveRideViewModelUtil.filterRideEtiqueteIamges(rideType: rideType)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideEtiqueCollectionView.dataSource = self
        rideEtiqueCollectionView.delegate = self
        rideEtiqueCollectionView.register(UINib(nibName: "RideEtiquetteHelpImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideEtiquetteHelpImagesCollectionViewCell")
        
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
    }
}


extension RideEtiquetImageViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rideEtiquetteImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideEtiquetteHelpImagesCollectionViewCell", for: indexPath as IndexPath) as! RideEtiquetteHelpImagesCollectionViewCell
            if rideEtiquetteImages.endIndex <= indexPath.row {
                return cell
            }
        cell.rideEtiquetteCollectionImageView.backgroundColor = .black
        cell.rideEtiquetteCollectionImageView.image = nil
        
        ImageCache.getInstance().getImageFromCache(imageUrl: self.rideEtiquetteImages[indexPath.row].smallMediaUrl!, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
                cell.rideEtiquetteCollectionImageView.image = image
            })
           if  isTapped {
               rideEtiqueCollectionView.scrollToItem(at:IndexPath(item: indexNumber ?? 0, section: 0), at: .left, animated: false)
               isTapped = false
        } else {
            ImageCache.getInstance().getImageFromCache(imageUrl: self.rideEtiquetteImages[indexPath.row].smallMediaUrl!, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
                    cell.rideEtiquetteCollectionImageView.image = image
                })
        }
        return cell
    }
}


extension RideEtiquetImageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoUrl = self.rideEtiquetteImages[indexPath.row].bigMediaUrl , self.rideEtiquetteImages[indexPath.row].mediaType == UserRideEtiquetteMedia.MEDIA_TYPE_VIDEO {
            let vedioURL = URL(string: videoUrl)
            let player = AVPlayer(url: vedioURL!)
            let playervc = AVPlayerViewController()
            playervc.player = player
            self.parent?.present(playervc, animated: true) {
                playervc.player!.play()
            }
        }
    }
    }

    //MARK: UICollectionViewDelegateFlowLayout
    extension RideEtiquetImageViewController: UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: rideEtiqueCollectionView.frame.size.width, height: rideEtiqueCollectionView.frame.size.height)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
    }
    
