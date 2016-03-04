//  Copyright © 2016 Straylight. All rights reserved.

#include "OpenCVClient.h"

#include "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;


@implementation OpenCVClient : NSObject

+ (UIImage*)grayscaleImage:(UIImage*)image {
    cv:Mat mat = [image cvMatRepresentationColor];

    // Grayscale the image.
    cv::cvtColor(mat, mat, CV_BGR2GRAY);

    return [UIImage imageFromCVMat: mat];
}

@end