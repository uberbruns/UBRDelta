//
//  UITableViewHeaderFooterView+Extensions.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta

extension UITableViewHeaderFooterView : UpdateableTableViewHeaderFooterView {
    
    func updateViewWithItem(item: ComparableItem, animated: Bool) {
        guard let sectionItem = item as? TableViewSectionItem else { return }
        
        if let userInfo = sectionItem.userInfo,
            let role = userInfo["role"] as? String where role == "footer" {
                textLabel?.text = sectionItem.footer
        } else {
            textLabel?.text = sectionItem.title?.uppercaseString
        }
        
    }
    
}