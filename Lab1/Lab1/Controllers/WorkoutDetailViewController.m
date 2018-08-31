//
//  WorkoutDetailViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutDetailViewController.h"
#import "WorkoutModel.h"
#import "WorkoutDetailTableViewCell.h"

@interface WorkoutDetailViewController ()
@property (strong, nonatomic) WorkoutModel* model;
@property (strong, nonatomic) Workout* workout;
@property (strong, nonatomic) NSArray* exercises;
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
    self.workout = self.model.workouts[self.workoutNumber];
    self.title = self.workout.name;
    self.exercises = [self.model getExercisesForWorkout:self.workout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.exercises.count;
}

// populates each cell with workout info
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellTableIdentifier = @"WorkoutDetailCell";
    
    WorkoutDetailTableViewCell *cell = (WorkoutDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WorkoutDetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Exercise* curExercise = (Exercise*)self.exercises[indexPath.row];
    cell.exerciseTitleLabel.text = curExercise.name;
    
    return cell;
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
