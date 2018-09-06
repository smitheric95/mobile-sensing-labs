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

@end

@implementation ExerciseGraphsController
@synthesize collectionView = _collectionView;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (IBAction)toggleGraphType:(id)sender {
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
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
    
    cell.chartTitle.text = text;
    
    [cell.chartArea.xAxis setEnabled:false];
    cell.chartArea.data = dataToPlot;
    
    return cell;
}

@end
