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
        // Return Vars
        var insertionIndexes = [Int]()
        var deletionIndexes = [Int]()
        var reloadIndexMap = [Int:Int]()
        var moveIndexMap = [Int:Int]()
        var unmovedItems = [ComparableItem]()
        
        // Diffing
        var oldIDs = [Int]()
        var newIDs = [Int]()
        var unmIDs = [Int]()
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
            let newId = newItem.uniqueIdentifier
            newIDs.append(newId)
            newIDMap[newId] = newIndex
        }
        
        
        for oldID in oldIDs where newIDMap[oldID] == nil {
            let oldIndex = oldIDMap[oldID]!
            deletionIndexes.append(oldIndex)
        }
        
        unmovedItems = newItems.filter({ oldIDMap[$0.uniqueIdentifier] != nil }).sort({ a, b in
            let indexA = oldIDMap[a.uniqueIdentifier]!
            let indexB = oldIDMap[b.uniqueIdentifier]!
            return indexA < indexB
        })
        
        for newId in newIDs {
            
            let newIndex = newIDMap[newId]!
            let newItem = newItems[newIndex]
            
            // Looking for Changes
            if let oldIndex = oldIDMap[newId] {
                let oldItem = oldItems[oldIndex]
                switch oldItem.compareTo(newItem) {
                case .Changed(_) :
                    reloadIndexMap[oldIndex] = newIndex
                default:
                    break
                }
            } else {
                insertionIndexes.append(newIndex)
                unmovedItems.insert(newItem, atIndex: newIndex)
            }
            
        }
        

        
        

        
        for (unmIndex, unmItem) in unmovedItems.enumerate() {
            let id = unmItem.uniqueIdentifier
            unmIDs.append(id)
            unmIDMap[id] = unmIndex
        }


        
        // Move
        let diffResult = DiffArray<Int>.diff(unmIDs, newIDs)
        for diffStep in diffResult.results.sort({ $0.index < $1.index }) {
            switch diffStep {
            case .Delete(_, let id) :
                let unmIndex = unmIDMap[id]!
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
