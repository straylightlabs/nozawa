//
//  MainMenuViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var saveItemImageButton: UIButton!
    @IBOutlet weak var detectItemButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveItemImageButton.addTarget(self, action: "saveItemImageButtonTapped:", forControlEvents: .TouchDown)
        self.detectItemButton.addTarget(self, action: "detectItemButtonTapped:", forControlEvents: .TouchDown)
    }

    // MARK: Actions

    func saveItemImageButtonTapped(sender: UIButton!) {
        let viewController = SaveItemCameraViewController()
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func detectItemButtonTapped(sender: UIButton!) {
        let viewController = DetectItemViewController()
        self.navigationController!.pushViewController(viewController, animated: true)
    }
}
