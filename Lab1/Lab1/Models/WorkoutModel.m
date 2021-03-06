//
//  WorkoutModel.m
//  Lab1
//
//  Created by Jake Carlson on 8/27/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutModel.h"
#import "NewWorkoutTableViewCell.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WorkoutModel ()
@property (strong, nonatomic) WorkoutModel *singleton;
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (readonly, strong, nonatomic) NSDictionary *workoutStructure;
@end

@implementation WorkoutModel
@synthesize singleton = _singleton;
@synthesize workoutStructure = _workoutStructure;

+ (WorkoutModel *)sharedManager {
    NSLog(@"Allocating shared model");
    static WorkoutModel *sharedWorkoutModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWorkoutModel = [[self alloc] initOnce];
    });
    return sharedWorkoutModel;
}

- (WorkoutModel *)initOnce {
    if (!_singleton)
        _singleton = [[WorkoutModel alloc] init];
    
    return _singleton;
}

- (NSDictionary *)readJsonWorkoutFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"workouts" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (NSDictionary *)workoutStructure {
    if (!_workoutStructure) {
        _workoutStructure = [self readJsonWorkoutFile];
    }

    return _workoutStructure;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Lab1"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    return self.persistentContainer.viewContext;
}

- (NSEntityDescription *)workoutEntityDescription {
    NSEntityDescription *desc = nil;
    desc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:self.managedObjectContext];
    NSLog(@"Entity description: %@", desc);
    return desc;
}

- (NSEntityDescription *)exerciseEntityDescription {
    NSEntityDescription *desc = nil;
    desc = [NSEntityDescription entityForName:@"Exercise" inManagedObjectContext:self.managedObjectContext];
    NSLog(@"Entity description: %@", desc);
    return desc;
}

- (NSEntityDescription *)setEntityDescription {
    NSEntityDescription *desc = nil;
    desc = [NSEntityDescription entityForName:@"Set" inManagedObjectContext:self.managedObjectContext];
    NSLog(@"Entity description: %@", desc);
    return desc;
}

- (Exercise *)getExerciseWithName:(NSString *)name {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Exercise fetchRequest] error:&error];
    for (Exercise *ent in entities) {
        if (ent.name == name) {
            return ent;
        }
    }
    NSLog(@"Could not find exercise with name: %@", name);
    return nil;
}

- (Set *)createSetForWorkoutAndExercise:(Workout *)workout withExercise:(Exercise *)exercise {
    NSLog(@"Creating set for wk %@ and ex %@", workout.name, exercise.name);
    Set *set = [[Set alloc] initWithEntity:self.setEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    set.exercise = exercise;
    set.workout = workout;
//    set.weight = 0;
//    set.reps = 0;
    return set;
}

- (NSArray *)getSetsForWorkoutAndExercise:(Workout *)workout withExercise:(Exercise *)exercise {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Set fetchRequest] error:&error];
    NSMutableArray *result = [@[] mutableCopy];
    for (Set *ent in entities) {
        if (ent.workout == workout && ent.exercise == exercise) {
            [result addObject:ent];
        }
    }
    return [self sortSetsById:result];
}

- (NSArray *)getSetsForExercise:(Exercise *)exercise {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Set fetchRequest] error:&error];
    NSMutableArray *result = [@[] mutableCopy];
    for (Set *ent in entities) {
        if (ent.exercise == exercise) {
            [result addObject:ent];
        }
    }
    return [self sortSetsById:result];
}

- (NSArray *)getSetsForWorkout:(Workout *)workout {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Set fetchRequest] error:&error];
    NSMutableArray *result = [@[] mutableCopy];
    for (Set *ent in entities) {
        if (ent.workout == workout) {
            [result addObject:ent];
        }
    }
    return [self sortSetsById:result];
}

- (NSArray *)sortSetsById:(NSArray *)sets {
    return [sets sortedArrayUsingComparator:^NSComparisonResult(Set *a, Set *b) {
        int64_t first = a.id;
        int64_t second = b.id;
        return first < second;
    }];
}

- (NSArray *)sortExercisesByFavorite:(NSArray *)exercises {
    return [exercises sortedArrayUsingComparator:^NSComparisonResult(Exercise *a, Exercise *b) {
        BOOL first = a.isFavorite;
        BOOL second = b.isFavorite;
        return first < second;
    }];
}

