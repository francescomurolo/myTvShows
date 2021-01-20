//
//  NewTvShowViewController.m
//  MyTvShows
//
//  Created by user174240 on 12/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "NewTvShowViewController.h"
#import "AppDelegate.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"
#import "Show+CoreDataClass.h"
#import "Season+CoreDataClass.h"
#import "Episode+CoreDataClass.h"
#import "ChoosePlatformsViewController.h"

@interface NewTvShowViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *seasonsTextField;
@property (weak, nonatomic) IBOutlet UITextField *episodesTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSArray <Category *>*categories;
@property Show *show;

@property NSArray <NSNumber *>*episodesNumber;
@property NSMutableArray <NSNumber *>*tempEpisodesNumber;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;
@property UITextField *currentTextField;

@end

@implementation NewTvShowViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchCategories];
    
    [self setDescriptionTextViewStyle];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
}

- (void)fetchCategories{
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    request.sortDescriptors = @[nameDescriptor];
    _categories = [_context executeFetchRequest:request error:nil];
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
    else if([_currentTextField isEqual:_seasonsTextField]){
        NSInteger capacity = [_pickerView selectedRowInComponent:0] + 1;
        [_seasonsTextField setText:[NSString stringWithFormat:@"%ld",capacity]];
        [_episodesTextField setEnabled:YES];
        [_episodesTextField setTextColor:UIColor.linkColor];
        
        _tempEpisodesNumber = [NSMutableArray array];
        for(int i=0;i<capacity;i++)
            [_tempEpisodesNumber addObject:[NSNumber numberWithInteger:0]];
        
        _episodesNumber = [NSArray arrayWithArray:_tempEpisodesNumber];
    
    }else if([_currentTextField isEqual:_episodesTextField])
        _episodesNumber = [NSArray arrayWithArray:_tempEpisodesNumber];
    
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

- (void)setDescriptionTextViewStyle {
    [_descriptionTextView.layer setBorderWidth:0.5];
    [_descriptionTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_descriptionTextView.layer setCornerRadius:5.0];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)unwindToCreateShowController:(UIStoryboardSegue *)unwindSegue{}

- (IBAction)save:(UIBarButtonItem *)sender {
    if([self checkData]){
        Show *show = [[Show alloc] initWithContext:_context];
        
        NSString *name = [_nameTextField text];
        NSString *description = [_descriptionTextView text];
        NSString *category = [_categoryTextField text];
        NSString *link = [_linkTextField text];
        NSInteger score = [_scoreTextField.text integerValue];
        NSInteger seasonsNumber = [_seasonsTextField.text integerValue];
        
        [show setPhoto:UIImageJPEGRepresentation(_imageView.image, 1)];
        [show setName:name];
        [show setShowDescription:description];
        [show setScore:score];
        [show setLink:link];
        [show addPlatform:[NSSet setWithArray:_platforms]];
        
        Season *season;
        Episode *episode;
        for(int i=0;i<seasonsNumber;i++){
            season = [[Season alloc] initWithContext:_context];
            [season setShow:show];
            
            for(int c=0;c<[_episodesNumber[i] intValue];c++){
                episode = [[Episode alloc] initWithContext:_context];
                [episode setSeason:season];
            }
        }
        
        for(Category *cat in _categories){
            if([cat.name isEqualToString:category]){
                show.category = cat;
                break;
            }
        }
        
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
    else if([_nameTextField.text length]==0)
        return NO;
    else if([_descriptionTextView.text length]==0)
        return NO;
    else if([_categoryTextField.text length]==0)
        return NO;
    else if([_scoreTextField.text length]==0)
        return NO;
    else if([_seasonsTextField.text length]==0)
        return NO;
    else if([_episodesNumber containsObject:[NSNumber numberWithInteger:0]])
        return NO;
    else if([_platforms count]==0)
        return NO;
    return YES;
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
    if([_currentTextField isEqual:_episodesTextField])
        return 2;
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([_currentTextField isEqual:_episodesTextField]){
        switch (component) {
            case 0:
                return [[_seasonsTextField text] intValue];
                break;
                
            case 1:
                return 101;
                break;
        }
    }else{
        if([_currentTextField isEqual:_categoryTextField])
            return _categories.count;
        else if([_currentTextField isEqual:_scoreTextField])
            return 5;
        else if([_currentTextField isEqual:_seasonsTextField])
            return 50;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return self.categories[row].name;
    else if([_currentTextField isEqual:_episodesTextField]){
        if(component == 0)
            return [NSString stringWithFormat:@"Season %ld",row+1];
        else
            return [NSString stringWithFormat:@"%ld",row];
    }
    else
        return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UIPickeViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([_currentTextField isEqual:_episodesTextField]){
        if(component == 0)
            [pickerView selectRow:[[_tempEpisodesNumber objectAtIndex:row] integerValue] inComponent:1 animated:YES];
        else{
            [_tempEpisodesNumber replaceObjectAtIndex:[pickerView selectedRowInComponent:0] withObject:[NSNumber numberWithInteger:[pickerView selectedRowInComponent:1]]];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(![textField isEqual:_nameTextField] && ![textField isEqual:_linkTextField]){
        [_pickerView setDataSource:self];
        [_pickerView setDelegate:self];
        
        _currentTextField = textField;
        
        [textField setInputView:_pickerView];
        [textField setInputAccessoryView:_pvToolbar];
        
        if([textField isEqual:_scoreTextField] || [textField isEqual:_seasonsTextField]){
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
        else if([textField isEqual:_episodesTextField]){
            _tempEpisodesNumber = [NSMutableArray arrayWithArray:_episodesNumber];
            
            [_pickerView selectRow:0 inComponent:0 animated:YES];
            [_pickerView selectRow:[[_tempEpisodesNumber objectAtIndex:0] integerValue] inComponent:1 animated:YES];
        }
        else if([textField isEqual:_categoryTextField]){
            if([textField.text length] == 0)
                [_pickerView selectRow:0 inComponent:0 animated:YES];
            else{
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

#pragma mark - Segue Preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"ChoosePlatformsSegue"]){
       ChoosePlatformsViewController *vc = (ChoosePlatformsViewController *)segue.destinationViewController;
        vc.context = _context;
        vc.delegate = _delegate;
        vc.chosenPlatforms = [[NSMutableArray alloc] initWithArray:_platforms];
    }
}

@end
