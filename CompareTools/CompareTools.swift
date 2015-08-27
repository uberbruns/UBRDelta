//
//  CompareTools.swift
//  iOS Project
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


struct ComparisonTool {
    
    static func diff<T: Comparable where T : Hashable>(old oldItems: [T], new newItems: [T]) -> ComparisonResult<T>
    {
        // Internal Functions
        func twoIntHash(a:Int, _ b:Int) -> Int {
            // See http://stackoverflow.com/a/13871379
            return a >= b ? a * a + a + b : a + b * b
        }
        
        
        // Comparison Cache
        var compareCache = [Int:ComparisonLevel]()
        func compare(oldItem oldItem: T, newItem: T) -> ComparisonLevel {
            let hash = twoIntHash(oldItem.hashValue, newItem.hashValue)
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
        
        return diffResult
    }
    
    
    
    static func diff2(old oldItems: [Comparable], new newItems: [Comparable]) -> ComparisonResult2
    {
        // Internal Functions
        func twoIntHash(a:Int, _ b:Int) -> Int {
            // See http://stackoverflow.com/a/13871379
            return a >= b ? a * a + a + b : a + b * b
        }
        
        
        // Comparison Cache
        var compareCache = [Int:ComparisonLevel]()
        func compare(oldItem oldItem: Comparable, newItem: Comparable) -> ComparisonLevel {
            let hash = twoIntHash(oldItem.hashValue, newItem.hashValue)
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
            
            let intIndex = unmovedItems.indexOf({ unmItem -> Bool in
                let equalityLevel = compare(oldItem: unmItem, newItem: newItem)
                return equalityLevel == .PerfectEquality || equalityLevel == .IdentifierEquality
            })
            
            if let intIndex = intIndex where newIndex != intIndex {
                // Move
                moveSet[intIndex] = newIndex
            }
        }
        
        
        // Bundle result
        let diffResult = ComparisonResult2(
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