- (NSArray *)getExercisesForSets:(NSArray *)sets {
    NSMutableArray *exercises = [@[] mutableCopy];
    
    for (Set *set in sets) {
        if (![exercises containsObject:set.exercise]) {
            [exercises addObject:set.exercise];
        }
    }
    
    return exercises;
}

- (NSArray *)getExercisesForWorkout:(Workout *)workout {
    NSArray *setsForWorkout = [self getSetsForWorkout:workout];
    NSLog(@"Num sets %lu", (unsigned long)setsForWorkout.count);
    NSLog(@"%@", setsForWorkout);
    setsForWorkout = [[NSSet setWithArray:setsForWorkout] allObjects];
    
    return [[NSSet setWithArray:[self getExercisesForSets:setsForWorkout]] allObjects];
}


- (NSArray *)getExercises {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Exercise fetchRequest] error:&error];
    return [self sortExercisesByFavorite:entities];
}

- (NSArray *)getExerciseNames {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Exercise fetchRequest] error:&error];
    NSMutableArray * result = [@[] mutableCopy];
    for (Exercise *ex in entities) {
        [result addObject:ex.name];
    }
    return result;
}

- (NSUInteger)getNumSets {
    NSError *error;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:[Set fetchRequest] error:&error];
    return entities.count;
}

- (void)populateWithSampleData {
    NSMutableArray *builtWorkouts = [@[] mutableCopy];
    for (id name in self.workoutStructure[@"exercises"]) {
        Exercise *ex = [[Exercise alloc] initWithEntity:self.exerciseEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        ex.name = name;
        ex.isFavorite = [self.workoutStructure[@"exercises"][name][@"isFavorite"] integerValue] == 1;
    }
    NSDateFormatter *dateParser = [[NSDateFormatter alloc] init];
    dateParser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    for (id name in self.workoutStructure[@"workouts"]) {
        Workout *wk = [[Workout alloc] initWithEntity:self.workoutEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        wk.startTime = [dateParser dateFromString:self.workoutStructure[@"workouts"][name][@"startTime"]];
        wk.endTime = [dateParser dateFromString:self.workoutStructure[@"workouts"][name][@"endTime"]];
        wk.name = name;
        for (id exName in self.workoutStructure[@"workouts"][name][@"exercises"]) {
            Exercise *ex = [self getExerciseWithName:exName];
            for (id set in self.workoutStructure[@"workouts"][name][@"exercises"][exName]) {
                Set *s = [self createSetForWorkoutAndExercise:wk withExercise:ex];
                s.weight = [set[@"weight"] doubleValue];
                s.reps = [set[@"reps"] integerValue];
                s.id = [self getNumSets] + 1;
            }
        }
        [builtWorkouts addObject:wk];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime"
                                                 ascending:NO];
    
    self.workouts = [[builtWorkouts sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    NSLog(@"Generated workouts: %@", self.workouts);
}


// takes an array of WorkoutTableViewCells and saves them
- (void)saveExercises:(NSMutableArray *)exercises withName:(NSString*)workoutName withStartDate:(NSDate*)startDate withEndDate:(NSDate*)endDate {
    NSArray* names = [self getExerciseNames];

    // create the workout
    Workout *wk = [[Workout alloc] initWithEntity:self.workoutEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    wk.name = workoutName;
    wk.startTime = startDate;
    wk.endTime = endDate;
    
    // create the exercises
    for (NewWorkoutTableViewCell *cell in exercises) {
        NSString* name = names[[cell.workoutTypePicker selectedRowInComponent:0]];
        Exercise *ex = [self getExerciseWithName:name];
        
        if (ex == nil) {
            ex = [[Exercise alloc] initWithEntity:self.exerciseEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
            ex.name = name;
        }
        // create the sets
        for (int i = 0; i < cell.setsField.value; i++) {
            Set *s = [self createSetForWorkoutAndExercise:wk withExercise:ex];
            s.weight = cell.weightSlider.value;
            s.reps = [cell.repsField.text integerValue];
            s.id = [self getNumSets] + 1;
        }
    }
    
    // save the workout
    [self.workouts insertObject:wk atIndex:0];
}

@end
