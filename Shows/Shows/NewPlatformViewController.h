//
//  NewPlatformViewController.h
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface NewPlatformViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;

@end

NS_ASSUME_NONNULL_END
