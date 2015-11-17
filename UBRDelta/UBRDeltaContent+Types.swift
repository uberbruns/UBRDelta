//
//  UBRDeltaContent+Types.swift
//  UBRDelta
//
//  Created by Karsten Bruns on 10/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public protocol ComparableItem {
    
    var uniqueIdentifier: Int { get }
    func compareTo(other: ComparableItem) -> ComparisonLevel
    
}



public protocol ComparableSectionItem : ComparableItem {
    
    var items: [ComparableItem] { get set }
    
}