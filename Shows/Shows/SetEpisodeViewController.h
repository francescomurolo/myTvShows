//
//  SetEpisodeViewController.h
//  Shows
//
//  Created by user174240 on 14/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class Episode;

NS_ASSUME_NONNULL_BEGIN

@interface SetEpisodeViewController : UIViewController
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;
@property Episode *episode;
@end

NS_ASSUME_NONNULL_END
