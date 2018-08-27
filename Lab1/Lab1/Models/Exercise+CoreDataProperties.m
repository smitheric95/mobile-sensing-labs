//
//  Exercise+CoreDataProperties.m
//  Lab1
//
//  Created by Jake Carlson on 8/27/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Exercise+CoreDataProperties.h"

@implementation Exercise (CoreDataProperties)

+ (NSFetchRequest<Exercise *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
}

@dynamic id;
@dynamic isFavorite;
@dynamic logo;
@dynamic name;
@dynamic set;

@end
