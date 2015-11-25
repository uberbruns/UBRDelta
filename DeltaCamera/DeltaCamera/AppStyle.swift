//
//  AppStyle.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 08/10/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit

struct AppStyle {
    
    static var defaultTintColor = UIColor(red:0.51, green:0.69, blue:0.29, alpha:1.0)
    static var defaultTextColor = UIColor.blackColor()
    static var defaultValueColor = UIColor.grayColor()
    
    
    static func applyDefaultAppearance() {
        UINavigationBar.appearance().tintColor = AppStyle.defaultTintColor
        UISwitch.appearance().onTintColor = AppStyle.defaultTintColor
        UITextField.appearance().tintColor = AppStyle.defaultTintColor
    }
    
}
