//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeHeart.h"

#import "AVFoundation/AVFoundation.h"


using namespace cv;

@interface OpenCVBridgeHeart()
@property (nonatomic) cv::Mat image;
@end

@implementation OpenCVBridgeHeart
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).

-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2RGB); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"WOOOOOOOOOOOOOo", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(0, 10), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
    self.image = image;
}

@end
