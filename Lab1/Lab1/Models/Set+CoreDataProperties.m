//
//  Set+CoreDataProperties.m
//  Lab1
//
//  Created by Jake Carlson on 8/29/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Set+CoreDataProperties.h"

@implementation Set (CoreDataProperties)

+ (NSFetchRequest<Set *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Set"];
}

@dynamic reps;
@dynamic weight;
@dynamic exercise;
@dynamic workout;

@end
