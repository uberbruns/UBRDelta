//
//  SwitchItem.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


struct SwitchItem : TableViewItem, SelectableTableViewItem  {
    
    typealias ValueHandler = (value: Bool) -> ()
    
    let id: String
    let reuseIdentifier = "Switch"
    
    let title: String
    let value: Bool
    let valueHandler: ValueHandler
    let selectionHandler: SelectionHandler?
    
    init(id: String, title: String, value: Bool, valueHandler: ValueHandler, selectionHandler: SelectionHandler? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.valueHandler = valueHandler
        self.selectionHandler = selectionHandler
    }
}



extension SwitchItem : ComparableItem {

    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherRow = other as? SwitchItem else { return .Different }
        
        if otherRow.title == self.title && otherRow.value == self.value && otherRow.id == self.id {
            return .Same
        } else {
            return .Changed([:])
        }
    }

}