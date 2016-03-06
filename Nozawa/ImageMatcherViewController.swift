//  Copyrigh © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ImageMatcherViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

  let tableView = UITableView()
  var matches: [UIImage] = []
  let imageMatcher = NZImageMatcher()
  let imagePicker = UIImagePickerController()

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.imagePicker.delegate = self

    self.loadPresetData()
    self.loadSubviews()

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTapped:")
  }

  // MARK: Actions

  func addButtonTapped(sender: UIButton) {
    self.imagePicker.allowsEditing = false
    self.imagePicker.sourceType = .PhotoLibrary
    self.presentViewController(self.imagePicker, animated: true, completion: nil)
  }

  // MARK: UIImagePickerControllerDelegate

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let similarImages = imageMatcher.getSimilarImages(pickedImage) as! [ImageResult]
      self.displayMatches(similarImages)
      self.imageMatcher.addImage(pickedImage, name: "")
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.matches.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
    cell.imageView!.image = self.matches[indexPath.row]
    return cell
  }

  // MARK: Private

  func loadPresetData() {
    for item in ImageItem.items {
      imageMatcher.addImage(item.image, name: item.name)
    }
  }

  func displayMatches(matches: [ImageResult]) {
    self.matches = []
    for match in matches {
      self.matches.append(match.debugImage)
    }
    self.tableView.reloadData()
  }

  func loadSubviews() {
    self.view.backgroundColor = UIColor.whiteColor()

    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.rowHeight = 160
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    self.view.addSubview(self.tableView)
    self.tableView.snp_makeConstraints{ make in
      make.edges.equalTo(self.view)
    }
  }

}
