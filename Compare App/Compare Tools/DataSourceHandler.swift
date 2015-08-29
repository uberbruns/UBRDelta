//
//  DataSourceHandler.swift
//
//  Created by Karsten Bruns on 27/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation


public class DataSourceHandler {
    
    public typealias ItemUpdateHandler = (items: [ComparableItem], section: Int, insertIndexPaths: [NSIndexPath], reloadIndexPaths: [NSIndexPath], deleteIndexPaths: [NSIndexPath]) -> ()
    public typealias ItemReorderHandler = (items: [ComparableItem], section: Int, reorderMap: [Int:Int]) -> ()
    public typealias SectionUpdateHandler = (sections: [ComparableSection], insertIndexSet: NSIndexSet, reloadIndexSet: NSIndexSet, deleteIndexSet: NSIndexSet) -> ()
    public typealias SectionReorderHandler = (sections: [ComparableSection], reorderMap: [Int:Int]) -> ()
    public typealias StartHandler = () -> ()
    public typealias CompletionHandler = () -> ()
    
    public var userInterfaceUpdateTime: Double = 0.2
    
    // Update handler
    public var itemUpdate: ItemUpdateHandler? = nil
    public var itemReorder: ItemReorderHandler? = nil
    public var sectionUpdate: SectionUpdateHandler? = nil
    public var sectionReorder: SectionReorderHandler? = nil
    
    public var start: StartHandler? = nil
    public var completion: CompletionHandler? = nil
    
    // State vars to mind the background operation
    private var isDiffing: Bool = false
    private var resultIsOutOfDate: Bool = false
    
    // State var to mind the UI update
    private var timeLockEnabled: Bool = false
    private var lastUpdateTime: NSDate = NSDate(timeIntervalSince1970: 0)
    
    // Section data
    private var oldSections: [ComparableSection]? = nil
    private var newSections: [ComparableSection]? = nil
    
    
    public func queueComparison(oldSections oldSections: [ComparableSection], newSections: [ComparableSection])
    {
        // Set Sections
        if self.oldSections == nil {
            self.oldSections = oldSections
        }
        
        self.newSections = newSections
        
        // Guarding
        if isDiffing == true {
            self.resultIsOutOfDate = true
            return
        }
        
        diff()
    }
    
    
    private func diff()
    {
        guard let oldSections = self.oldSections else { return }
        guard let newSections = self.newSections else { return }
        
        let mainQueue = dispatch_get_main_queue()
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        self.isDiffing = true
        self.resultIsOutOfDate = false
        
        dispatch_async(backgroundQueue) {
            
            var itemDiffs = [Int: ComparisonResult]()
            
            for (oldSectionIndex, oldSection) in oldSections.enumerate() {
                
                let newIndex = newSections.indexOf({ newSection -> Bool in
                    let comparisonLevel = newSection.compareTo(oldSection)
                    return comparisonLevel.hasSameIdentifier
                })
                
                if let newIndex = newIndex {
                    // Diffing
                    let oldItems = oldSection.items
                    let newItems = newSections[newIndex].items
                    let itemDiff = ComparisonTool.diff(old: oldItems, new: newItems)
                    itemDiffs[oldSectionIndex] = itemDiff
                }
                
            }
            
            let sectionDiff = ComparisonTool.diff(old: oldSections.map({$0}), new: newSections.map({$0}))
            
            dispatch_async(mainQueue) {
                
                // Guarding
                if self.resultIsOutOfDate == true {
                    self.diff()
                    return
                }
                
                if self.timeLockEnabled == true {
                    return
                }
                
                let updateAllowedIn = self.lastUpdateTime.timeIntervalSinceNow + self.userInterfaceUpdateTime
                if  updateAllowedIn > 0 {
                    self.timeLockEnabled = true
                    DataSourceHandler.executeDelayed(updateAllowedIn) {
                        self.timeLockEnabled = false
                        self.diff()
                    }
                    return
                }
                
                // Start Updating
                self.start?()
                
                for (oldSectionIndex, itemDiff) in itemDiffs.sort({ $0.0 < $1.0 }) {
                    
                    // Create index paths
                    let insertIndexPaths = itemDiff.insertionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    let reloadIndexPaths = itemDiff.reloadSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    let deleteIndexPaths = itemDiff.deletionSet.map({ index in NSIndexPath(forRow: index, inSection: oldSectionIndex)})
                    
                    // Call item handler functions
                    self.itemUpdate?(items: itemDiff.unmovedItems, section: oldSectionIndex, insertIndexPaths: insertIndexPaths, reloadIndexPaths: reloadIndexPaths, deleteIndexPaths: deleteIndexPaths)
                    self.itemReorder?(items: itemDiff.newItems, section: oldSectionIndex, reorderMap: itemDiff.moveSet)
                    
                }
                
                // Change type
                let updateItems = sectionDiff.unmovedItems.flatMap({ $0 as? ComparableSection })
                let reorderItems = sectionDiff.newItems.flatMap({ $0 as? ComparableSection })
                
                // Call section handler functions
                self.sectionUpdate?(sections: updateItems, insertIndexSet: sectionDiff.insertionSet, reloadIndexSet: sectionDiff.reloadSet, deleteIndexSet: sectionDiff.deletionSet)
                self.sectionReorder?(sections: reorderItems, reorderMap: sectionDiff.moveSet)
                
                // Call completion block
                self.completion?()
                
                // Reset state
                self.lastUpdateTime = NSDate()
                self.oldSections = nil
                self.newSections = nil
                self.isDiffing = false
            }
            
        }
        
    }
    
    
    static private func executeDelayed(time: Int, action: () -> ())
    {
        self.executeDelayed(Double(time), action: action)
    }
    
    
    static private func executeDelayed(time: Double, action: () -> ())
    {
        if time == 0 {
            action()
            return
        }
        
        let nanoSeconds: Int64 = Int64(Double(NSEC_PER_SEC) * time);
        let when = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
        dispatch_after(when, dispatch_get_main_queue(), {
            action()
        });
    }
    
}