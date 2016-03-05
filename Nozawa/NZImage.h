//  Copyright © 2016 Straylight. All rights reserved.

#import <Foundation/Foundation.h>

@class UIImage;

@interface NZImageInternal : NSObject

- (void)addImage:(UIImage *)image
       imageName:(NSString *)name;

- (void)addImage:(UIImage *)image;

- (double)calculateMatch:(UIImage *)image;

- (UIImage *)drawKeypoints:(UIImage *)image;
@end


@interface NZImage : NSObject

@end
