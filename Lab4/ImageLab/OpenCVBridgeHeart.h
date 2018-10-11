//
//  OpenCVBridgeSub.h
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridge.hh"

@interface OpenCVBridgeHeart : OpenCVBridge
@property (nonatomic) int heartRate;
@property (nonatomic) int bufferLen;

-(void)copyBuffer:(float*)target;

@end
