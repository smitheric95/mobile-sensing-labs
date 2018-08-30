//
//  Set+CoreDataProperties.h
//  Lab1
//
//  Created by Jake Carlson on 8/29/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Set+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Set (CoreDataProperties)

+ (NSFetchRequest<Set *> *)fetchRequest;

@property (nonatomic) int64_t reps;
@property (nonatomic) float weight;
@property (nullable, nonatomic, retain) Exercise *exercise;
@property (nullable, nonatomic, retain) Workout *workout;

@end

NS_ASSUME_NONNULL_END
