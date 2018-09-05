//
//  ExerciseGraphsCollectionViewCell.m
//  Lab1
//
//  Created by Jake Carlson on 9/4/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "ExerciseGraphsCollectionViewCell.h"

@interface ExerciseGraphsCollectionViewCell ()
@end

@implementation ExerciseGraphsCollectionViewCell
//@synthesize exerciseToPlot = _exerciseToPlot;

//- (WorkoutModel *)model {
//    if (!_model)
//        _model = [WorkoutModel sharedManager];
//    return _model;
//}
//
////- (Exercise *)exerciseToPlot {
////    if (!_exerciseToPlot)
////        _exerciseToPlot = nil;
////    return _exerciseToPlot;
////}
//
////- (void)setExerciseToPlot:(Exercise *)exerciseToPlot {
////    self.exerciseToPlot = exerciseToPlot;
////}
//
////- (LineChartView *)chartArea {
////    if (!_chartArea)
////        _chartArea = [[LineChartView alloc] init];
////    return _chartArea;
////}
//
//- (void)drawChart {
////    self.chartArea.delegate = self;
//
//    ChartDataSet *chartData = [[ChartDataSet alloc] init];
//    int pos = 0;
//    for (Set *set in [self.model getSetsForExercise:self.exerciseToPlot]) {
//        pos++;
//        ChartDataEntry *entryForSet = [[ChartDataEntry alloc] init];
//        entryForSet.x = pos;
//        entryForSet.y = set.weight;
//        [chartData addEntry:entryForSet];
//    }
//
//    LineChartData *dataToPlot = [[LineChartData alloc] init];
//    LineChartView *lineChart = [[LineChartView alloc] init];
////    self.lineChart = lineChart;
//    [dataToPlot addDataSet:chartData];
////    self.chartArea = lineChart;
////    self.chartArea.data = dataToPlot;
////    self.chartArea.backgroundColor = UIColor.blueColor;
////    [self addSubview:self.lineChart];
////    [self bringSubviewToFront:self.chartArea];
////    [self setBackgroundColor:UIColor.blueColor];
//}


@end
