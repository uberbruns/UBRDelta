//
//  CompareTools.swift
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public struct UBRDelta {
    

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
            let hash = UBRDelta.twoIntHash(oldItem.uniqueIdentifier, newItem.uniqueIdentifier)
            if let cachedResult = compareCache[hash] {
                return cachedResult
            } else {
                let result = newItem.compareTo(oldItem)
                compareCache[hash] = result
                return result
            }
        }
        
        
        // Init vars
        var insertionIndexes = [Int]()
        var deletionIndexes = [Int]()
        var reloadIndexMap = [Int:Int]()
        var moveIndexMap = [Int:Int]()
        
        
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
                deletionIndexes.append(oldIndex)
            }
            
        }
        
        // Iterating over 'newItems' to insert new items into 'unmovedItems'
        // and to determine indexes that need to be inseret and updated
        for (newIndex, newItem) in newItems.enumerate() {
            
            var comparisonLevel = ComparisonLevel.Different
            
            let oldIndex = oldItems.indexOf({ oldItem -> Bool in
                comparisonLevel = compareItems(oldItem: oldItem, newItem: newItem)
                return comparisonLevel.hasSameIdentifier
            })
            
            if let oldIndex = oldIndex {
                
                switch comparisonLevel {
                case .Changed :
                    reloadIndexMap[oldIndex] = newIndex
                default :
                    break
                }
                
            } else if oldIndex == nil {
                
                // Insert
                insertionIndexes.append(newIndex)
                
                if newIndex < unmovedItems.count {
                    unmovedItems.insert(newItem, atIndex: newIndex)
                } else {
                    unmovedItems.append(newItem)
                }
                
            }
            
        }
        

        // The reload index needs to be based on the unmoved items indexes
        // because reloading is part of the first step. But currently
        // its referencing newIndex
        // We can do this in the next step, but the next step iterates
        // over newIndex and the reloadIndexMap is [oldIndex:newIndex].
        // So we flip it
        let flippedReloadIndexMap = reloadIndexMap.reduce([Int:Int]()) { (var dict, element: (Int, Int)) -> [Int:Int] in
            dict[element.1] = element.0
            return dict
        }
        
        
        // Iterating over 'newItems' and 'unmovedItems'
        // to determine the movement of items
        
        // TODO: Better Implementation https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
        
        for (newIndex, newItem) in newItems.enumerate() {
            
            let unmovedIndex = unmovedItems.indexOf({ unmItem -> Bool in
                let comparisonLevel = compareItems(oldItem: unmItem, newItem: newItem)
                return comparisonLevel.hasSameIdentifier
            })
            
            
            // Move
            if let unmovedIndex = unmovedIndex where newIndex != unmovedIndex {
                moveIndexMap[unmovedIndex] = newIndex
            }
            
            // We use the flipped index to swap  newIndex against unmovedIndex
            if let oldIndex = flippedReloadIndexMap[newIndex] {
                reloadIndexMap[oldIndex] = unmovedIndex
            }
        }
        
        
        // Bundle result
        let diffResult = ComparisonResult(
            insertionIndexes: insertionIndexes,
            deletionIndexes: deletionIndexes,
            reloadIndexMap: reloadIndexMap,
            moveIndexMap: moveIndexMap,
            oldItems: oldItems,
            unmovedItems: unmovedItems,
            newItems: newItems
        )
        
        return diffResult
    }

    
}
