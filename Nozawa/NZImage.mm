//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImage.h"
#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>
#include <opencv2/stitching/detail/matchers.hpp>

using namespace cv;
using namespace std;

static cv::Mat vstack(const std::vector<cv::Mat> &mats) {
  if (mats.empty()) {
    return cv::Mat();
  }

  int nRows = 0;
  int nCols = mats.front().cols;
  int datatype = mats.front().type();
  std::vector<cv::Mat>::const_iterator it;
  for (it = mats.begin(); it != mats.end(); ++it) {
    nRows += it->rows;
  }

  int startRow = 0;
  int endRow = 0;
  cv::Mat stacked(nRows, nCols, datatype);
  for (it = mats.begin(); it != mats.end(); ++it) {
    if (it->rows == 0) {
      continue;
    }

    CV_Assert(it->cols == nCols);
    CV_Assert(it->type() == datatype);

    startRow = endRow;
    endRow = startRow + it->rows;
    cv::Mat mat = stacked.rowRange(startRow, endRow);
    it->copyTo(mat);
  }
  return stacked;
}

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
  Ptr<cv::FeatureDetector> _featureDetector;
  Ptr<cv::detail::FeaturesMatcher> _featuresMatcher;
  UIImage *_previousImage;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _imapArray = [NSMutableArray array];
    _r = 0;
    _featureDetector = cv::ORB::create();
  }
  return self;
}

- (void)addImage:(UIImage *)image
       imageName:(NSString *)name {
  cv:Mat imageMat = [image cvMatRepresentationColor];
  cv::cvtColor(imageMat , imageMat , CV_RGBA2RGB);  // Drop alpha channel.
  std:vector<cv::KeyPoint> keypoints;
  cv::Mat descriptor;
  _featureDetector->detectAndCompute(imageMat, noArray(), keypoints, descriptor);
  
  ImapObject *imapObject = [[ImapObject alloc] init];
  imapObject.indexStart = self.r;
  //imapObject.indexEnd = self.r + descripor. - 1, FIXME
  imapObject.name = name;
  imapObject.image = image;
  [_imapArray addObject:imapObject];

  _descArray.push_back(descriptor);
}

- (UIImage *) drawKeypoints:(UIImage *)image {
  cv:Mat imageMat = [image cvMatRepresentationColor];
  cv::cvtColor(imageMat , imageMat , CV_RGBA2RGB);  // Drop alpha channel.

  std:vector<cv::KeyPoint> keypoints;
  cv::Mat descriptor;
  _featureDetector->detectAndCompute(imageMat, noArray(), keypoints, descriptor);

  if (keypoints.empty()) {
    return nil;
  }

  cv::Mat outMat;
  cv::drawKeypoints(imageMat, keypoints, outMat);
  return [UIImage imageFromCVMat: outMat];
}

- (void)match:(UIImage *)image
    imageName:(NSString *)name {
  cv:Mat imageMat = [image cvMatRepresentationColor];
  sstd:vector<cv::KeyPoint> keypoints;
  cv::Mat descriptor;
  _featureDetector->detectAndCompute(imageMat, noArray(), keypoints, descriptor);
  
  cv::Mat imgDb =vstack(self.descArray);
}

- (void)addImage:(UIImage *)image {
  _previousImage = image;
}

- (double)calculateMatch:(UIImage *)image {
  if (!_previousImage) {
    return 0;
  }
  
  Mat imageMat1 = [_previousImage cvMatRepresentationColor];
  Mat imageMat2 = [image cvMatRepresentationColor];
  
  
  detail::ImageFeatures features1;
  detail::ImageFeatures features2;
  detail::MatchesInfo matchesInfo;
  
  detail::OrbFeaturesFinder featuresFinder;
  featuresFinder(imageMat1, features1);
  featuresFinder(imageMat2, features2);
  
  detail::BestOf2NearestMatcher featuresMatcher;
  featuresMatcher(features1, features2, matchesInfo);
  
  double confidence = matchesInfo.confidence;
  return confidence;
}

@end
