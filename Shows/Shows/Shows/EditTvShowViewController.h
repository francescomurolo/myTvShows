//
//  EditTvShowViewController.h
//  Shows
//
//  Created by user174240 on 16/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class Show;
@class Platform;

NS_ASSUME_NONNULL_BEGIN

@interface EditTvShowViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;
@property Show *show;
@property NSArray <Platform *> *platforms;
@end

NS_ASSUME_NONNULL_END
