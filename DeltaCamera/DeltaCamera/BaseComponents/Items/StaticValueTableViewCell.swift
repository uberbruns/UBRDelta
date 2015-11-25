//
//  StaticValueCell.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 25/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


class StaticValueTableViewCell: UITableViewCell, UpdateableTableViewCell {
    
    let titleView = UILabel()
    let valueView = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        addSubviews()
        addViewConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        // Title View
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleView)
        
        // Value View
        valueView.textAlignment = .Right
        valueView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueView)
    }
    
    
    func addViewConstraints() {
        let views = ["titleView": titleView, "valueView": valueView]
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleView]-[valueView]-|", options: [], metrics: nil, views: views)
        let vColorView = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleView]-|", options: [], metrics: nil, views: views)
        let vCounterView = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[valueView]-|", options: [], metrics: nil, views: views)
        addConstraints(h + vColorView + vCounterView)
    }
 
    
    func updateCellWithItem(item: ComparableItem, animated: Bool) {
        guard let staticValueItem = item as? StaticValueItem else { return }
        titleView.text = staticValueItem.title
        valueView.text = staticValueItem.value
    }
    
}