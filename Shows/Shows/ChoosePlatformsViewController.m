//
//  ChoosePlatformsViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "ChoosePlatformsViewController.h"
#import "AppDelegate.h"
#import "Platform+CoreDataClass.h"
#import "NewTvShowViewController.h"

@interface ChoosePlatformsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property NSArray <Platform *> *platforms;

@end

@implementation ChoosePlatformsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchAllPlatforms];
    [_tableView reloadData];
    
    if([_chosenPlatforms count] == 0)
        _chosenPlatforms = [NSMutableArray array];
    else{
        [_doneButton setEnabled:YES];
        NSIndexPath *indexPath;
        for(Platform *cPlatform in _chosenPlatforms){
            for(Platform *platform in _platforms){
                if([platform.name isEqualToString:[cPlatform name]]){
                    indexPath = [NSIndexPath indexPathForRow:[_platforms indexOfObject:platform] inSection:0];
                    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
        }
    }
}

- (void)fetchAllPlatforms{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[nameDescriptor];
    _platforms = [_context executeFetchRequest:request error:nil];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_platforms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Platform *platform = _platforms[indexPath.row];
    [cell.textLabel setText:[platform name]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_chosenPlatforms addObject:[_platforms objectAtIndex:indexPath.row]];
    
    if(![_doneButton isEnabled])
        [_doneButton setEnabled:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_chosenPlatforms removeObject:[_platforms objectAtIndex:indexPath.row]];
    
    if([_chosenPlatforms count] == 0)
        [_doneButton setEnabled:NO];
}
- (IBAction)doneSelected:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"UnwindSegue" sender:self];
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NewTvShowViewController *vc = (NewTvShowViewController *)segue.destinationViewController;
    vc.platforms = [NSArray arrayWithArray:_chosenPlatforms];
}

@end
