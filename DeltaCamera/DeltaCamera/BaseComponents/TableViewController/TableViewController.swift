//
//  TableViewController.swift
//  CompareApp
//
//  Created by Karsten Bruns on 30/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Controller -

    var reusableCellNibs = [String:UINib]()
    var reusableCellClasses = [String:AnyClass]()
    
    var sections: [TableViewSectionItem] = []
    let contentDiffer = UBRDeltaContent()
    private var animateViews = true
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    
    // MARK: - View -
    // MARK: Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContentDiffer()
        prepareReusableTableViewCells()
        addTableView()
        updateTableView()
        updateAppearance()
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    
    // MARK: Add Views

    func addTableView() {
        // Add
        view.addSubview(tableView)
        
        // Configure
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Add reusable cells
        prepareReusableTableViewCells()
        reusableCellNibs.forEach { (identifier, nib) -> () in tableView.registerNib(nib, forCellReuseIdentifier: identifier) }
        reusableCellClasses.forEach { (identifier, cellClass) -> () in tableView.registerClass(cellClass, forCellReuseIdentifier: identifier) }

        // Constraints
        let viewDict = ["tableView" : tableView]
        let v = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tableView]-0-|", options: [], metrics: nil, views: viewDict)
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tableView]-0-|", options: [], metrics: nil, views: viewDict)
        view.addConstraints(v + h)
    }

    
    // MARK: Update Views

    func updateAppearance() {
        switch tableView.style {
        case .Grouped :
            tableView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        default :
            tableView.backgroundColor = UIColor(white: 1, alpha: 1.0)
        }
    }
    
    
    func updateView(animated: Bool = true) {
        animateViews = animated
        updateTableView()
    }
    
    
    func updateTableView() {
        let newSections: [TableViewSectionItem] = generateItems()
        
        if sections.count == 0 {
            sections = newSections
            tableView.reloadData()
        } else {
            let oldSections = sections.map({ $0 as ComparableSectionItem })
            let newSections = newSections.map({ $0 as ComparableSectionItem })
            contentDiffer.queueComparison(oldSections: oldSections, newSections: newSections)
        }
    }

    
    // MARK: Configuration
    
    func configureContentDiffer() {
        
        contentDiffer.userInterfaceUpdateTime = 0.16667
        
        contentDiffer.start = { [weak self] in
            guard let weakSelf = self else { return }
            if weakSelf.animateViews == false {
                UIView.setAnimationsEnabled(false)
            }
        }
        
        contentDiffer.itemUpdate = { [weak self] (items, section, insertIndexes, reloadIndexMap, deleteIndexes) in
            guard let weakSelf = self else { return }
            weakSelf.sections[section].items = items
            weakSelf.tableView.beginUpdates()
            
            for (itemIndexBefore, itemIndexAfter) in reloadIndexMap {
                let indexPathBefore = NSIndexPath(forRow: itemIndexBefore, inSection: section)
                guard let cell = weakSelf.tableView.cellForRowAtIndexPath(indexPathBefore) else { continue }
                if let updateableCell = cell as? UpdateableTableViewCell {
                    let item: ComparableItem = items[itemIndexAfter]
                    updateableCell.updateCellWithItem(item, animated: true)
                } else {
                    weakSelf.tableView.reloadRowsAtIndexPaths([indexPathBefore], withRowAnimation: .Automatic)
                }
            }
            
            weakSelf.tableView.deleteRowsAtIndexPaths(deleteIndexes.map({ NSIndexPath(forRow: $0, inSection: section) }), withRowAnimation: .Top)
            weakSelf.tableView.insertRowsAtIndexPaths(insertIndexes.map({ NSIndexPath(forRow: $0, inSection: section) }), withRowAnimation: .Top)
            weakSelf.tableView.endUpdates()
        }
        
        contentDiffer.itemReorder = { [weak self] (items, section, reorderMap) in
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
        
        contentDiffer.sectionUpdate = { [weak self] (sections, insertIndexes, reloadIndexMap, deleteIndexes) in

            guard let weakSelf = self else { return }
            weakSelf.sections = sections.flatMap({ $0 as? TableViewSectionItem })
            weakSelf.tableView.beginUpdates()
            
            let insertSet = NSMutableIndexSet()
            insertIndexes.forEach({ insertSet.addIndex($0) })

            let deleteSet = NSMutableIndexSet()
            deleteIndexes.forEach({ deleteSet.addIndex($0) })

            weakSelf.tableView.insertSections(insertSet, withRowAnimation: .Automatic)
            weakSelf.tableView.deleteSections(deleteSet, withRowAnimation: .Automatic)
            
            for (sectionIndexBefore, sectionIndexAfter) in reloadIndexMap {
                
                if let sectionItem = sections[sectionIndexAfter] as? TableViewSectionItem,
                    let headerView = weakSelf.tableView.headerViewForSection(sectionIndexBefore) as? UpdateableTableViewHeaderFooterView,
                    let footerView = weakSelf.tableView.footerViewForSection(sectionIndexBefore) as? UpdateableTableViewHeaderFooterView {
                        
                        var headerItem = sectionItem
                        headerItem.userInfo = ["role":"header"]
                        var footerItem = sectionItem
                        footerItem.userInfo = ["role":"footer"]
                        
                        headerView.updateViewWithItem(headerItem, animated: true)
                        footerView.updateViewWithItem(footerItem, animated: true)
                        
                } else {
                    weakSelf.tableView.reloadSections(NSIndexSet(index: sectionIndexBefore), withRowAnimation: .Automatic)
                }
            }
            
            weakSelf.tableView.endUpdates()
        }
        
        contentDiffer.sectionReorder = { [weak self] (sections, reorderMap) in
            guard let weakSelf = self else { return }
            weakSelf.sections = sections.flatMap({ $0 as? TableViewSectionItem })
            if reorderMap.count > 0 {
                weakSelf.tableView.beginUpdates()
                for (from, to) in reorderMap {
                    weakSelf.tableView.moveSection(from, toSection: to)
                }
                weakSelf.tableView.endUpdates()
            }
        }
        
        contentDiffer.completion = { [weak self] in
            guard let weakSelf = self else { return }
            UIView.setAnimationsEnabled(true)
            weakSelf.animateViews = true
        }
    }

    
    // MARK: - API -
    
    func prepareReusableTableViewCells() { }
    
    
    func generateItems() -> [TableViewSectionItem] {
        return []
    }
    
    
    // MARK: - Protocols -
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        if let tableViewItem = item as? TableViewItem {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(tableViewItem.reuseIdentifier)!
            
            if let updateableCell = cell as? UpdateableTableViewCell {
                updateableCell.updateCellWithItem(item, animated: false)
            }
            
            if let manipulatingCell = cell as? ManipulatingTableViewCell {
                manipulatingCell.tableView = tableView
            }
            
            if let selectableItem = item as? SelectableTableViewItem {
                cell.selectionStyle = selectableItem.selectionHandler != nil ? .Default : .None
            }

            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            return cell
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
    
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = sections[section]
        return section.footer
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        if let selectableItem = item as? SelectableTableViewItem {
            selectableItem.selectionHandler?()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


}
