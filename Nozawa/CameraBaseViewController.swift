//
//  CameraBaseViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class CameraBaseViewController: UIViewController {

    // Properties configurable.
    var focusMode: AVCaptureFocusMode = .ContinuousAutoFocus

    var cameraView: UIView?
    var cameraDevice: AVCaptureDevice?
    var cameraLayer: AVCaptureVideoPreviewLayer?
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()

    var focusing = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stillImageOutput.outputSettings[AVVideoPixelAspectRatioKey] = AVVideoCodecJPEG
        self.captureSession.addOutput(self.stillImageOutput)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView, cameraLayer = self.cameraLayer {
            cameraLayer.frame = cameraView.bounds
        }
    }

    deinit {
        if let device = self.cameraDevice {
            device.removeObserver(self, forKeyPath: "adjustingFocus")
            device.removeObserver(self, forKeyPath: "adjustingExposure")
            device.removeObserver(self, forKeyPath: "adjustingWhiteBalance")
        }
    }

    // MARK: Public

    func loadCameraView() -> UIView {
        let cameraView = UIView()
        self.cameraView = cameraView

        cameraView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(cameraView)

        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: "cameraViewTapped:")
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        cameraView.addGestureRecognizer(gestureRecognizer)

        return cameraView
    }

    func startCameraSession() -> Bool {
        if self.cameraView == nil {
            print("loadCameraView() must be called first.")
            return false
        }

        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.Back {
                if let captureDevice = device as? AVCaptureDevice {
                    self.cameraDevice = captureDevice
                    self.setupCameraDevice(captureDevice)
                    self.captureSession.startRunning()
                    return true
                }
            }
        }
        return false
    }

    func stopCameraSession() {
        if let cameraView = self.cameraView {
            self.captureSession.stopRunning()
            cameraView.removeFromSuperview()
            self.cameraView = nil
        }
    }

    func didCompleteCameraAdjustment() {
        // Do something in child classes.
    }

    // MARK: Actions

    func cameraViewTapped(singleTap: UITapGestureRecognizer) {
        if self.focusMode != .AutoFocus {
            print("Manual focus only supported with .AutoFocus mode")
            return
        }

        if let device = self.cameraDevice, layer = self.cameraLayer {
            if !device.focusPointOfInterestSupported {
                print("Device does not support changing focus point")
                return
            }
            let touchPoint = singleTap.locationInView(self.cameraView)
            let focusPoint = layer.captureDevicePointOfInterestForPoint(touchPoint)
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                self.focusing = true
                device.unlockForConfiguration()
            } catch {
                print("Failed to change the focus point")
            }
        }
    }

    // MARK: Observers

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "adjustingFocus" || keyPath == "adjustingExposure" || keyPath == "adjustingExposure" {
            if let device = self.cameraDevice {
                if !device.adjustingFocus && !device.adjustingExposure && !device.adjustingWhiteBalance {
                    self.maybeTakeStillImage()
                }
            }
        }
    }

    // MARK: Private

    private func setupCameraDevice(cameraDevice: AVCaptureDevice) {
        cameraDevice.addObserver(self, forKeyPath: "adjustingFocus", options: .New, context: nil)
        cameraDevice.addObserver(self, forKeyPath: "adjustingExposure", options: .New, context: nil)
        cameraDevice.addObserver(self, forKeyPath: "adjustingWhiteBalance", options: .New, context: nil)

        self.addCaptureDeviceInput(cameraDevice)

        self.cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView!.layer.addSublayer(self.cameraLayer!)
        self.cameraView!.layer.masksToBounds = true
    }

    private func addCaptureDeviceInput(device: AVCaptureDevice) {
        if self.captureSession.inputs.count > 0 {
            print("Input device already added.")
            return
        }

        do {
            try device.lockForConfiguration()
            device.focusMode = self.focusMode
            device.unlockForConfiguration()

            let input = try AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(input)
        } catch {
            print("Failed to setup camera device input")
        }
    }

    private func maybeTakeStillImage() {
        if !self.focusing {
            return
        }

        let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection) { imageSampleBuffer, error in
            let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            if data == nil {
                return
            }

            self.stopCameraSession()

            let imageView = UIImageView(image: UIImage(data: data))
            self.view.addSubview(imageView)
            imageView.snp_makeConstraints{ make in
                make.edges.equalTo(self.view)
            }
        }

        self.focusing = false
    }
}
