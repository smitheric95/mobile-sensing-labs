//
//  WorkoutModel.h
//  Lab1
//
//  Created by Jake Carlson on 8/27/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Workout+CoreDataClass.h"
#import "Exercise+CoreDataClass.h"
#import "Set+CoreDataClass.h"

@interface WorkoutModel : NSObject

+ (WorkoutModel *)sharedManager;
- (void)populateWithSampleData;
- (NSArray *)getSetsForWorkoutAndExercise:(Workout *)workout withExercise:(Exercise *)exercise;
- (NSArray *)getSetsForExercise:(Exercise *)exercise;
- (NSArray *)getSetsForWorkout:(Workout *)workout;
- (NSArray *)getExercisesForWorkout:(Workout *)workout;
- (Exercise *)getExerciseWithName:(NSString *)name; // TODO: remove
- (NSArray *)getExerciseNames;
- (void)saveContext;
- (Exercise*)getBlankExercise;
@property (strong, nonatomic) NSMutableArray *workouts;
@end
