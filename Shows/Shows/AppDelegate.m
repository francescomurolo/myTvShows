//
//  AppDelegate.m
//  Shows
//
//  Created by user174240 on 13/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "AppDelegate.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"

@interface AppDelegate ()
@property NSManagedObjectContext *context;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.context = self.persistentContainer.viewContext;
    
    if(![self dataExists])
        [self createData];
    
    return YES;
}

- (void)createData {
    Category *category;
    Platform *platform;
    NSArray *categories = [NSArray arrayWithObjects:@"Documentary",@"Soap",@"Animation",
                           @"Drama",@"Action",@"Comedy",@"Crime",@"Adventure",@"Fantasy",
                           @"Horror",@"Thriller",@"Romance",@"Anime",@"Reality", nil];
    
    for(NSString *name in categories){
        category = [[Category alloc] initWithContext:self.context];
        [category setName:name];
    }
    
    NSArray *platforms = [NSArray arrayWithObjects:@"Netflix",@"Amazon Prime Video",@"Apple TV+", nil];
    
    for(NSString *name in platforms){
        platform = [[Platform alloc] initWithContext:self.context];
        [platform setName:name];
    }
    
    [self saveContext];
}

- (BOOL)dataExists{
    NSFetchRequest *requestC = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray<Category*>*categories = [self.context executeFetchRequest:requestC error:nil];
    
    NSFetchRequest *requestP = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    NSArray<Platform*>*platforms = [self.context executeFetchRequest:requestP error:nil];
    
    if([categories count] == 0 && [platforms count] == 0)
        return NO;
    
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Shows"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    //NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([self.context hasChanges] && ![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
