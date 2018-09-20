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
#define LEFT_FREQ_BOUND 15000.0
#define RIGHT_FREQ_BOUND 20000.0
#define FREQ_DELTA 500.0

@interface AudioModel ()
@property (strong, nonatomic) AudioModel *singleton;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (nonatomic) int bufferSize;
@property (nonatomic) float* arrayData;
@property (nonatomic) float* fftMagnitude;
@property (nonatomic) int outputFreq;
@property (nonatomic) BOOL shouldScheduleDopplerDetection;
@property (nonatomic) enum UserMotion currentUserMotion;
@property (nonatomic) NSArray *highestPeakInRangeArray;
@end

@implementation AudioModel
@synthesize singleton = _singleton;
@synthesize bufferSize = _bufferSize;
@synthesize highestPeakInRangeArray = _highestPeakInRangeArray;

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

-(NSArray*)highestPeakInRangeArray {
    if(!_highestPeakInRangeArray){
        _highestPeakInRangeArray = [[NSMutableArray alloc] init];
    }
    return _highestPeakInRangeArray;
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
    self.shouldScheduleDopplerDetection = true;
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
    self.shouldScheduleDopplerDetection = false;
}

-(void)setOutputTone:(int)freq {
    self.outputFreq = freq;
}

-(void)dealloc {
    free(self.arrayData);
    free(self.fftMagnitude);
}

-(void)getDataStream:(float*)destinationArray {
    for (int i = 0; i < BUFFER_SIZE; i++) {
        destinationArray[i] = self.arrayData[i];
    }
}

-(void)getMagnitudeStream:(float*)destinationArray {
    for (int i = 0; i < BUFFER_SIZE/2; i++) {
        destinationArray[i] = self.fftMagnitude[i];
    }
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
    
    return f2 + (((m3 - m2) / ((2*m2) - m1 - m2)) * (f2 - f1)/2);
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
    
    float maxFreq1 = [self quadApprox:maxIndex1];
    float maxFreq2 = [self quadApprox:maxIndex2];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // add max frequencies
    [result addObject:[NSNumber numberWithFloat:maxFreq1]];
    [result addObject:[NSNumber numberWithFloat:maxFreq2]];

    
    free(maxPerWindow);
    return result;
}

-(NSArray *)getPeakInFreqRange {
    return self.highestPeakInRangeArray;
}

-(enum UserMotion)getCurrentUserMotion {
    return self.currentUserMotion;
}

-(NSArray *)getPeakInFreqRangeOnArray:(float)leftFreqBound
                       withRightBound:(float)rightFreqBound
                            withDelta:(float)delta
                              onArray:(float *)array {
    size_t leftIndex = (leftFreqBound - delta) / CONVERT_FACTOR;
    size_t rightIndex = (rightFreqBound + delta) / CONVERT_FACTOR;
    
    float maxMag = 0.0;
    size_t maxIndex = leftIndex;
    
    vDSP_maxvi(array + leftIndex, 1, &maxMag, &maxIndex, rightIndex - leftIndex);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:[NSNumber numberWithFloat:maxIndex * CONVERT_FACTOR + leftFreqBound - delta]];
    [result addObject:[NSNumber numberWithFloat:maxMag]];
    [result addObject:[NSNumber numberWithLong:maxIndex]];
    
    return result;
}

-(enum UserMotion)getUserMotion:(float)leftFreqBound withRightBound:(float)rightFreqBound withDelta:(float)delta {
    float *fftMagCopy = malloc(sizeof(float) * BUFFER_SIZE / 2);
    [self getMagnitudeStream:fftMagCopy];
    
    NSArray *maxInRange = [self getPeakInFreqRangeOnArray:leftFreqBound
                                           withRightBound:rightFreqBound
                                                withDelta:delta
                                                  onArray:fftMagCopy];
    
    int range = 12;
    
    float leftMean, rightMean;
    vDSP_meanv(fftMagCopy + [maxInRange[2] integerValue] - range, 1, &leftMean, range);
    vDSP_meanv(fftMagCopy + [maxInRange[2] integerValue], 1, &rightMean, range);
    
    float diff = rightMean - leftMean;
    
    free(fftMagCopy);
    
    if (diff > 0 && fabs(diff) > 2) {
        return TOWARD;
    }
    else if (diff < 0 && fabs(diff) > 2) {
        return AWAY;
    }
    return NO_MOTION;
}

-(void)startRecordingAudio {
    // initialize buffer
    self.shouldScheduleDopplerDetection = false;
    self.currentUserMotion = NO_MOTION;
    __block AudioModel * __weak  weakSelf = self;
    dispatch_queue_t analysisQueue = dispatch_queue_create("analysisQueue", DISPATCH_QUEUE_SERIAL);
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
        [weakSelf scheduleFftOnQueue:analysisQueue];
        if (weakSelf.shouldScheduleDopplerDetection) {
            [weakSelf scheduleDopplerDetection:analysisQueue];
        }
    }];
    [self.audioManager play];
}

-(void)scheduleFftOnQueue:(dispatch_queue_t)queue {
    __block AudioModel * __weak  weakSelf = self;
    dispatch_async(queue, ^{
        [weakSelf.buffer fetchFreshData:weakSelf.arrayData
                         withNumSamples:BUFFER_SIZE];
        [weakSelf.fftHelper performForwardFFTWithData:weakSelf.arrayData
                           andCopydBMagnitudeToBuffer:weakSelf.fftMagnitude];
    });
}

-(void)scheduleDopplerDetection:(dispatch_queue_t)queue {
    __block AudioModel * __weak  weakSelf = self;
    dispatch_async(queue, ^{
        weakSelf.highestPeakInRangeArray = [weakSelf getPeakInFreqRangeOnArray:LEFT_FREQ_BOUND
                                                                withRightBound:RIGHT_FREQ_BOUND
                                                                     withDelta:FREQ_DELTA
                                                                       onArray:weakSelf.fftMagnitude];
        weakSelf.currentUserMotion = [weakSelf getUserMotion:LEFT_FREQ_BOUND
                                              withRightBound:RIGHT_FREQ_BOUND
                                                   withDelta:FREQ_DELTA];
    });
}

@end
