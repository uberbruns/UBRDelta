//
//  StaticValueItem.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


struct ColorItem : TableViewItem  {
    
    let reuseIdentifier = "Color"
    let id: String
    let color: CVColor
    
    init(id: String, color: CVColor) {
        self.id = id
        self.color = color
    }
}



extension ColorItem : ComparableItem {
    
    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherItem = other as? ColorItem else { return .Different }
        
        let colorDidChange = color != otherItem.color
        
        if !colorDidChange {
            return .Same
        } else {
            return .Changed(["color":colorDidChange])
        }
    }
    
}
