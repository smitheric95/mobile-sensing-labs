//
//  WorkoutViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutViewController.h"
#import "NewWorkoutViewController.h"
#import "WorkoutDetailViewController.h"
#import "WorkoutModel.h"

@interface WorkoutViewController ()
@property (strong, nonatomic) WorkoutModel *model;
@end

@implementation WorkoutViewController

- (WorkoutModel *)model {
    if (!_model)
        _model = [WorkoutModel sharedManager];
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"View did load");
    [self.model populateWithSampleData];
    id workout = self.model.workouts[0];
    id sets = [self.model getSetsForWorkout:workout];
    NSLog(@"Sets: %@", sets);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.model.workouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Workout *curWorkout = self.model.workouts[indexPath.row];
    cell.textLabel.text = curWorkout.name;
    cell.detailTextLabel.text = @"More";
    cell.tag = indexPath.row; // save row number in cell
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    BOOL isNotNew = [[segue destinationViewController] isKindOfClass:[WorkoutDetailViewController class]];
    
    // show detail of workout
    if(isNotNew){
        UITableViewCell* cell = (UITableViewCell*)sender;
        WorkoutDetailViewController *vc = [segue destinationViewController];
        
        vc.title = cell.textLabel.text;
        vc.workout = self.model.workouts[cell.tag];
    }
}


@end
