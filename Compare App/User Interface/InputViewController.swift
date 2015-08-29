//
//  InputViewController.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit

class InputViewController : UITableViewController
{
    var sections: [DataSourceSection] = []
    let dataSourceHandler = DataSourceHandler()
    
    var showSectionA: Bool = false { didSet { updateTableView() } }
    var showSectionB: Bool = false { didSet { updateTableView() } }
    var showSectionsExclusive: Bool = false { didSet { updateTableView() } }
    var toggle: Bool = false { didSet { updateTableView() } }
    
    
    // MARK: - View -
    // MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupDataSourceHandler()
        updateTableView()
    }
    
    
    
    // MARK: Setup & Update
    
    func setupDataSourceHandler()
    {
        dataSourceHandler.start = {
        }
        
        dataSourceHandler.itemUpdate = { (items, section, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) in
            self.sections[section].items = items
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Fade)
            
            for indexPath in reloadIndexPaths {
                if let updateableCell = self.tableView.cellForRowAtIndexPath(indexPath) as? UpdateableTableViewCell {
                    let item: ComparableItem = items[indexPath.row]
                    updateableCell.updateCellWithItem(item, animated: true)
                } else {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
            
            self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.itemReorder = { (items, section, reorderMap) in
            self.sections[section].items = items
            self.tableView.beginUpdates()
            for (from, to) in reorderMap {
                let fromIndexPath = NSIndexPath(forRow: from, inSection: section)
                let toIndexPath = NSIndexPath(forRow: to, inSection: section)
                self.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.sectionUpdate = { (sections, insertIndexSet, reloadIndexSet, deleteIndexSet) in
            // All section animations look broken
            UIView.setAnimationsEnabled(false)
            self.sections = sections.flatMap({ $0 as? DataSourceSection })
            self.tableView.beginUpdates()
            self.tableView.deleteSections(deleteIndexSet, withRowAnimation: .None)
            self.tableView.reloadSections(reloadIndexSet, withRowAnimation: .None)
            self.tableView.insertSections(insertIndexSet, withRowAnimation: .None)
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
        dataSourceHandler.sectionReorder = { (sections, reorderMap) in
            self.sections = sections.flatMap({ $0 as? DataSourceSection })
            self.tableView.beginUpdates()
            for (from, to) in reorderMap {
                self.tableView.moveSection(from, toSection: to)
            }
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.completion = {
            print("Table View Updated")
        }
        
    }
    
    
    func updateTableView()
    {
        var newSections: [DataSourceSection] = []
        
        // Input Section
        var inputSection = DataSourceSection(i: 1, title: "Inputs")
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
        newSections.append(inputSection)
            
            
        // Section A
        if showSectionA == true {
            // Input Section
            var sectionA = DataSourceSection(i: 2, title: "Section A")
            var items: [ComparableItem] = []
            
            let valueItemA = StaticValueItem(id: "valueA", title: "Hello", value: "World")
            items.append(valueItemA)
            
            sectionA.items = items
            newSections.append(sectionA)
        }
        
        
        // Section B
        if showSectionB == true {
            // Input Section
            var sectionB = DataSourceSection(i: 3, title: "Section B")
            var items: [ComparableItem] = []
            
            let valueItemA = StaticValueItem(id: "valueB", title: "Hello", value: "Karsten!")
            items.append(valueItemA)
            
            sectionB.items = items
            newSections.append(sectionB)
        }
        
        
        if sections.count == 0 {
            sections = newSections
            tableView.reloadData()
        } else {
            let oldSections = self.sections.map({ $0 as ComparableSection })
            let newSections = newSections.map({ $0 as ComparableSection })
            dataSourceHandler.queueComparison(oldSections: oldSections, newSections: newSections)
        }
    }
    
    
    // MARK: - Protocols -
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].items.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let item = sections[indexPath.section].items[indexPath.row]
        
        if let tableViewItem = item as? TableViewItem {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(tableViewItem.reuseIdentifier)! as UITableViewCell
            cell.selectionStyle = .None
            
            if let updateableCell = cell as? UpdateableTableViewCell {
                updateableCell.updateCellWithItem(item, animated: false)
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            return cell
            
        }
        
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let section = sections[section]
        return section.title
    }
}
