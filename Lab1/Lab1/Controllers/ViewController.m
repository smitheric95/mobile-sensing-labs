//
//  ViewController.m
//  Lab1
//
//  Created by Eric Smith on 8/25/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Exercise+CoreDataClass.h"

@interface ViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *exercises; // TODO: Make this workouts

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self populateWithSampleData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    NSLog(@"Created managed object context %@", context);
    return context;
}

- (void)populateWithSampleData {
    self.exercises = [@[[[Exercise alloc] init].name = @"Bench"] mutableCopy];
    NSLog(@"Generated exercises: %@", self.exercises);
}

@end
