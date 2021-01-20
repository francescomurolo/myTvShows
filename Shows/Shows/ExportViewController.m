//
//  ExportViewController.m
//  Shows
//
//  Created by user174240 on 16/09/2020.
//  Copyright © 2020 Francesco Murolo. All rights reserved.
//

#import "ExportViewController.h"
#import "Show+CoreDataClass.h"
#import "Season+CoreDataClass.h"
#import "Category+CoreDataClass.h"
#import "Platform+CoreDataClass.h"

@interface ExportViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *platformTextField;

@property UIPickerView *pickerView;
@property UIToolbar *pvToolbar;
@property UITextField *currentTextField;
@property NSArray <Category *>*categories;
@property NSArray <Platform *>*platforms;
@end

@implementation ExportViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchObjects];
    
    _pickerView = [[UIPickerView alloc] init];
    
    [self setToolbar];
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

- (Category *) getCategoryFromName:(NSString *)name{
    Category *category;
    for(Category *cat in _categories)
        if([cat.name isEqualToString:name])
            category = cat;
    return category;
}

- (Platform *) getPlatformFromName:(NSString *)name{
    Platform *platform;
    for(Platform *p in _platforms)
        if([p.name isEqualToString:name])
            platform = p;
    return platform;
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
    else if([_currentTextField isEqual:_platformTextField])
        [_platformTextField setText:_platforms[[_pickerView selectedRowInComponent:0]].name];
    else if([_currentTextField isEqual:_scoreTextField])
        [_scoreTextField setText:[NSString stringWithFormat:@"%ld",[_pickerView selectedRowInComponent:0] + 1]];
    
    [self.view endEditing:YES];
}

-(void)cancelTouched:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)export:(UIBarButtonItem *)sender {
    NSArray <Show *>*shows = [self fetchFilteredShows];
    
    if(shows.count>0){
        NSString *content = @"Name,Description,Score,Link,Category,Seasons number,Episodes number,Platforms\n";
        
        for(Show *show in shows){
            content = [content stringByAppendingFormat:@"\"%@\",\"%@\",%d,%@,%@,%ld,",show.name,show.showDescription,show.score,show.link,show.category.name,show.season.array.count];
            for(Season *season in show.season.array){
                if(season != show.season.array.lastObject)
                    content = [content stringByAppendingFormat:@"%ld-",season.episode.count];
                else
                    content = [content stringByAppendingFormat:@"%ld",season.episode.count];
            }
            
            content = [content stringByAppendingString:@","];
            for(Platform *platform in show.platform.allObjects){
                if(platform != show.platform.allObjects.lastObject)
                    content = [content stringByAppendingFormat:@"%@ ",platform.name];
                else
                    content = [content stringByAppendingFormat:@"%@\n",platform.name];
            }
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *dir = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
        NSURL *file = [dir URLByAppendingPathComponent:@"MyTvShows.csv"];
        [content writeToURL:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
        
        UIActivityViewController *shareActivity = [[UIActivityViewController alloc] initWithActivityItems:@[file] applicationActivities:nil];
        [self presentViewController:shareActivity animated:YES completion:nil];
    }else
        [self showAlert:@"No Tv Show selected!"];
}

-(NSMutableArray *)fetchFilteredShows{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Show"];
    NSMutableArray *filters = [NSMutableArray array];
    if([_platformTextField.text length]>0){
        NSPredicate *predicateP = [NSPredicate predicateWithFormat:@"platform CONTAINS[cd] %@",[self getPlatformFromName:_platformTextField.text]];
        [filters addObject:predicateP];
    }
    if([_categoryTextField.text length]>0){
        NSPredicate *predicateC = [NSPredicate predicateWithFormat:@"category=%@",[self getCategoryFromName:_categoryTextField.text]];
        [filters addObject:predicateC];
    }
    if([_scoreTextField.text integerValue]>0){
        NSPredicate *predicateS = [NSPredicate predicateWithFormat:@"score=%ld",[_scoreTextField.text integerValue]];
        [filters addObject:predicateS];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:filters];
    [request setPredicate:predicate];
    
    return [[_context executeFetchRequest:request error:nil] mutableCopy];
}

- (void)showAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:  UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)restore:(UIBarButtonItem *)sender {
    [_categoryTextField setText:nil];
    [_scoreTextField setText:nil];
    [_platformTextField setText:nil];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return _categories.count;
    else if([_currentTextField isEqual:_platformTextField])
        return _platforms.count;
    else if([_currentTextField isEqual:_scoreTextField])
        return 5;

    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([_currentTextField isEqual:_categoryTextField])
        return self.categories[row].name;
    else if([_currentTextField isEqual:_platformTextField])
    return self.platforms[row].name;
    else
        return [NSString stringWithFormat:@"%ld",row+1];
}

#pragma mark - UITextFieldDelegate

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

@end
