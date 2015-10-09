//
//  iOS_ProjectTests.swift
//  iOS ProjectTests
//
//  Created by Karsten Bruns on 19/06/15.
//  Copyright (c) 2015 bruns.me. All rights reserved.
//

import UIKit
import XCTest
import CompareTools



extension Int : ComparableItem {
    
    public var uniqueIdentifier: Int { return self }
    
    public func compareTo(other: ComparableItem) -> ComparisonLevel {
        if let otherInt = other  as? Int {
            return otherInt == self ? .Same : .Different
        }
        return ComparisonLevel.Different
    }
    
}



class iOS_ProjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExample() {
        
        let old = [968, 979, 970, 969].map({ $0 as ComparableItem })
        let new = [970, 1001, 979, 968, 969].map({ $0 as ComparableItem })
        
        let itemDiff = ComparisonTool.diff(old: old, new: new)
        
        let expectedCount = itemDiff.oldItems.count + itemDiff.insertionIndexes.count - itemDiff.deletionIndexes.count
        let newCount = itemDiff.newItems.count

        print("Old", itemDiff.oldItems.map({ $0.uniqueIdentifier }))
        print("Unm", itemDiff.unmovedItems.map({ $0.uniqueIdentifier }))
        print("New", itemDiff.newItems.map({ $0.uniqueIdentifier }))

        if newCount != expectedCount {
            print("Calculation mistake: 1")
            XCTAssert(false, "Failed")
        }
        
        if itemDiff.newItems.count != itemDiff.unmovedItems.count {
            print("Calculation mistake: 2")
            XCTAssert(false, "Failed")
        }
        
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
