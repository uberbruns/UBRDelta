//
//  CompareTools.swift
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public struct ComparisonTool {

    private static func twoIntHash(a:Int, _ b:Int) -> UInt64
    {
        let a64 = UInt64(abs(a)) % UInt64(UInt32.max)
        let b64 = UInt64(abs(b)) % UInt64(UInt32.max)
        return a64 << 32 | b64
    }

    
    public static func diff(old oldItems: [ComparableItem], new newItems: [ComparableItem]) -> ComparisonResult
    {
        // Comparison Cache
        var compareCache = [UInt64:ComparisonLevel]()
        func compareItems(oldItem oldItem: ComparableItem, newItem: ComparableItem) -> ComparisonLevel {
            let hash = ComparisonTool.twoIntHash(oldItem.uniqueIdentifier, newItem.uniqueIdentifier)
            if let cachedResult = compareCache[hash] {
                return cachedResult
            } else {
                let result = newItem.compareTo(oldItem)
                compareCache[hash] = result
                return result
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
        var unmovedItems = [ComparableItem]()
        
        
        // Iterating over 'oldItems' to fill 'unmoved' items
        // and to determine indexes that can be deleted
        for (oldIndex, oldItem) in oldItems.enumerate() {
            
            let newIndex = newItems.indexOf({ newItem -> Bool in
                let comparisonLevel = compareItems(oldItem: oldItem, newItem: newItem)
                return comparisonLevel.hasSameIdentifier
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
            
            var comparisonLevel = ComparisonLevel.Different
            
            let oldIndex = oldItems.indexOf({ oldItem -> Bool in
                comparisonLevel = compareItems(oldItem: oldItem, newItem: newItem)
                return comparisonLevel.hasSameIdentifier
            })
            
            if let oldIndex = oldIndex {
                
                if comparisonLevel == .SameIdentifier {
                    // Reload
                    reloadSet.addIndex(oldIndex)
                } else if comparisonLevel == .Same && newIndex == oldIndex {
                    // No Reload
                    sameSet.addIndex(newIndex)
                }
                
            } else if oldIndex == nil {
                
                // Insert
                insertionSet.addIndex(newIndex)
                
                if newIndex < unmovedItems.count {
                    unmovedItems.insert(newItem, atIndex: newIndex)
                } else {
                    unmovedItems.append(newItem)
                }
                
            }
            
        }
        
        
        // Iterating over 'newItems' and 'unmovedItems'
        // to determine the movement of items
        for (newIndex, newItem) in newItems.enumerate() {
            
            let intIndex = unmovedItems.indexOf({ unmItem -> Bool in
                let comparisonLevel = compareItems(oldItem: unmItem, newItem: newItem)
                return comparisonLevel.hasSameIdentifier
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
