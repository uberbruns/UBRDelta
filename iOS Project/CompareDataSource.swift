//
//  CompareDataSource.swif
//  iOS Project
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation




struct CompareDataSource {
    
    typealias ItemUpdate = (items: [Comparable], section: Int, insertIndexPaths: [NSIndexPath], reloadIndexPaths: [NSIndexPath], deleteIndexPaths: [NSIndexPath]) -> ()
    typealias ItemReorder = (items: [Comparable], section: Int, reorderMap: [Int:Int]) -> ()
    typealias SectionUpdate = (sections: [ComparableSection], insertIndexSet: NSIndexSet, reloadIndexSet: NSIndexSet, deleteIndexSet: NSIndexSet) -> ()
    typealias SectionReorder = (sections: [ComparableSection], reorderMap: [Int:Int]) -> ()
    typealias CompletionHandler = () -> ()
    
    static func diff(oldSections oldSections: [ComparableSection], newSections: [ComparableSection], itemUpdate: ItemUpdate, itemReorder: ItemReorder, sectionUpdate: SectionUpdate, sectionReorder: SectionReorder, completionHandler: CompletionHandler? = nil)
    {
        let mainQueue = dispatch_get_main_queue()
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        dispatch_async(backgroundQueue) {
            
            var itemDiffs = [Int: ComparisonResult]()
            
            for (oldSectionIndex, oldSection) in oldSections.enumerate() {
                
                let newIndex = newSections.indexOf({ newSection -> Bool in
                    let equalityLevel = newSection.compareTo(oldSection)
                    return equalityLevel == .Same || equalityLevel == .SameIdentifier
                })
                
                if let newIndex = newIndex {
                    // Diffing
                    let oldItems = oldSection.items
                    let newItems = newSections[newIndex].items
                    let itemDiff = ComparisonTool.diff(old: oldItems, new: newItems)
                    itemDiffs[oldSectionIndex] = itemDiff
                }
                
            }
            
            dispatch_async(mainQueue) {
                
                for (oldSectionIndex, itemDiff) in itemDiffs.sort({ $0.0 < $1.0 }) {
                    
                    // Create index paths
                    let insertIndexPaths = itemDiff.insertionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    let reloadIndexPaths = itemDiff.reloadSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    let deleteIndexPaths = itemDiff.deletionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    
                    // Call item handler functions
                    itemUpdate(items: itemDiff.unmovedItems, section: oldSectionIndex, insertIndexPaths: insertIndexPaths, reloadIndexPaths: reloadIndexPaths, deleteIndexPaths: deleteIndexPaths)
                    itemReorder(items: itemDiff.newItems, section: oldSectionIndex, reorderMap: itemDiff.moveSet)
                    
                }
                
                let sectionDiff = ComparisonTool.diff(old: oldSections.map({$0}), new: newSections.map({$0}))
                
                // Change type
                let updateItems = sectionDiff.unmovedItems.flatMap({ $0 as? ComparableSection })
                let reorderItems = sectionDiff.newItems.flatMap({ $0 as? ComparableSection })
                
                // Call section handler functions
                sectionUpdate(sections: updateItems, insertIndexSet: sectionDiff.insertionSet, reloadIndexSet: sectionDiff.reloadSet, deleteIndexSet: sectionDiff.deletionSet)
                sectionReorder(sections: reorderItems, reorderMap: sectionDiff.moveSet)
                
                completionHandler?()
            }
            
        }
        
    }
    
}