//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImageMatcher.h"
#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>
#include <opencv2/stitching/detail/matchers.hpp>

using namespace cv;
using namespace std;

const double kMaxImageSize = 400;

void rotate(cv::Mat& src, double angle, cv::Mat& dst) {
  int len = std::max(src.cols, src.rows);
  cv::Point2f pt(len/2., len/2.);
  cv::Mat r = cv::getRotationMatrix2D(pt, angle, 1.0);
  
  cv::warpAffine(src, dst, r, cv::Size(len, len));
}

void cropMat(cv::Mat& src, cv::Mat& dst) {
  cv::Rect roi(src.cols/4., src.rows/4., src.cols/2., src.rows/2.);
  cv::Mat cropped(src, roi);
  cropped.copyTo(dst);
}

@interface ImageResult()
@property cv::Mat imageMat;
@property detail::ImageFeatures features;
@property detail::MatchesInfo matchesInfo;
@end

@interface Ticker: NSObject
@end

@implementation Ticker {
    NSDate* startDate;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        startDate = [NSDate date];
    }
    return self;
}

- (void)tick:(NSString *)label {
    NSTimeInterval interval = [startDate timeIntervalSinceNow];
    NSLog(@"%@: %f", label, interval);
}

@end

@implementation ImageResult

- (instancetype)initWithImage:(UIImage *)image
                         name:(NSString *)name
                         crop:(BOOL)crop {
  self = [super init];
  if (self) {
    _image = image;
    _name = name;

    // (_grid_size=Size(3,1), nfeatures=1500, scaleFactor=1.3f, nlevels=5)
    detail::OrbFeaturesFinder featuresFinder(cv::Size(3,1), 1500, 1.3f, 5);
    cv::Mat imageMat = [image cvMatRepresentationColor];

    double colScale = kMaxImageSize / imageMat.cols;
    double rowScale = kMaxImageSize / imageMat.rows;
    double colRowScale = min(colScale, rowScale);
    if (colRowScale < 1.0) {
      cv::resize(imageMat, imageMat, cv::Size(), colRowScale, colRowScale);
    }

    if (crop) {
      cropMat(imageMat, _imageMat);
    } else if (image.imageOrientation == UIImageOrientationRight) {
      rotate(imageMat, -90.f,_imageMat);
    } else {
      _imageMat = imageMat;
    }

    //cv::Mat mat = [image cvMatRepresentationGray];
    cv::cvtColor(_imageMat, _imageMat, CV_RGBA2RGB);  // Drop alpha channel.
    featuresFinder(_imageMat, _features);
  }
  return self;
}

- (double_t)calculateSimilarityWtihOtherImage:(ImageResult *)other {
  // (try_use_gpu=false, match_conf=0.3f, num_matches_thresh1=6, num_matches_thresh2=6)
  detail::BestOf2NearestMatcher featuresMatcher(true, 0.3f, 10, 10);
  detail::MatchesInfo matchesInfo;  
  featuresMatcher(self.features, other.features, matchesInfo);
  _matchesInfo = matchesInfo;
  double_t confidence1 = matchesInfo.confidence;
  featuresMatcher(other.features, self.features, matchesInfo);
  double_t confidence2 = matchesInfo.confidence;
                  
  return MAX(confidence1, confidence2);
}

- (void)drawDebugMatchingImage:(ImageResult *)other {
  if (_matchesInfo.matches.empty()) {
    return;
  }
  cv::Mat debugImageMat;
  cv::drawMatches(self.imageMat, self.features.keypoints,
                  other.imageMat, other.features.keypoints, _matchesInfo.matches, debugImageMat);
  _debugImage = [UIImage imageFromCVMat:debugImageMat];
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
            name:(NSString *)name
            crop:(BOOL)crop {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:name crop:crop];
  if (imageResult.hasKeyPoints) {
    [_baseImages addObject:imageResult];
  }
}

- (NSArray *)getSimilarImages:(UIImage *)image
                         crop:(BOOL)crop {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:nil crop:crop];
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
    [baseImage drawDebugMatchingImage:imageResult];
    [similarImages addObject:baseImage];
  }
  return similarImages;
}

+ (UIImage *)drawKeypoints:(UIImage *)image {
  ImageResult *imageResult =
      [[ImageResult alloc] initWithImage:image name:nil crop:NO];
  if (!imageResult.hasKeyPoints) {
    return image;
  }
  cv::Mat srcMat = imageResult.imageMat;
  cv::Mat outMat(srcMat.rows, srcMat.cols, CV_8UC4);
  for (auto k : imageResult.features.keypoints) {
      cv::circle(outMat, k.pt, 3, cv::Scalar(0, 255, 0, 255));
  }
  return [UIImage imageFromCVMat: outMat];
}

@end
