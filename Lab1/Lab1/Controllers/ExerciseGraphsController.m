//
//  ViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/25/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <Charts/Charts.h>
#import "ExerciseGraphsController.h"
#import "ExerciseGraphsCollectionViewCell.h"

@interface ExerciseGraphsController ()
@property (strong, nonatomic) WorkoutModel *model;
@property (strong, nonatomic) NSArray *exercises;
@property (weak, nonatomic) IBOutlet UISegmentedControl *graphTypeSegmentedControl;
@property (strong, nonatomic) NSMutableArray *dataToPlot;
@property (nonatomic) BOOL shouldUpdateData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ExerciseGraphsController
@synthesize collectionView = _collectionView;
@synthesize dataToPlot = _dataToPlot;

- (WorkoutModel *)model {
    if (!_model)
        _model = [WorkoutModel sharedManager];
    return _model;
}

- (NSArray *)exercises {
    if (!_exercises)
        _exercises = [self.model getExercises];
    return _exercises;
}

- (NSMutableArray *)dataToPlot {
    if (!_dataToPlot)
        _dataToPlot = [self generateData];
    if (self.shouldUpdateData) {
        _dataToPlot = [self generateData];
        self.shouldUpdateData = false;
    }
    return _dataToPlot;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"View did load");
    [self.model populateWithSampleData];
    Workout *workout = self.model.workouts[0];
    NSArray *sets = [self.model getExercisesForWorkout:workout];
    NSLog(@"Exercises: %@", sets);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.shouldUpdateData = true;
    self.graphTypeSegmentedControl.layer.zPosition = 1;
    self.collectionView.layer.zPosition = 0;
    
    [self setStatusBarBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(toggleSegmentedControl) userInfo:nil repeats:true];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (IBAction)toggleGraphType:(id)sender {
    [self.collectionView reloadData];
    self.shouldUpdateData = true;
}

- (void)toggleSegmentedControl {
    self.graphTypeSegmentedControl.selectedSegmentIndex = (self.graphTypeSegmentedControl.selectedSegmentIndex + 1) % 2;
    [self.collectionView reloadData];
    self.shouldUpdateData = true;
}

- (NSMutableArray *)generateData {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.exercises.count; i++) {
        Exercise *ex = [self.exercises objectAtIndex:i];
    
        NSMutableArray *chartData = [[NSMutableArray alloc] init];
        int pos = 0;
        for (Set *set in [self.model getSetsForExercise:ex]) {
            pos++;
            ChartDataEntry *entryForSet = nil;
            if (self.graphTypeSegmentedControl.selectedSegmentIndex == 0) {
                entryForSet = [[ChartDataEntry alloc] initWithX:pos y:set.weight];
            } else {
                entryForSet = [[ChartDataEntry alloc] initWithX:pos y:set.reps];
            }
            
            [chartData addObject:entryForSet];
        }
    
        LineChartDataSet *dataSet = nil;
        if (self.graphTypeSegmentedControl.selectedSegmentIndex == 0) {
            dataSet = [[LineChartDataSet alloc] initWithValues:chartData label:@"Weight"];
        } else {
            dataSet = [[LineChartDataSet alloc] initWithValues:chartData label:@"Reps"];
        }
        LineChartData *dataToPlot = [[LineChartData alloc] initWithDataSet:dataSet];
        [result addObject:dataToPlot];
    }
    
    return result;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exercises.count;
}

- (ExerciseGraphsCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ExerciseGraphsCell";
    ExerciseGraphsCollectionViewCell *cell = (ExerciseGraphsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Exercise *ex = [self.exercises objectAtIndex:indexPath.row];
    NSString *text = ex.name;
    
    cell.chartTitle.text = text;
    
    [cell.chartArea.xAxis setEnabled:false];
    [cell.chartArea clear];
    cell.chartArea.data = self.dataToPlot[indexPath.row];
    cell.layer.zPosition = -1;
    [cell.chartArea notifyDataSetChanged];
    [cell.chartArea setPinchZoomEnabled:true];
    
    return cell;
}

@end
