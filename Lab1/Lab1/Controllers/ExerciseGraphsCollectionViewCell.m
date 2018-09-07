//
//  ExerciseGraphsCollectionViewCell.m
//  Lab1
//
//  Created by Jake Carlson on 9/4/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "ExerciseGraphsCollectionViewCell.h"

@interface ExerciseGraphsCollectionViewCell ()
@property (nonatomic, strong) NSLayoutConstraint *cellWidthConstraint;
@end

@implementation ExerciseGraphsCollectionViewCell

- (NSLayoutConstraint *)cellWidthConstraint {
    if (!_cellWidthConstraint)
        _cellWidthConstraint = [[NSLayoutConstraint alloc] init];
    return _cellWidthConstraint;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.cellWidthConstraint.constant = UIScreen.mainScreen.bounds.size.width;
}

@end
