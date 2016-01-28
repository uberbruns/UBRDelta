//
//  ColorListViewController.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 23/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import UBRDelta

class ColorListViewController: TableViewController, CameraViewDelegate {

    // MARK: - Controller -

    let cameraView = CameraView()
    var colors = [CVColor]()
    var enableColorSampling = false {
        didSet {
            // cameraView.delegate = enableColorSampling ? self : nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - View -
    // MARK: Life-Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color List"
        view.backgroundColor = UIColor.whiteColor()
        addCameraView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(cameraView)
    }

    // MARK: Add views
    
    func addCameraView() {
        cameraView.backgroundColor = UIColor.blackColor()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)

        let viewsDictionary: [String: AnyObject] = ["cameraView" : cameraView]
        let horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[cameraView(120)]-15-|", options: [], metrics: nil, views: viewsDictionary)
        let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[cameraView(160)]-15-|", options: [], metrics: nil, views: viewsDictionary)
        view.addConstraints(horizontalConstraint + verticalConstraint)
    }
    
    
    // MARK: - Content -
    
    override func prepareReusableTableViewCells() {
        self.reusableCellClasses["Color"] = ColorTableViewCell.self
        self.reusableCellClasses["StaticValue"] = StaticValueTableViewCell.self
        self.reusableCellClasses["Switch"] = SwitchTableViewCell.self
    }
    
    
    override func generateItems() -> [TableViewSectionItem] {
        
        var sections = [TableViewSectionItem]()

        // Info Section
        var infoSection = TableViewSectionItem(id: "infoSection", title: "Info")
        var infoItems = [ComparableItem]()
        
        // Enable Color Sampling Switch
        let switchItem = SwitchItem(id: "sampleColors", title: "Sample Colors", value: enableColorSampling, valueHandler: { [weak self] (value) -> () in
            guard let weakSelf = self else { return }
            weakSelf.enableColorSampling = value
            weakSelf.updateTableView()
        })
        infoItems.append(switchItem)
        
        // Count Item
        if enableColorSampling {
            let countItem = StaticValueItem(id: "count", title: "Color Count", value: "\(colors.count)")
            infoItems.append(countItem)
        }
        
        infoSection.items = infoItems
        sections.append(infoSection)
        
        // Color Samples
        if enableColorSampling {
            var colorSection = TableViewSectionItem(id: "colorSection", title: "Colors")
            colorSection.items = colors.map({ color -> ComparableItem in
                let item = ColorItem(id: "\(color.raw)", color: color)
                return item as ComparableItem
            })
            sections.append(colorSection)
        }
        
        return sections
    }

    
    // MARK: - Protocols -
    // MARK: Camera View

    func cameraView(cameraView: CameraView, didSampleColors colors: [CVColor]) {
        self.colors = colors
        updateTableView()
    }

}

