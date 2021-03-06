//
//  ModuleBViewController.m
//  AudioLab
//
//  Created by Eric Smith on 9/15/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ModuleBViewController.h"
#import "AudioModel.h"

@interface ModuleBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *motionLabel;
@property (weak, nonatomic) IBOutlet UILabel *decibelLabel;
@property (weak, nonatomic) IBOutlet UILabel *inHertzLabel;
@property (weak, nonatomic) IBOutlet UILabel *outHertzLabel;
@property (strong, nonatomic) AudioModel* model;
@property (weak, nonatomic) IBOutlet UISlider *outputHertzSlider;

@end

@implementation ModuleBViewController

- (AudioModel *)model {
    if (!_model)
        _model = [AudioModel sharedManager];
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self scheduleUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.model setOutputTone:self.outputHertzSlider.value];
    [self.model playAudio];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.model pauseAudio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sliderMoved:(UISlider *)sender {
    self.outHertzLabel.text = [NSString stringWithFormat:@"out:   %d kHz", (int)sender.value];
    [self.model setOutputTone:(int)sender.value];
    [self.model playAudio];
}

- (void)scheduleUpdate {
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateLabels) userInfo:nil repeats:true];
}

- (void)updateLabels {
    NSArray *maxes = [self.model getPeakInFreqRange];
    if (maxes.count > 0) {
        self.inHertzLabel.text = [NSString stringWithFormat:@"%ld Hz", [maxes[0] integerValue]];
        self.decibelLabel.text = [NSString stringWithFormat:@"%ld dB", [maxes[1] integerValue]];
    }
    enum UserMotion userMotion = [self.model getCurrentUserMotion];
    if (userMotion == TOWARD) {
        self.motionLabel.text = @"Toward";
    }
    else if (userMotion == AWAY) {
        self.motionLabel.text = @"Away";
    }
    else {
        self.motionLabel.text = @"No Motion";
    }
}

@end
