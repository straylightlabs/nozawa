//  Copyrigh © 2016 Straylight. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ImageCell: UITableViewCell {
  let backgroundImageView = UIImageView()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.contentView.addSubview(self.backgroundImageView)
    self.backgroundImageView.snp_makeConstraints{ make in
      make.edges.equalTo(self.contentView)
    }
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

class SimulatorUtility {
  class var isRunningSimulator: Bool {
    return TARGET_OS_SIMULATOR != 0
  }
}

class ImageMatcherViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

  let tableView = UITableView()
  var matches: [UIImage] = []
  let imagePicker = UIImagePickerController()

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.imagePicker.delegate = self

    self.loadSubviews()

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTapped:")
  }

  // MARK: Actions

  func addButtonTapped(sender: UIButton) {
    self.imagePicker.allowsEditing = false
    self.imagePicker.sourceType = SimulatorUtility.isRunningSimulator ? .PhotoLibrary : .Camera
    self.presentViewController(self.imagePicker, animated: true, completion: nil)
  }

  // MARK: UIImagePickerControllerDelegate

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let similarImages = ImageItem.imageMatcher.getSimilarImages(pickedImage, crop: false) as! [ImageResult]
      self.displayMatches(similarImages)

      let item = ImageItem(name: "", image: pickedImage)
      item.add()
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.matches.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ImageCell
    cell.backgroundImageView.image = self.matches[indexPath.row]
    cell.backgroundImageView.contentMode = .ScaleAspectFit
    return cell
  }

  // MARK: Private

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
    self.tableView.separatorStyle = .None
    self.tableView.registerClass(ImageCell.self, forCellReuseIdentifier: "cell")
    self.view.addSubview(self.tableView)
    self.tableView.snp_makeConstraints{ make in
      make.edges.equalTo(self.view)
    }
  }

}
