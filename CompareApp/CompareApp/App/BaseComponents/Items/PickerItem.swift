//
//  PickerItem.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


protocol PickerValue {
    
    var pickerTitle: String { get }
    func isEqualTo(other: PickerValue) -> Bool
    
}


extension PickerValue where Self: Equatable {
    
    func isEqualTo(other: PickerValue) -> Bool
    {
        if let o = other as? Self { return self == o }
        return false
    }
    
}


extension String : PickerValue {

    var pickerTitle: String {
        return self
    }

}


struct PickerItem: TableViewItem  {
    
    typealias ValueHandler = (value: PickerValue) -> ()
    
    let id: String
    let reuseIdentifier = "PickerRow"
    
    let title: String
    let values: [PickerValue]
    let selectedValue: PickerValue
    let valueHandler: ValueHandler
    
    init(id: String, title: String, values: [PickerValue], value: PickerValue, valueHandler: ValueHandler)
    {
        self.id = id
        self.title = title
        self.values = values
        self.valueHandler = valueHandler
        self.selectedValue = value
    }
    
}



extension PickerItem : ComparableItem {
    
    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel
    {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherItem = other as? PickerItem else { return .Different }
        guard self.values.count == otherItem.values.count else { return .Different }

        let equalValues = Array(zip(self.values, otherItem.values)).indexOf{ !$0.0.isEqualTo($0.1) } == nil
        
        if equalValues &&
            self.title == otherItem.title &&
            self.selectedValue.isEqualTo(otherItem.selectedValue) &&
            self.id == otherItem.id {
            return .Same
        } else {
            return .SameIdentifier
        }
    }
    
}
