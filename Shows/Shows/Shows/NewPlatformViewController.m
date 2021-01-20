//
//  NewPlatformViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "NewPlatformViewController.h"
#import "Platform+CoreDataClass.h"
#import "AppDelegate.h"

@interface NewPlatformViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation NewPlatformViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - IBAction

- (IBAction)save:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    
    Platform *platform;
    
    switch ([self check_text]) {
        case 0:
            platform = [[Platform alloc] initWithContext:_context];
            [platform setName:[_nameTextField text]];
            [_delegate saveContext];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 1:
            [self showAlert:@"The platform already exists!"];
            break;
        
        case 2:
            [self showAlert:@"The name field cannot be empty!"];
            break;
    }
}

- (NSInteger)check_text {
    if([self.nameTextField hasText]){
    NSString *name = [[_nameTextField text] lowercaseString];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    NSArray <Platform*>*platforms = [_context executeFetchRequest:request error:nil];
    
    for(int i=0;i<platforms.count;i++){
        if([[platforms[i] valueForKey:@"name"] lowercaseString] == name)
            return 1;
    }
    return 0;
        
    }else
        return 2;
}

- (void)showAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:  UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
