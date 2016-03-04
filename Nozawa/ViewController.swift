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

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoPickerButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!

    var cameraView: UIView?
    var cameraLayer: CALayer?

    let imagePicker = UIImagePickerController()
    let captureSession = AVCaptureSession()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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

        self.captureSession.sessionPreset = AVCaptureSessionPresetLow
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
            self.photoImageView.contentMode = .ScaleAspectFit
            self.photoImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Private

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
