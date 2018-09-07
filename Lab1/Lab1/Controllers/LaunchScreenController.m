//
//  LaunchScreenController.m
//  Lab1
//
//  Created by Jake Carlson on 9/7/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "LaunchScreenController.h"

@interface LaunchScreenController ()

@end

@implementation LaunchScreenController

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingImage.image = [UIImage imageNamed:@"gym"];

    //https://www.andrewcbancroft.com/2014/07/27/fade-in-out-animations-as-class-extensions-with-swift/
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        self.appLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.appLabel.alpha = 1;
        self.appLabel.hidden = true;
    }];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(presentTabbedView) userInfo:nil repeats:false];
}

- (void)presentTabbedView {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TabbedViewController"] animated:true completion:nil];
}

@end
