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

class SaveItemViewController: CameraBaseViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubviews()
    }

    override func viewWillAppear(animated: Bool) {
        self.showLiveCameraView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let cameraView = self.cameraView {
            var bounds = cameraView.bounds
            bounds.size.width /= 3;
            bounds.size.height /= 3;
            bounds.origin.x += bounds.size.width
            bounds.origin.y += bounds.size.height
            let redRectangleImage = UIImageView(frame: bounds)
            redRectangleImage.image = self.drawRedRectangle(bounds.size)
            self.view.addSubview(redRectangleImage)
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
    }

    private func showLiveCameraView() {
        self.startCameraSession()
    }

    private func drawRedRectangle(size: CGSize) -> UIImage {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        CGContextStrokeRect(context, bounds)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
