//
//  JLToastView.swift
//  Quickride
//
//  Created by KNM Rao on 03/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import UIKit

public let JLToastViewBackgroundColorAttributeName = "JLToastViewBackgroundColorAttributeName"
public let JLToastViewCornerRadiusAttributeName = "JLToastViewCornerRadiusAttributeName"
public let JLToastViewTextInsetsAttributeName = "JLToastViewTextInsetsAttributeName"
public let JLToastViewTextColorAttributeName = "JLToastViewTextColorAttributeName"
public let JLToastViewFontAttributeName = "JLToastViewFontAttributeName"
public let JLToastViewPortraitOffsetYAttributeName = "JLToastViewPortraitOffsetYAttributeName"
public let JLToastViewLandscapeOffsetYAttributeName = "JLToastViewLandscapeOffsetYAttributeName"

@objc public class JLToastView: UIView {
    
    var backgroundView: UIView!
    var textLabel: UILabel!
    var textInsets: UIEdgeInsets!
    var navigateButton : UIButton!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        
        
        self.backgroundView = UIView()
        self.backgroundView.frame = self.bounds
        self.backgroundView.backgroundColor = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewBackgroundColorAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as? UIColor
        self.backgroundView.layer.cornerRadius = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewCornerRadiusAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! CGFloat
        self.backgroundView.clipsToBounds = true
        self.addSubview(self.backgroundView)
        
        self.textLabel = UILabel()
        self.textLabel.frame = self.bounds
        self.textLabel.textColor = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewTextColorAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as? UIColor
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.font = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewFontAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! UIFont
        self.textLabel.numberOfLines = 0
        self.textLabel.textAlignment = .center;
        self.addSubview(self.textLabel)
        
        self.navigateButton = UIButton()
        self.navigateButton.frame = CGRect(x: self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 2, y: self.textLabel.frame.origin.y, width: 30, height: 20)
        self.navigateButton.addTarget(self, action: #selector(JLToastView.btnBack(_:)), for: UIControl.Event.touchUpInside)
        
        self.navigateButton.backgroundColor = UIColor.red
        self.addSubview(self.navigateButton)
        
        self.textInsets = (type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewTextInsetsAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! NSValue).uiEdgeInsetsValue
    }
    @objc func btnBack(_ sender: AnyObject)
    {
              AppDelegate.getAppDelegate().log.debug("btnBack()")
    }
    
    
    func btnNavigate()
    {
        let appDelegate = AppDelegate()
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
//        let containerViewController = toastSelectViewController
        
        //appDelegate.window!.rootViewController = containerViewController
        //appDelegate.window!.makeKeyAndVisible()
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    func updateView() {
      AppDelegate.getAppDelegate().log.debug("updateView()")
        let deviceWidth = UIScreen.main.bounds.width
        //        let font = self.textLabel.font
        let constraintSize = CGSize(width: deviceWidth * (280.0 / 320.0), height: CGFloat.greatestFiniteMagnitude)
        let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
        self.textLabel.frame = CGRect(
            x: self.textInsets.left,
            y: self.textInsets.top,
            width: textLabelSize.width,
            height: textLabelSize.height
        )
        
        var widthOfView : CGFloat = 0.0
        
        if self.navigateButton.isHidden == true
        {
            widthOfView = self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right
        }
        else
        {
            widthOfView = self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right + self.navigateButton.frame.width
        }
        self.backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: widthOfView,
            height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
        )
        
        var x: CGFloat
        var y: CGFloat
        var width:CGFloat
        var height:CGFloat
        
        let screenSize = UIScreen.main.bounds.size
        let backgroundViewSize = self.backgroundView.frame.size
        
        let systemVersion = (UIDevice.current.systemVersion as NSString).floatValue
        
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        let portraitOffsetY = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewPortraitOffsetYAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! CGFloat
        let landscapeOffsetY = type(of: self).defaultValueForAttributeName(
            attributeName: JLToastViewLandscapeOffsetYAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! CGFloat
        
        if UIDevice.current.orientation.isLandscape && systemVersion < 8.0 {
            width = screenSize.height
            height = screenSize.width
            y = landscapeOffsetY
        } else {
            width = screenSize.width
            height = screenSize.height
            if UIDevice.current.orientation.isLandscape {
                y = landscapeOffsetY
            } else {
                y = portraitOffsetY
            }
        }
        
        x = (width - backgroundViewSize.width) * 0.5
        y = height - (backgroundViewSize.height + y)
        self.frame = CGRect(x: x, y: y, width: backgroundViewSize.width, height: backgroundViewSize.height);
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
      AppDelegate.getAppDelegate().log.debug("hitTest()")
        if let _ = self.superview {
            let pointInWindow = self.convert(point, to: self.superview)
            let contains = self.frame.contains(pointInWindow)
            if contains && self.isUserInteractionEnabled {
                return self
            }
        }
        return nil
    }
    
}

public extension JLToastView {
    private struct Singleton {
        static var defaultValues: [String: [UIUserInterfaceIdiom: AnyObject]] = [
            // backgroundView.color
            JLToastViewBackgroundColorAttributeName: [
                .unspecified: UIColor(white: 0, alpha: 0.7)
            ],
            
            // backgroundView.layer.cornerRadius
            JLToastViewCornerRadiusAttributeName: [
                .unspecified: 5 as AnyObject
            ],
            
            JLToastViewTextInsetsAttributeName: [
                .unspecified: NSValue(uiEdgeInsets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
            ],
            
            // textLabel.textColor
            JLToastViewTextColorAttributeName: [
                .unspecified: UIColor.white
            ],
            
            // textLabel.font
            JLToastViewFontAttributeName: [
                .unspecified: UIFont.systemFont(ofSize: 12),
                .phone: UIFont.systemFont(ofSize: 12),
                .pad: UIFont.systemFont(ofSize: 16),
            ],
            
            JLToastViewPortraitOffsetYAttributeName: [
                .unspecified: 30 as AnyObject,
                .phone: 30 as AnyObject,
                .pad: 60 as AnyObject,
            ],
            JLToastViewLandscapeOffsetYAttributeName: [
                .unspecified: 20 as AnyObject,
                .phone: 20 as AnyObject,
                .pad: 40 as AnyObject,
            ],
        ]
    }
    
    class func defaultValueForAttributeName(attributeName: String,
        forUserInterfaceIdiom userInterfaceIdiom: UIUserInterfaceIdiom)
        -> AnyObject {
            let valueForAttributeName = Singleton.defaultValues[attributeName]!
            if let value: AnyObject = valueForAttributeName[userInterfaceIdiom] {
                return value
            }
            return valueForAttributeName[.unspecified]!
    }
    
    class func setDefaultValue(value: AnyObject,
        forAttributeName attributeName: String,
        userInterfaceIdiom: UIUserInterfaceIdiom) {
            var values = Singleton.defaultValues[attributeName]!
            values[userInterfaceIdiom] = value
            Singleton.defaultValues[attributeName] = values
    }
}
