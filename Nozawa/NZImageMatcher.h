//  Copyright © 2016 Straylight. All rights reserved.

#import <Foundation/Foundation.h>

@class UIImage;

@interface ImageResult : NSObject
@property UIImage *image;
@property NSString *name;
@property double_t similarity;
@property UIImage *debugImage;
@end

@interface NZImageMatcher : NSObject

- (void)addImage:(UIImage *)image
            name:(NSString *)name
            crop:(BOOL)crop;

// Returns an array of ImageResult in order of similarity.
- (NSArray *)getSimilarImages:(UIImage *)image
                         crop:(BOOL)crop;

+ (UIImage *)drawKeypoints:(UIImage *)image;

@end
