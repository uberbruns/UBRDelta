//
//  DataSourceSection.swift
//  iOS Project
//
//  Created by Karsten Bruns on 28/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


struct DataSourceSection : ComparableSection
{
    var items: [Comparable] = []
    let i: Int
    let title: String
    
    var uniqueIdentifier: Int { return i }
    
    init(i: Int, title: String) {
        self.i = i
        self.title = title
    }
    
    
    func compareTo(other: Comparable) -> ComparisonLevel
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


func ==(lhs: DataSourceSection, rhs: DataSourceSection) -> Bool
{
    return lhs.i == rhs.i && lhs.title == rhs.title
}