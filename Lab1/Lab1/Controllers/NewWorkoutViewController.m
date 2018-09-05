//
//  NewWorkoutViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "NewWorkoutViewController.h"
#import "NewWorkoutTableViewCell.h"
#import "WorkoutModel.h"

@interface NewWorkoutViewController ()
@property (strong, nonatomic) WorkoutModel* model;
@property NSInteger exerciseCount;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSDateFormatter *dateParser;
@property (strong, nonatomic) NSMutableArray* exercises;
@property (weak, nonatomic) IBOutlet UITextField *workoutTitle;
@property (strong, nonatomic) NSDate* startTime;
@property (strong, nonatomic) NSDate* endTime;
@end

@implementation NewWorkoutViewController

- (WorkoutModel *)model {
    if (!_model)
        _model = [WorkoutModel sharedManager];
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.exercises = [[NSMutableArray alloc] init];
    self.exerciseCount = 1;
    
    self.dateParser = [[NSDateFormatter alloc] init];
    self.dateParser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    // save current time
    self.startTime = [NSDate date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveWorkout:(id)sender {
    // pass the cells to the model
    self.endTime = [NSDate date];
    [self.model saveExercises:self.exercises withName:self.workoutTitle.text withStartDate:self.startTime withEndDate:self.endTime];
}

// triggers adding a cell
- (IBAction)addExercise:(id)sender {
    self.exerciseCount++;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.exerciseCount;
}

// populates each cell with a blank exercise
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellTableIdentifier = @"NewWorkoutCell";
    
    NewWorkoutTableViewCell *cell = (NewWorkoutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellTableIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // add picker data
    _pickerData = self.model.getExerciseNames;
    cell.workoutTypePicker.dataSource = self;
    cell.workoutTypePicker.delegate = self;
    
    // add the cell object to exercises
    if (![self.exercises containsObject:cell]) {
        [self.exercises addObject:cell];
    }
    
    return cell;
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
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
