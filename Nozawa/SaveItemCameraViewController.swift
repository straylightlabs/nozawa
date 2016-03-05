//
//  SaveItemViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class SaveItemCameraViewController: CameraBaseViewController {

    var captureRectView: UIImageView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.focusMode = .AutoFocus

        self.loadSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView {
            var size = cameraView.bounds.size
            size.width /= 3;
            size.height /= 3;
            self.captureRectView.image = self.drawRedRectangle(size)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.startCameraSession()
    }

    override func didTakeStillImage(image: UIImage) {
        let captureRect = CGRect(
            x: image.size.width / 3,
            y: image.size.height / 3,
            width: image.size.width / 3,
            height: image.size.height / 3)
        let croppedImage = image.crop(captureRect)

        let viewController = SaveItemFormViewController.createWith(croppedImage)
        self.presentViewController(viewController, animated: true, completion: nil)
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

        self.captureRectView = UIImageView()
        self.captureRectView.contentMode = .Center
        self.view.addSubview(self.captureRectView)
        self.captureRectView.snp_makeConstraints{ make in
            make.edges.equalTo(cameraView)
        }
    }

    private func drawRedRectangle(size: CGSize) -> UIImage {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        CGContextStrokeRect(context, bounds)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
