//
//  CustomViewController.m
//  iosGkh
//
//  Controller for view, showing when accessory button on a cell pressed.
//
//  Created by Evgeniy Sorokin on 14.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CustomViewController.h"
#import "CustomView.h"
#import "HomeViewController.h"
#import "BasicAuthModule.h"
#import "ActionSheetStringPicker.h"
#import "SBJsonParser.h"

@interface CustomViewController ()

// storing selected values : paramId - value
@property(nonatomic, strong) NSMutableDictionary *selectedValues;

@end

@implementation CustomViewController

@synthesize tableRowIndex = _tableRowIndex;
@synthesize selectedValues = _selectedValues;

#pragma mark Acessors

- (NSMutableDictionary *) selectedValues {
    if (!_selectedValues) {
        _selectedValues = [NSMutableDictionary dictionary];
    }
    return _selectedValues;
}

- (id)init {
    self = [super init];
    if (self) {
        // Registering for notifications

        // notificates when user tapped on input param field
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paramInputFieldTapped:)
                                                     name:@"ParamInputFieldTapped"
                                                   object:nil];
    }
    return self;
}

- (void)rightBarButtonHandler {
    NSLog(@"right bar button clicked");
    NSEnumerator *enumerator = [self.selectedValues keyEnumerator];
    id key;
    BOOL reload = NO;
    while ((key = [enumerator nextObject])) {
        reload = YES;
        NSDictionary *notificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:key, @"updateKey"
                                                ,[self.selectedValues valueForKey:key], @"newValue"
                                                ,self.tableRowIndex, @"rowIndex"
                                                ,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTableData"
                                                            object:self
                                                          userInfo:notificationDictionary];        
    }
    if (reload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCurrentGraph" object:nil];
    }
    UINavigationController *navigationController = (UINavigationController *) self.parentViewController;
    [navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)paramInputFieldTapped:(NSNotification *)notification {
    NSLog(@"param input field tapped");
    if (!notification) return;
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
    NSString *paramId = [notification.userInfo valueForKey:@"inputId"];
    NSString *fieldDescription = [notification.userInfo valueForKey:@"pickerDescription"];
    
    if (!paramId) return;
#warning TODO : loading mask
    NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:paramId, @"param", nil];
    [client postPath:@"param/value/list" parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post succeeded");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = [responseJson objectAtIndex:i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:fieldDescription
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               UITextField *inputField = (UITextField *) notification.object;
                                               inputField.text = [selectedJson valueForKey:@"name"];
                                               [self.selectedValues setValue:[selectedJson valueForKey:@"id"] forKey:paramId];
                                               NSLog(@"selected: %@", selectedJson);
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"cancel");
                                         }
                                              origin:self.view];
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
