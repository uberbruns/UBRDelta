//
//  TableViewSectionItem.swift
//
//  Created by Karsten Bruns on 28/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation
import UBRDelta


public struct TableViewSectionItem : ComparableSectionItem {
    
    public var uniqueIdentifier: Int { return id.hash }
    public var items: [ComparableItem] = []
    
    public let id: String
    public var title: String?
    public var footer: String? = nil
    public var userInfo: [String:AnyObject]? = nil
    
    public init(id: String, title: String?) {
        self.id = id
        self.title = title
    }
    
    
    public func compareTo(other: ComparableItem) -> ComparisonLevel {
        guard let other = other as? TableViewSectionItem else { return .Different }
        guard other.id == self.id else { return .Different }
        
        let titleChanged = other.title != title
        let footerChanged = other.footer != footer
        
        if  !titleChanged && !footerChanged {
            return .Same
        } else {
            return .Changed(["title":titleChanged, "footer": footerChanged])
        }
    }
    
}