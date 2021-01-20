//
//  PlatformsViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "PlatformsViewController.h"
#import "Platform+CoreDataClass.h"
#import "AppDelegate.h"
#import "NewPlatformViewController.h"

@interface PlatformsViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray <Platform *> *platforms;
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;

@end

@implementation PlatformsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = self.delegate.persistentContainer.viewContext;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchAllPlatforms];
    [_tableView reloadData];
}

- (void)fetchAllPlatforms{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[nameDescriptor];
    _platforms = [[_context executeFetchRequest:request error:nil] mutableCopy];
    
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to delete the platform?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionCancel];
        
        UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
            Platform *platform = self.platforms[indexPath.row];
            [self.platforms removeObject:platform];
            [self.context deleteObject:platform];
            [self.delegate saveContext];
            [self.tableView reloadData];
        }];
        [alert addAction:actionDelete];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"NewPlatformSegue"]){
       NewPlatformViewController *vc = (NewPlatformViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
    }
}
@end
