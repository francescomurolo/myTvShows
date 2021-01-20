//
//  NewSeasonViewController.m
//  Shows
//
//  Created by user174240 on 14/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "NewSeasonViewController.h"
#import "Show+CoreDataClass.h"
#import "Episode+CoreDataClass.h"
#import "Season+CoreDataClass.h"
#import "AppDelegate.h"

@interface NewSeasonViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *numberEpisodesTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *button;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;

@end

@implementation NewSeasonViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle: [NSString stringWithFormat:@"Season %ld",_show.season.count+1]];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
}

- (void)setToolbar {
   _pvToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _pickerView.frame.size.width, 35)];
    
    [_pvToolbar setBarStyle:UIBarStyleDefault];
    [_pvToolbar setTranslucent:YES];
    [_pvToolbar sizeToFit];
    
    NSMutableArray *barItems = [NSMutableArray array];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTouched:)];
    [barItems addObject:cancelButton];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTouched:)];
    [barItems addObject:doneButton];
    
    [_pvToolbar setItems:barItems];
    [_pvToolbar setUserInteractionEnabled:YES];
}

- (void)doneTouched:(UIBarButtonItem *)sender{
    [_numberEpisodesTextField setText:[NSString stringWithFormat:@"%ld",[_pickerView selectedRowInComponent:0] + 1]];
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)saveButton:(UIBarButtonItem *)sender {
    Season *season = [[Season alloc] initWithContext:_context];
    
    Episode *episode;
    for(int i=0;i<[_numberEpisodesTextField.text intValue];i++){
        episode = [[Episode alloc] initWithContext:_context];
        [episode setSeason:season];
    }
    [season setShow:_show];
    
    [_delegate saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 100;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UITextFieldDeelegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([_numberEpisodesTextField.text length] == 0)
      [_button setEnabled:NO];
    else
        [_button setEnabled:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [_pickerView setDataSource:self];
    [_pickerView setDelegate:self];
    
    [textField setInputView:_pickerView];
    [textField setInputAccessoryView:_pvToolbar];
    
    if([textField.text length] == 0)
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    else{
        for (int i=0; i<[_pickerView numberOfRowsInComponent:0]; i++) {
            if(i == [textField.text intValue] - 1){
                [_pickerView selectRow:i inComponent:0 animated:YES];
                break;
            }
        }
    }
}

@end
