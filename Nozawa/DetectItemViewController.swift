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

class DetectItemViewController: CameraBaseViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var photoImageView: UIImageView!
    var detectionResultLabel: UILabel!

    var captureDebugCounter = 0
    var processingCapturedImage = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()
    }

    override func viewWillAppear(animated: Bool) {
        self.showLiveCameraView()

        super.viewWillAppear(animated)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        connection.videoOrientation = .Portrait
        if let device = self.cameraDevice {
            if device.adjustingFocus || device.adjustingExposure || device.adjustingWhiteBalance || self.processingCapturedImage {
                return
            }
            self.processingCapturedImage = true
            if let img = self.imageFromSampleBuffer(sampleBuffer) {
                let conversionStart = NSDate()

                // TODO(maekawa): Merge drawKeypoints and findMatches so that keypoints detection runs only once.
                let processedImage = NZImageInternal().drawKeypoints(img)
                dispatch_async(dispatch_get_main_queue(), {
                    self.photoImageView?.image = processedImage
                })

                let detectionResult = self.findMatches(img)
                dispatch_async(dispatch_get_main_queue(), {
                    self.detectionResultLabel.text = detectionResult
                })

                let elapsedSec = NSDate().timeIntervalSinceDate(conversionStart) as Double
                print("capture\(self.captureDebugCounter++): size = \(img.size), elapsed = \(elapsedSec*1000)[ms]")
            }
            self.processingCapturedImage = false
        }
    }

    // MARK: Private

    private func loadSubviews() {
        self.view.backgroundColor = UIColor.whiteColor()

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.top.left.right.bottom.equalTo(0)
        }

        self.photoImageView = UIImageView()
        self.photoImageView.backgroundColor = UIColor.grayColor()
        self.photoImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.photoImageView)
        self.photoImageView.snp_makeConstraints{ make in
            make.top.right.equalTo(8)
            make.width.height.equalTo(200)
        }

        self.detectionResultLabel = UILabel()
        self.detectionResultLabel.numberOfLines = 0
        self.detectionResultLabel.backgroundColor = UIColor(white: 1, alpha: 0.3)
        self.view.addSubview(self.detectionResultLabel)
        self.detectionResultLabel.snp_makeConstraints{ make in
            make.bottom.equalTo(self.view.snp_bottom).offset(-8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
    }

    private func showLiveCameraView() {
        self.startCameraSession()

        // Set output.
        let out = AVCaptureVideoDataOutput()
        out.setSampleBufferDelegate(self, queue: dispatch_queue_create("videocapture", nil))
        out.alwaysDiscardsLateVideoFrames = true
        if (self.captureSession.canAddOutput(out)) {
            self.captureSession.addOutput(out)
        }
    }

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer : CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciimg = CIImage(CVPixelBuffer: pixelBuffer)
            let ciContext:CIContext = CIContext(options: nil)
            let cgimg:CGImageRef = ciContext.createCGImage(ciimg, fromRect: ciimg.extent)
            return UIImage(CGImage: cgimg)
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
