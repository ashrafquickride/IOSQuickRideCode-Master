//
//  ErrorProcessUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 21/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class ErrorProcessUtils {
    
    static func handleError(responseObject: NSDictionary?,error : NSError?,viewController : UIViewController?, handler: alertControllerActionHandler?){
        AppDelegate.getAppDelegate().log.error("handleError(), response : \(String(describing: responseObject)) , error : \(String(describing: error))")
        QuickRideProgressSpinner.stopSpinner()
        var viewController = viewController
        
        if viewController == nil{
            viewController = ViewControllerUtils.getCenterViewController()
        }
        
        if viewController != nil {
            if responseObject == nil{
                handleError(error: error, viewController: viewController!, handler: handler)
            }else{
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: viewController,handler: nil)
            }
        }
    }
    static func handleResponseError( responseError: ResponseError?,error : NSError?,viewController : UIViewController?,handler: alertControllerActionHandler? = nil){
        AppDelegate.getAppDelegate().log.error("handleError(), responseError : \(String(describing: responseError)) , error : \(String(describing: error))")
        QuickRideProgressSpinner.stopSpinner()
        if viewController != nil {
            if responseError == nil{
                handleError(error: error, viewController: viewController!, handler: handler)
            }else{
                
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: viewController,handler: handler)
            }
        }
    }
    private  static func handleError (error : NSError?, viewController : UIViewController, handler: alertControllerActionHandler?) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.error("handleError(), error : \(String(describing: error))")
        if (error == QuickRideErrors.NetworkConnectionNotAvailableError) {
            displayNetworkError(viewController: viewController, handler: handler)
        }else if error == QuickRideErrors.RequestTimedOutError {
            displayRequestTimeOutError(viewController: viewController, handler: handler)
        }else if error == QuickRideErrors.LocationNotAvailableError{
          MessageDisplay.displayAlert(messageString: Strings.google_server_not_found, viewController: viewController, handler: handler)
        }else if error == QuickRideErrors.NetworkConnectionSlowError{
           displayNetworkSlowError(viewController: viewController)
        }else{
              ErrorProcessUtils.displayServerError(viewController: viewController)
        }
    }

    static func displayNetworkError(viewController : UIViewController, handler: alertControllerActionHandler?){
        AppDelegate.getAppDelegate().log.debug("displayNetworkError()")
        
        if Thread.isMainThread == true{
            let networkDialog =  NetworkErrorDialogue.loadFromNibNamed(nibNamed: "NetworkErrorDialogue") as! NetworkErrorDialogue
            networkDialog.initializeDataBeforePresenting(message: Strings.network_issue, actionName: Strings.ok, viewController: viewController, handler: handler)
            
        }else{
            DispatchQueue.main.async() { () -> Void in
                let networkDialog =  NetworkErrorDialogue.loadFromNibNamed(nibNamed: "NetworkErrorDialogue") as! NetworkErrorDialogue
                networkDialog.initializeDataBeforePresenting(message: Strings.network_issue, actionName: Strings.ok, viewController: viewController, handler: nil)
            }
        }
    }
    static func displayRequestTimeOutError(viewController : UIViewController, handler: alertControllerActionHandler?){
        AppDelegate.getAppDelegate().log.debug("displayRequestTimeOutError()")
     
         DispatchQueue.main.async() { () -> Void in
            let networkErrorDialogue = NetworkErrorDialogue.loadFromNibNamed(nibNamed: "NetworkErrorDialogue") as! NetworkErrorDialogue
            networkErrorDialogue.initializeDataBeforePresenting(message: Strings.server_busy_error, actionName: nil, viewController: viewController, handler: {(result) -> Void in
                handler?(result)
            })
           
        }
    }
    static func getErrorMessageFromErrorObject( error : ResponseError) -> String{
        AppDelegate.getAppDelegate().log.debug("getErrorMessageFromErrorObject()")
        var errorMessage = ""
        if error.userMessage != nil && error.userMessage!.isEmpty == false{
            errorMessage = error.userMessage!
        }
        if error.hintForCorrection != nil && error.hintForCorrection!.isEmpty == false{
            errorMessage = errorMessage+" "+error.hintForCorrection!
        }
        return errorMessage
    }
    static func displayServerError(viewController : UIViewController){
        QuickRideProgressSpinner.stopSpinner()
        
        AppDelegate.getAppDelegate().log.debug("displayServerError()")
        
        if Thread.isMainThread == true{
            let serverErrorDialogue = ServerErrorDialogue.loadFromNibNamed(nibNamed: "ServerErrorDialogue") as! ServerErrorDialogue
            serverErrorDialogue.initializeDataBeforePresenting(viewController: viewController,handler: nil)
        }else{
             DispatchQueue.main.async() { () -> Void in
                let serverErrorDialogue = ServerErrorDialogue.loadFromNibNamed(nibNamed: "ServerErrorDialogue") as! ServerErrorDialogue
                serverErrorDialogue.initializeDataBeforePresenting(viewController: viewController,handler: nil)
            }
        }
    }
    
    static func displayNetworkSlowError(viewController : UIViewController){
        
        AppDelegate.getAppDelegate().log.debug("displayNetworkSlowError()")
        
        if Thread.isMainThread == true{
            let networkSlowErrorDialogue = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NetworkSlowErrorDialogue") as! NetworkSlowErrorDialogue
            
            ViewControllerUtils.addSubView(viewControllerToDisplay: networkSlowErrorDialogue)
            networkSlowErrorDialogue.view!.layoutIfNeeded()
        }else{
            DispatchQueue.main.async() { () -> Void in
                let networkSlowErrorDialogue = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NetworkSlowErrorDialogue") as! NetworkSlowErrorDialogue
                ViewControllerUtils.addSubView(viewControllerToDisplay: networkSlowErrorDialogue)
                networkSlowErrorDialogue.view!.layoutIfNeeded()
            }
        }
    }
    
    static func getErrorMessage(responseObject: NSDictionary?,error : NSError?) -> String? {
        if responseObject == nil {
            if (error == QuickRideErrors.NetworkConnectionNotAvailableError) {
                return Strings.network_issue
            }else if error == QuickRideErrors.RequestTimedOutError {
                return Strings.server_busy_error
            }else if error == QuickRideErrors.LocationNotAvailableError{
                return Strings.google_server_not_found
            }else if error == QuickRideErrors.NetworkConnectionSlowError{
                return Strings.network_slow_error_message
            }else{
                return Strings.server_busy_error
            }
        }else {
            guard let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData")) else {
                return nil
            }
            return ErrorProcessUtils.getErrorMessageFromErrorObject(error: error)
        }
    }
    
}
