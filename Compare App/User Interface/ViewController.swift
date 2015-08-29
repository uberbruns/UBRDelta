//
//  ViewController.swift
//
//  Created by Karsten Bruns on 19/06/15.
//  Copyright (c) 2015 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {
    
    var lastIdentity = 0
    var sections: [ComparableSection] = []
    var latestData: [DataSourceSection] = []
    var timer: NSTimer? = nil
    
    let dataSourceHandler = DataSourceHandler()
    
    
    // MARK: - View -
    // MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupDataSourceHandler()
        
        sections = (0..<5).map({ num in self.newSection() })
        latestData = sections.flatMap({ $0 as? DataSourceSection })
        
        let shufflebutton = UIBarButtonItem(title: "Shuffle", style: .Plain, target: self, action: Selector("shuffleAction:"))
        navigationItem.rightBarButtonItem = shufflebutton
        
        let testbutton = UIBarButtonItem(title: "Run", style: .Plain, target: self, action: Selector("runAction:"))
        navigationItem.leftBarButtonItem = testbutton
        
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: Setup & Update
    
    func setupDataSourceHandler()
    {
        dataSourceHandler.itemUpdate = { (items, section, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) in
            self.sections[section].items = items
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Middle)
            self.tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
            self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Middle)
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
        
        dataSourceHandler.sectionUpdate = { (sections, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) in
            self.sections = sections.flatMap({ $0 as? DataSourceSection })
            self.tableView.beginUpdates()
            self.tableView.deleteSections(deleteIndexPaths, withRowAnimation: .Middle)
            self.tableView.reloadSections(reloadIndexPaths, withRowAnimation: .None)
            self.tableView.insertSections(insertIndexPaths, withRowAnimation: .Middle)
            self.tableView.endUpdates()
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
            self.testAction(self)
        }
        
    }
    
    
    func updateTableView(sections: [DataSourceSection])
    {
        let oldSections = latestData.map({ $0 as ComparableSection })
        let newSections = sections.map({ $0 as ComparableSection })
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
        if let section = sections[section] as? DataSourceSection {
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
    
    
    func newSection() -> DataSourceSection {
        let c = (0..<3).map({ num in self.newItem() })
        
        lastIdentity += 1
        var result = DataSourceSection(i: lastIdentity, title: "Section \(lastIdentity)")
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
    
    
    func shuffleSections(sections: [DataSourceSection]) -> [DataSourceSection]
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