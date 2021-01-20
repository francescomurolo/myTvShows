//
//  NewTvShowViewController.h
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class Platform;

NS_ASSUME_NONNULL_BEGIN

@interface NewTvShowViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;
@property NSArray <Platform *> *platforms;

@end

NS_ASSUME_NONNULL_END
