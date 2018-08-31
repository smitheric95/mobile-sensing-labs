//
//  WorkoutDetailViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutDetailViewController.h"
#import "WorkoutModel.h"

@interface WorkoutDetailViewController ()
@property (strong, nonatomic) WorkoutModel *model;

@end

@implementation WorkoutDetailViewController

- (WorkoutModel *)model {
    if (!_model)
        _model = [WorkoutModel sharedManager];
    return _model;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Workout* curWorkout = (Workout*)self.workout;
    self.title = curWorkout.name;
    
    for (Exercise* exercise in [self.model getSetsForWorkout:curWorkout]) {
        NSLog(exercise);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
