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

class DetectItemViewController: CameraBaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    var photoImageView: UIImageView!
    var photoPickerButton: UIButton!
    var cameraButton: UIButton!

    var pickingImage = false

    let imagePicker = UIImagePickerController()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()

        self.imagePicker.delegate = self

        self.photoPickerButton.addTarget(self, action: "photoPickerButtonTapped:", forControlEvents: .TouchDown)
        self.cameraButton.addTarget(self, action: "cameraButtonTapped:", forControlEvents: .TouchDown)
    }

    override func viewWillAppear(animated: Bool) {
        if !self.pickingImage {
            self.showLiveCameraView()
        }
    }
    
    // MARK: Actions

    func photoPickerButtonTapped(sender: UIButton) {
        self.pickingImage = true

        self.stopCameraSession()

        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }

    func cameraButtonTapped(sender: UIButton) {
        self.photoImageView.image = nil
        self.pickingImage = false

        self.showLiveCameraView()
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoImageView.image = pickedImage
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.edges.equalTo(self.photoImageView)
        }

        self.startCameraSession()

        // Set output.
        let out = AVCaptureVideoDataOutput()
        out.setSampleBufferDelegate(self, queue: dispatch_queue_create("myqueue", nil))
        out.alwaysDiscardsLateVideoFrames = true
        if (self.captureSession.canAddOutput(out)) {
            self.captureSession.addOutput(out)
        }
    }

    var captureDebugCounter = 0
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        dispatch_async(dispatch_get_main_queue(), {
            if let img = self.imageFromSampleBuffer(sampleBuffer) {
                print("capture\(self.captureDebugCounter++): size = \(img.size)")
            }
        })
    }

    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer : CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer) {
            return UIImage(CIImage:CIImage(CVPixelBuffer: pixelBuffer))
        }
        return nil
    }
}
