//
//  ViewController.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/4/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoPickerButton: UIButton!
    
    @IBOutlet weak var photoImageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        self.photoPickerButton.addTarget(self, action: "photoPickerButtonTapped:", forControlEvents: .TouchDown)
    }

    // MARK: Actions

    func photoPickerButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.contentMode = .ScaleAspectFit
            photoImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
