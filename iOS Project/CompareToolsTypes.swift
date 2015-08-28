//
//  CompareToolsTypes.swift
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public enum ComparisonLevel {
    
    case Different, Same, SameIdentifier
    
    public var hasSameIdentifier: Bool {
        return self == .Same || self == .SameIdentifier
    }
}


public protocol Comparable {
    
    var uniqueIdentifier: Int { get }
    func compareTo(other: Comparable) -> ComparisonLevel
    
}


public protocol ComparableSection : Comparable {
    
    var items: [Comparable] { get set }
    
}


public struct ComparisonResult {
    
    public let insertionSet: NSIndexSet
    public let deletionSet: NSIndexSet
    public let reloadSet: NSIndexSet
    public let sameSet: NSIndexSet
    public let moveSet: [Int:Int]

    public let oldItems: [Comparable]
    public let unmovedItems: [Comparable]
    public let newItems: [Comparable]
    
    public init(insertionSet: NSIndexSet, deletionSet: NSIndexSet, reloadSet: NSIndexSet, sameSet: NSIndexSet, moveSet: [Int:Int], oldItems: [Comparable], unmovedItems: [Comparable], newItems: [Comparable])
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
