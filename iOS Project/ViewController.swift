//
//  ViewController.swift
//  iOS Project
//
//  Created by Karsten Bruns on 19/06/15.
//  Copyright (c) 2015 bruns.me. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {
    
    var lastIdentity = 0
    var sections: [Mummy] = []
    let dataSourceHandler = DataSourceHandler()
    
    
    // MARK: - View -
    // MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupDataSourceHandler()
        
        sections = (0..<5).map({ num in self.newSection() })
        
        let shufflebutton = UIBarButtonItem(title: "Shuffle", style: .Plain, target: self, action: Selector("shuffleAction:"))
        navigationItem.rightBarButtonItem = shufflebutton
        
        let testbutton = UIBarButtonItem(title: "Test", style: .Plain, target: self, action: Selector("testAction:"))
        navigationItem.leftBarButtonItem = testbutton
    }
    
    
    // MARK: Setup & Update

    func setupDataSourceHandler()
    {
        dataSourceHandler.itemUpdate = { (items, section, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) in
            self.sections[section].children = items.flatMap({ $0 as? Dummy })
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Middle)
            self.tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
            self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Middle)
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.itemReorder = { (items, section, reorderMap) in
            self.sections[section].children = items.flatMap({ $0 as? Dummy })
            self.tableView.beginUpdates()
            for (from, to) in reorderMap {
                let fromIndexPath = NSIndexPath(forRow: from, inSection: section)
                let toIndexPath = NSIndexPath(forRow: to, inSection: section)
                self.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }
            self.tableView.endUpdates()
        }
        
        dataSourceHandler.sectionUpdate = { (sections, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) in
            self.sections = sections.flatMap({ $0 as? Mummy })
            self.tableView.beginUpdates()
            self.tableView.deleteSections(deleteIndexPaths, withRowAnimation: .Middle)
            self.tableView.reloadSections(reloadIndexPaths, withRowAnimation: .None)
            self.tableView.insertSections(insertIndexPaths, withRowAnimation: .Middle)
            self.tableView.endUpdates()
        }

        dataSourceHandler.sectionReorder = { (sections, reorderMap) in
            self.sections = sections.flatMap({ $0 as? Mummy })
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


    func updateTableView(sections: [Mummy])
    {
        let oldSections = self.sections.map({ $0 as ComparableSection })
        let newSections = sections.map({ $0 as ComparableSection })
        
        dataSourceHandler.queueComparison(oldSections: oldSections, newSections: newSections)
    }
    
    
    // MARK: Actions
    
    func shuffleAction(sender: AnyObject)
    {
        updateTableView(shuffleSection(self.sections))
    }
    
    
    func testAction(sender: AnyObject)
    {
        var cellsTested = 0
        
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPathForCell(cell) else { continue }
            let shouldValue = self.sections[indexPath.section].children[indexPath.row].v
            let hasValue = Int((cell.textLabel?.text)!)!
            if shouldValue != hasValue {
                print("Is:", hasValue, "Should:", shouldValue)
            }
            cellsTested++
        }
        
        print("Test ended (cells tested: \(cellsTested))")
    }
    
    
    // MARK: - Protocols -
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].children.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let item = sections[indexPath.section].children[indexPath.row]
        
        cell.textLabel?.text = "\(item.v)"
        cell.detailTextLabel?.text = "Identity: \(item.i)"
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sections[section].name
    }

    
    // MARK: - Helper -
    
    func newItem() -> Dummy {
        lastIdentity += 1
        let v: Int = Int(arc4random_uniform(255))
        return Dummy(v: v, i: lastIdentity)
        
    }
    
    
    func newSection() -> Mummy {
        let c = (0..<3).map({ num in self.newItem() })
        
        lastIdentity += 1
        var result = Mummy(i: lastIdentity, name: "Section \(lastIdentity)")
        result.children = c
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
    
    
    func shuffleSection(sections: [Mummy]) -> [Mummy]
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
        let doInsernsert: Int = Int(arc4random_uniform(6))
        if doInsernsert == 2 {
            newSections.insertAtRandomIndex([self.newSection()])
        }
        
        // Change
        for (index, section) in newSections.enumerate() {
            var newSection = section
            newSection.children = shuffleItems(section.children)
            newSections[index] = newSection
        }
        
        return newSections
    }

    
}