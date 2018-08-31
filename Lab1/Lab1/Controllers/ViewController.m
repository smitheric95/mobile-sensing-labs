//
//  ViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/25/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "ViewController.h"
#import "WorkoutModel.h"

@interface ViewController ()
@property (strong, nonatomic) WorkoutModel *model;

@end

@implementation ViewController

- (WorkoutModel *)model {
    if (!_model)
        _model = [WorkoutModel sharedManager];
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"View did load");
    [self.model populateWithSampleData];
    Workout *workout = self.model.workouts[0];
    NSArray *sets = [self.model getExercisesForWorkout:workout];
    NSLog(@"Exercises: %@", sets);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
