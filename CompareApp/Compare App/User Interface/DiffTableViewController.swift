//
//  DiffTableViewController.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools

class DiffTableViewController: UITableViewController {

    var sections: [DiffTableViewSectionItem] = []
    let dataSourceHandler = DataSourceHandler()
    
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
            self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Top)
            
            for indexPath in reloadIndexPaths {
                if let updateableCell = self.tableView.cellForRowAtIndexPath(indexPath) as? UpdateableTableViewCell {
                    let item: ComparableItem = items[indexPath.row]
                    updateableCell.updateCellWithItem(item, animated: true)
                } else {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
            
            self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Top)
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
            
            self.sections = sections.flatMap({ $0 as? DiffTableViewSectionItem })
            self.tableView.beginUpdates()
            
            self.tableView.deleteSections(deleteIndexSet, withRowAnimation: .None)
            
            for sectionIndex in reloadIndexSet {
                if let headerView = self.tableView.headerViewForSection(sectionIndex) as? UpdateableTableViewHeaderFooterView {
                    let sectionItem = sections[sectionIndex]
                    headerView.updateViewWithItem(sectionItem, animated: true)
                }
            }
            
            self.tableView.reloadSections(reloadIndexSet, withRowAnimation: .None)
            self.tableView.insertSections(insertIndexSet, withRowAnimation: .None)
            
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.sectionReorder = { (sections, reorderMap) in
            self.sections = sections.flatMap({ $0 as? DiffTableViewSectionItem })
            if reorderMap.count > 0 {
                self.tableView.beginUpdates()
                for (from, to) in reorderMap {
                    self.tableView.moveSection(from, toSection: to)
                }
                self.tableView.endUpdates()
            }
            UIView.setAnimationsEnabled(true)
            
        }
        
        dataSourceHandler.completion = {
            print("Table View Updated")
        }
        
    }
    
    
    func updateTableView()
    {
        let newSections: [DiffTableViewSectionItem] = generateSectionItems()
        
        if sections.count == 0 {
            sections = newSections
            tableView.reloadData()
        } else {
            let oldSections = self.sections.map({ $0 as ComparableSectionItem })
            let newSections = newSections.map({ $0 as ComparableSectionItem })
            dataSourceHandler.queueComparison(oldSections: oldSections, newSections: newSections)
        }
    }
    
    
    func generateSectionItems() -> [DiffTableViewSectionItem]
    {
        return []
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier(tableViewItem.reuseIdentifier)!
            
            if let updateableCell = cell as? UpdateableTableViewCell {
                updateableCell.updateCellWithItem(item, animated: false)
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
            cell.selectionStyle = .None
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
