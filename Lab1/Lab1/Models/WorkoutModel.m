//
//  WorkoutModel.m
//  Lab1
//
//  Created by Jake Carlson on 8/27/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "WorkoutModel.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Workout+CoreDataClass.h"

@interface WorkoutModel ()
@property (strong, nonatomic) WorkoutModel *singleton;
@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

@implementation WorkoutModel
@synthesize singleton = _singleton;

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

- (void)populateWithSampleData {
    Workout *wk = [[Workout alloc] initWithEntity:self.workoutEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    wk.name = @"Bench";
    self.workouts = [@[wk] mutableCopy];
    //    self.exercises = [@[[[Exercise alloc] init].name = @"Bench"] mutableCopy];
    NSLog(@"Generated workouts: %@", self.workouts);
}

@end
