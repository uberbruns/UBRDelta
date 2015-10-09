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
    
    typealias ValueHandler = (selectedValues: [PickerValue]) -> ()
    
    let id: String
    let reuseIdentifier = "PickerRow"
    
    let title: String
    let displayedValue: String
    let components: [[PickerValue]]
    let selectedValues: [PickerValue]
    let valueHandler: ValueHandler
    
    init(id: String, title: String, displayedValue: String, selectedValues: [PickerValue], values: [[PickerValue]], valueHandler: ValueHandler)
    {
        self.id = id
        self.title = title
        self.displayedValue = displayedValue
        self.components = values
        self.valueHandler = valueHandler
        self.selectedValues = selectedValues
    }
    
}



extension PickerItem : ComparableItem {
    
    var uniqueIdentifier: Int { return id.hash }
    
    func compareTo(other: ComparableItem) -> ComparisonLevel
    {
        guard other.uniqueIdentifier == self.uniqueIdentifier else { return .Different }
        guard let otherItem = other as? PickerItem else { return .Different }
        guard self.components.count == otherItem.components.count else { return .Different }
        guard self.selectedValues.count == otherItem.selectedValues.count else { return .Different }

        var equalComponents = true
        
        //
        for var i = 0; i < components.count; i++ {
            
            let componentOfSelf = self.components[i]
            let componentOfOther = otherItem.components[i]
            
            if componentOfSelf.count != componentOfOther.count {
                equalComponents = false
                break
            }
            
            equalComponents = Array(zip(componentOfSelf, componentOfOther)).indexOf{ !$0.0.isEqualTo($0.1) } == nil

            if equalComponents == false {
                break
            }
        }
        
        
        let equalSelectedValues = Array(zip(self.selectedValues, otherItem.selectedValues)).indexOf{ !$0.0.isEqualTo($0.1) } == nil
        
        if equalComponents &&
            equalSelectedValues &&
            self.title == otherItem.title &&
            self.displayedValue == otherItem.displayedValue &&
            self.id == otherItem.id {
            return .Same
        } else {
            return .Changed(["components": !equalComponents])
        }
    }
    
}
