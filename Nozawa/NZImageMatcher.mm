//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImageMatcher.h"
#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>
#include <opencv2/stitching/detail/matchers.hpp>

using namespace cv;
using namespace std;


@interface ImageResult()
@property detail::ImageFeatures features;
@end


@implementation ImageResult

- (instancetype)initWithImage:(UIImage *)image
                         name:(NSString *)name {
  self = [super init];
  if (self) {
    _image = image;
    _name = name;

    detail::OrbFeaturesFinder featuresFinder;
    cv::Mat mat = [image cvMatRepresentationColor];
    //cv::Mat mat = [image cvMatRepresentationGray];
    cv::cvtColor(mat , mat , CV_RGBA2RGB);  // Drop alpha channel.
    featuresFinder(mat, _features);
  }
  return self;
}

- (double_t)calculateSimilarityWtihOtherImage:(ImageResult *)other {
  detail::MatchesInfo matchesInfo;  
  detail::BestOf2NearestMatcher featuresMatcher;
  featuresMatcher(self.features, other.features, matchesInfo);
  double_t confidence1 = matchesInfo.confidence;
  featuresMatcher(other.features, self.features, matchesInfo);
  double_t confidence2 = matchesInfo.confidence;
  return MAX(confidence1, confidence2);
}

@end


@implementation NZImageMatcher {
  NSMutableArray *_baseImages;  // Of imageResult.
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _baseImages = [NSMutableArray array];
  }
  return self;
}

- (void)addImage:(UIImage *)image
            name:(NSString *)name {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:name];
  [_baseImages addObject:imageResult];
}

- (NSArray *)getSimilarImages:(UIImage *)image {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:nil];
  if (imageResult.features.keypoints.empty()) {
    return [NSArray array];
  }
  for (ImageResult *baseImage : _baseImages) {
    double_t similarity = [baseImage calculateSimilarityWtihOtherImage:imageResult];
    baseImage.similarity = similarity;
  }
  NSSortDescriptor *similaritySortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"self.similarity" ascending:NO];
  NSArray *sortedImages =
      [_baseImages sortedArrayUsingDescriptors:@[similaritySortDescriptor]];
  NSMutableArray *similarImages = [NSMutableArray array];
  for (ImageResult *baseImage in sortedImages) {
    if (baseImage.similarity <= 0) {
      continue;
    }
    [similarImages addObject:baseImage];
  }
  return similarImages;
}

@end
