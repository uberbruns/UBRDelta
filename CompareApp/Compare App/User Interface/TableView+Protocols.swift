//
//  UITableViewCell+Protocols.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


protocol TableViewItem {
    
    var id: String { get }
    var reuseIdentifier: String { get }
    
}


protocol UpdateableTableViewCell {
    
    func updateCellWithItem(item: ComparableItem, animated: Bool)
    
}


protocol UpdateableTableViewHeaderFooterView {
    
    func updateViewWithItem(item: ComparableItem, animated: Bool)
    
}


extension UITableViewHeaderFooterView : UpdateableTableViewHeaderFooterView {

    func updateViewWithItem(item: ComparableItem, animated: Bool)
    {
        guard let sectionItem = item as? DiffTableViewSectionItem else { return }
        textLabel?.text = sectionItem.title
    }
    
}