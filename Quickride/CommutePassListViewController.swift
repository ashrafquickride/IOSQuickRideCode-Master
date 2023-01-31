//
//  CommutePassListViewController.swift
//  Quickride
//
//  Created by Admin on 19/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CommutePassListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIViewControllerTransitioningDelegate,UINavigationControllerDelegate{
   
   @IBOutlet weak var fromLocationLbl: UILabel!
    
    @IBOutlet weak var toLocationLbl: UILabel!
    
    @IBOutlet weak var commutePassListTableView: UITableView!
    
    @IBOutlet weak var locationSwapImgView: UIImageView!
    
    var commutePasses = [RidePass]()
    let transition = TransitionAnimator()
    var selectedCell = UITableViewCell()
    
    func initializeDataBeforePresenting(commutePasses : [RidePass]){
        self.commutePasses = commutePasses
    }
    
    override func viewDidLoad() {
        
        if UserDataCache.getInstance()?.getHomeLocation() != nil && UserDataCache.getInstance()?.getOfficeLocation() != nil{
            fromLocationLbl.text = UserDataCache.getInstance()?.getHomeLocation()?.shortAddress
            toLocationLbl.text = UserDataCache.getInstance()?.getOfficeLocation()?.shortAddress
        }else{
            fromLocationLbl.text = commutePasses[0].fromAddress
             toLocationLbl.text = commutePasses[0].toAddress
        }

        ImageUtils.setTintedIcon(origImage: UIImage(named: "icon_swap")!, imageView: locationSwapImgView, color: UIColor(netHex: 0x00B557))
        commutePassListTableView.delegate = self
        commutePassListTableView.dataSource = self
        self.navigationController?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = true
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.commutePasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "CommutePassTableViewCell") as! CommutePassTableViewCell
        if commutePasses.endIndex <= indexPath.row{
            return cell
        }
      cell.selectionStyle = .none
      cell.initializeViews(pass: commutePasses[indexPath.row], index: indexPath.row)
      return cell
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let pass = commutePasses[indexPath.row]
        
        var isAnyPassActive = false
        var activatedPassTotalRidesCount : Int?
        let activatedPass = getActivatedPassIfAny()
        
        if activatedPass != nil{
            isAnyPassActive = true
            activatedPassTotalRidesCount = activatedPass!.totalRides
        }
        selectedCell = tableView.cellForRow(at: indexPath) as! CommutePassTableViewCell
        let passDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PassDetailViewController") as! PassDetailViewController
        passDetailViewController.initializeDataBeforePresenting(isCurrentPassActive: checkWhetherCurrentPassIsActive(pass: pass) , isAnyPassActive: isAnyPassActive, activatedPassTotalRidesCount: activatedPassTotalRidesCount,pass: pass, index: indexPath.row)
        passDetailViewController.transitioningDelegate = self
        self.navigationController?.pushViewController(passDetailViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
  
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func checkWhetherCurrentPassIsActive(pass : RidePass) -> Bool{
        for commutePass in commutePasses{
            if commutePass == pass && commutePass.status == RidePass.PASS_STATUS_ACTIVE{
                return true
            }
        }
        return false
    }
    
    func getActivatedPassIfAny() -> RidePass?{
        for commutePass in commutePasses{
           if commutePass.status == RidePass.PASS_STATUS_ACTIVE{
                return commutePass
            }
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil) else {
          return transition
        }
        switch operation{
        case .push:
            transition.originFrame = originFrame
            transition.presenting = true
            selectedCell.isHidden = true
         default:
            transition.presenting = false
            selectedCell.isHidden = false
        }
        
        return transition
    }

}
