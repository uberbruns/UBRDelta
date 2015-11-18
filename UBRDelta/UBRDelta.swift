//
//  CompareTools.swift
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public struct UBRDelta {
    
    public static func diff(old oldItems: [ComparableItem], new newItems: [ComparableItem]) -> ComparisonResult
    {
        // Return Vars
        var insertionIndexes = [Int]()
        var deletionIndexes = [Int]()
        var reloadIndexMap = [Int:Int]()
        var moveIndexMap = [Int:Int]()
        
        
        // Diffing
        var oldIDs = [Int]()
        var newIDs = [Int]()
        var oldIDMap = [Int:Int]()
        var newIDMap = [Int:Int]()
        var unmIDMap = [Int:Int]()
        
        
        // Prepare
        for (oldIndex, oldItem) in oldItems.enumerate() {
            let id = oldItem.uniqueIdentifier
            oldIDs.append(id)
            oldIDMap[id] = oldIndex
        }
        
        for (newIndex, newItem) in newItems.enumerate() {
            let id = newItem.uniqueIdentifier
            newIDs.append(id)
            newIDMap[id] = newIndex
            
            // Looking for Changes
            if let oldIndex = oldIDMap[id] {
                let oldItem = oldItems[oldIndex]
                switch oldItem.compareTo(newItem) {
                case .Changed(_) :
                    reloadIndexMap[oldIndex] = newIndex
                default:
                    break
                }
            }
        }
        
        
        // Unmoved Items: New items on old positions
        let unmovedItems = newItems.sort({ a, b in
            let indexA = oldIDMap[a.uniqueIdentifier] ?? newIDMap[a.uniqueIdentifier]
            let indexB = oldIDMap[b.uniqueIdentifier] ?? newIDMap[b.uniqueIdentifier]
            return indexA < indexB
        })
        
        for (index, movedItem) in unmovedItems.enumerate() {
            let id = movedItem.uniqueIdentifier
            unmIDMap[id] = index
        }
        
        
        // Diff
        let diffResult = DiffArray<Int>.diff(oldIDs, newIDs)
        for diffStep in diffResult.results.sort({ $0.index < $1.index }) {
            switch diffStep {
            case .Insert(let index, let id) :
                if oldIDMap[id] == nil {
                    insertionIndexes.append(index)
                } else {
                    let unmIndex = unmIDMap[id]!
                    let newIndex = newIDMap[id]!
                    moveIndexMap[unmIndex] = newIndex
                }
            case .Delete(let index, let id) :
                if newIDMap[id] == nil {
                    deletionIndexes.append(index)
                }
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
