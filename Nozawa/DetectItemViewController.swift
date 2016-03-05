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

class DetectItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    var photoImageView: UIImageView!
    var photoPickerButton: UIButton!
    var cameraButton: UIButton!
    var cameraView: UIView?
    var cameraLayer: AVCaptureVideoPreviewLayer?

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
            cameraLayer.frame = cameraView.bounds
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.showLiveCameraView()
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
        self.showLiveCameraView()
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
        self.view.backgroundColor = UIColor.whiteColor()

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
        self.photoImageView.backgroundColor = UIColor.grayColor()
        self.photoImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.photoImageView)
        self.photoImageView.snp_makeConstraints{ make in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(self.photoPickerButton.snp_top).offset(-8)
        }
    }

    func showLiveCameraView() {
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

    func setupCamera(cameraDevice: AVCaptureDevice) {
        self.addCaptureDeviceInput(cameraDevice)

        let cameraView = UIView()
        self.cameraView = cameraView

        cameraView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(cameraView)
        cameraView.snp_makeConstraints{ make in
            make.edges.equalTo(self.photoImageView)
        }

        self.cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.layer.addSublayer(self.cameraLayer!)
        cameraView.layer.masksToBounds = true
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

        // Set output.
        let out = AVCaptureVideoDataOutput()
        out.setSampleBufferDelegate(self, queue: dispatch_queue_create("myqueue", nil))
        out.alwaysDiscardsLateVideoFrames = true
        if (captureSession.canAddOutput(out)) {
            captureSession.addOutput(out)
        }
    }

    var captureDebugCounter = 0
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        dispatch_async(dispatch_get_main_queue(), {
            print("capture\(self.captureDebugCounter++)")
        })
    }
}
