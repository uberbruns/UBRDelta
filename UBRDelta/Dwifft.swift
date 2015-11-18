//
//  LCS.swift
//  Dwifft
//
//  Created by Jack Flintermann on 3/14/15.
//  Copyright (c) 2015 jflinter. All rights reserved.
//

internal struct Diff<T> {
    internal let results: [DiffStep<T>]
}

internal func +<T> (left: Diff<T>, right: DiffStep<T>) -> Diff<T> {
    return Diff<T>(results: left.results + [right])
}

/// These get returned from calls to DiffArray.diff(). They represent insertions or deletions that need to happen to transform array a into array b.
internal enum DiffStep<T> : CustomDebugStringConvertible {
    case Insert(Int, T)
    case Delete(Int, T)
    var isInsertion: Bool {
        switch(self) {
        case .Insert:
            return true
        case .Delete:
            return false
        }
    }
    internal var debugDescription: String {
        switch(self) {
        case .Insert(let i, let j):
            return "+\(j)@\(i)"
        case .Delete(let i, let j):
            return "-\(j)@\(i)"
        }
    }
    var index: Int {
        switch(self) {
        case .Insert(let i, _):
            return i
        case .Delete(let i, _):
            return i
        }
    }
    var value: T {
        switch(self) {
        case .Insert(let j):
            return j.1
        case .Delete(let j):
            return j.1
        }
    }
}

internal struct DiffArray<Element: Equatable> {
    
    /// Returns the sequence of ArrayDiffResults required to transform one array into another.
    internal static func diff(arrayA: [Element], _ arrayB: [Element]) -> Diff<Element> {
        let table = MemoizedSequenceComparison.buildTable(arrayA, arrayB, arrayA.count, arrayB.count)
        return DiffArray.diffFromIndices(table, arrayA, arrayB, arrayA.count, arrayB.count)
    }
    
    /// Walks back through the generated table to generate the diff.
    private static func diffFromIndices(table: [[Int]], _ x: [Element], _ y: [Element], _ i: Int, _ j: Int) -> Diff<Element> {
        if i == 0 && j == 0 {
            return Diff<Element>(results: [])
        } else if i == 0 {
            return diffFromIndices(table, x, y, i, j-1) + DiffStep.Insert(j-1, y[j-1])
        } else if j == 0 {
            return diffFromIndices(table, x, y, i - 1, j) + DiffStep.Delete(i-1, x[i-1])
        } else if table[i][j] == table[i][j-1] {
            return diffFromIndices(table, x, y, i, j-1) + DiffStep.Insert(j-1, y[j-1])
        } else if table[i][j] == table[i-1][j] {
            return diffFromIndices(table, x, y, i - 1, j) + DiffStep.Delete(i-1, x[i-1])
        } else {
            return diffFromIndices(table, x, y, i-1, j-1)
        }
    }
        
}

internal struct MemoizedSequenceComparison<T: Equatable> {
    static func buildTable(x: [T], _ y: [T], _ n: Int, _ m: Int) -> [[Int]] {
        var table = Array(count: n + 1, repeatedValue: Array(count: m + 1, repeatedValue: 0))
        for i in 0...n {
            for j in 0...m {
                if (i == 0 || j == 0) {
                    table[i][j] = 0
                }
                else if x[i-1] == y[j-1] {
                    table[i][j] = table[i-1][j-1] + 1
                } else {
                    table[i][j] = max(table[i-1][j], table[i][j-1])
                }
            }
        }
        return table
    }
}
