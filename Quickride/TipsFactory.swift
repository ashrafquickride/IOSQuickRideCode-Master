//
//  TipsFactory.swift
//  Quickride
//
//  Created by QuickRideMac on 1/21/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TipsFactory
{
    static let OFFER_RIDE_CONTEXT : String = "OFFER_RIDE"
    static let FIND_RIDE_CONTEXT : String = "FIND_RIDE"
    static let RIDER_RIDE_CREATED_CONTEXT : String = "RIDER_RIDE_CREATED"
    static let PASSENGER_RIDE_CREATED_CONTEXT : String = "PASSENGER_RIDE_CREATED"
    static let INVITE_SEND_RIDER_CONTEXT : String = "INVITE_SEND_RIDER"
    static let INVITE_SEND_PASSENGER_CONTEXT : String = "INVITE_SEND_PASSENGER"
    static let INVITE_SEND_PASSENGER_STARTED_RIDER_CONTEXT : String = "INVITE_SEND_PASSENGER_STARTED_RIDER_CONTEXT"
    static let RIDER_JOINED_PASSENGER_CONTEXT = "RIDER_JOINED_PASSENGER"
    static let PASSENGER_JOINED_RIDER_CONTEXT : String = "PASSENGER_JOINED_RIDER"
    static let RIDER_RIDE_STARTED_CONTEXT : String = "RIDER_RIDE_STARTED"
    static let RIDER_RIDE_STARTED_FOR_PASSENGER_CONTEXT : String = "PASSENGER_RIDE_STARTED"
    static let RIDER_RIDE_DELAYED_CONTEXT : String = "RIDER_RIDE_DELAYED"
    static let RIDER_GROUP_CHAT_CONTEXT : String = "RIDER_GROUP_CHAT"
    static let RIDE_PREFERENCES : String = "RIDE_PREFERENCES"
    static let NOTIFICATION_ACTION_CONTEXT : String = "NOTIFICATION_ACTION_CONTEXT"
    static let UPDATE_FARE_CONTEXT : String = "UPDATE_FARE_CONTEXT"

    static var sharedInstance : TipsFactory?
    var displayingTipDialog : TipsView?
    var existedContext : String?
    var isDisplayedAlreadyATip = false

    static func getInstance() -> TipsFactory{
        AppDelegate.getAppDelegate().log.debug("getInstance()")
        if sharedInstance == nil{
            sharedInstance = TipsFactory()
        }
        return self.sharedInstance!
    }
    
    func removeCache(){
        AppDelegate.getAppDelegate().log.debug("removeConversationCache()")
        self.displayingTipDialog = nil
        self.existedContext = nil
        self.isDisplayedAlreadyATip = false
        TipsFactory.sharedInstance = nil
    }
    func displayTip(context : String) -> Bool
    {
                if (context == existedContext || isDisplayedAlreadyATip)
                {
                    return true
                }
                if(displayingTipDialog != nil)
                {
                    displayingTipDialog!.removeFromSuperview()
                    displayingTipDialog = nil
                    existedContext = nil
                }
               let tips = getTipBasedOnContext(context: context)
                if tips.isEmpty
                {
                    return false
                }
                let tipStatus : Int? = getTipStatus(context: context)
                if tipStatus!+1 >= tips.count
                {
                    return false
                }
                existedContext = context
                if(tipStatus == -1)
                {
                    displayTipDialog(context: context,tips: tips,tipPosition: 0);
                }
                else
                {
                    displayTipDialog(context: context,tips: tips,tipPosition: tipStatus!+1)
                }
                isDisplayedAlreadyATip = true
           if TipsFactory.OFFER_RIDE_CONTEXT == context && getTipStatus(context: TipsFactory.FIND_RIDE_CONTEXT)! < 0
           {
                TipsFactory.setTipAlreadyDisplayedFlag(flag: false)
            }
            if(TipsFactory.FIND_RIDE_CONTEXT == context && getTipStatus(context: TipsFactory.OFFER_RIDE_CONTEXT)! < 0)
            {
                TipsFactory.setTipAlreadyDisplayedFlag(flag: false)
            }
                return true
    }
    
    static func setTipAlreadyDisplayedFlag(flag : Bool)
    {
        self.sharedInstance?.isDisplayedAlreadyATip = flag
    }
    
    func getTipBasedOnContext(context : String) -> [String]
    {
        var requiredContext : [String]?

        switch context
        {
        case TipsFactory.OFFER_RIDE_CONTEXT:
            requiredContext = Strings.OFFER_RIDE_TIP
            break
        case TipsFactory.FIND_RIDE_CONTEXT:
            requiredContext =  Strings.FIND_RIDE_TIP
            break
        case TipsFactory.RIDER_RIDE_CREATED_CONTEXT:
            requiredContext = Strings.RIDER_RIDE_CREATED
            break
        case TipsFactory.PASSENGER_RIDE_CREATED_CONTEXT:
            requiredContext = Strings.PASSENGER_RIDE_CREATED
            break
        case TipsFactory.INVITE_SEND_RIDER_CONTEXT:
            requiredContext = Strings.INVITE_SEND_RIDER
            break
        case TipsFactory.INVITE_SEND_PASSENGER_CONTEXT:
            requiredContext = Strings.INVITE_SEND_PASSENGER
            break
        case TipsFactory.INVITE_SEND_PASSENGER_STARTED_RIDER_CONTEXT:
            requiredContext = Strings.INVITE_SEND_PASSENGER_STARTED_RIDER_CONTEXT
            break
        case TipsFactory.RIDER_JOINED_PASSENGER_CONTEXT:
            requiredContext = Strings.RIDER_JOINED_PASSENGER
            break
        case TipsFactory.PASSENGER_JOINED_RIDER_CONTEXT:
            requiredContext = Strings.PASSENGER_JOINED_RIDER
            break
        case TipsFactory.RIDER_RIDE_STARTED_CONTEXT:
            requiredContext = Strings.RIDER_RIDE_STARTED
            break
        case TipsFactory.RIDER_RIDE_STARTED_FOR_PASSENGER_CONTEXT:
            requiredContext = Strings.PASSENGER_RIDE_STARTED
            break
        case TipsFactory.RIDER_RIDE_DELAYED_CONTEXT:
            requiredContext = Strings.RIDER_RIDE_DELAYED
            break
        case TipsFactory.RIDER_GROUP_CHAT_CONTEXT:
            requiredContext = Strings.RIDER_GROUP_CHAT_TIP
            break
        case TipsFactory.RIDE_PREFERENCES:
            requiredContext = Strings.RIDE_PREFERENCES
            break
        case TipsFactory.NOTIFICATION_ACTION_CONTEXT:
            requiredContext = Strings.NOTIFICATION_ACTION
            break
        case TipsFactory.UPDATE_FARE_CONTEXT:
            requiredContext = Strings.UPDATE_FARE_ACTION
            break
        default:
            break
        }
        return requiredContext!
    }
    func getTipStatus(context : String) -> Int?
    {
        return SharedPreferenceHelper.getTipStatus(key: context)
    }

    func storeTipStatus(context : String,value : Int)
    {
        SharedPreferenceHelper.storeTipStatus(key: context,value: value)
    }
    private func displayTipDialog(context : String, tips : [String], tipPosition : Int)
    {
        AppDelegate.getAppDelegate().log.debug("Displaying of info Dialog")
        let tipsView = TipsView.loadFromNibNamed(nibNamed: "TipView") as! TipsView
        tipsView.adjustViewBasedOnTips(message: tips[tipPosition])
        tipsView.displayTipDialog(context: context, viewController: ViewControllerUtils.getCenterViewController(), tips: tips, tipPosition: tipPosition)
    }
}
