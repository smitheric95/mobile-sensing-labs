//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"
#import "FFTHelper.h"
#import "AudioModel.h"

@interface ViewController ()
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) AudioModel* model;
@end


@implementation ViewController

#pragma mark Lazy Instantiation
- (AudioModel *)model {
    if (!_model)
        _model = [AudioModel sharedManager];
    return _model;
}

-(SMUGraphHelper*)graphHelper{
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:15
                                                       numGraphs:3
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:[self.model getBufferSize]];
    }
    return _graphHelper;
}

#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.graphHelper setFullScreenBounds];
    [self.model startRecordingAudio];
}

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream
    
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*[self.model getBufferSize]);
    float* fftMagnitude = malloc(sizeof(float)*[self.model getBufferSize]/2);
    [self.model getDataStream:arrayData];
    [self.model getMagnitudeStream:fftMagnitude];
    
    //send off for graphing
    [self.graphHelper setGraphData:arrayData
                    withDataLength:[self.model getBufferSize]
                     forGraphIndex:0];

    // graph the FFT Data
    [self.graphHelper setGraphData:fftMagnitude
                    withDataLength:[self.model getBufferSize]/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];
    
    // graph the two maxs
//    float *maxes = malloc(sizeof(float)*[self.model getBufferSize]/2);
//    NSArray *maxMag = [self.model getTwoFreqHighestMagnitude];
//    for (size_t i = 0; i < [self.model getBufferSize]/2; i++) {
//        maxes = 0;
//    }
//    maxes[[maxMag[0] integerValue]] = 10;
//    maxes[[maxMag[2] integerValue]] = 10;
    [self.graphHelper setGraphData:[self.model getTwoFreqHighestMagnitude]
                    withDataLength:[self.model getBufferSize]/2/6
                     forGraphIndex:2
                 withNormalization:24
                     withZeroValue:0];

    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
//    free(maxes);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

@end
