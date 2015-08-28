//
//  CompareToolsTypes.swift
//  iOS Project
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public enum ComparisonLevel {
    
    case Different, Same, SameIdentifier
    
    var hasSameIdentifier: Bool {
        return self == .Same || self == .SameIdentifier
    }
}


public protocol Comparable {
    var identifier: UInt32 { get }
    func compareTo(other: Comparable) -> ComparisonLevel
}


protocol ComparableSection : Comparable {
    var items: [Comparable] { get }
}


struct ComparisonResult {
    
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
