//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImage.h"
#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>
//#include <opencv2/highgui.hpp>
//#include <opencv2/nonfree.hpp>
//#include <opencv2/legacy.hpp>

using namespace cv;
using namespace std;

@interface ImapObject : NSObject

@property int32_t indexStart;
@property int32_t indexEnd;
@property NSString *name;
@property UIImage *image;

@end


@implementation ImapObject
@end


@interface NZImageInternal()

@property NSMutableArray *imapArray;  // Array of ImapObject.
@property std::vector<cv::Mat> descArray;  // Array of
@property int32_t r;

@end

@implementation NZImageInternal {
  NSMutableArray *_imapArray;  // Array of ImapObject.
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _imapArray = [NSMutableArray array];
    _r = 0;
  }
  return self;
}

- (void)addImage:(UIImage *)image
       imageName:(NSString *)name {
  cv:Mat imageMat = [image cvMatRepresentationColor];
  std:vector<cv::KeyPoint> keypoints;
  cv::Mat descriptor;
  
  Ptr<cv::FeatureDetector> featureDetector = cv::ORB::create();
  featureDetector->detectAndCompute(imageMat, noArray(), keypoints, descriptor);
  
  ImapObject *imapObject = [[ImapObject alloc] init];
  imapObject.indexStart = self.r;
  //imapObject.indexEnd = self.r + descripor. - 1,
  imapObject.name = name;
  imapObject.image = image;
  [_imapArray addObject:imapObject];

  _descArray.push_back(descriptor);
}

@end


@implementation NZImage {
  
}

@end