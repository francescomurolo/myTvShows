//
//  PreferencesViewController.m
//  Shows
//
//  Created by user174240 on 16/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AppDelegate.h"
#import "ExportViewController.h"

@interface PreferencesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property NSManagedObjectContext *context;
@property AppDelegate *delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PreferencesViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = _delegate.persistentContainer.viewContext;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.textLabel setText:@"Export to CSV file"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"ExportSegue"]){
    ExportViewController *vc = (ExportViewController *)segue.destinationViewController;
    vc.context = _context;
    vc.delegate = _delegate;
    }
}

@end
