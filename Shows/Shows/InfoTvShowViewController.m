//
//  InfoTvShowViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "InfoTvShowViewController.h"
#import "Show+CoreDataClass.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"
#import "SeasonsListViewController.h"
#import "EditTvShowViewController.h"

@interface InfoTvShowViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *platformsLabel;


@end

@implementation InfoTvShowViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:[_show name]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setData];
}

- (void) setData{
    [_imageView setImage:[UIImage imageWithData:_show.photo]];
    [_descriptionTextView setText:[_show showDescription]];
    if([_show category]!=nil)
        [_categoryLabel setText:[_show.category name]];
    
    if([_show score]>0)
        [_scoreLabel setText:[NSString stringWithFormat:@"%d", _show.score]];
    
    if([_show.link length] == 0)
        [_linkLabel setText:@"No link"];
    else
        [_linkLabel setText:[_show link]];
    
    [_platformsLabel setText:@""];
    for(Platform *platform in [_show platform].allObjects){
        if([[_show.platform allObjects] indexOfObject:platform] == [_show.platform count]-1)
            _platformsLabel.text = [_platformsLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@",platform.name]];
        else
            _platformsLabel.text = [_platformsLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@, ",platform.name]];
    }
}

#pragma mark - Segue preparation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"SeasonsListSegue"]){
        SeasonsListViewController *vc = (SeasonsListViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.show = _show;
    }else if([[segue identifier] isEqualToString:@"EditSegue"]){
        EditTvShowViewController *vc = (EditTvShowViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.show = _show;
    }
}

@end
