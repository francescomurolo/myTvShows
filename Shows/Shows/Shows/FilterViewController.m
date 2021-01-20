//
//  FilterViewController.m
//  Shows
//
//  Created by user174240 on 15/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "FilterViewController.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface FilterViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *platformTextField;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;
@property UITextField *currentTextField;

@property NSArray <Category *>*categories;
@property NSArray <Platform *>*platforms;
@end

@implementation FilterViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchObjects];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
    
    [_categoryTextField setText:_categoryFilter];
    
    if(_scoreFilter==0)
        [_scoreTextField setText:nil];
    else
        [_scoreTextField setText:[NSString stringWithFormat:@"%ld",_scoreFilter]];
    
    [_platformTextField setText:_platformFilter];
}

- (void)fetchObjects{
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    NSFetchRequest *requestC = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    requestC.sortDescriptors = @[nameDescriptor];
    _categories = [_context executeFetchRequest:requestC error:nil];

    NSFetchRequest *requestP = [NSFetchRequest fetchRequestWithEntityName:@"Platform"];
    requestP.sortDescriptors = @[nameDescriptor];
    _platforms = [_context executeFetchRequest:requestP error:nil];
}

- (void)setToolbar {
    _pvToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _pickerView.frame.size.width, 35)];
    
    [_pvToolbar setBarStyle:UIBarStyleDefault];
    [_pvToolbar setTranslucent:YES];
    [_pvToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray array] init];
    
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
    if([_currentTextField isEqual:_categoryTextField])
        [_categoryTextField setText:_categories[[_pickerView selectedRowInComponent:0]].name];
    else if([_currentTextField isEqual:_scoreTextField])
        [_scoreTextField setText:[NSString stringWithFormat:@"%ld",[_pickerView selectedRowInComponent:0] + 1]];
    if([_currentTextField isEqual:_platformTextField])
        [_platformTextField setText:_platforms[[_pickerView selectedRowInComponent:0]].name];
    
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)restoreButton:(UIButton *)sender {
    [_categoryTextField setText:nil];
    [_scoreTextField setText:nil];
    [_platformTextField setText:nil];
}

- (IBAction)applyButton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"UnwindHomeSegue" sender:self];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return _categories.count;
    else if([_currentTextField isEqual:_scoreTextField])
        return 5;
    else if([_currentTextField isEqual:_platformTextField])
        return _platforms.count;

    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return _categories[row].name;
    else if([_currentTextField isEqual:_platformTextField])
        return _platforms[row].name;
    else
        return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UITextViedDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [_pickerView setDataSource:self];
    [_pickerView setDelegate:self];
        
    _currentTextField = textField;
        
    [textField setInputView:_pickerView];
    [textField setInputAccessoryView:_pvToolbar];
    
    if([textField.text length] == 0)
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    else{
        if([textField isEqual:_scoreTextField]){
            for (int i=0; i<[_pickerView numberOfRowsInComponent:0]; i++) {
                if(i == [textField.text intValue] - 1){
                    [_pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
        else if([textField isEqual:_categoryTextField]){
            for(Category *cat in _categories){
                if([cat.name isEqualToString:[textField text]]){
                    [_pickerView selectRow:[_categories indexOfObject:cat] inComponent:0 animated:YES];
                    break;
                }
            }
        }
        else if([textField isEqual:_platformTextField]){
            for(Platform *p in _platforms){
                if([p.name isEqualToString:[textField text]]){
                    [_pickerView selectRow:[_platforms indexOfObject:p] inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
}

#pragma mark - Segue Preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HomeViewController *vc = (HomeViewController *)segue.destinationViewController;
    vc.categoryFilter = [_categoryTextField text];
    vc.scoreFilter = [_scoreTextField.text integerValue];
    vc.platformFilter = [_platformTextField text];
}


@end
