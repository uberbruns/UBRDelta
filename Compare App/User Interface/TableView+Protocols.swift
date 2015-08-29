//
//  UITableViewCell+Protocols.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


protocol TableViewItem {
    
    var reuseIdentifier: String { get }
    
}


protocol UpdateableTableViewCell {
    
    func updateCellWithItem(item: ComparableItem, animated: Bool)
    
}