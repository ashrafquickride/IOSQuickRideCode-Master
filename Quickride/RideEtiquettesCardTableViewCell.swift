//
//  RideEtiquettesCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 27/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import AVKit

class RideEtiquettesCardTableViewCell: UITableViewCell {
    
    @IBOutlet var rideEtiquettesCollectionView: UICollectionView!
    @IBOutlet weak var getCertifiedOutlet: UIStackView!
    
    private var rideObj: Ride?
    private var rideEtiquettes = [UserRideEtiquetteMedia]()
    
    func initializeView(rideObj: Ride){
        self.rideObj = rideObj
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        if let rideType = rideObj.rideType {
            rideEtiquettes = LiveRideViewModelUtil.filterRideEtiqueteIamges(rideType: rideType)
        }
        setupUI()
    }
    
    private func setupUI() {
        rideEtiquettesCollectionView.register(UINib(nibName: "RideEtiquetteImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideEtiquetteImageCollectionViewCell")
        rideEtiquettesCollectionView.reloadData()
        setUpCertificate()
    }

    func setUpCertificate()  {
        UserDataCache.getInstance()?.getRideEtiquetteCertificate(userId: String(UserDataCache.getCurrentUserId()), handler: {
            (rideEtiquetteCertification) in
            if rideEtiquetteCertification == nil && self.getURLForRideEtiquette() != nil  {
                self.getCertifiedOutlet.isHidden = false
                self.getCertifiedOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.getCertifiedAction(_: ))))
            }else {
                self.getCertifiedOutlet.isHidden = true
            }
            
        })
    }
    @objc func getCertifiedAction(_ gesture: UIGestureRecognizer) {
        if let url = getURLForRideEtiquette() {
            let queryItems = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps = URLComponents(string :  url)
            urlcomps?.queryItems = [queryItems]
            if urlcomps?.url != nil {
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: "Ride Etiquette Certification", url: urlcomps?.url, actionComplitionHandler: nil)
                self.parentViewController?.navigationController?.pushViewController(webViewController, animated: false)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    func getURLForRideEtiquette() -> String? {
        guard let urlPath = ConfigurationCache.getInstance()?.getClientConfiguration()?.rideEtqtCertificationUrl,let token = SharedPreferenceHelper.getJWTAuthenticationToken(),let name = UserDataCache.getInstance()?.getUserName() else {
            return nil
        }
        return urlPath
    }

    
}
extension RideEtiquettesCardTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rideEtiquettes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideEtiquetteImageCollectionViewCell", for: indexPath as IndexPath) as! RideEtiquetteImageCollectionViewCell
            if rideEtiquettes.endIndex <= indexPath.row {
                return cell
            }
        cell.imageView.backgroundColor = .black
        cell.imageView.image = nil
        ImageCache.getInstance().getImageFromCache(imageUrl: self.rideEtiquettes[indexPath.row].smallMediaUrl!, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
                cell.imageView.image = image?.roundedCornerImage
            })
        
        return cell
    }
    
}
extension RideEtiquettesCardTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoUrl = rideEtiquettes[indexPath.row].bigMediaUrl , rideEtiquettes[indexPath.row].mediaType == UserRideEtiquetteMedia.MEDIA_TYPE_VIDEO {
            let vedioURL = URL(string: videoUrl)
            let player = AVPlayer(url: vedioURL!)
            let playervc = AVPlayerViewController()
            playervc.player = player
            self.parentViewController?.present(playervc, animated: true) {
                playervc.player!.play()
            }
        }else if rideEtiquettes[indexPath.row].mediaType == UserRideEtiquetteMedia.MEDIA_TYPE_IMAGE {
            let rideEtiqueViewController =  UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideEtiquetImageViewController") as! RideEtiquetImageViewController
            let countNumber = indexPath.row
            rideEtiqueViewController.initializingView(rideObject: rideObj, countNumber: countNumber)
            self.parentViewController?.navigationController?.pushViewController(rideEtiqueViewController, animated: false)
//            rideEtiqueViewController.modalPresentationStyle = .overCurrentContext
//            self.parentViewController?.present(rideEtiqueViewController, animated: false, completion: nil)
            }
            
        }
    }
    
    

