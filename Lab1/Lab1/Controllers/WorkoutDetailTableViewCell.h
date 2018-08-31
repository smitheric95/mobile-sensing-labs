//
//  WorkoutDetailTableViewCell.h
//  Lab1
//
//  Created by Eric Smith on 8/30/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *exerciseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *setsLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@end
