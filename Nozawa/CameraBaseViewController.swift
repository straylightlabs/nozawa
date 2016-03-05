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

    var cameraView: UIView?
    var cameraLayer: AVCaptureVideoPreviewLayer?

    let captureSession = AVCaptureSession()

    // MARK: Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView, cameraLayer = self.cameraLayer {
            cameraLayer.frame = cameraView.bounds
        }
    }

    func loadCameraView() -> UIView {
        let cameraView = UIView()
        self.cameraView = cameraView

        cameraView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(cameraView)
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
                    self.setupCamera(captureDevice)
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

    // MARK: Private

    private func setupCamera(cameraDevice: AVCaptureDevice) {
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
            device.focusMode = .ContinuousAutoFocus
            device.unlockForConfiguration()

            try self.captureSession.addInput(AVCaptureDeviceInput(device: device))
        } catch {
            print("Failed to setup camera device input")
        }
    }

}
