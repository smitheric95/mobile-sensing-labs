//
//  Exercise+CoreDataProperties.h
//  Lab1
//
//  Created by Jake Carlson on 8/29/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//
//

#import "Exercise+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Exercise (CoreDataProperties)

+ (NSFetchRequest<Exercise *> *)fetchRequest;

@property (nonatomic) BOOL isFavorite;
@property (nullable, nonatomic, copy) NSString *logo;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) Set *set;

@end

NS_ASSUME_NONNULL_END
