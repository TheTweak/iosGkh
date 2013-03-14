//
//  CustomViewController.m
//  iosGkh
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

@end

@implementation CustomViewController

- (id)init {
    self = [super init];
    if (self) {
        // Registering for notifications

        // notificates when user tapped on input param field
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paramInputFieldTapped:) name:@"ParamInputFieldTapped"
                                                   object:nil];
    }
    return self;
}

- (void)rightBarButtonHandler {
    NSLog(@"right bar button clicked");
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
    NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:paramId, @"type", nil];
    [client postPath:@"param/value" parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
//                                               self.pickedValueId = [selectedJson valueForKey:@"id"];
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
