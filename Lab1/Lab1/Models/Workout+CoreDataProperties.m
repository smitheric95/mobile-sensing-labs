//
//  Workout+CoreDataProperties.m
//  Lab1
//
//  Created by Jake Carlson on 8/29/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Workout+CoreDataProperties.h"

@implementation Workout (CoreDataProperties)

+ (NSFetchRequest<Workout *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
}

@dynamic endTime;
@dynamic name;
@dynamic startTime;
@dynamic set;

@end
