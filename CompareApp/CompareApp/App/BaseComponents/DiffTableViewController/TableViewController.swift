//
//  TableViewController.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools

class TableViewController: UITableViewController {

    var sections: [TableViewSectionItem] = []
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
        
        dataSourceHandler.start = { }
        
        dataSourceHandler.itemUpdate = { [weak self] (items, section, insertIndexes, reloadIndexMap, deleteIndexes) in
            guard let weakSelf = self else { return }
            weakSelf.sections[section].items = items
            weakSelf.tableView.beginUpdates()
            
            for (before, after) in reloadIndexMap {
                let indexPathBefore = NSIndexPath(forRow: before, inSection: section)
                if let updateableCell = weakSelf.tableView.cellForRowAtIndexPath(indexPathBefore) as? UpdateableTableViewCell {
                    let item: ComparableItem = items[after]
                    updateableCell.updateCellWithItem(item, animated: true)
                } else {
                    weakSelf.tableView.reloadRowsAtIndexPaths([indexPathBefore], withRowAnimation: .None)
                }
            }
            
            weakSelf.tableView.deleteRowsAtIndexPaths(deleteIndexes.map({ NSIndexPath(forRow: $0, inSection: section) }), withRowAnimation: .Fade)
            weakSelf.tableView.insertRowsAtIndexPaths(insertIndexes.map({ NSIndexPath(forRow: $0, inSection: section) }), withRowAnimation: .Fade)
            weakSelf.tableView.endUpdates()
        }
        
        dataSourceHandler.itemReorder = { [weak self] (items, section, reorderMap) in
            guard let weakSelf = self else { return }
            weakSelf.sections[section].items = items
            weakSelf.tableView.beginUpdates()
            for (from, to) in reorderMap {
                let fromIndexPath = NSIndexPath(forRow: from, inSection: section)
                let toIndexPath = NSIndexPath(forRow: to, inSection: section)
                weakSelf.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }
            weakSelf.tableView.endUpdates()
        }
        
        dataSourceHandler.sectionUpdate = { [weak self] (sections, insertIndexes, reloadIndexMap, deleteIndexes) in
            
            guard let weakSelf = self else { return }
            weakSelf.sections = sections.flatMap({ $0 as? TableViewSectionItem })
            weakSelf.tableView.beginUpdates()
            
            let insertSet = NSMutableIndexSet()
            insertIndexes.forEach({ insertSet.addIndex($0) })
            
            let deleteSet = NSMutableIndexSet()
            deleteIndexes.forEach({ deleteSet.addIndex($0) })
            
            weakSelf.tableView.insertSections(insertSet, withRowAnimation: .None)
            weakSelf.tableView.deleteSections(deleteSet, withRowAnimation: .None)
            
            for (sectionIndexBefore, sectionIndexAfter) in reloadIndexMap {
                if let headerView = weakSelf.tableView.headerViewForSection(sectionIndexBefore) as? UpdateableTableViewHeaderFooterView {
                    let sectionItem = sections[sectionIndexAfter]
                    headerView.updateViewWithItem(sectionItem, animated: true)
                } else {
                    weakSelf.tableView.reloadSections(NSIndexSet(index: sectionIndexBefore), withRowAnimation: .None)
                }
            }
            
            weakSelf.tableView.endUpdates()
        }
        
        dataSourceHandler.sectionReorder = { [weak self] (sections, reorderMap) in
            guard let weakSelf = self else { return }
            weakSelf.sections = sections.flatMap({ $0 as? TableViewSectionItem })
            if reorderMap.count > 0 {
                weakSelf.tableView.beginUpdates()
                for (from, to) in reorderMap {
                    weakSelf.tableView.moveSection(from, toSection: to)
                }
                weakSelf.tableView.endUpdates()
            }
            // UIView.setAnimationsEnabled(true)
        }
        
        dataSourceHandler.completion = { }
    }
    
    
    func updateTableView()
    {
        let newSections: [TableViewSectionItem] = generateItems()
        
        if sections.count == 0 {
            sections = newSections
            tableView.reloadData()
        } else {
            let oldSections = sections.map({ $0 as ComparableSectionItem })
            let newSections = newSections.map({ $0 as ComparableSectionItem })
            dataSourceHandler.queueComparison(oldSections: oldSections, newSections: newSections)
        }
    }
    
    
    func generateItems() -> [TableViewSectionItem]
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
