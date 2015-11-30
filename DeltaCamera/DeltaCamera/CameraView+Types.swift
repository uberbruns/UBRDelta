//
//  CameraView+Types.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 25/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit


struct CVColor : Equatable {
    
    private static let colorReduction: UInt16 = 32
    
    let raw: UInt16
    var count: Int = 1
    
    var color: UIColor {
        let rr = (raw & 0xF00) >> 8
        let gg = (raw & 0x0F0) >> 4
        let bb = (raw & 0x00F)
        let f = 256 / CGFloat(CVColor.colorReduction)
        return UIColor(red: CGFloat(rr) / f, green: CGFloat(gg) / f, blue: CGFloat(bb) / f, alpha: 1.0)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8) {
        let r = UInt16(red)   / CVColor.colorReduction
        let g = UInt16(green) / CVColor.colorReduction
        let b = UInt16(blue)  / CVColor.colorReduction
        let rShifted = r << 8
        let gShifted = g << 4
        let bShifted = b << 0
        self.raw = rShifted | gShifted | bShifted
    }
    
}

func ==(lhs: CVColor, rhs: CVColor) -> Bool {
    return lhs.raw == rhs.raw && lhs.count == rhs.count
}


protocol CameraViewDelegate : class {
    func cameraView(cameraView: CameraView, didSampleColors colors: [CVColor])
}


struct RGBColor {

    let r: UInt8
    let g: UInt8
    let b: UInt8
    
    init(red: UInt8, green: UInt8, blue: UInt8) {
        self.r = red
        self.g = green
        self.b = blue
    }
    
}