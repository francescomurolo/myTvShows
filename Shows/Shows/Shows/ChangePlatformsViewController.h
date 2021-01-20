//
//  ChangePlatformsViewController.h
//  Shows
//
//  Created by user174240 on 16/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class Platform;

NS_ASSUME_NONNULL_BEGIN

@interface ChangePlatformsViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;
@property NSMutableArray <Platform *> *chosenPlatforms;
@end

NS_ASSUME_NONNULL_END
