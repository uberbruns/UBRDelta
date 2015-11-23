//
//  UBRDelta+Protocols.swift
//  UBRDelta
//
//  Created by Karsten Bruns on 17/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public protocol ComparableItem {
    
    var uniqueIdentifier: Int { get }
    func compareTo(other: ComparableItem) -> ComparisonLevel
    
}
