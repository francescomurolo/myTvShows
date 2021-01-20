//
//  EditTvShowViewController.m
//  Shows
//
//  Created by user174240 on 16/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "EditTvShowViewController.h"
#import "AppDelegate.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"
#import "Show+CoreDataClass.h"
#import "ChangePlatformsViewController.h"

@interface EditTvShowViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSArray <Category *>*categories;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;
@property UITextField *currentTextField;
@end

@implementation EditTvShowViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchCategories];
    
    [self setDescriptionTextViewStyle];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
    
    [_imageView setImage:[UIImage imageWithData:_show.photo]];
    _descriptionTextView.text = [_show showDescription];
    if([_show category]!=nil)
        _categoryTextField.text = [_show.category name];
    if([_show score]>0)
        _scoreTextField.text = [NSString stringWithFormat:@"%d", _show.score];
    
    if([_show.link length] >0)
        _linkTextField.text = [_show link];
    _platforms = [NSMutableArray arrayWithArray:_show.platform.allObjects];
}

- (void)fetchCategories{
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    request.sortDescriptors = @[nameDescriptor];
    _categories = [_context executeFetchRequest:request error:nil];
}

- (void)setDescriptionTextViewStyle {
    [_descriptionTextView.layer setBorderWidth:0.5];
    [_descriptionTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_descriptionTextView.layer setCornerRadius:5.0];
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
    if([_currentTextField isEqual:_categoryTextField])
        [_categoryTextField setText:_categories[[_pickerView selectedRowInComponent:0]].name];
    else if([_currentTextField isEqual:_scoreTextField])
        [_scoreTextField setText:[NSString stringWithFormat:@"%ld",[_pickerView selectedRowInComponent:0] + 1]];
    
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - IBAction
- (IBAction)unwindToEditTvShowController:(UIStoryboardSegue *)unwindSegue{}

- (IBAction)saveChanges:(UIBarButtonItem *)sender {
    if([self checkData]){
        [_show setPhoto:UIImageJPEGRepresentation(_imageView.image, 1)];
        [_show setShowDescription:_descriptionTextView.text];
        [_show setScore:[_scoreTextField.text integerValue]];
        [_show setLink:_linkTextField.text];
        [_show setPlatform:[NSSet setWithArray:_platforms]];
        
        [_delegate saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Make sure you have entered all the information about TV show!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)checkData{
    if([_imageView image]==nil)
        return NO;
    else if([_descriptionTextView.text length]==0)
        return NO;
    else if([_categoryTextField.text length]==0)
        return NO;
    else if([_scoreTextField.text length]==0)
        return NO;
    else if([_platforms count]==0)
        return NO;
    return YES;
}

- (IBAction)deleteButton:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to delete this Tv show?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionCancel];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
        [self.context deleteObject:self.show];
        [self.delegate saveContext];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert addAction:actionDelete];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)chooseImage:(UIButton *)sender {
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    imagePC.delegate = self;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Photo Source" message:@"Choose a source" preferredStyle:  UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [imagePC setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:imagePC animated:YES completion:nil];
        }else
            [self errorCameraAlert];
    }];
    [actionSheet addAction:actionCamera];
    
    UIAlertAction *actionLibrary = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [imagePC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePC animated:YES completion:nil];
    }];
    [actionSheet addAction:actionLibrary];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:actionCancel];
    
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)errorCameraAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Camera not available!" preferredStyle:  UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_imageView setImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return self.categories[row].name;
    else
        return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField isEqual:_scoreTextField] || [textField isEqual:_categoryTextField]){
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
        }
    }
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"ChangePlatformsSegue"]){
       ChangePlatformsViewController *vc = (ChangePlatformsViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.chosenPlatforms = [NSMutableArray arrayWithArray:_platforms];
    }
}

@end
