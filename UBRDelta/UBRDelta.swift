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
        var unmIDs = [Int]()
        var reloadIDs = Set<Int>()
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
            let id = oldItem.uniqueIdentifier
            oldIDMap[id] = oldIndex
            if let newIndex = newIDMap[id] {
                let newItem = newItems[newIndex]
                unmovedItems.append(newItem)
                unmIDs.append(id)
            } else {
                deletionIndexes.append(oldIndex)
            }
        }
        
        // Search for insertions and updates
        for (newIndex, newItem) in newItems.enumerate() {
            // Looking for changes
            let id = newItem.uniqueIdentifier
            if let oldIndex = oldIDMap[id] {
                let oldItem = oldItems[oldIndex]
                if oldItem.compareTo(newItem).isChanged {
                    // Found change
                    reloadIDs.insert(id)
                }
            } else {
                // Found insertion
                insertionIndexes.append(newIndex)
                unmovedItems.insert(newItem, atIndex: newIndex)
                unmIDs.insert(id, atIndex: newIndex)
            }
        }
        
        // Reload
        for (unmIndex, unmItem) in unmovedItems.enumerate() {
            let id = unmItem.uniqueIdentifier
            if reloadIDs.contains(id) {
                let oldIndex = oldIDMap[id]!
                reloadIndexMap[oldIndex] = unmIndex
            }
        }
        
        // Detect moving items
        let diffResult = DiffArray<Int>.diff(unmIDs, newIDs)
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
