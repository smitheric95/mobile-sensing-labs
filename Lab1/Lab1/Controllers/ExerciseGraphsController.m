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
//@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (strong, nonatomic) NSMutableArray *charts;

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

//- (NSMutableArray *)charts {
//    if (!_charts)
//        _charts = [[NSMutableArray alloc] init];
//    return _charts;
//}

//- (UICollectionView *)collectionView {
//    if (!_collectionView)
//        _collectionView = [[UICollectionView alloc] init];
//    return _collectionView;
//}

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
//    static NSString *cellIdentifier = @"ExerciseGraphsCell";
//    [self.collectionView registerClass:ExerciseGraphsCollectionViewCell.class forCellWithReuseIdentifier:cellIdentifier];
//    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

//- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}

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
    
//    cell.chartTitle.text = text;
    
    NSMutableArray *chartData = [[NSMutableArray alloc] init];
    int pos = 0;
    for (Set *set in [self.model getSetsForExercise:ex]) {
        pos++;
        ChartDataEntry *entryForSet = [[ChartDataEntry alloc] initWithX:pos y:set.weight];
        [chartData addObject:entryForSet];
    }

    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithValues:chartData label:@"Weight"];
    LineChartData *dataToPlot = [[LineChartData alloc] initWithDataSet:dataSet];
//    LineChartView *lineChart = [[LineChartView alloc] init];
    
//    cell.chartArea = lineChart;
    
    cell.chartArea.noDataText = @"Get outta here";
    cell.chartArea.data = dataToPlot;
    cell.chartArea.chartDescription.text = text;

//    lineChart.noDataText = @"Get outta here";
//    lineChart.data = dataToPlot;
//    lineChart.chartDescription.text = text;

//    [cell setChartArea:lineChart];
//    cell.chartArea = lineChart;
//    cell.backgroundColor = UIColor.blueColor;
    
    return cell;
}


//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
