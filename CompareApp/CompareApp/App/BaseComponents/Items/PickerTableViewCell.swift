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
        guard let pickerItem = item as? PickerItem else { return }
        self.item = pickerItem
        titleLabel.text = pickerItem.title
        valueLabel.text = pickerItem.selectedValue.pickerTitle
        
        let selectedRow = pickerItem.values.indexOf({ $0.isEqualTo(pickerItem.selectedValue) }) ?? 0
        pickerControl.selectRow(selectedRow, inComponent: 0, animated: animated)
    }
    
}


extension PickerTableViewCell : UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }

    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        guard let pickerItem = item else { return 0 }
        return pickerItem.values.count
    }
    
}


extension PickerTableViewCell : UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        guard let value = item?.values[row] else { return nil }
        return value.pickerTitle
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        guard let pickerItem = item else { return }
        let selectedValue = pickerItem.values[row]
        pickerItem.valueHandler(value: selectedValue)
    }
}

