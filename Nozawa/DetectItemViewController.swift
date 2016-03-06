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

    var capturedImageView: UIImageView!
    var keypointsOverlayView: UIImageView!
    var detectionResultLabel: UILabel!

    var processingDrawKeypoints = false
    var processingFindMatches = false

    let videoOutput = AVCaptureVideoDataOutput()
    let dispatchQueueVideoCapture = dispatch_queue_create("videocapture", nil)
    let dispatchQueueMatching = dispatch_queue_create("matching", nil)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()
    }

    override func viewWillAppear(animated: Bool) {
        self.showLiveCameraView()

        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)

        videoOutput.setSampleBufferDelegate(nil, queue: nil)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if self.processingDrawKeypoints { return }
        self.processingDrawKeypoints = true
        defer { self.processingDrawKeypoints = false }

        // Set video orientation to fix rotation of the captured image.
        connection.videoOrientation = .Portrait

        if let img = self.imageFromSampleBuffer(sampleBuffer) {
            dispatch_async(dispatch_get_main_queue(), {
                self.capturedImageView?.image = img
            })

            let drawKeypointsStart = NSDate()
            let processedImage = NZImageMatcher.drawKeypoints(img)
            let drawKeypointsElapsed = NSDate().timeIntervalSinceDate(drawKeypointsStart) as Double
            print("drawKeypoints: \(drawKeypointsElapsed*1000)[ms]")

            dispatch_async(dispatch_get_main_queue(), {
                self.keypointsOverlayView!.image = processedImage
            })

            dispatch_async(self.dispatchQueueMatching, {
                if self.processingFindMatches { return }
                self.processingFindMatches = true
                defer { self.processingFindMatches = false }

                if let device = self.cameraDevice {
                    if !device.adjustingFocus && !device.adjustingExposure && !device.adjustingWhiteBalance {
                        let findMatchesStart = NSDate()
                        let detectionResult = self.findMatches(img)
                        let findMatchesElapsed = NSDate().timeIntervalSinceDate(findMatchesStart) as Double
                        print("findMatches: \(findMatchesElapsed*1000)[ms]")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.detectionResultLabel.text = detectionResult
                        })
                    }
                }
            })
        }
    }

    // MARK: Private

    private func loadSubviews() {
        self.view.backgroundColor = UIColor.whiteColor()

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.top.left.right.bottom.equalTo(0)
        }
        self.keypointsOverlayView = UIImageView()
        self.keypointsOverlayView.alpha = 0.6
        self.view.addSubview(self.keypointsOverlayView)
        self.keypointsOverlayView.snp_makeConstraints{ make in
            make.edges.equalTo(cameraView.snp_edges)
        }
        
        self.capturedImageView = UIImageView()
        self.capturedImageView.backgroundColor = UIColor.grayColor()
        self.capturedImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.capturedImageView)
        self.capturedImageView.snp_makeConstraints{ make in
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
        videoOutput.setSampleBufferDelegate(self, queue: self.dispatchQueueVideoCapture)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if self.captureSession.canAddOutput(videoOutput) {
            self.captureSession.addOutput(videoOutput)
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
