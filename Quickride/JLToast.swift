//
//  JLToast.swift
//  Quickride
//
//  Created by KNM Rao on 03/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import UIKit

public struct JLToastDelay {
    public static let ShortDelay: TimeInterval = 2.0
    public static let LongDelay: TimeInterval = 3.5
}

public class JLToast: Operation {
    
    public var view: JLToastView = JLToastView()
    
    public var checkLink : Bool?
        {
        get {
            return true
        }
        set {
            self.view.navigateButton.isHidden = newValue!
        }
    }
    
    public var text: String? {
        get {
            return self.view.textLabel.text
        }
        set {
            self.view.textLabel.text = newValue
        }
    }
    
    public var delay: TimeInterval = 0
    public var duration: TimeInterval = JLToastDelay.ShortDelay
    
     public var _executing = false
    override public var isExecuting: Bool {
        get {
            return self._executing
        }
        set {
            self.willChangeValue(forKey: "isExecuting")
            self._executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
     public var _finished = false
    override public var isFinished: Bool {
        get {
            return self._finished
        }
        set {
            self.willChangeValue(forKey: "isFinished")
            self._finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    public class func makeText(text: String) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText()")
        return JLToast.makeText(text: text, delay: 0, duration: JLToastDelay.ShortDelay)
    }
    
    
    public class func makeText(text: String, checkLink : Bool, destination : UIViewController) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText() \(text)")
        return JLToast.makeText(text: text, delay: 0, duration: JLToastDelay.ShortDelay, checkLink : checkLink, destination : UIViewController())
    }
    
    public class func makeText(text: String, duration: TimeInterval) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText() \(text)")
        return JLToast.makeText(text: text, delay: 0, duration: duration)
    }
    
    public class func makeText(text: String, delay: TimeInterval, duration: TimeInterval) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText() \(text)")
        let toast = JLToast()
        toast.text = text
        toast.delay = delay
        toast.duration = duration
        toast.checkLink = true
        return toast
    }
    public class func makeText(text: String, delay: TimeInterval, duration: TimeInterval,checkLink : Bool , destination : UIViewController) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText() \(text)")
        let toast = JLToast()
        toast.text = text
        toast.delay = delay
        toast.duration = duration
        toast.checkLink = checkLink
        return toast
    }
    
    public class func makeText(text: String, delay: TimeInterval, duration: TimeInterval, destination : UIViewController) -> JLToast {
      AppDelegate.getAppDelegate().log.debug("makeText() \(text)")
        let toast = JLToast()
        toast.text = text
        toast.delay = delay
        toast.duration = duration
        toast.checkLink = true
        return toast
    }
    
    
    public func show() {
      AppDelegate.getAppDelegate().log.debug("show()")
        JLToastCenter.defaultCenter().addToast(toast: self)
    }
    
    override public func start() {
      AppDelegate.getAppDelegate().log.debug("start()")
        if !Thread.isMainThread {
            DispatchQueue.main.async(execute: {
                self.start()
            })
        } else {
            super.start()
        }
    }
    
    override public func main() {
      AppDelegate.getAppDelegate().log.debug("main()")
        self._executing = true
        
        DispatchQueue.main.async(execute: {
            self.view.updateView()
            self.view.alpha = 0
            UIApplication.shared.windows.first?.addSubview(self.view)
            UIView.animate(
                withDuration: 0.5,
                delay: self.delay,
                options: .beginFromCurrentState,
                animations: {
                    self.view.alpha = 1
                },
                completion: { completed in
                    UIView.animate(
                        withDuration: self.duration,
                        animations: {
                            self.view.alpha = 1.0001
                        },
                        completion: { completed in
                            self.finish()
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.alpha = 0
                            })
                        }
                    )
                }
            )
        })
    }
    
    public func finish() {
      AppDelegate.getAppDelegate().log.debug("finish()")
        self._executing = false
        self._finished = true
    }
}
