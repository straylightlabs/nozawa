//  Copyright © 2016 Straylight. All rights reserved.

#import <Foundation/Foundation.h>

@class UIImage;

@interface NZImageMatcher : NSObject

- (void)addBaseImage:(UIImage *)image;

- (NSArray *)getSimilarImages:(UIImage *)image;

@end
