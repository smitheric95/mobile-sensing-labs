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
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
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
    
    // calculate time
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE, MMM d"];
    
    NSString* newLabel = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:self.workout.startTime]];
    
    NSString* timeDifference = [self remainingTime:self.workout.startTime endDate:self.workout.endTime];
    
    newLabel = [newLabel stringByAppendingString:@" - "];
    newLabel = [newLabel stringByAppendingString:timeDifference];
    
    self.dateLabel.text = newLabel;
}

- (IBAction)markAsFavorite:(id)sender {
    UISwitch *switchInCell = (UISwitch *)sender;
    
    UITableViewCell* cell = switchInCell.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ((Exercise*)self.exercises[indexPath.row]).isFavorite = true;
    NSLog(@"%ld", (long)indexPath.row);
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
    
    // set each element of the cell
    Exercise* curExercise = (Exercise*)self.exercises[indexPath.row];
    cell.exerciseTitleLabel.text = curExercise.name;
    
    // get sets
    NSArray* sets = [self.model getSetsForWorkoutAndExercise:self.workout withExercise:curExercise];
    NSLog(@"Sets for exercie and workout: %@", sets);
    NSLog(@"Exercises with name :%@", [self.model getExerciseWithName:curExercise.name]);
    cell.setsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)sets.count];
    
    // append reps to repsLabel
    if (sets.count > 0) {
        NSString* newLabel = @"";
        
        for (int i = 0; i < sets.count; i++) {
            newLabel = [newLabel stringByAppendingString:[NSString stringWithFormat:@"%lld ", ((Set*)sets[i]).reps]];
        }
        cell.repsLabel.text = newLabel;
    }
    else {
        cell.repsLabel.text = @"None";
    }
    
    // append weight to weightLabel
    if (sets.count > 0) {
        NSString* newLabel = @"";
        
        for (int i = 0; i < sets.count; i++) {
            newLabel = [newLabel stringByAppendingString:[NSString stringWithFormat:@"%.f ", ((Set*)sets[i]).weight]];
        }
        cell.weightLabel.text = newLabel;
    }
    else {
        cell.weightLabel.text = @"None";
    }
    
    // set favorite switch
    [cell.isFavorite setOn: curExercise.isFavorite];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// source: https://stackoverflow.com/a/32648869/8853372
-(NSString*)remainingTime:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSDateComponents *components;
    NSInteger days;
    NSInteger hour;
    NSInteger minutes;
    NSString *durationString;
    
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate: startDate toDate: endDate options: 0];
    
    days = [components day];
    hour = [components hour];
    minutes = [components minute];
    
    if(days>0)
    {
        if(days>1)
            durationString=[NSString stringWithFormat:@"%d days",days];
        else
            durationString=[NSString stringWithFormat:@"%d day",days];
        return durationString;
    }
    if(hour>0)
    {
        if(hour>1)
            durationString=[NSString stringWithFormat:@"%d hours",hour];
        else
            durationString=[NSString stringWithFormat:@"%d hour",hour];
        return durationString;
    }
    if(minutes>0)
    {
        if(minutes>1)
            durationString = [NSString stringWithFormat:@"%d minutes",minutes];
        else
            durationString = [NSString stringWithFormat:@"%d minute",minutes];
        
        return durationString;
    }
    return @"";
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
