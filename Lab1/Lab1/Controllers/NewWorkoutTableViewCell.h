//
//  NewWorkoutTableViewCell.h
//  Lab1
//
//  Created by Eric Smith on 9/2/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWorkoutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIPickerView *workoutTypePicker;
@property (weak, nonatomic) IBOutlet UITextField *repsField;
@property (weak, nonatomic) IBOutlet UILabel *setsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *setsField;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UISlider *weightSlider;

@end
