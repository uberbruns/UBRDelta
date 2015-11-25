//
//  StaticValueItem.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 25/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


struct StaticValueItem : TableViewItem  {
    
    let reuseIdentifier = "StaticValue"
    let id: String
    let title: String
    let value: String
    
    init(id: String, title: String, value: String) {
        self.id = id
        self.title = title
        self.value = value
    }
}



extension StaticValueItem : ComparableItem {
    
    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherItem = other as? StaticValueItem else { return .Different }
        
        let titleDidChange = title != otherItem.title
        let valueDidChange = value != otherItem.value
        
        if !titleDidChange && !valueDidChange {
            return .Same
        } else {
            return .Changed(["title":titleDidChange, "value":valueDidChange])
        }
    }
    
}

