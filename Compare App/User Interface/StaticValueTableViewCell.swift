//
//  StaticValueTableViewCell.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit

class StaticValueTableViewCell: UITableViewCell {
    
    
}


extension StaticValueTableViewCell : UpdateableTableViewCell {
    
    func updateCellWithItem(item: ComparableItem, animated: Bool)
    {
        guard let staticValueItem = item as? StaticValueItem else { return }
        
        self.textLabel?.text = staticValueItem.title
        self.detailTextLabel?.text = staticValueItem.value
    }
    
}