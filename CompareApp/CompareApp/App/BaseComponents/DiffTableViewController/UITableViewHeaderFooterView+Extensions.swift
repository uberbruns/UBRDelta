//
//  UITableViewHeaderFooterView+Extensions.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools

extension UITableViewHeaderFooterView : UpdateableTableViewHeaderFooterView {
    
    func updateViewWithItem(item: ComparableItem, animated: Bool)
    {
        guard let sectionItem = item as? TableViewSectionItem else { return }
        textLabel?.text = sectionItem.title
    }
    
}