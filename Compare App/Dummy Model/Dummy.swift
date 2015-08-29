//
//  Dummy.swift
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation




struct Dummy : ComparableItem
{
    let v: Int
    let i: Int
    
    var uniqueIdentifier: Int { return i }
    
    init(v: Int, i: Int) {
        self.v = v
        self.i = i
    }
    
    
    func compareTo(other: ComparableItem) -> ComparisonLevel
    {
        guard let other = other as? Dummy else { return .Different }
        
        if other.i == self.i {
            if other.v == self.v {
                return .Same
            } else {
                return .SameIdentifier
            }
        } else {
            return .Different
        }
    }
    
}


func ==(lhs: Dummy, rhs: Dummy) -> Bool
{
    return lhs.i == rhs.i && lhs.v == rhs.v
}