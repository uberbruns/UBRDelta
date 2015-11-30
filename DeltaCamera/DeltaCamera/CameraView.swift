//
//  CameraView.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 24/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Accelerate


class CameraView : UIView, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session = AVCaptureSession()
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { return self.layer as! AVCaptureVideoPreviewLayer }
    var frameCounter: UInt8 = 0
    var rgbBuffer = [[RGBColor]]()
    weak var delegate: CameraViewDelegate? = nil
    
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startCameraSession()
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startCameraSession() {
    
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetMedium
        session.commitConfiguration()
        
        let devices: [AVCaptureDevice] = AVCaptureDevice.devices() as! [AVCaptureDevice]
        
        for device in devices {
            guard device.hasMediaType(AVMediaTypeVideo) && device.supportsAVCaptureSessionPreset(AVCaptureSessionPresetLow) else { continue }
            guard let input = try? AVCaptureDeviceInput(device: device) else { continue }
            guard session.canAddInput(input) else { continue }
            do {
                try device.lockForConfiguration()
                session.addInput(input)
                device.unlockForConfiguration()
            }
            catch {
                continue
            }
            break
        }
        
        
        let pixelFormatKex: NSString = kCVPixelBufferPixelFormatTypeKey
        let pixelFormat: Int = Int(kCVPixelFormatType_32BGRA)
        let settings = [pixelFormatKex:pixelFormat]
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = settings
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: backgroundQueue)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        videoPreviewLayer.session = session
        session.startRunning()
    }

    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        guard let delegate = delegate else { return }
        

        let cameraBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(cameraBuffer, 0)
        
        // Source image buffer from camera buffer
        let sourceBaseAddress = UnsafeMutablePointer<UInt8>(CVPixelBufferGetBaseAddress(cameraBuffer))
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(cameraBuffer);
        let sourceWidth = UInt(CVPixelBufferGetWidth(cameraBuffer))
        let sourceHeight = UInt(CVPixelBufferGetHeight(cameraBuffer))
        var sourceBuffer = vImage_Buffer(data: sourceBaseAddress, height: sourceHeight, width: sourceWidth, rowBytes: sourceBytesPerRow)

        // Destination image buffer for scaling
        let bytesPerPixel = 4
        let destWidth = sourceWidth / 8
        let destHeight = sourceHeight / 8
        let destPixelCount = Int(destWidth * destHeight)
        let destBytesPerRow = destWidth * UInt(bytesPerPixel)
        let destByteCount = Int(destHeight * destBytesPerRow)
        let destData = UnsafeMutablePointer<UInt8>.alloc(destByteCount)
        defer { destData.dealloc(destByteCount) }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: Int(destBytesPerRow))
        
        // Scale the image
        let error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, 0)
        guard error == kvImageNoError else { return }

        // Sample colors
        var colors = [CVColor]()
        var sampleAddress = destData
        let endAddress = destData + destByteCount
        
        if rgbBuffer.count != destPixelCount {
            rgbBuffer = Array(count: destPixelCount, repeatedValue: [RGBColor]())
        }

        var i = 0
        while sampleAddress < endAddress {
            let red = (sampleAddress + 2).memory
            let green = (sampleAddress + 1).memory
            let blue = sampleAddress.memory
            rgbBuffer[i].append(RGBColor(red: red, green: green, blue: blue))
            sampleAddress += bytesPerPixel
            i++
        }

        // Delegate result
        if frameCounter == 10 {
            
            for rgbColors in rgbBuffer {
                
                var r = 0
                var g = 0
                var b = 0
                
                for rgbColor in rgbColors {
                    r += Int(rgbColor.r)
                    g += Int(rgbColor.g)
                    b += Int(rgbColor.b)
                }
                
                r /= rgbColors.count
                g /= rgbColors.count
                b /= rgbColors.count
                
                let color = CVColor(red: UInt8(r), green: UInt8(g), blue: UInt8(b))
                if let index = colors.indexOf({ $0.raw == color.raw }) {
                    var updateColor = colors[index]
                    updateColor.count++
                    colors[index] = updateColor
                } else {
                    colors.append(color)
                }
                
            }
            
            let result = colors.sort({ $0.count > $1.count })
            let mainQueue = dispatch_get_main_queue()
            
            dispatch_async(mainQueue) {
                delegate.cameraView(self, didSampleColors: result)
            }
            
            frameCounter = 0;
            rgbBuffer.removeAll(keepCapacity: true)
            
        } else {
            frameCounter++
        }
        
        CVPixelBufferUnlockBaseAddress(cameraBuffer, 0)

    }

}
