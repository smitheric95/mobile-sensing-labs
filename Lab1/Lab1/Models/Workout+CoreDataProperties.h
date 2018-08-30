//
//  Workout+CoreDataProperties.h
//  Lab1
//
//  Created by Jake Carlson on 8/29/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Workout+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Workout (CoreDataProperties)

+ (NSFetchRequest<Workout *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *startTime;
@property (nullable, nonatomic, retain) Set *set;

@end

NS_ASSUME_NONNULL_END
