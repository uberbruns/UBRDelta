//
//  InputViewController.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


class InputViewController : DiffTableViewController {

    var showSectionA: Bool = false { didSet { updateTableView() } }
    var showSectionB: Bool = false { didSet { updateTableView() } }
    var showSectionsExclusive: Bool = false { didSet { updateTableView() } }
    var toggle: Bool = false { didSet { updateTableView() } }
    var expandCell: Bool = false { didSet { updateTableView() } }
    
    
    override func generateItems() -> [DiffTableViewSectionItem]
    {
        var sectionItems: [DiffTableViewSectionItem] = []
        
        // Input Section
        var inputSection = DiffTableViewSectionItem(i: 1, title: "Inputs")
        var inputItems: [ComparableItem] = []
        
        let switchItemA = SwitchItem(id: "switchA", title: "Show Section A", value: showSectionA) { (value) -> () in
            self.showSectionA = value
            if self.toggle {
                self.showSectionB = !value
            } else if self.showSectionsExclusive && value == true {
                self.showSectionB = false
            }
        }
        inputItems.append(switchItemA)
        
        let switchItemB = SwitchItem(id: "switchB", title: "Show Section B", value: showSectionB) { (value) -> () in
            if self.toggle {
                self.showSectionA = !value
            } else if self.showSectionsExclusive && value == true {
                self.showSectionA = false
            }
            self.showSectionB = value
        }
        inputItems.append(switchItemB)
        
        let exclusiveItem = SwitchItem(id: "exclusive", title: "Exclusive", value: showSectionsExclusive) { (value) -> () in
            self.showSectionsExclusive = value
            self.showSectionB = (self.showSectionA == true && self.showSectionB == true) ? false : self.showSectionB
            if value == false {
                self.toggle = false
            }
        }
        inputItems.append(exclusiveItem)
        
        if showSectionsExclusive == true {
            let toggleItem = SwitchItem(id: "toggle", title: "Toggle", value: toggle) { (value) -> () in
                self.toggle = value
                if self.showSectionA == false && self.showSectionB == false {
                    self.showSectionA = true
                }
            }
            inputItems.append(toggleItem)
        }
        
        inputSection.items = inputItems
        sectionItems.append(inputSection)
        
        
        // Section A
        if showSectionA == true {
            
            var sectionA = DiffTableViewSectionItem(i: 2, title: "Section A (\(NSDate()))")
            var items: [ComparableItem] = []
            
            let valueItemA = StaticValueItem(id: "valueA", title: "Hello", value: "World")
            items.append(valueItemA)
            
            sectionA.items = items
            sectionItems.append(sectionA)
        }
        
        
        // Section B
        if showSectionB == true {
            
            var sectionB = DiffTableViewSectionItem(i: 3, title: "Section B")
            var items: [ComparableItem] = []
            
            let valueItemB = StaticValueItem(id: "valueB", title: "Hello", value: "Karsten")
            items.append(valueItemB)
            
            
            let switchItemB = SwitchItem(id: "expandCell", title: "Expand Cell", value: expandCell) { (value) -> () in
                self.expandCell = value
            }
            items.append(switchItemB)
            
            sectionB.items = items
            sectionItems.append(sectionB)
            
        }
        
        return sectionItems
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        guard let item = sections[indexPath.section].items[indexPath.row] as? TableViewItem else { return 44.0 }
        
        if item.id == "valueB" && expandCell == true {
            return 128.0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}
