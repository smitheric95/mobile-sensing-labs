//
//  WorkoutModel.h
//  Lab1
//
//  Created by Jake Carlson on 8/27/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkoutModel : NSObject

+ (WorkoutModel *)sharedManager;
- (void)populateWithSampleData;
- (void)saveContext;
@property (strong, nonatomic) NSMutableArray *workouts; // TODO: Make this workouts
@end
