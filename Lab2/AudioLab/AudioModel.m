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
@property (nonatomic) int outputFreq;
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

-(void)playAudio {
    __block float phase = 0.0;
    double frequency = self.outputFreq * 1000;
    double phaseIncrement = 2*M_PI*frequency/self.audioManager.samplingRate;
    double sineWaveRepeatMax = 2*M_PI;
    
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         for (int i=0; i < numFrames; ++i)
         {
             data[i] = sin(phase);
             
             phase += phaseIncrement;
             if (phase >= sineWaveRepeatMax) phase -= sineWaveRepeatMax;
             
         }
     }];
    
    [self.audioManager play];
}

-(void)pauseAudio {
    [self.audioManager setOutputBlock:nil];
}

-(void)setOutputTone:(int)freq {
    self.outputFreq = freq;
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

-(void)updateBuffer {
    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    [self takeFft];
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
    
    // add max frequencies
    [result addObject:[NSNumber numberWithFloat:maxIndex1 * convertIndexToFreq]];
    [result addObject:[NSNumber numberWithFloat:maxIndex2 * convertIndexToFreq]];
    
    // add max magnitudes
    [result addObject:[NSNumber numberWithFloat:maxMag1]];
    [result addObject:[NSNumber numberWithFloat:maxMag2]];
    
    free(maxPerWindow);
    return result;
}

-(NSArray *)getPeakInFreqRange:(float)leftFreqBound withRightBound:(float)rightFreqBound withDelta:(float)delta {
    return [self getPeakInFreqRangeOnArray:leftFreqBound withRightBound:rightFreqBound withDelta:delta onArray:self.fftMagnitude];
}

-(NSArray *)getPeakInFreqRangeOnArray:(float)leftFreqBound withRightBound:(float)rightFreqBound withDelta:(float)delta onArray:(float *)array {
    float convertIndexToFreq = self.audioManager.samplingRate / (BUFFER_SIZE);
    size_t leftIndex = (leftFreqBound - delta) / convertIndexToFreq;
    size_t rightIndex = (rightFreqBound + delta) / convertIndexToFreq;
    
    float maxMag;
    size_t maxIndex;
    
    vDSP_maxvi(array + leftIndex, 1, &maxMag, &maxIndex, rightIndex - leftIndex);
//    NSLog(@"index: %u", maxIndex);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:[NSNumber numberWithFloat:maxIndex * convertIndexToFreq + leftFreqBound - delta]];
    [result addObject:[NSNumber numberWithFloat:maxMag]];
    [result addObject:[NSNumber numberWithLong:maxIndex]];
    
    return result;
}

-(enum UserMotion)getUserMotion:(float)leftFreqBound withRightBound:(float)rightFreqBound withDelta:(float)delta {
    float convertIndexToFreq = self.audioManager.samplingRate / (BUFFER_SIZE);
    size_t leftIndex = (leftFreqBound - delta) / convertIndexToFreq;
    size_t rightIndex = (rightFreqBound + delta) / convertIndexToFreq;
    
    float *fftMagCopy = malloc(sizeof(float) * BUFFER_SIZE / 2);
    [self getMagnitudeStream:fftMagCopy];
    
    NSArray *maxInRange = [self getPeakInFreqRangeOnArray:leftFreqBound withRightBound:rightFreqBound withDelta:delta onArray:fftMagCopy];
    
    float mean, std = 0.0;
    vDSP_meanv(fftMagCopy, 1, &mean, BUFFER_SIZE / 2);
    for (int i = 0; i < rightIndex - leftIndex; i++) {
        float val = (fftMagCopy + leftIndex)[i] - mean;
        std += val * val;
    }
    std /= rightIndex - leftIndex;
    std = sqrtf(std);
    
    int range = 20;
    
    int numInLeft = [self getNumSamplesAboveMeanInArray:fftMagCopy + [maxInRange[2] integerValue] - range withLength:range withMean:mean andStd:std];
    int numInRight = [self getNumSamplesAboveMeanInArray:fftMagCopy + [maxInRange[2] integerValue] + range withLength:range withMean:mean andStd:std];
    
//    for (int i = -6; i <= 6; i++) {
//        fftMagCopy[[maxInRange[2] integerValue] + i] = -10;
//    }
//    NSArray *maxInFilteredRange = [self getPeakInFreqRangeOnArray:leftFreqBound withRightBound:rightFreqBound withDelta:delta onArray:fftMagCopy];

    free(fftMagCopy);
    
    int diff = numInRight - numInLeft;
    int allowedDiff = 6;
    
    if (diff > 0 && abs(diff) < allowedDiff) {
        return TOWARD;
    }
    else if (diff < 0 && abs(diff) < allowedDiff) {
        return AWAY;
    }
    return NO_MOTION;
}

-(int)getNumSamplesAboveMeanInArray:(float *)array withLength:(int)size withMean:(float)mean andStd:(float)std {
    int result = 0;
    for (int i = 0; i < size; i++) {
        if (array[i] > mean + std) {
            result++;
        }
    }
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
