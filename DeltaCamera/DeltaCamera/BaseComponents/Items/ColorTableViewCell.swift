//
//  StaticValueTableViewCell.swift
//  CompareApp
//
//  Created by Karsten Bruns on 29/08/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta


class ColorTableViewCell: UITableViewCell, UpdateableTableViewCell {
    
    let colorView = UIView()
    let counterView = UILabel()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        userInteractionEnabled = false
        selectionStyle = .None
        addSubviews()
        addViewConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        // Color View
        colorView.backgroundColor = UIColor.blackColor()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorView)

        // Counter View
        counterView.textAlignment = .Right
        counterView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(counterView)
    }

    
    func addViewConstraints() {
        let views = ["colorView": colorView, "counterView": counterView]
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[colorView(40)]-[counterView]-|", options: [], metrics: nil, views: views)
        let vColorView = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[colorView]-|", options: [], metrics: nil, views: views)
        let vCounterView = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[counterView]-|", options: [], metrics: nil, views: views)
        addConstraints(h + vColorView + vCounterView)
    }
    
    func updateCellWithItem(item: ComparableItem, animated: Bool) {
        guard let colorItem = item as? ColorItem else { return }
        colorView.backgroundColor = colorItem.color.color
        counterView.text = "\(colorItem.color.count)"
    }
    
}