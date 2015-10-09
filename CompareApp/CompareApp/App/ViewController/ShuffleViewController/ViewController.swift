//
//  ViewController.swift
//
//  Created by Karsten Bruns on 19/06/15.
//  Copyright (c) 2015 bruns.me. All rights reserved.
//

import UIKit
import CompareTools


class ViewController: UITableViewController {
    
    var lastIdentity = 0
    var sections: [ComparableSectionItem] = []
    var latestData: [TableViewSectionItem] = []
    var timer: NSTimer? = nil
    
    let dataSourceHandler = DataSourceHandler()
    
    
    // MARK: - View -
    // MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupDataSourceHandler()
        
        sections = (0..<5).map({ num in self.newSection() })
        latestData = sections.flatMap({ $0 as? TableViewSectionItem })
        
        let shufflebutton = UIBarButtonItem(title: "Shuffle", style: .Plain, target: self, action: Selector("shuffleAction:"))
        navigationItem.rightBarButtonItem = shufflebutton
        
        let testbutton = UIBarButtonItem(title: "Run", style: .Plain, target: self, action: Selector("runAction:"))
        navigationItem.leftBarButtonItem = testbutton
        
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: Setup & Update
    
    func setupDataSourceHandler() {
        
        dataSourceHandler.userInterfaceUpdateTime = 0.16667
        
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
        
        dataSourceHandler.completion = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.testAction(weakSelf)
        }
    }
    
    
    func updateTableView(sections: [TableViewSectionItem])
    {
        let oldSections = latestData.map({ $0 as ComparableSectionItem })
        let newSections = sections.map({ $0 as ComparableSectionItem })
        self.latestData = sections
        
        dataSourceHandler.queueComparison(oldSections: oldSections, newSections: newSections)
    }
    
    
    // MARK: Actions
    
    func shuffleAction(sender: AnyObject)
    {
        // Murder Test
//        for _ in 0..<10 {
//            let newData = shuffleSections(self.latestData)
//            updateTableView(newData)
//        }

        // Real Test
        let newData = shuffleSections(self.latestData)
        updateTableView(newData)
    }
    
    
    var testNumber: Int = 0
    
    func testAction(sender: AnyObject)
    {
        var cellsTested = 0
        testNumber++
        
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPathForCell(cell) else { continue }
            
            if let shouldValue = (self.latestData[indexPath.section].items[indexPath.row] as? Dummy)?.v,
                let text = cell.textLabel?.text,
                let hasValue = Int(text) {
                    if shouldValue != hasValue {
                        print("Is:", hasValue, "Should:", shouldValue)
                    }
            }
            cellsTested++
        }
        
        print("Test \(testNumber) ended (cells tested: \(cellsTested))")
    }
    
    
    func runAction(sender: AnyObject)
    {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("shuffleAction:"), userInfo: nil, repeats: true)
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
        
        if let dummy = item as? Dummy {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = "\(dummy.v)"
            cell.detailTextLabel?.text = "Identity: \(dummy.i)"
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
        if let section = sections[section] as? TableViewSectionItem {
            return section.title
        } else {
            return nil
        }
    }
    
    
    // MARK: - Helper -
    
    func newItem() -> Dummy {
        lastIdentity += 1
        let v: Int = Int(arc4random_uniform(255))
        return Dummy(v: v, i: lastIdentity)
        
    }
    
    
    func newSection() -> TableViewSectionItem {
        let c = (0..<3).map({ num in self.newItem() })
        
        lastIdentity += 1
        var result = TableViewSectionItem(i: lastIdentity, title: "Section \(lastIdentity)")
        result.items = c.map({ $0 as ComparableItem })
        return result
    }
    
    
    func shuffleItems(let items: [Dummy]) -> [Dummy]
    {
        var newItems = items
        
        // Move
        let elements = newItems.extractRandomElements(count: 2)
        newItems.insertAtRandomIndex(elements)
        
        // Remove
        let maxD = UInt32(min(2,max(0,newItems.count-1)))
        let delete: Int = Int(arc4random_uniform(maxD))
        let _ = newItems.extractRandomElements(count: delete)
        
        // Insert
        let maxI = UInt32(min(2,max(0,10-newItems.count)))
        let insert: Int = Int(arc4random_uniform(maxI))
        let newElements = (0..<insert).map({ _ in self.newItem() })
        newItems.insertAtRandomIndex(newElements)

        // Change
        let change: Int = Int(arc4random_uniform(2))
        for _ in 0..<(min(change,newItems.count)) {
            let index = Int(arc4random_uniform(UInt32(newItems.count)))
            let v = Int(arc4random_uniform(255))
            let oldItem = newItems[index]
            let newItem = Dummy(v: v, i: oldItem.i)
            newItems[index] = newItem
        }
        
        return newItems
    }
    
    
    func shuffleSections(sections: [TableViewSectionItem]) -> [TableViewSectionItem]
    {
        var newSections = sections
        
        // Move
        let doMove: Int = Int(arc4random_uniform(6))
        if doMove == 2 {
            let elements = newSections.extractRandomElements(count: 1)
            newSections.insertAtRandomIndex(elements)
        }
        
        // Remove
        let doDelete: Int = Int(arc4random_uniform(6))
        if newSections.count > 1 && doDelete == 2 {
            let _ = newSections.extractRandomElements(count: 1)
        }
        
        // Insert
        let doInsert: Int = Int(arc4random_uniform(6))
        if doInsert == 2 {
            newSections.insertAtRandomIndex([self.newSection()])
        }
        
        // Change
        for (index, section) in newSections.enumerate() {
            var newSection = section
            newSection.items = shuffleItems(section.items.flatMap({ $0 as? Dummy})).map({ $0 as ComparableItem })
            newSections[index] = newSection
        }
        
        return newSections
    }
    
    
}