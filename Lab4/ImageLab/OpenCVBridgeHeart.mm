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
@property (atomic) NSMutableArray *redValues;
@property (strong, nonatomic) dispatch_queue_t heartRateQueue;
@end

@implementation OpenCVBridgeHeart
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).
//@synthesize heartRateQueue = _heartRateQueue;

-(int)bufferLen {
    return 120;
}

-(NSMutableArray*)redValues {
    if(!_redValues)
        _redValues = [[NSMutableArray alloc] init];
    return _redValues;
}

-(dispatch_queue_t)heartRateQueue {
    if(!_heartRateQueue)
        _heartRateQueue = dispatch_queue_create("heartRateQueue", DISPATCH_QUEUE_SERIAL);
    return _heartRateQueue;
}

-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2RGB); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    if (avgPixelIntensity.val[2] > 128.0) {
        dispatch_async(self.heartRateQueue, ^{
            [self checkForHeartBeat:avgPixelIntensity.val[2]];
        });
    }
    
    self.image = image;
}

-(void)checkForHeartBeat:(double)newRedVal {
//    NSLog(@"num: %d redness: %f", self.redValues.count, newRedVal);
    [self.redValues addObject:[NSNumber numberWithDouble:newRedVal]];
    if (self.redValues.count > self.bufferLen + 30) {
        self.heartRate = [self findHeartRate];
        [self.redValues removeObjectsInRange:NSMakeRange(0, 30)];
    }
}

-(int)findHeartRate {
    NSMutableArray *maxForWindows = [[NSMutableArray alloc] init];
    NSMutableArray *minForWindows = [[NSMutableArray alloc] init];
    int windowSize = 12;
    for (int i = 0; i < self.redValues.count - windowSize; i++) {
        NSNumber *max = self.redValues[i];
        NSNumber *min = self.redValues[i];
        for (int j = 1; j < windowSize; j++) {
            if (max < self.redValues[i+j])
                max = self.redValues[i+j];
            if (min > self.redValues[i+j])
                min = self.redValues[i+j];
        }
        [maxForWindows addObject:max];
        [minForWindows addObject:min];
    }
    
    NSMutableArray *peaks = [[NSMutableArray alloc] init];
    NSMutableArray *troughs = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.redValues.count - windowSize; i++) {
        if (self.redValues[i] == maxForWindows[i])
            [peaks addObject:@(i)];
        if (self.redValues[i] == minForWindows[i])
            [troughs addObject:@(i)];
    }
    
    float count = (peaks.count + troughs.count) / 2.0;
    return count / (self.redValues.count / 30) * 30;
}

-(NSArray*)copyBuffer {
    return [[NSArray alloc] initWithArray:self.redValues copyItems:true];
}

-(bool)hasFilledBuffer {
    return self.redValues.count >= self.bufferLen;
}

@end
