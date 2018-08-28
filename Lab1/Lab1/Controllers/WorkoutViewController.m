//
//  WorkoutViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutViewController.h"
#import "NewWorkoutViewController.h"
#import "WorkoutModel.h"
#import "Workout+CoreDataClass.h"

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
    [self.model populateWithSampleData];
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
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
    
    
    BOOL isNew = [[segue destinationViewController] isKindOfClass:[NewWorkoutViewController class]];
    
    // create a new workout
    if(isNew){
        
    }
    // show info about old workout
    else {
//        UITableViewCell* cell = (UITableViewCell*)sender;
//        NewWorkoutViewController *vc = [segue destinationViewController];
    }
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
