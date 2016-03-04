#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif


@interface UIImage (OpenCV)

+ (UIImage *)imageFromCVMat:(cv::Mat)mat;

- (cv::Mat)cvMatRepresentationColor;
- (cv::Mat)cvMatRepresentationGray;

@end