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
    self.title = self.workout.name;
//    self.exercises = [self.model.]
//    for (Exercise* exercise in [self.model getSetsForWorkout:curWorkout]) {
//        NSLog(exercise);
//    }
}

// populates each cell with workout info
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellTableIdentifier = @"WorkoutDetailCell";
    
    WorkoutDetailTableViewCell *cell = (WorkoutDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WorkoutDetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
//    cell.exerciseTitleLabel.text = [tableData objectAtIndex:indexPath.row];
    
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
