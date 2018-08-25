//
//  AppDelegate.h
//  Lab1
//
//  Created by Eric Smith on 8/25/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

