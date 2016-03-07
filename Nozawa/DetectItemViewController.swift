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

    var captureRectView: UIImageView!
    var keypointsOverlayView: UIImageView!
    var detectionResultLabel: UILabel!
    var detectionDebugViews: [UIImageView] = []
    static let maxDetectionDebugViews = 4

    var processingDrawKeypoints = false
    var processingFindMatches = false
    var showDebugImages = false

    var videoOutput: AVCaptureVideoDataOutput!
    let dispatchQueueVideoCapture = dispatch_queue_create("videocapture", DISPATCH_QUEUE_CONCURRENT)
    let dispatchQueueDrawKeypoints = dispatch_queue_create("drawkeypoints", DISPATCH_QUEUE_CONCURRENT)
    let dispatchQueueFindMatches = dispatch_queue_create("findmatches", DISPATCH_QUEUE_CONCURRENT)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "toggleDebugImagesVisibility:")
    }

    override func viewWillAppear(animated: Bool) {
        self.startCameraSession()

        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.stopCameraSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView {
            var size = cameraView.bounds.size
            size.width /= 2;
            size.height /= 2;
            self.captureRectView.image = SaveItemCameraViewController.drawRedRectangle(size)
        }
    }

    // MARK: CameraBaseViewController

    override func startCameraSession() -> Bool {
        if !super.startCameraSession() {
            return false
        }

        // Set output.
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dispatchQueueVideoCapture)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if self.captureSession.canAddOutput(videoOutput) {
            self.captureSession.addOutput(videoOutput)
        }

        self.processingDrawKeypoints = false
        self.processingFindMatches = false
        self.showDebugImages = false

        return true
    }

    override func stopCameraSession() {
        self.captureSession.removeOutput(videoOutput)
        super.stopCameraSession()
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Set video orientation to fix rotation of the captured image.
        connection.videoOrientation = .Portrait

        if let image = self.imageFromSampleBuffer(sampleBuffer) {
            if !self.processingDrawKeypoints {
                dispatch_async(dispatchQueueDrawKeypoints, { [weak self] in
                    self?.processingDrawKeypoints = true
                    defer { self?.processingDrawKeypoints = false }

                    self?.doDrawKeypoints(image)
                })
            }
            if !self.processingFindMatches {
                dispatch_async(dispatchQueueFindMatches, { [weak self] in
                    self?.processingFindMatches = true
                    defer { self?.processingFindMatches = false }

                    if let device = self?.cameraDevice {
                        if !device.adjustingFocus && !device.adjustingExposure && !device.adjustingWhiteBalance {
                            self?.doFindMatches(image)
                        }
                    }
                })
            }
        }
    }

    // MARK: Actions

    func toggleDebugImagesVisibility(sender: UIButton) {
        self.showDebugImages = !self.showDebugImages

        for view in self.detectionDebugViews {
            view.hidden = !self.showDebugImages
        }
    }

    // MARK: Private
    private func loadSubviews() {
        self.view.backgroundColor = UIColor.whiteColor()

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(self.view.snp_bottom)
        }
        self.keypointsOverlayView = UIImageView()
        self.view.addSubview(self.keypointsOverlayView)
        self.keypointsOverlayView.snp_makeConstraints{ make in
            make.edges.equalTo(cameraView.snp_edges)
        }

        self.captureRectView = UIImageView()
        self.captureRectView.contentMode = .Center
        self.view.addSubview(self.captureRectView)
        self.captureRectView.snp_makeConstraints{ make in
            make.edges.equalTo(cameraView)
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

        for i in 0...(DetectItemViewController.maxDetectionDebugViews - 1) {
            let subImageView : UIImageView = UIImageView()
            subImageView.contentMode = .ScaleAspectFit
            subImageView.hidden = !self.showDebugImages
            detectionDebugViews.append(subImageView)
            self.view.addSubview(subImageView)
            subImageView.snp_makeConstraints{make in
                make.top.equalTo((i + 1) * 100)
                make.right.equalTo(0)
                make.width.equalTo(200)
                make.height.equalTo(100)
            }
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

    private func doDrawKeypoints(image: UIImage) {
        let drawKeypointsStart = NSDate()
        let processedImage = NZImageMatcher.drawKeypoints(image)
        let drawKeypointsElapsed = NSDate().timeIntervalSinceDate(drawKeypointsStart) as Double
        print("drawKeypoints: \(drawKeypointsElapsed*1000)[ms]")

        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.keypointsOverlayView!.image = processedImage
        })
    }

    private func doFindMatches(image: UIImage) {
        let findMatchesStart = NSDate()
        var matches = ImageItem.imageMatcher.getSimilarImages(image, crop: false) as! [ImageResult]
        let findMatchesElapsed = NSDate().timeIntervalSinceDate(findMatchesStart) as Double
        print("findMatches: \(findMatchesElapsed*1000)[ms]")

        let maxNum = DetectItemViewController.maxDetectionDebugViews
        if matches.count > maxNum {
            matches = Array(matches[0..<maxNum])
        }

        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            let detectionResult = NSMutableAttributedString(string: "Detection Result:")
            for image in matches {
                var attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
                if image.similarity >= 0.7 {
                    attributes = [NSForegroundColorAttributeName: UIColor.greenColor()]
                } else if image.similarity >= 0.5 {
                    attributes = [NSForegroundColorAttributeName: UIColor.yellowColor()]
                }
                detectionResult.appendAttributedString(NSAttributedString(string: String(format: "\n%@ = %.2f", image.name, image.similarity), attributes: attributes))
            }
            self?.detectionResultLabel.attributedText = detectionResult
            for view in (self?.detectionDebugViews ?? []) {
                view.image = nil
            }
            for i in 0..<matches.count {
                self?.detectionDebugViews[i].image = matches[i].debugImage
            }
        })
    }
}
