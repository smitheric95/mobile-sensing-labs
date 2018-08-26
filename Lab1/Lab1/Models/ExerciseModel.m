//
//  ExerciseModel.m
//  Lab1
//
//  Created by Jake Carlson on 8/26/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "ExerciseModel.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ExerciseModel ()
@property (strong, nonatomic) NSMutableArray *exercises;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ExerciseModel

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
