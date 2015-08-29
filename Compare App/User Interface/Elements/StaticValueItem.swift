//
//  StaticValueItem.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit


struct StaticValueItem : TableViewItem  {
    
    let id: String
    let reuseIdentifier = "StaticValueRow"
    
    let title: String
    let value: String
    
    init(id: String, title: String, value: String)
    {
        self.id = id
        self.title = title
        self.value = value
    }
}



extension StaticValueItem : ComparableItem {
    
    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel
    {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherRow = other as? StaticValueItem else { return .Different }
        
        if otherRow.title == self.title && otherRow.value == self.value && otherRow.id == self.id {
            return .Same
        } else {
            return .SameIdentifier
        }
    }
    
}
