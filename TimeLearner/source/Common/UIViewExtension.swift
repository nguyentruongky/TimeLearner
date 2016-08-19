//
//  UIViewExtension.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit

extension UIView {
    func createBorder(width: CGFloat, color: UIColor) {
        
        layer.borderColor = color.CGColor
        layer.borderWidth = width
    }
    
    func createRoundCorner(radius: CGFloat) {
        
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

struct Common {
    static func changeStatusBarToDark(dark: Bool) {
        UIApplication.sharedApplication().statusBarStyle = dark ?
            UIStatusBarStyle.Default : UIStatusBarStyle.LightContent
    }
}