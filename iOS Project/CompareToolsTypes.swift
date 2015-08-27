//
//  CompareToolsTypes.swift
//  iOS Project
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


@objc public enum ComparisonLevel : Int {
    case NoEquality, PerfectEquality, IdentifierEquality
}


@objc public protocol Comparable {
    var identifier: Int { get }
    var hashValue: Int { get }
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


struct ComparisonResult2 {
    
    let insertionSet: NSIndexSet
    let deletionSet: NSIndexSet
    let reloadSet: NSIndexSet
    let sameSet: NSIndexSet
    let moveSet: [Int:Int]

    let oldItems: [Comparable]
    let unmovedItems: [Comparable]
    let newItems: [Comparable]
    
    init(insertionSet: NSIndexSet, deletionSet: NSIndexSet, reloadSet: NSIndexSet, sameSet: NSIndexSet, moveSet: [Int:Int], oldItems: [Comparable], unmovedItems: [Comparable], newItems: [Comparable])
    {
        self.insertionSet = insertionSet
        self.deletionSet = deletionSet
        self.reloadSet = reloadSet
        self.sameSet = sameSet
        self.moveSet = moveSet
        
        self.oldItems = oldItems
        self.unmovedItems = unmovedItems
        self.newItems = newItems
    }
    
}
