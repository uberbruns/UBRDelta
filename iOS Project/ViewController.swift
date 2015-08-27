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
        sections = (0..<3).map({ num in self.newSection() })

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
        let delete: Int = Int(arc4random_uniform(2))
        let _ = newItems.extractRandomElements(count: delete)

        // Insert
        let insert: Int = Int(arc4random_uniform(2))
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
        if delete == 2 {
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
    
    
    func shuffleAction2(sender: AnyObject) {

        let oldSections = self.sections
        let newSections = shuffleSection(oldSections)

        CompareDataSource.diff(oldSections: oldSections, newSections: newSections,
            itemUpdate: { (section, diff) -> () in

                let insertIndexPaths = diff.insertionSet.map({ index in NSIndexPath(forRow: index, inSection: section)})
                let reloadIndexPaths = diff.reloadSet.map({ index in NSIndexPath(forRow: index, inSection: section)})
                let deleteIndexPaths = diff.deletionSet.map({ index in NSIndexPath(forRow: index, inSection: section)})
                
                self.sections[section].children = diff.unmovedItems as! [Dummy]
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Middle)
                self.tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
                self.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Middle)
                self.tableView.endUpdates()
                
            }, itemReorder: { (section, diff) -> () in
                
                print("Sec: ", section)
                print("Old: ", (diff.oldItems as! [Dummy]).map({ "\($0.i): \($0.v)" }))
                print("Unm: ", (diff.unmovedItems as! [Dummy]).map({ "\($0.i): \($0.v)" }))
                print("Mov: ", diff.moveSet)
                print("New: ", (diff.newItems as! [Dummy]).map({ "\($0.i): \($0.v)" }))
                
                self.sections[section].children = diff.newItems as! [Dummy]
                self.tableView.beginUpdates()
                for (from, to) in diff.moveSet {
                    let fromIndexPath = NSIndexPath(forRow: from, inSection: section)
                    let toIndexPath = NSIndexPath(forRow: to, inSection: section)
                    self.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
                }
                self.tableView.endUpdates()

            }, sectionUpdate: { (diff) -> () in
                
                self.sections = diff.unmovedItems as! [Mummy]
                self.tableView.beginUpdates()
                self.tableView.deleteSections(diff.deletionSet, withRowAnimation: .Middle)
                self.tableView.reloadSections(diff.reloadSet, withRowAnimation: .None)
                self.tableView.insertSections(diff.insertionSet, withRowAnimation: .Middle)
                self.tableView.endUpdates()

            }, sectionReorder: { (diff) -> () in
                
                self.sections = diff.newItems as! [Mummy]
                self.tableView.beginUpdates()
                for (from, to) in diff.moveSet {
                    self.tableView.moveSection(from, toSection: to)
                }
                self.tableView.endUpdates()
                
        })
        
        
        testAction(self)
    }
    
    
    
    func shuffleAction(sender: AnyObject) {
        
        let oldSections = self.sections
        let newSections = shuffleSection(oldSections)


        // Function Outline:
        // 1. Update current section data with new item data
        // 2. Move items around
        // 3. Update current section data with new section data
        // 4. Move sections around

        
        for (oldSectionIndex, oldSection) in oldSections.enumerate() {

            // Guarding
            guard let newIndex = newSections.indexOf({ newSection in
                let comparison = newSection.compareTo(oldSection)
                return comparison == .PerfectEquality || comparison == .IdentifierEquality
            }) else {
                continue
            }
            
            // Diffing
            let oldItems = oldSection.children
            let newItems = newSections[newIndex].children
            let itemDiff = ComparisonTool.diff(old: oldItems, new: newItems)
            let insertIndexPaths = itemDiff.insertionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
            let reloadIndexPaths = itemDiff.reloadSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
            let deleteIndexPaths = itemDiff.deletionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
            
//            print(" ")
//            print("Old: ", oldItems.map({ "\($0.i): \($0.v)" }))
//            print("Unm: ", itemDiff.unmovedItems.map({ "\($0.i): \($0.v)" }))
//            print("New: ", newItems.map({ "\($0.i): \($0.v)" }))

            // 1
            self.sections[oldSectionIndex].children = itemDiff.unmovedItems
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Middle)
            tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Middle)
            tableView.endUpdates()
            
            // 2
            self.sections[oldSectionIndex].children = newItems
            tableView.beginUpdates()
            for (from, to) in itemDiff.moveSet {
                let fromIndexPath = NSIndexPath(forRow: from, inSection: oldSectionIndex)
                let toIndexPath = NSIndexPath(forRow: to, inSection: oldSectionIndex)
                tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }
            tableView.endUpdates()

        }

        // Diffing
        let sectionDiff = ComparisonTool.diff(old: oldSections, new: newSections)
        let unMovedSections = sectionDiff.unmovedItems

        // 3
        self.sections = unMovedSections
        tableView.beginUpdates()
        tableView.deleteSections(sectionDiff.deletionSet, withRowAnimation: .Middle)
        tableView.reloadSections(sectionDiff.reloadSet, withRowAnimation: .None)
        tableView.insertSections(sectionDiff.insertionSet, withRowAnimation: .Middle)
        tableView.endUpdates()

        // 4
        self.sections = newSections
        tableView.beginUpdates()
        for from in Array(sectionDiff.moveSet.keys) {
            let to = sectionDiff.moveSet[from]!
            tableView.moveSection(from, toSection: to)
        }
        tableView.endUpdates()

        
        testAction(self)
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


