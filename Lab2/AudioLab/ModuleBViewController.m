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
    [self.model setOutputTone:15];
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
}

- (void)scheduleUpdate {
//    __block ModuleBViewController * __weak  weakSelf = self;
    [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateLabels) userInfo:nil repeats:true];
}

- (void)updateLabels {
    [self.model updateBuffer];
    
    NSArray *maxes = [self.model getTwoFreqHighestMagnitude];
    self.inHertzLabel.text = [NSString stringWithFormat:@"%ld Hz", [maxes[0] integerValue]];
    self.decibelLabel.text = [NSString stringWithFormat:@"%ld dB", [maxes[2] integerValue]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
