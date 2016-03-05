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

    var pickingImage = false

    let imagePicker = UIImagePickerController()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()

        self.imagePicker.delegate = self

        self.photoPickerButton.addTarget(self, action: "photoPickerButtonTapped:", forControlEvents: .TouchDown)
    }

    override func viewWillAppear(animated: Bool) {
        if !self.pickingImage {
            self.showLiveCameraView()
        }
    }
    
    // MARK: Actions

    func photoPickerButtonTapped(sender: UIButton) {
        self.pickingImage = true

        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoImageView.image = NZImageInternal().drawKeypoints(pickedImage)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Private

    func loadSubviews() {
        self.view.backgroundColor = UIColor.whiteColor()

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(self.view.snp_height).multipliedBy(0.5)
        }

        self.photoImageView = UIImageView()
        self.photoImageView.backgroundColor = UIColor.grayColor()
        self.photoImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.photoImageView)
        self.photoImageView.snp_makeConstraints{ make in
            make.left.right.equalTo(0)
            make.top.equalTo(cameraView.snp_bottom)
            make.height.equalTo(self.view.snp_height).multipliedBy(0.5)
        }

        self.photoPickerButton = UIButton(type: .System)
        self.photoPickerButton.setTitle("Camera Roll", forState: .Normal)
        self.view.addSubview(self.photoPickerButton)
        self.photoPickerButton.snp_makeConstraints{ make in
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-8)
            make.trailing.equalTo(self.view.snp_trailingMargin)
        }
    }

    func showLiveCameraView() {
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
            objc_sync_enter(self)
            if let img = self.imageFromSampleBuffer(sampleBuffer) {
                //self.findMatches(img)

                let conversionStart = NSDate()
                self.photoImageView?.image = NZImageInternal().drawKeypoints(img)
                let elapsedSec = NSDate().timeIntervalSinceDate(conversionStart) as Double
                print("capture\(self.captureDebugCounter++): size = \(img.size), elapsed = \(elapsedSec*1000)[ms]")
            }
            objc_sync_exit(self)
        })
    }

    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer : CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciimg = CIImage(CVPixelBuffer: pixelBuffer)
            let ciContext:CIContext = CIContext(options: nil)
            let cgimg:CGImageRef = ciContext.createCGImage(ciimg, fromRect: ciimg.extent)
            return UIImage(CGImage: cgimg, scale: 1.0, orientation: .Up)
        }
        return nil
    }

    private func findMatches(image: UIImage) {
        let similarImages = ImageItem.imageMatcher.getSimilarImages(image)
        print(similarImages)
    }
}
