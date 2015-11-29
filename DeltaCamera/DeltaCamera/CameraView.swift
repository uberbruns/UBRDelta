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
import QuartzCore
import Accelerate


class CameraView : UIView, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session = AVCaptureSession()
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { return self.layer as! AVCaptureVideoPreviewLayer }
    var frameCounter: UInt8 = 0
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
                device.whiteBalanceMode = AVCaptureWhiteBalanceMode.Locked
                device.exposureMode = AVCaptureExposureMode.Locked
                session.addInput(input)
                device.unlockForConfiguration()
            }
            catch {}
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
        frameCounter = frameCounter &+ 1
        guard frameCounter%10 == 0 else { return }

        typealias UnsafeIntegerPointer = UnsafeMutablePointer<UInt8>
        
        let cameraBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(cameraBuffer,0)
        
        // Source
        let sourceBaseAddress = UnsafeIntegerPointer(CVPixelBufferGetBaseAddress(cameraBuffer))
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(cameraBuffer);
        let sourceWidth = UInt(CVPixelBufferGetWidth(cameraBuffer))
        let sourceHeight = UInt(CVPixelBufferGetHeight(cameraBuffer))
        var sourceBuffer = vImage_Buffer(data: sourceBaseAddress, height: sourceHeight, width: sourceWidth, rowBytes: sourceBytesPerRow)

        // Desitination
        let bytesPerPixel = 4
        let destWidth = sourceWidth / 32
        let destHeight = sourceHeight / 32
        let destBytesPerRow = destWidth * UInt(bytesPerPixel)
        let destByteCount = Int(destHeight * destBytesPerRow)
        let destData = UnsafeMutablePointer<UInt8>.alloc(destByteCount)
        defer { destData.dealloc(destByteCount) }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: Int(destBytesPerRow))
        
        // scale the image
        let error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, 0)
        guard error == kvImageNoError else { return }

        // Sample colors
        var colors = [CVColor]()
        var sampleAddress = destData
        let endAddress = destData + destByteCount
        

        while sampleAddress < endAddress {
            let red = (sampleAddress + 2).memory
            let green = (sampleAddress + 1).memory
            let blue = sampleAddress.memory
            let color = CVColor(red: red, green: green, blue: blue)
            if let index = colors.indexOf({ $0.raw == color.raw }) {
                var updateColor = colors[index]
                updateColor.count++
                colors[index] = updateColor
            } else {
                colors.append(color)
            }
            sampleAddress += bytesPerPixel
        }
        
        
        let result = colors.sort({ $0.count > $1.count })
        
        let mainQueue = dispatch_get_main_queue()
        dispatch_async(mainQueue) {
            delegate.cameraView(self, didSampleColors: result)
        }
        
        CVPixelBufferUnlockBaseAddress(cameraBuffer, 0)

    }

}
