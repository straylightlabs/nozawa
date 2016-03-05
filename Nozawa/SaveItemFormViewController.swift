//
//  SaveItemFormViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit

class SaveItemFormViewController: UIViewController, UITextFieldDelegate {

    var image: UIImage!

    @IBOutlet weak var bottleLableImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    static func createWith(image: UIImage) -> SaveItemFormViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("SaveItemForm") as! SaveItemFormViewController
        viewController.image = image
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bottleLableImageView.image = self.image
        self.itemNameTextField.delegate = self

        self.saveButton.addTarget(self, action: "saveButtonTapped:", forControlEvents: .TouchDown)
        self.cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: .TouchDown)
    }

    // MARK: Actions

    func saveButtonTapped(sender: UIButton!) {
        if let name = self.itemNameTextField.text {
            if !name.isEmpty {
                let item = ImageItem(name: name, image: self.image)
                item.save()

                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func cancelButtonTapped(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        self.saveButtonTapped(nil)
    }
}
