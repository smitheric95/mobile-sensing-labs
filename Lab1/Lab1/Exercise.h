//
//  ExerciseModel.h
//  Lab1
//
//  Created by Jake Carlson on 8/26/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Exercise : NSObject

@property (nonatomic) NSInteger *exerciseId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSTimeInterval *duration;

@end
