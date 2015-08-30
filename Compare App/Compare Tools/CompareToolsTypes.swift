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



public protocol ComparableItem {
    
    var uniqueIdentifier: Int { get }
    func compareTo(other: ComparableItem) -> ComparisonLevel
    
}



public protocol ComparableSectionItem : ComparableItem {
    
    var items: [ComparableItem] { get set }
    
}



public struct ComparisonResult {
    
    public let insertionSet: NSIndexSet
    public let deletionSet: NSIndexSet
    public let reloadSet: NSIndexSet
    public let sameSet: NSIndexSet
    public let moveSet: [Int:Int]

    public let oldItems: [ComparableItem]
    public let unmovedItems: [ComparableItem]
    public let newItems: [ComparableItem]
    
    public init(insertionSet: NSIndexSet, deletionSet: NSIndexSet, reloadSet: NSIndexSet, sameSet: NSIndexSet, moveSet: [Int:Int], oldItems: [ComparableItem], unmovedItems: [ComparableItem], newItems: [ComparableItem])
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
