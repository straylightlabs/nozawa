//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImageMatcher.h"
#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>
#include <opencv2/stitching/detail/matchers.hpp>

using namespace cv;
using namespace std;


@interface NZImage : NSObject

@property UIImage *image;
@property detail::ImageFeatures features;
@property double_t similarity;  // Used only temporarily for sorting.

@end


@implementation NZImage

- (instancetype)initWithImage:(UIImage *)image {
  self = [super init];
  if (self) {
    _image = image;

    detail::OrbFeaturesFinder featuresFinder;
    cv::Mat mat = [image cvMatRepresentationColor];
    cv::cvtColor(mat , mat , CV_RGBA2RGB);  // Drop alpha channel.
    featuresFinder(mat, _features);
  }
  return self;
}

- (double_t)calculateSimilarityWtihOtherImage:(NZImage *)other {
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
  NSMutableArray *_baseImages;  // Of NZImage.
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _baseImages = [NSMutableArray array];
  }
  return self;
}

- (void)addBaseImage:(UIImage *)image {
  NZImage *nzImage = [[NZImage alloc] initWithImage:image];
  [_baseImages addObject:nzImage];
}

- (NSArray *)getSimilarImages:(UIImage *)image {
  NZImage *nzImage = [[NZImage alloc] initWithImage:image];
  for (NZImage *baseImage : _baseImages) {
    double_t similarity = [baseImage calculateSimilarityWtihOtherImage:nzImage];
    baseImage.similarity = similarity;
  }
  NSSortDescriptor *similaritySortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"self.similarity" ascending:NO];
  NSArray *sortedImages =
      [_baseImages sortedArrayUsingDescriptors:@[similaritySortDescriptor]];
  NSMutableArray *similarImages = [NSMutableArray array];
  for (NZImage *baseImage in sortedImages) {
    if (baseImage.similarity <= 0) {
      continue;
    }
    [similarImages addObject:baseImage.image];
  }
  return similarImages;
}

@end
