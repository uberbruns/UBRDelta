//
//  PickerTableViewCell.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


class PickerTableViewCell: UITableViewCell {
    
    private var item: PickerItem? = nil
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var valueLabel: Label!
    @IBOutlet weak var pickerControl: UIPickerView!
    
}


extension PickerTableViewCell : UpdateableTableViewCell {
    
    func updateCellWithItem(item: ComparableItem, animated: Bool)
    {
        guard let newItem = item as? PickerItem else { return }
        
        titleLabel.text = newItem.title
        valueLabel.text = newItem.displayedValue

        // Check if reloadAllComponents() is neccessary
        if let oldItem = self.item {
            self.item = newItem
            let comparisonLevel = newItem.compareTo(oldItem)
            switch comparisonLevel {
            case .Changed(let changed) :
                guard changed["components"] == true else { break }
                pickerControl.reloadAllComponents()
                break
            default :
                break
            }
        } else {
            self.item = newItem
        }
        
        
        for (component, values) in newItem.components.enumerate() {
            let selectedValue = newItem.selectedValues[component]
            let selectedRow = values.indexOf({ $0.isEqualTo(selectedValue) }) ?? 0
            pickerControl.selectRow(selectedRow, inComponent: component, animated: animated)
        }
        
    }
    
}


extension PickerTableViewCell : UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        guard let pickerItem = item else { return 0 }
        return pickerItem.components.count
    }

    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        guard let pickerItem = item else { return 0 }
        return pickerItem.components[component].count
    }
    
}


extension PickerTableViewCell : UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        guard let value = item?.components[component][row] else { return nil }
        return value.pickerTitle
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        guard let pickerItem = item else { return }
        
        let selectedValues: [PickerValue] = (0..<pickerItem.components.count).map({ c in
            let r = (c == component) ? row : pickerView.selectedRowInComponent(c)
            return pickerItem.components[c][r]
        })

        pickerItem.valueHandler(selectedValues: selectedValues)
    }
}

