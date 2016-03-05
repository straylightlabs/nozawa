//
//  UIImage.swift
//  Nozawa
//
//  Created by Ryo Kawaguchi on 3/5/16.
//  Copyright © 2016 Straylight. All rights reserved.
//

import Foundation

extension UIImage {

    func crop(rect: CGRect) -> UIImage {
        var correctedRect = rect
        switch (self.imageOrientation) {
        case .Right:
            correctedRect = CGRect(x: rect.origin.y, y: rect.origin.x, width: rect.height, height: rect.width)
        default:
            break  // TODO: Support other types?
        }

        let imageRef = CGImageCreateWithImageInRect(self.CGImage, correctedRect)
        return UIImage(CGImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
    }
}