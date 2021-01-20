//
//  SeasonsListViewController.m
//  Shows
//
//  Created by user174240 on 14/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "SeasonsListViewController.h"
#import "EpisodesListViewController.h"
#import "NewSeasonViewController.h"
#import "Show+CoreDataClass.h"
#import "Season+CoreDataClass.h"

@interface SeasonsListViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray <Season *>*seasons;
@end

@implementation SeasonsListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchSeasons];
    [_tableView reloadData];
}

- (void)fetchSeasons{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Season"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show=%@",_show.objectID];
    request.predicate = predicate;
    _seasons = _show.season.array;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_seasons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Season %ld",indexPath.row+1];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"EpisodesListSegue"]){
        EpisodesListViewController *vc = (EpisodesListViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.season = _seasons[[_tableView indexPathForSelectedRow].row];
    }else if([[segue identifier] isEqualToString:@"NewSeasonSegue"]){
        NewSeasonViewController *vc = (NewSeasonViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.show = _show;
    }
}

@end
