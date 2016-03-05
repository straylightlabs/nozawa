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

    // MARK: Private

    func loadSubviews() {
        self.view.backgroundColor = UIColor.whiteColor()

        let cameraView = self.loadCameraView()
        cameraView.snp_makeConstraints{ make in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(self.view.snp_bottom)
        }
    }

    func showLiveCameraView() {
        self.startCameraSession()
    }
}
