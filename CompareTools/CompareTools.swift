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
    
    let insertionSet: NSMutableIndexSet
    let deletionSet: NSMutableIndexSet
    let reloadSet: NSMutableIndexSet
    let sameSet: NSMutableIndexSet
    let moveSet: [Int:Int]
    let unmovedItems: [T]
    
    init(insertionSet: NSMutableIndexSet, deletionSet: NSMutableIndexSet, reloadSet: NSMutableIndexSet, sameSet: NSMutableIndexSet, moveSet: [Int:Int], unmovedItems: [T])
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
    
    static func diff<T: Comparable>(old oldItems: [T], new newItems: [T]) -> ComparisonResult<T>
    {
        NSLog("Start")
        let insertionSet = NSMutableIndexSet()
        let deletionSet = NSMutableIndexSet()
        let reloadSet = NSMutableIndexSet()
        let sameSet = NSMutableIndexSet()
        var moveSet = [Int:Int]()
        
        
        var unmovedItems = [T]()

        
        // Delete
        for (oldIndex, oldItem) in oldItems.enumerate() {
            
            let newIndex = newItems.indexOf({ newItem -> Bool in
                let equalityLevel = newItem.compareTo(oldItem)
                return equalityLevel == .PerfectEquality || equalityLevel == .IdentifierEquality
            })
            
            // Delete
            if newIndex == nil {
                deletionSet.addIndex(oldIndex)
            } else {
                unmovedItems.append(newItems[newIndex!])
            }
            
        }
        
        // Insert, Reload
        for (newIndex, newItem) in newItems.enumerate() {
            
            var equalityLevel = ComparisonLevel.NoEquality
            
            let oldIndex = oldItems.indexOf({ oldItem -> Bool in
                equalityLevel = oldItem.compareTo(newItem)
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
        
        
        // Move
        for (newIndex, newItem) in newItems.enumerate() {
            
            let intIndex = unmovedItems.indexOf({ oldItem -> Bool in
                let equalityLevel = oldItem.compareTo(newItem)
                return equalityLevel == .PerfectEquality
            })
            
            if let intIndex = intIndex where newIndex != intIndex {
                // Move
                moveSet[intIndex] = newIndex
            }
            
        }
        
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
