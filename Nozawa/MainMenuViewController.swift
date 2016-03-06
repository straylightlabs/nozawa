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
    @IBOutlet weak var imageMatcherButton: UIButton!
    @IBOutlet weak var clearDataButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveItemImageButton.addTarget(self, action: "saveItemImageButtonTapped:", forControlEvents: .TouchDown)
        self.detectItemButton.addTarget(self, action: "detectItemButtonTapped:", forControlEvents: .TouchDown)
        self.imageMatcherButton.addTarget(self, action: "imageMatcherButtonTapped:", forControlEvents: .TouchDown)
        self.clearDataButton.addTarget(self, action: "clearDataButtonTapped:", forControlEvents: .TouchDown)
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
  
    func imageMatcherButtonTapped(sender: UIButton!) {
        let viewController = ImageMatcherViewController()
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func clearDataButtonTapped(sender: UIButton!) {
        ImageItem.clearAll()
    }
}
