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
    var detectionResultLabel: UILabel!

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
            make.height.equalTo(cameraView.snp_height)
        }

        self.photoPickerButton = UIButton(type: .System)
        self.photoPickerButton.setTitle("Camera Roll", forState: .Normal)
        self.view.addSubview(self.photoPickerButton)
        self.photoPickerButton.snp_makeConstraints{ make in
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-8)
            make.trailing.equalTo(self.view.snp_trailingMargin)
        }

        self.detectionResultLabel = UILabel()
        self.detectionResultLabel.numberOfLines = 0
        self.detectionResultLabel.backgroundColor = UIColor(white: 1, alpha: 0.3)
        self.view.addSubview(self.detectionResultLabel)
        self.detectionResultLabel.snp_makeConstraints{ make in
            make.bottom.equalTo(self.photoPickerButton.snp_top).offset(-8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
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
    var processingCapturedImage = false
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if let device = self.cameraDevice {
            if device.adjustingFocus || device.adjustingExposure || device.adjustingWhiteBalance {
                return
            }
            if self.processingCapturedImage {
                return
            }
            self.processingCapturedImage = true
            if let img = self.imageFromSampleBuffer(sampleBuffer) {
                let conversionStart = NSDate()
                let processedImage = NZImageInternal().drawKeypoints(img)
                let detectionResult = self.findMatches(img)
                let elapsedSec = NSDate().timeIntervalSinceDate(conversionStart) as Double
                print("capture\(self.captureDebugCounter++): size = \(img.size), elapsed = \(elapsedSec*1000)[ms]")

                dispatch_async(dispatch_get_main_queue(), {
                    self.photoImageView?.image = processedImage
                    self.detectionResultLabel.text = detectionResult
                })
            }
            self.processingCapturedImage = false
        }
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

    private func findMatches(image: UIImage) -> String {
        var similarImages = ImageItem.imageMatcher.getSimilarImages(image) as! [ImageResult]
        if similarImages.count > 3 {
            similarImages = Array(similarImages[0..<3])
        }
        var detectionResult = "Detection Result:"
        for image in similarImages {
            detectionResult += String(format: "\n%@ = %.2f", image.name, image.similarity)
        }
        return detectionResult
    }
}
