//
//  ExerciseGraphsCollectionViewCell.h
//  Lab1
//
//  Created by Jake Carlson on 9/4/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>

@interface ExerciseGraphsCollectionViewCell : UICollectionViewCell
//@property (strong, nonatomic) Exercise *exerciseToPlot;
@property (weak, nonatomic) IBOutlet LineChartView *chartArea;
@property (strong, nonatomic) IBOutlet UILabel *chartTitle;

//- (void)setExerciseToPlot:(Exercise *)exerciseToPlot;
//- (void)drawChart;

@end
