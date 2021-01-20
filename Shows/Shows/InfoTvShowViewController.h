//
//  InfoTvShowViewController.h
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class Show;

NS_ASSUME_NONNULL_BEGIN

@interface InfoTvShowViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;
@property Show *show;

@end

NS_ASSUME_NONNULL_END
