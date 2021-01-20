//
//  EpisodesListViewController.m
//  Shows
//
//  Created by user174240 on 14/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "EpisodesListViewController.h"
#import "Episode+CoreDataClass.h"
#import "Season+CoreDataClass.h"
#import "Show+CoreDataClass.h"
#import "SetEpisodeViewController.h"

@interface EpisodesListViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray <Episode*>*episodes;
@end

@implementation EpisodesListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchEpisodes];
    [_tableView reloadData];
}

- (void)fetchEpisodes{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Episode"];
    request.predicate = [NSPredicate predicateWithFormat:@"season=%@",_season.objectID];
    _episodes = _season.episode.array;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_episodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Episode %ld",indexPath.row+1];
    
    if(_episodes[indexPath.row].watched)
        cell.detailTextLabel.text = @"Watched";
    else
        cell.detailTextLabel.text = nil;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"SetEpisodeSegue"]){
        SetEpisodeViewController *vc = (SetEpisodeViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.episode = _episodes[[_tableView indexPathForSelectedRow].row];
    }
}

@end
