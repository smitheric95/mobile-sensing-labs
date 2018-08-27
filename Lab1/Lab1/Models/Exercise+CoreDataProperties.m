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

- (Exercise *)setName: (NSString *)name {
    if (!_name)
        _name = name;
    return self;
}

@dynamic id;
@dynamic isFavorite;
@dynamic logo;
@dynamic name;
@dynamic set;

@end
