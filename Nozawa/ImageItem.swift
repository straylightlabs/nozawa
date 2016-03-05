//
//  Item.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import Foundation

class ImageItem: NSObject, NSCoding {

    var name: String
    var image: UIImage?

    static var items = [ImageItem]()
    static let imageMatcher = NZImageMatcher()

    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("items")

    struct PropertyKey {
        static let nameKey = "name"
        static let imageKey = "image"
    }

    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image

        super.init()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as? UIImage
        self.init(name: name, image: image)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
    }

    func save() -> Bool {
        ImageItem.addItem(self)
        if NSKeyedArchiver.archiveRootObject(ImageItem.items, toFile: ImageItem.ArchiveURL.path!) {
            return true
        }
        print("Failed to persist the data.")
        return false
    }

    static func addItem(item: ImageItem) {
        items.append(item)
        imageMatcher.addBaseImage(item.image)
    }

    static func loadAll() -> [ImageItem]? {
        if let items = NSKeyedUnarchiver.unarchiveObjectWithFile(ImageItem.ArchiveURL.path!) as? [ImageItem] {
            for item in items {
                addItem(item)
            }
            print("Loaded \(items.count) items.")
            return items
        }
        return nil
    }
}