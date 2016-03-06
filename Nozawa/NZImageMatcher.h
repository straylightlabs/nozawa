//  Copyright © 2016 Straylight. All rights reserved.

#import <Foundation/Foundation.h>

@class UIImage;

@interface ImageResult : NSObject
@property UIImage *image;
@property NSString *name;
@property double_t similarity;
@end

@interface NZImageMatcher : NSObject

- (void)addImage:(UIImage *)image
            name:(NSString *)name;

// Returns an array of ImageResult in order of similarity.
- (NSArray *)getSimilarImages:(UIImage *)image;

+ (UIImage *)drawKeypoints:(UIImage *)image;

@end
