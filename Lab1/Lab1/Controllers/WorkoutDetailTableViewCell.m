//
//  WorkoutDetailTableViewCell.m
//  Lab1
//
//  Created by Eric Smith on 8/30/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutDetailTableViewCell.h"
@interface WorkoutDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *exerciseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *setsLabel;
@end

@implementation WorkoutDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
