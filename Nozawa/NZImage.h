//  Copyright © 2016 Straylight. All rights reserved.

#import <Foundation/Foundation.h>

@class UIImage;

@interface NZImageInternal : NSObject

- (void)addImage:(UIImage *)image
       imageName:(NSString *)name;
@end


@interface NZImage : NSObject

@end
