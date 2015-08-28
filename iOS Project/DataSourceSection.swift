//
//  DataSourceSection.swift
//
//  Created by Karsten Bruns on 28/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public struct DataSourceSection : ComparableSection
{
    public var uniqueIdentifier: Int { return i }
    public var items: [Comparable] = []
    
    public let i: Int
    public let title: String
    
    public init(i: Int, title: String) {
        self.i = i
        self.title = title
    }
    
    
    public func compareTo(other: Comparable) -> ComparisonLevel
    {
        guard let other = other as? DataSourceSection else { return .Different }
        
        if other.i == self.i {
            if other.title == self.title {
                return .Same
            } else {
                return .SameIdentifier
            }
        } else {
            return .Different
        }
    }
    
}


public func ==(lhs: DataSourceSection, rhs: DataSourceSection) -> Bool
{
    return lhs.i == rhs.i && lhs.title == rhs.title
}