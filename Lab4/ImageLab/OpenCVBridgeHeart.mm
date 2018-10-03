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
    
}

@end
