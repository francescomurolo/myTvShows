//
//  HomeViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Show+CoreDataClass.h"
#import "InfoTvShowViewController.h"
#import "NewTvShowViewController.h"
#import "FilterViewController.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"

@interface HomeViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray <Show*>*shows;
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;

@end

@implementation HomeViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = _delegate.persistentContainer.viewContext;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchShows];
    [_tableView reloadData];
}

- (void)fetchShows{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Show"];
    NSMutableArray *filters = [NSMutableArray array];
    if([_platformFilter length]>0){
        NSPredicate *predicateP = [NSPredicate predicateWithFormat:@"platform CONTAINS[cd] %@",[self getPlatformFromName:_platformFilter]];
        [filters addObject:predicateP];
    }
    if([_categoryFilter length]>0){
        NSPredicate *predicateC = [NSPredicate predicateWithFormat:@"category=%@",[self getCategoryFromName:_categoryFilter]];
        [filters addObject:predicateC];
    }
    if(_scoreFilter>0){
        NSPredicate *predicateS = [NSPredicate predicateWithFormat:@"score=%ld",_scoreFilter];
        [filters addObject:predicateS];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:filters];
    [request setPredicate:predicate];
    _shows = [[_context executeFetchRequest:request error:nil] mutableCopy];
}

- (Platform *) getPlatformFromName:(NSString *)name{
    NSFetchRequest *pRequest = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    NSArray <Platform*>*platforms=[_context executeFetchRequest:pRequest error:nil];
    Platform *platform;
    for(Platform *p in platforms)
        if([p.name isEqualToString:name])
            platform = p;
    return platform;
}

- (Category *) getCategoryFromName:(NSString *)name{
    NSFetchRequest *catRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray <Category*>*categories=[_context executeFetchRequest:catRequest error:nil];
    Category *category;
    for(Category *cat in categories)
        if([cat.name isEqualToString:name])
            category = cat;
    return category;
}

#pragma mark - UITableViewConrollerDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_shows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Show *show = _shows[indexPath.row];
    [cell.textLabel setText:[show name]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[show score]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"InfoTvShowSegue"]){
        InfoTvShowViewController *vc = (InfoTvShowViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.show = _shows[[_tableView indexPathForSelectedRow].row];
    }else if([[segue identifier] isEqualToString:@"NewTvShowSegue"]){
        _categoryFilter = nil;
        _scoreFilter = 0;
        _platformFilter = nil;
        NewTvShowViewController *vc = (NewTvShowViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
    }else if([[segue identifier] isEqualToString:@"FilterSegue"]){
        FilterViewController *vc = (FilterViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.categoryFilter = _categoryFilter;
        vc.scoreFilter = _scoreFilter;
        vc.platformFilter = _platformFilter;
    }
}

#pragma mark - IBAction
- (IBAction)unwindToHomeController:(UIStoryboardSegue *)unwindSegue{}


@end
