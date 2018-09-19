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
#define CONVERT_FACTOR 5.3833

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

-(float)quadApprox:(int)i2 {
    int i1 = i2 - 1;
    int i3 = i2 + 1;
    
    float f1 = i1 * CONVERT_FACTOR;
    float f2 = i2 * CONVERT_FACTOR;
    float f3 = i3 * CONVERT_FACTOR;
    
    float m1 = self.fftMagnitude[i1];
    float m2 = self.fftMagnitude[i2];
    float m3 = self.fftMagnitude[i3];
    
    return f2 + (((m3 - m2) / ((2*m2) - m1 - m2)) * (f3 - f1)/2);
}

-(NSArray *)getTwoFreqHighestMagnitude {
    int windowSize = 50;
    int numWindows = ((BUFFER_SIZE/2) - windowSize);
    float *maxPerWindow = malloc(sizeof(float)*numWindows);

    vDSP_vswmax(self.fftMagnitude, 1, maxPerWindow, 1, numWindows, windowSize);
    
    NSMutableArray *peaks = [[NSMutableArray alloc] init];
    
    // collect peaks
    for (int i = 0; i < numWindows; i++) {
        if (maxPerWindow[i] == self.fftMagnitude[i]) {
            [peaks addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    // find two largest peaks
    int maxIndex1 = 0, maxIndex2 = 0;
    for (int i = 0; i < peaks.count; i++) {
        if (self.fftMagnitude[[peaks[i] intValue]] > self.fftMagnitude[maxIndex1]) {
            maxIndex2 = maxIndex1;
            maxIndex1 = [peaks[i] intValue];
        }
        else if (self.fftMagnitude[[peaks[i] intValue]] > self.fftMagnitude[maxIndex2]) {
            maxIndex2 = [peaks[i] intValue];
        }
    }
    
    
    float maxFreq1 = [self quadApprox:maxIndex1] - (windowSize/2);
    float maxFreq2 = [self quadApprox:maxIndex2] - (windowSize/2);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // add max frequencies
    if (maxFreq1 > maxFreq2){
        [result addObject:[NSNumber numberWithFloat:maxFreq1]];
        [result addObject:[NSNumber numberWithFloat:maxFreq2]];
    }
    else {
        [result addObject:[NSNumber numberWithFloat:maxFreq2]];
        [result addObject:[NSNumber numberWithFloat:maxFreq1]];
    }
    
    free(maxPerWindow);
    return result;
}

-(NSArray *)getPeakInFreqRange:(float)leftFreqBound withRightBound:(float)rightFreqBound withDelta:(float)delta {
    float convertIndexToFreq = self.audioManager.samplingRate / (BUFFER_SIZE);
    size_t leftIndex = (leftFreqBound - delta) / convertIndexToFreq;
    size_t rightIndex = (rightFreqBound + delta) / convertIndexToFreq;
    
    float maxMag;
    size_t maxIndex;
    
    vDSP_maxvi(self.fftMagnitude + leftIndex, 1, &maxMag, &maxIndex, rightIndex - leftIndex);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:[NSNumber numberWithFloat:maxIndex * convertIndexToFreq + leftFreqBound - delta]];
    [result addObject:[NSNumber numberWithFloat:maxMag]];
    
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
