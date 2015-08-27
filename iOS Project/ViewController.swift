//
//  ViewController.swift
//  iOS Project
//
//  Created by Karsten Bruns on 19/06/15.
//  Copyright (c) 2015 bruns.me. All rights reserved.
//

import UIKit


extension Array {
    
    mutating func extractRandomElements(count count: Int) -> [Element] {
        var elements = [Element]()
        for _ in 0..<(min(count,self.count)) {
            let index = Int(arc4random_uniform(UInt32(self.count)))
            elements.append(self[index])
            self.removeAtIndex(index)
        }
        return elements
    }
    
    mutating func insertAtRandomIndex(newElements: [Element]) {
        for newElement in newElements {
            let index = Int(arc4random_uniform(UInt32(self.count)))
            self.insert(newElement, atIndex: index)
        }
    }
    
    
}


class ViewController: UITableViewController {
    
    
    var lastIdentity = 0
    var sections: [Mummy] = []
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sections = (0..<5).map({ num in self.newSection() })
        
        let shufflebutton = UIBarButtonItem(title: "Shuffle", style: .Plain, target: self, action: Selector("shuffleAction2:"))
        navigationItem.rightBarButtonItem = shufflebutton
        
        let testbutton = UIBarButtonItem(title: "Test", style: .Plain, target: self, action: Selector("testAction:"))
        navigationItem.leftBarButtonItem = testbutton
    }
    
    
    override func viewDidAppear(animated: Bool) {
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].children.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let item = sections[indexPath.section].children[indexPath.row]
        
        cell.textLabel?.text = "\(item.v)"
        cell.detailTextLabel?.text = "Identity: \(item.i)"
        
        return cell
    }
    
    
    func shuffleItems(let items: [Dummy]) -> [Dummy] {
        
        var newItems = items.map({ Dummy(v: $0.v, i: $0.i)})
        
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
    
    
    func shuffleSection(sections: [Mummy]) -> [Mummy] {
        
        var newSections: [Mummy] = sections.map({ aSection in
            let m = Mummy(i: aSection.i, name: aSection.name)
            m.children = aSection.children
            return m
        })
        
        // Move
        let elements = newSections.extractRandomElements(count: 1)
        newSections.insertAtRandomIndex(elements)
        
        // Remove
        let delete: Int = Int(arc4random_uniform(4))
        if newSections.count > 1 && delete == 2 {
            print("delete section")
            let _ = newSections.extractRandomElements(count: 1)
        }
        
        // Insert
        let insert: Int = Int(arc4random_uniform(4))
        if insert == 2 {
            print("insert section")
            newSections.insertAtRandomIndex([self.newSection()])
        }
        
        // Change
        for section in newSections {
            section.children = shuffleItems(section.children)
        }
        
        return newSections
    }
    
    
    var isDiffing: Bool = false
    
    func shuffleAction2(sender: AnyObject) {
        
        guard isDiffing == false else { return }
        isDiffing = true
        
        let oldSections = self.sections.map({ $0 as ComparableSection })
        let newSections = shuffleSection(self.sections).map({ $0 as ComparableSection })
        
        CompareDataSource.diff(oldSections: oldSections, newSections: newSections,
            itemUpdate: { (items, section, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) -> () in
                
                self.sections[section].children = items.flatMap({ $0 as? Dummy })
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Middle)
                self.tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
                self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Middle)
                self.tableView.endUpdates()
                
            }, itemReorder: { (items, section, reorderMap) -> () in
                
                self.sections[section].children = items.flatMap({ $0 as? Dummy })
                self.tableView.beginUpdates()
                for (from, to) in reorderMap {
                    let fromIndexPath = NSIndexPath(forRow: from, inSection: section)
                    let toIndexPath = NSIndexPath(forRow: to, inSection: section)
                    self.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
                }
                self.tableView.endUpdates()
                
            }, sectionUpdate: { (sections, insertIndexPaths, reloadIndexPaths, deleteIndexPaths) -> () in
                
                self.sections = sections.flatMap({ $0 as? Mummy })
                self.tableView.beginUpdates()
                self.tableView.deleteSections(deleteIndexPaths, withRowAnimation: .Middle)
                self.tableView.reloadSections(reloadIndexPaths, withRowAnimation: .None)
                self.tableView.insertSections(insertIndexPaths, withRowAnimation: .Middle)
                self.tableView.endUpdates()
                
            }, sectionReorder: { (sections, reorderMap) -> () in
                
                self.sections = sections.flatMap({ $0 as? Mummy })
                self.tableView.beginUpdates()
                for (from, to) in reorderMap {
                    self.tableView.moveSection(from, toSection: to)
                }
                self.tableView.endUpdates()
                
            }, completionHandler: {

                self.isDiffing = false
                self.testAction(self)

        })
        
        
    }
    
    
    
    func testAction(sender: AnyObject) {
        
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
    
    func newItem() -> Dummy {
        lastIdentity += 1
        let v: Int = Int(arc4random_uniform(255))
        return Dummy(v: v, i: lastIdentity)
        
    }
    
    func newSection() -> Mummy {
        let c = (0..<3).map({ num in self.newItem() })
        
        lastIdentity += 1
        let result = Mummy(i: lastIdentity, name: "Section")
        result.children = c
        return result
    }
    
}


