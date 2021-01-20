//
//  SetEpisodeViewController.m
//  Shows
//
//  Created by user174240 on 14/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "SetEpisodeViewController.h"
#import "Episode+CoreDataClass.h"
#import "Season+CoreDataProperties.h"
#import "Show+CoreDataClass.h"
#import "AppDelegate.h"

@interface SetEpisodeViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *watchedButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;

@property BOOL watched;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;

@end

@implementation SetEpisodeViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _watched = [_episode watched];
    [self changeViewElements];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
}

- (void)changeViewElements{
    if(_watched){
        [_watchedButton setImage:[UIImage systemImageNamed:@"checkmark.square"] forState:UIControlStateNormal];
        [_scoreLabel setTextColor:UIColor.labelColor];
        [_scoreTextField setEnabled:YES];
        if([_episode score] > 0)
            [_scoreTextField setText:[NSString stringWithFormat:@"%d",[_episode score]]];
    }else{
        [_watchedButton setImage:[UIImage systemImageNamed:@"square"] forState:UIControlStateNormal];
        [_scoreLabel setTextColor:UIColor.lightGrayColor];
        [_scoreTextField setEnabled:NO];
        [_scoreTextField setText:nil];
    }
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
    [_scoreTextField setText:[NSString stringWithFormat:@"%ld",[_pickerView selectedRowInComponent:0] + 1]];
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)watchedButtonClicked:(UIButton *)sender {
    _watched = !_watched;
    [self changeViewElements];
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender {
    [_episode setWatched:_watched];
    if([_scoreTextField.text length] != 0)
        [_episode setScore:[_scoreTextField.text intValue]];
    
    [_delegate saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 5;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UITextFieldDelegate

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
