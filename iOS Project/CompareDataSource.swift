//
//  CompareDataSource.swif
//  iOS Project
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


@objc protocol ComparableSection :  Comparable {
    var items: [Comparable] { get }
}


struct CompareDataSource {
    
    typealias SectionUpdate = (diff: ComparisonResult2) -> ()
    typealias SectionReorder = (diff: ComparisonResult2) -> ()
    typealias ItemUpdate = (section: Int, diff: ComparisonResult2) -> ()
    typealias ItemReorder = (section: Int, diff: ComparisonResult2) -> ()
    
    static func diff(oldSections oldSections: [ComparableSection], newSections: [ComparableSection], itemUpdate: ItemUpdate, itemReorder: ItemReorder, sectionUpdate: SectionUpdate, sectionReorder: SectionReorder)
    {
        var itemDiffs = [Int: ComparisonResult2]()
        
        for (oldSectionIndex, oldSection) in oldSections.enumerate() {
            
            let newIndex = newSections.indexOf({ newSection -> Bool in
                let equalityLevel = newSection.compareTo(oldSection)
                return equalityLevel == .PerfectEquality || equalityLevel == .IdentifierEquality
            })

            if let newIndex = newIndex {
                // Diffing
                let oldItems = oldSection.items
                let newItems = newSections[newIndex].items
                let itemDiff = ComparisonTool.diff2(old: oldItems, new: newItems)
                itemDiffs[oldSectionIndex] = itemDiff
                
                itemUpdate(section: oldSectionIndex, diff: itemDiff)
                itemReorder(section: oldSectionIndex, diff: itemDiff)
            }
            
            
        }
        
        
//        for (oldSectionIndex, itemDiff) in itemDiffs.sort({ $0.0 < $1.0 }) {
//        }
        
        
        let sectionDiff = ComparisonTool.diff2(old: oldSections, new: newSections)
        sectionUpdate(diff: sectionDiff)
        sectionReorder(diff: sectionDiff)
//
//        if let oldSections = (oldSections as Any) as? [ComparableSection],
//            let newSections = (newSections as Any) as? [ComparableSection] {
//        }
        
    }
    
}