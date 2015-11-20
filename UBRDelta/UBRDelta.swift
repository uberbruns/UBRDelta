//
//  UBRDelta.swift
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public struct UBRDelta {
    
    public static func diff(old oldItems: [ComparableItem], new newItems: [ComparableItem]) -> ComparisonResult
    {
        // Init return vars
        var insertionIndexes = [Int]()
        var deletionIndexes = [Int]()
        var reloadIndexMap = [Int:Int]()
        var moveIndexMap = [Int:Int]()
        var unmovedItems = [ComparableItem]()
        
        // Diffing
        var newIDs = [Int]()
        var oldIDMap = [Int:Int]()
        var newIDMap = [Int:Int]()
        
        // Prepare mapping vars for new items
        for (newIndex, newItem) in newItems.enumerate() {
            let newId = newItem.uniqueIdentifier
            newIDs.append(newId)
            newIDMap[newId] = newIndex
        }
        
        // - Prepare mapping vars for old items
        // - Create the unmoved array
        // - Search for deletions
        for (oldIndex, oldItem) in oldItems.enumerate() {
            let oldId = oldItem.uniqueIdentifier
            oldIDMap[oldId] = oldIndex
            if let newIndex = newIDMap[oldId] {
                let newItem = newItems[newIndex]
                unmovedItems.append(newItem)
            } else {
                deletionIndexes.append(oldIndex)
            }
        }
        
        // Search for insertions and updates
        for (newIndex, newItem) in newItems.enumerate() {
            // Looking for changes
            if let oldIndex = oldIDMap[newItem.uniqueIdentifier] {
                let oldItem = oldItems[oldIndex]
                if oldItem.compareTo(newItem).isChanged {
                    // Found change
                    reloadIndexMap[oldIndex] = newIndex
                }
            } else {
                // Found insertion
                insertionIndexes.append(newIndex)
                unmovedItems.insert(newItem, atIndex: newIndex)
            }
        }
        
        // Detect moving items
        let diffResult = DiffArray<Int>.diff(unmovedItems.map({ $0.uniqueIdentifier }), newIDs)
        for diffStep in diffResult.results {
            switch diffStep {
            case .Delete(let unmIndex, let id) :
                let newIndex = newIDMap[id]!
                moveIndexMap[unmIndex] = newIndex
            default :
                break
            }
        }
        
        // Bundle result
        let comparisonResult = ComparisonResult(
            insertionIndexes: insertionIndexes,
            deletionIndexes: deletionIndexes,
            reloadIndexMap: reloadIndexMap,
            moveIndexMap: moveIndexMap,
            oldItems: newItems,
            unmovedItems: unmovedItems,
            newItems: newItems
        )
        
        return comparisonResult
    }
    
}
