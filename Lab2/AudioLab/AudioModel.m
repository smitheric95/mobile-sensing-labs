//
//  AudioModel.m
//  AudioLab
//
//  Created by Eric Smith on 9/12/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "AudioModel.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"

#define BUFFER_SIZE 2048*4

@interface AudioModel ()
@property (strong, nonatomic) AudioModel *singleton;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (nonatomic) int bufferSize;
@property (nonatomic) float* arrayData;
@property (nonatomic) float* fftMagnitude;
@end

@implementation AudioModel
@synthesize singleton = _singleton;
@synthesize bufferSize = _bufferSize;

+ (AudioModel *)sharedManager {
    NSLog(@"Allocating shared model");
    static AudioModel *sharedAudioModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAudioModel = [[self alloc] initOnce];
    });
    
    return sharedAudioModel;
}

- (AudioModel *)initOnce {
    if (!_singleton) {
        _singleton = [[AudioModel alloc] init];
    }
    return _singleton;
}

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}


-(int)getBufferSize {
    return BUFFER_SIZE;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}
-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}

-(float*)arrayData {
    if (!_arrayData) {
        _arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    }
    return _arrayData;
}

-(float*)fftMagnitude {
    if (!_fftMagnitude) {
        _fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    }
    return _fftMagnitude;
}

-(void)dealloc {
    free(self.arrayData);
    free(self.fftMagnitude);
}

-(float*)getDataStream {
    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    
    return self.arrayData;
}

-(float*)getMagnitudeStream:(float*)arrayData {
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:self.fftMagnitude];
    return self.fftMagnitude;
}

-(void)startRecordingAudio {
    // initialize buffer
    __block AudioModel * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    [self.audioManager play];
}
@end
