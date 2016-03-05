//
//  ViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/4/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photoImageView: UIImageView!
    var photoPickerButton: UIButton!
    var cameraButton: UIButton!
    var cameraView: UIView?
    var cameraLayer: CALayer?
    var cameraAspectRatio = 1.0

    let imagePicker = UIImagePickerController()
    let captureSession = AVCaptureSession()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()

        self.imagePicker.delegate = self

        self.photoPickerButton.addTarget(self, action: "photoPickerButtonTapped:", forControlEvents: .TouchDown)
        self.cameraButton.addTarget(self, action: "cameraButtonTapped:", forControlEvents: .TouchDown)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView, cameraLayer = self.cameraLayer {
            var bounds = cameraView.bounds
            bounds.origin.x -= 25
            bounds.size.width += 50
            cameraLayer.frame = bounds
        }
    }

    // MARK: Actions

    func photoPickerButtonTapped(sender: UIButton) {
        if let cameraView = self.cameraView {
            self.captureSession.stopRunning()
            cameraView.removeFromSuperview()
            self.cameraView = nil
        }

        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }

    func cameraButtonTapped(sender: UIButton) {
        if self.cameraView != nil {
            print("Camera view already open.")
            return
        }

        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.Back {
                if let captureDevice = device as? AVCaptureDevice {
                    self.setupCamera(captureDevice)
                    return
                }
            }
        }
        print("Back camera not found.")
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Private

    func loadSubviews() {
        self.photoPickerButton = UIButton(type: .System)
        self.photoPickerButton.setTitle("Camera Roll", forState: .Normal)
        self.view.addSubview(self.photoPickerButton)
        self.photoPickerButton.snp_makeConstraints{ make in
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-8)
            make.trailing.equalTo(self.view.snp_trailingMargin)
        }

        self.cameraButton = UIButton(type: .System)
        self.cameraButton.setTitle("Live Camera", forState: .Normal)
        self.view.addSubview(self.cameraButton)
        self.cameraButton.snp_makeConstraints{ make in
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-8)
            make.leading.equalTo(self.view.snp_leadingMargin)
        }

        self.photoImageView = UIImageView()
        self.photoImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.photoImageView)
        self.photoImageView.snp_makeConstraints{ make in
            make.top.equalTo((self.topLayoutGuide as! UIView).snp_bottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(self.photoPickerButton.snp_top).offset(-8)
        }
    }

    func setupCamera(cameraDevice: AVCaptureDevice) {
        self.addCaptureDeviceInput(cameraDevice)

        let dimension = CMVideoFormatDescriptionGetDimensions(cameraDevice.activeFormat.formatDescription)
        self.cameraAspectRatio = Double(dimension.width) / Double(dimension.height)

        let cameraView = UIView()
        self.cameraView = cameraView

        cameraView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(cameraView)
        cameraView.snp_makeConstraints{ make in
            make.edges.equalTo(self.photoImageView)
        }

        self.cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraView.layer.addSublayer(self.cameraLayer!)
        self.captureSession.startRunning()
    }

    func addCaptureDeviceInput(device: AVCaptureDevice) {
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
