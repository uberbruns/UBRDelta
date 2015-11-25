//
//  UITableViewCell+Protocols.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


typealias SelectionHandler = () -> ()


protocol TableViewItem {
    
    var id: String { get }
    var reuseIdentifier: String { get }
    
}


protocol UpdateableTableViewCell {
    
    func updateCellWithItem(item: ComparableItem, animated: Bool)
    
}


@objc protocol ManipulatingTableViewCell {
    
    var tableView: UITableView? { get set }
    
}


protocol UpdateableTableViewHeaderFooterView {
    
    func updateViewWithItem(item: ComparableItem, animated: Bool)
    
}


protocol SelectableTableViewItem {

    var selectionHandler: SelectionHandler? { get }

}


protocol DeletableTableViewItem {
    
    var deletable: Bool { get }
    
}
