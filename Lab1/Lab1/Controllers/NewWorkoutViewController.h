//
//  NewWorkoutViewController.h
//  Lab1
//
//  Created by Eric Smith on 8/28/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWorkoutViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSMutableArray* exercises;
@property (weak, nonatomic) IBOutlet UITextField *workoutTitle;
@property (strong, nonatomic) NSDate* startTime;
@property (strong, nonatomic) NSDate* endTime;

@end
