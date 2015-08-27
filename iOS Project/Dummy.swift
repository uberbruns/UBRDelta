//
//  Dummy.swift
//  iOS Project
//
//  Created by Karsten Bruns on 26/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


class Mummy : Hashable, Equatable, Comparable
{
    var children: [Dummy] = []
    let i: Int
    let name: String
    
    @objc var identifier: Int { return i }
    
    init(i: Int, name: String) {
        self.i = i
        self.name = name
    }
    
    
    @objc func compareTo(other: Comparable) -> ComparisonLevel
    {
        guard let other = other as? Mummy else { return .NoEquality }
        
        if other.i == self.i {
            if other.name == self.name {
                return .PerfectEquality
            } else {
                return .IdentifierEquality
            }
        } else {
            return .NoEquality
        }
    }
    
    var hashValue: Int {
        return i
    }
}


func ==(lhs: Mummy, rhs: Mummy) -> Bool
{
    return lhs.i == rhs.i && lhs.name == rhs.name
}


class Dummy : Hashable, Equatable, Comparable
{
    let v: Int
    let i: Int
    
    @objc var identifier: Int { return i }
    
    init(v: Int, i: Int) {
        self.v = v
        self.i = i
    }
    
    
    @objc func compareTo(other: Comparable) -> ComparisonLevel
    {
        guard let other = other as? Dummy else { return .NoEquality }
        
        if other.i == self.i {
            if other.v == self.v {
                return .PerfectEquality
            } else {
                return .IdentifierEquality
            }
        } else {
            return .NoEquality
        }
    }
    
    var hashValue: Int {
        return i
    }
}


func ==(lhs: Dummy, rhs: Dummy) -> Bool
{
    return lhs.i == rhs.i && lhs.v == rhs.v
}