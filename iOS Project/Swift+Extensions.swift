//
//  Swift+Extensions.swift
//  iOS Project
//
//  Created by Karsten Bruns on 28/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


extension Array {
    
    mutating func extractRandomElements(count count: Int) -> [Element] {
        var elements = [Element]()
        for _ in 0..<(min(count,self.count)) {
            let index = Int(arc4random_uniform(UInt32(self.count)))
            elements.append(self[index])
            self.removeAtIndex(index)
        }
        return elements
    }
    
    mutating func insertAtRandomIndex(newElements: [Element]) {
        for newElement in newElements {
            let index = Int(arc4random_uniform(UInt32(self.count)))
            self.insert(newElement, atIndex: index)
        }
    }
    
    
}