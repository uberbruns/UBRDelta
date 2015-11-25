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
        cameraView.delegate = self
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
    }
    
    
    override func generateItems() -> [TableViewSectionItem] {
        var colorSection = TableViewSectionItem(id: "colorSection", title: nil)
        colorSection.items = colors.map({ color -> ComparableItem in
            let item = ColorItem(id: "\(color.raw)", color: color)
            return item as ComparableItem
        })
        return [colorSection]
    }

    
    // MARK: - Protocols -
    // MARK: Camera View

    func cameraView(cameraView: CameraView, didSampleColors colors: [CVColor]) {
        self.colors = colors
        updateTableView()
    }

}

