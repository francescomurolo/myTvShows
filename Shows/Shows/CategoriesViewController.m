//
//  CategoriesViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "CategoriesViewController.h"
#import "NewCategoryViewController.h"
#import "AppDelegate.h"
#import "Category+CoreDataClass.h"

@interface CategoriesViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray <Category *> *categories;
@property (nonatomic) NSManagedObjectContext *context;
@property AppDelegate *delegate;

@end

@implementation CategoriesViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = _delegate.persistentContainer.viewContext;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchAllCategories];
    [_tableView reloadData];
}

- (void)fetchAllCategories{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[nameDescriptor];
    _categories = [[_context executeFetchRequest:request error:nil] mutableCopy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Category *category = _categories[indexPath.row];
    [cell.textLabel setText:category.name];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to delete the category?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionCancel];
        
        UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
            Category *category = self.categories[indexPath.row];
            [self.categories removeObject:category];
            [self.context deleteObject:category];
            [self.delegate saveContext];
            [self.tableView reloadData];
        }];
        [alert addAction:actionDelete];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"NewCategorySegue"]){
       NewCategoryViewController *vc = (NewCategoryViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
    }
}
@end
