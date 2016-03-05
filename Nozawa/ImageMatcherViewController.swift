//  Copyright © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ImageMatcherViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let numSubImageViews = 4
  
  var photoImageView: UIImageView!
  //var subImageStackView: UIStackView!
  var subImageViews: Array<UIImageView>! = []
  var photoPickerButton: UIButton!
  
  var pickingImage = false
  
  let imageMatcher = NZImageMatcher()
  
  let imagePicker = UIImagePickerController()
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadSubviews()
    
    self.imagePicker.delegate = self
    
    self.photoPickerButton.addTarget(self, action: "photoPickerButtonTapped:", forControlEvents: .TouchDown)
  }
  
  override func viewWillAppear(animated: Bool) {

  }
  
  // MARK: Actions
  
  func photoPickerButtonTapped(sender: UIButton) {
    self.pickingImage = true
    
    self.imagePicker.allowsEditing = false
    self.imagePicker.sourceType = .PhotoLibrary
    self.presentViewController(self.imagePicker, animated: true, completion: nil)
  }
  
  // MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.photoImageView.image = pickedImage
      var similarImageResults : Array = imageMatcher.getSimilarImages(pickedImage)
      if similarImageResults.count > 0 {
        for var i in 0...(min(similarImageResults.count, numSubImageViews) - 1) {
          let subImageView : UIImageView = subImageViews[i]
          let imageResult : ImageResult = similarImageResults[i] as! ImageResult
          subImageView.image = imageResult.image
        }
      }
      imageMatcher.addImage(pickedImage, name: "")
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: Private
  
  func loadSubviews() {
    self.view.backgroundColor = UIColor.whiteColor()
    
    self.photoPickerButton = UIButton(type: .System)
    self.photoPickerButton.setTitle("Camera Roll", forState: .Normal)
    self.view.addSubview(self.photoPickerButton)
    self.photoPickerButton.snp_makeConstraints{ make in
      make.bottom.equalTo(self.view.snp_bottomMargin).offset(-8)
      make.trailing.equalTo(self.view.snp_trailingMargin)
    }
    
    
    self.photoImageView = UIImageView()
    self.photoImageView.backgroundColor = UIColor.grayColor()
    self.photoImageView.contentMode = .ScaleAspectFill
    self.view.addSubview(self.photoImageView)
    self.photoImageView.snp_makeConstraints{ make in
      make.left.right.equalTo(0)
      make.height.equalTo(self.view.snp_height).multipliedBy(0.5)
    }
    
//    self.subImageStackView = UIStackView()
//    self.subImageStackView.backgroundColor = UIColor.redColor()
//    self.subImageStackView.axis = .Horizontal
//    self.subImageStackView.alignment = .Center
//    self.subImageStackView.distribution = .Fill
//    self.subImageStackView.spacing = 8
//    self.view.addSubview(self.subImageStackView)
//    self.subImageStackView.snp_makeConstraints{ make in
//      make.left.right.equalTo(0)
//      make.top.equalTo(self.photoImageView.snp_bottom)
//      make.height.equalTo(100)
//    }
    
    for var i in 0...(numSubImageViews - 1) {
      let subImageView : UIImageView = UIImageView()
      subImageView.contentMode = .ScaleAspectFill
      self.view.addSubview(subImageView)
      subImageView.snp_makeConstraints{make in
        make.left.equalTo(100 * i)
        make.top.equalTo(self.photoImageView.snp_bottom).offset(20)
        make.width.equalTo(100)
        make.height.equalTo(100)
      }
      // self.subImageStackView.addArrangedSubview(subImageView)
            subImageViews.append(subImageView)
    }
  }
  

}
