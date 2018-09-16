//
//  ModuleBViewController.m
//  AudioLab
//
//  Created by Eric Smith on 9/15/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ModuleBViewController.h"

@interface ModuleBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *motionLabel;
@property (weak, nonatomic) IBOutlet UILabel *decibelLabel;
@property (weak, nonatomic) IBOutlet UILabel *inHertzLabel;
@property (weak, nonatomic) IBOutlet UILabel *outHertzLabel;

@end

@implementation ModuleBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sliderMoved:(UISlider *)sender {
    self.outHertzLabel.text = [NSString stringWithFormat:@"out:   %d kHZ", (int)sender.value];
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
