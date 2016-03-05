//
//  Item.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import Foundation

class Item: NSObject, NSCoding {

    var name: String
    var image: UIImage?

    static var items = [Item]()
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
        Item.items.append(self)
        if NSKeyedArchiver.archiveRootObject(Item.items, toFile: Item.ArchiveURL.path!) {
            return true
        }
        print("Failed to persist the data.")
        return false
    }

    static func loadAll() -> [Item]? {
        if let items = NSKeyedUnarchiver.unarchiveObjectWithFile(Item.ArchiveURL.path!) as? [Item] {
            Item.items = items
            print("Loaded \(items.count) items.")
            return items
        }
        return nil
    }
}