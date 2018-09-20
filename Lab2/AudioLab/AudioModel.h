//
//  AudioModel.h
//  AudioLab
//
//  Created by Eric Smith on 9/12/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

enum UserMotion {NO_MOTION, TOWARD, AWAY};

@interface AudioModel : NSObject
+ (AudioModel *)sharedManager;
-(int)getBufferSize;
-(void)getDataStream:(float*)destinationArray;
-(void)startRecordingAudio;
-(void)getMagnitudeStream:(float*)destinationArray;
-(NSArray *)getTwoFreqHighestMagnitude;
-(void)playAudio;
-(void)pauseAudio;
-(void)setOutputTone:(int)freq;
-(NSArray *)getPeakInFreqRange;
-(enum UserMotion)getCurrentUserMotion;
@end
