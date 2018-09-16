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
        // Blackman window appears to handle noise better than Hann (default)
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE andWindow:WindowTypeBlackman];
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

-(void)getDataStream:(float*)destinationArray {
    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    float *arrayData = self.arrayData;
    for (int i = 0; i < BUFFER_SIZE; i++) {
        destinationArray[i] = arrayData[i];
    }
}

-(void)getMagnitudeStream:(float*)destinationArray {
//    // take forward FFT
//    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
//    [self.fftHelper performForwardFFTWithData:self.arrayData
//                   andCopydBMagnitudeToBuffer:self.fftMagnitude];
    [self takeFft];
    for (int i = 0; i < BUFFER_SIZE/2; i++) {
        destinationArray[i] = self.fftMagnitude[i];
    }
}

-(void)takeFft {
    // take forward FFT
//    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    [self.fftHelper performForwardFFTWithData:self.arrayData
                   andCopydBMagnitudeToBuffer:self.fftMagnitude];
}

-(void)printFloatArr:(float*) arr withSize:(int)size {
    for (int i = 0; i < size; i++)
        NSLog(@"pos %i: %f", i, arr[i]);
}

-(NSArray *)getTwoFreqHighestMagnitude {
    int windowSize = 6; //6Hz
    int numWindows = BUFFER_SIZE/2/windowSize;
    float *maxPerWindow = malloc(sizeof(float)*numWindows);

    for (int i = 0; i < numWindows; i++) {
        float maxForWindow = self.fftMagnitude[i * windowSize];
        for (int j = 1; j < windowSize; j++) {
            if (self.fftMagnitude[i * windowSize + j] > maxForWindow) {
                maxForWindow = self.fftMagnitude[i * windowSize + j];
            }
        }
        maxPerWindow[i] = maxForWindow;
    }
    
    float maxMag1 = 0.0, maxMag2 = 0.0;
    size_t maxIndex1 = 0, maxIndex2 = 0;
    vDSP_maxvi(maxPerWindow, 1, &maxMag1, &maxIndex1, numWindows);
    maxPerWindow[maxIndex1] = -10;
    vDSP_maxvi(maxPerWindow, 1, &maxMag2, &maxIndex2, numWindows);
    
    float convertIndexToFreq = windowSize * self.audioManager.samplingRate / (BUFFER_SIZE);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:[NSNumber numberWithFloat:maxIndex1 * convertIndexToFreq]];
    [result addObject:[NSNumber numberWithFloat:maxIndex2 * convertIndexToFreq]];
    
    free(maxPerWindow);
    return result;
}

-(void)getSlopeOfArray:(float *)src srcSize:(size_t)size withDest:(float*)dest {
    for (size_t i = 0; i < size - 1; i++) {
        dest[i] = src[i + 1] - src[i];
    }
    dest[size - 1] = 0;
}

-(float *)getSqFft {
    float *sq = malloc(sizeof(float)*BUFFER_SIZE/2);
//    [self takeFft];
    vDSP_vsq(self.fftMagnitude, 1, sq, 1, BUFFER_SIZE/2);
    return sq;
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
