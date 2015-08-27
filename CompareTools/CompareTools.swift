//
//  CompareTools.swift
//  iOS Project
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


import Foundation


@objc public enum ComparisonLevel : Int {
    case NoEquality, PerfectEquality, IdentifierEquality
}


@objc public protocol Comparable {
    var identifier: Int { get }
    func compareTo(other: Comparable) -> ComparisonLevel
}




struct ComparisonResult<T: Comparable> {
    
    let insertionSet: NSIndexSet
    let deletionSet: NSIndexSet
    let reloadSet: NSIndexSet
    let sameSet: NSIndexSet
    let moveSet: [Int:Int]
    let unmovedItems: [T]
    
    init(insertionSet: NSIndexSet, deletionSet: NSIndexSet, reloadSet: NSIndexSet, sameSet: NSIndexSet, moveSet: [Int:Int], unmovedItems: [T])
    {
        self.insertionSet = insertionSet
        self.deletionSet = deletionSet
        self.reloadSet = reloadSet
        self.sameSet = sameSet
        self.moveSet = moveSet
        self.unmovedItems = unmovedItems
    }
    
}


struct ComparisonTool {
    
    static func diff<T: Comparable where T : Hashable>(old oldItems: [T], new newItems: [T]) -> ComparisonResult<T>
    {
        NSLog("Start")
        
        // Function Cache
        var compareCache = [T:[T:ComparisonLevel]]()
        func compare(oldItem oldItem: T, newItem: T) -> (ComparisonLevel) {
            if let memorized = compareCache[oldItem]?[newItem] {
                return memorized
            } else {
                let level = newItem.compareTo(oldItem)
                var newItems = compareCache[oldItem] ?? [:]
                newItems[newItem] = level
                compareCache[oldItem] = newItems
                return level
            }
        }
        
        
        let insertionSet = NSMutableIndexSet()
        let deletionSet = NSMutableIndexSet()
        let reloadSet = NSMutableIndexSet()
        let sameSet = NSMutableIndexSet()
        var moveSet = [Int:Int]()
        
        // Table views require that Insert/Delete/Update are done sperately from moving
        // So first we need an array of items that has the same content like 'newItems'
        // but is keeping the same order like 'oldItems'
        var unmovedItems = [T]()

        
        // Iterating over 'oldItems' to fill 'unmoved' items
        // and to determine indexes that can be deleted
        for (oldIndex, oldItem) in oldItems.enumerate() {
            
            let newIndex = newItems.indexOf({ newItem -> Bool in
                let equalityLevel = compare(oldItem: oldItem, newItem: newItem)
                return equalityLevel == .PerfectEquality || equalityLevel == .IdentifierEquality
            })
            
            if let newIndex = newIndex {
                // Update 'unmoved'
                unmovedItems.append(newItems[newIndex])
            } else {
                // Delete
                deletionSet.addIndex(oldIndex)
            }
            
        }
        
        
        // Iterating over 'newItems' to insert new items into 'unmovedItems'
        // and to determine indexes that need to be insertet and updated
        for (newIndex, newItem) in newItems.enumerate() {
            
            var equalityLevel = ComparisonLevel.NoEquality
            
            let oldIndex = oldItems.indexOf({ oldItem -> Bool in
                equalityLevel = compare(oldItem: oldItem, newItem: newItem)
                return equalityLevel == .PerfectEquality || equalityLevel == .IdentifierEquality
            })

            if let oldIndex = oldIndex {
                
                if equalityLevel == .IdentifierEquality {
                    // Reload
                    reloadSet.addIndex(oldIndex)
                    
                } else if equalityLevel == .PerfectEquality && newIndex == oldIndex {
                    // No Reload
                    sameSet.addIndex(newIndex)
                }
                
            } else if oldIndex == nil {
                
                // Insert
                insertionSet.addIndex(newIndex)
                
                if newIndex < unmovedItems.count {
                    unmovedItems.insert(newItems[newIndex], atIndex: newIndex)
                } else {
                    unmovedItems.append(newItems[newIndex])
                }

            }
            
        }
        
        
        // Iterating over 'newItems' and 'unmovedItems'
        // to determine the movement of items
        for (newIndex, newItem) in newItems.enumerate() {
            let intIndex = unmovedItems.indexOf(newItem)
            if let intIndex = intIndex where newIndex != intIndex {
                // Move
                moveSet[intIndex] = newIndex
            }
        }
        
        
        // Bundle result
        let diffResult = ComparisonResult(
            insertionSet: insertionSet,
            deletionSet: deletionSet,
            reloadSet: reloadSet,
            sameSet: sameSet,
            moveSet: moveSet,
            unmovedItems: unmovedItems
        )
        
        NSLog("End")
        
        return diffResult
    }
    
}
