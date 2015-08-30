//
//  SwitchTableViewCell.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    private var item: SwitchItem? = nil
    
    @IBAction func switchValueChanged(sender: AnyObject)
    {
        item?.valueHandler(value: switchControl.on)
    }
    
}


extension SwitchTableViewCell : UpdateableTableViewCell {

    func updateCellWithItem(item: ComparableItem, animated: Bool)
    {
        guard let switchItem = item as? SwitchItem else { return }

        self.item = switchItem
        
        if switchControl.on != switchItem.value {
            switchControl.setOn(switchItem.value, animated: animated)
        }
        
        if titleLabel.text != switchItem.title {
            titleLabel.text = switchItem.title
        }
    }

}
