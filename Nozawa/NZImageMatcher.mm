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

    // (_grid_size=Size(3,1), nfeatures=1500, scaleFactor=1.3f, nlevels=5)
    detail::OrbFeaturesFinder featuresFinder(cv::Size(3,1), 1500, 1.3f, 5);
    cv::Mat mat = [image cvMatRepresentationColor];
    //cv::Mat mat = [image cvMatRepresentationGray];
    cv::cvtColor(mat , mat , CV_RGBA2RGB);  // Drop alpha channel.
    featuresFinder(mat, _features);
  }
  return self;
}

- (double_t)calculateSimilarityWtihOtherImage:(ImageResult *)other {
  // (try_use_gpu=false, match_conf=0.3f, num_matches_thresh1=6, num_matches_thresh2=6)
  detail::BestOf2NearestMatcher featuresMatcher(true, 0.3f, 6, 6);
  detail::MatchesInfo matchesInfo;  
  featuresMatcher(self.features, other.features, matchesInfo);
  double_t confidence1 = matchesInfo.confidence;
  featuresMatcher(other.features, self.features, matchesInfo);
  double_t confidence2 = matchesInfo.confidence;
  return MAX(confidence1, confidence2);
}

- (BOOL)hasKeyPoints {
  return !_features.keypoints.empty();
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
  if (imageResult.hasKeyPoints) {
    [_baseImages addObject:imageResult];
  }
}

- (NSArray *)getSimilarImages:(UIImage *)image {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:nil];
  if (!imageResult.hasKeyPoints) {
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

+ (UIImage *)drawKeypoints:(UIImage *)image {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:nil];
  if (!imageResult.hasKeyPoints) {
    return image;
  }
  cv::Mat imageMat = [image cvMatRepresentationColor];
  cv::Mat outMat(imageMat.rows, imageMat.cols, imageMat.type());
  for (auto k : imageResult.features.keypoints) {
      cv::circle(outMat, k.pt, 3, cv::Scalar(0, 255, 0));
  }
  return [UIImage imageFromCVMat: outMat];
}

@end
