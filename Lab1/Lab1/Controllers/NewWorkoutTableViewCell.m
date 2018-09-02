//
//  NewWorkoutTableViewCell.m
//  Lab1
//
//  Created by Eric Smith on 9/2/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "NewWorkoutTableViewCell.h"

@implementation NewWorkoutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    /*
     * Add 'cancel' and 'Apply' buttons to keyboard
     * source: https://stackoverflow.com/a/11382044/8853372
     */
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.repsField.inputAccessoryView = numberToolbar;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)updateWeight:(UISlider*)sender {
    self.weightLabel.text = [NSString stringWithFormat:@"%d lbs", [@(sender.value) intValue]];
}

- (IBAction)updateSets:(UIStepper*)sender {
    self.setsLabel.text = [NSString stringWithFormat:@"%@", @(sender.value)];
}

-(void)cancelNumberPad{
    [self.repsField resignFirstResponder];
    self.repsField.text = @"";
}

-(void)doneWithNumberPad{
    NSString *numberFromTheKeyboard = self.repsField.text;
    [self.repsField resignFirstResponder];
}

@end
