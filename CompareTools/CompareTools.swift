//
//  CompareTools.swift
//  iOS Project
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


struct ComparisonTool {
    
    static func diff(old oldItems: [Comparable], new newItems: [Comparable]) -> ComparisonResult
    {
        // Internal Functions
        func twoIntHash(a:UInt32, _ b:UInt32) -> UInt64 {
            let a = UInt64(a)
            let b = UInt64(b)
            return a<<32 | b
        }
        
        
        // Comparison Cache
        var compareCache = [UInt64:ComparisonLevel]()
        func compareItems(oldItem oldItem: Comparable, newItem: Comparable) -> ComparisonLevel {
            let hash = twoIntHash(oldItem.identifier, newItem.identifier)
            if let memorized = compareCache[hash] {
                return memorized
            } else {
                let level = newItem.compareTo(oldItem)
                compareCache[hash] = level
                return level
            }
        }
        
        
        // Init vars
        let insertionSet = NSMutableIndexSet()
        let deletionSet = NSMutableIndexSet()
        let reloadSet = NSMutableIndexSet()
        let sameSet = NSMutableIndexSet()
        var moveSet = [Int:Int]()
        
        
        // Table views require that Insert/Delete/Update are done sperately from moving
        // So first we need an array of items that has the same content like 'newItems'
        // but is keeping the same order like 'oldItems'
        var unmovedItems = [Comparable]()
        
        
        // Iterating over 'oldItems' to fill 'unmoved' items
        // and to determine indexes that can be deleted
        for (oldIndex, oldItem) in oldItems.enumerate() {
            
            let newIndex = newItems.indexOf({ newItem -> Bool in
                let equalityLevel = compareItems(oldItem: oldItem, newItem: newItem)
                return equalityLevel == .Same || equalityLevel == .SameIdentifier
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
            
            var equalityLevel = ComparisonLevel.Different
            
            let oldIndex = oldItems.indexOf({ oldItem -> Bool in
                equalityLevel = compareItems(oldItem: oldItem, newItem: newItem)
                return equalityLevel == .Same || equalityLevel == .SameIdentifier
            })
            
            if let oldIndex = oldIndex {
                
                if equalityLevel == .SameIdentifier {
                    // Reload
                    reloadSet.addIndex(oldIndex)
                    
                } else if equalityLevel == .Same && newIndex == oldIndex {
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
            
            let intIndex = unmovedItems.indexOf({ unmItem -> Bool in
                let equalityLevel = compareItems(oldItem: unmItem, newItem: newItem)
                return equalityLevel == .Same || equalityLevel == .SameIdentifier
            })
            
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
            
            oldItems: oldItems,
            unmovedItems: unmovedItems,
            newItems: newItems
        )
        
        return diffResult
    }

    
}
