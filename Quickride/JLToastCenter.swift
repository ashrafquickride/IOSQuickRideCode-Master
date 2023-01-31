//
//  JLToastCenter.swift
//  Quickride
//
//  Created by KNM Rao on 03/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import UIKit

@objc public class JLToastCenter: NSObject {
    
    private var _queue: OperationQueue!
    
    private struct Singletone {
        static let defaultCenter = JLToastCenter()
    }
    
    public class func defaultCenter() -> JLToastCenter {
        return Singletone.defaultCenter
    }
    
    override init() {
        super.init()
        self._queue = OperationQueue()
        self._queue.maxConcurrentOperationCount = 1
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(JLToastCenter.deviceOrientationDidChange(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    public func addToast(toast: JLToast) {
      AppDelegate.getAppDelegate().log.debug("addToast()")
        self._queue.addOperation(toast)
    }
    
    @objc func deviceOrientationDidChange(_ sender: AnyObject?) {
      AppDelegate.getAppDelegate().log.debug("deviceOrientationDidChange()")
        if self._queue.operations.count > 0 {
            let lastToast: JLToast = _queue.operations[0] as! JLToast
            lastToast.view.updateView()
        }
    }
}
