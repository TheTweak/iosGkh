//
//  CounterValsViewController.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CounterValsViewController.h"
#import "CounterValTableCell.h"
#import "BasicAuthModule.h"
#import "DateYearPicker.h"
#import "SBJsonParser.h"

@interface CounterValsViewController ()
@property DateYearPicker *datePicker;
@property UITextField *valueField;
// ActionSheet с выбором Удалить или Добавить показание
@property UIActionSheet *addCounterValActionSheet;
// ActionSheet подтверждения об удалении показания
@property UIActionSheet *deleteConfirmationActionSheet;
@end

@implementation CounterValsViewController

@synthesize counterVals = _counterVals;
@synthesize datePicker = _datePicker;
@synthesize valueField = _valueField;
@synthesize counterId = _counterId;
@synthesize addCounterValActionSheet = _addCounterValActionSheet;
@synthesize deleteConfirmationActionSheet = _deleteConfirmationActionSheet;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Показания";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Добавить..."
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(addButtonHandler)];
    self.tableView.allowsSelection = NO;
    self.tableView.dataSource = self;
//    [self.tableView registerClass:[CounterValTableCell class] forCellReuseIdentifier:@"CounterValCell"];
}

// Кнопка "Добавить..."
- (void) addButtonHandler {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Показание"
                                                             delegate:self
                                                    cancelButtonTitle:@"Отмена"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Добавить", @"Удалить последнее", nil];
    self.addCounterValActionSheet = actionSheet;
    [actionSheet showInView:self.view];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)addCounterValButtonHandler {
    UIAlertView *window = [[UIAlertView alloc] initWithTitle:nil
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"Отмена", @"Сохранить", nil];
    CGRect parentViewRect = self.view.frame;
    window.delegate = self;
    window.frame = parentViewRect;
    window.cancelButtonIndex = 0;    
    [window show];
    int i = 0;
    for (UIView *subView in window.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *) subView;
            if (i == 0) {
                // Otmena
                //                button.backgroundColor = [UIColor redColor];
            }
            subView.frame = CGRectMake(i * 169 + 15, 10, 120, 30);
            i++;
        }
    }
    UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake(15, 50, parentViewRect.size.width - 30, 30)];
    valueField.placeholder = @"Значение";
    valueField.autocorrectionType = UITextAutocorrectionTypeNo;
    valueField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    valueField.backgroundColor = [UIColor whiteColor];
    valueField.borderStyle = UITextBorderStyleRoundedRect;
    valueField.delegate = self;
    valueField.returnKeyType = UIReturnKeyDone;
    self.valueField = valueField;
    
    DateYearPicker *datePicker = [[DateYearPicker alloc] initWithFrame:CGRectMake(15, valueField.frame.size.height + 55,
                                                                                  parentViewRect.size.width - 30,
                                                                                  parentViewRect.size.height)];
    self.datePicker = datePicker;
    [window addSubview:datePicker];
    [window addSubview:valueField];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            
        case 0: {
            if (actionSheet == self.addCounterValActionSheet) {
                // меню "показание"
                // кнопка добавить
                [self performSelector:@selector(addCounterValButtonHandler) withObject:self afterDelay:0];
            } else if (actionSheet == self.deleteConfirmationActionSheet) {
                // кнопка ОК в меню подтверждения об удалении показания
                self.deleteConfirmationActionSheet = nil;
                AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.counterId, @"counter", nil];
                [client postPath:@"removelast" parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                             NSData *responseData = (NSData *) responseObject;
                             NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                             NSDictionary *response = [jsonParser objectWithString:responseString];
                             id success = [response objectForKey:@"success"];
                             NSString *msg = [response objectForKey:@"msg"];
                             if ([@"0" isEqualToString:[success description]]) {
                                 // failed
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:msg delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                                 [alert show];
                             } else {
                                 // success
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Удалено" message:msg delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                                 [alert show];
                                 // reload table
                                 
                                 [client postPath:@"counter" parameters:[NSDictionary dictionaryWithObjectsAndKeys:self.counterId, @"counter", nil]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                                              NSData *responseData = (NSData *) responseObject;
                                              NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                              self.counterVals = [jsonParser objectWithString:responseString];
                                              UITableView *tableView = (UITableView *) self.view;
                                              [tableView reloadData];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"fail to load counter vals");
                                          }];
                                 
                             }
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"failed to save counter value");
                         }];
            }
            break;
        }
        case 1: {
            if (actionSheet == self.addCounterValActionSheet) {
                // удалить последнее показание
                UIActionSheet *confirmationSheet = [[UIActionSheet alloc] initWithTitle:@"Удалить последнее показание?"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Отмена"
                                                                 destructiveButtonTitle:nil
                                                                      otherButtonTitles:@"ОК", nil];
                [confirmationSheet showInView:self.view];
                self.deleteConfirmationActionSheet = confirmationSheet;
            }
            break;
        }
        default:
            break;
    }
    self.addCounterValActionSheet = nil;
}

#pragma mark - UIAlertViewDelegate

-(void)willPresentAlertView:(UIAlertView *)alertView {
    alertView.frame = CGRectMake(0, 100,
                                 self.view.frame.size.width, self.view.frame.size.height - 50);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        
    switch (buttonIndex) {
        case 1: {
            // кнопка сохранить
            // Add counter value
            // Todo: Value validation
            AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
            NSString *month = [self.datePicker month];
            NSString *year = [self.datePicker year];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.counterId, @"counter",
                                    self.valueField.text, @"val",
                                    [NSString stringWithFormat:@"%@.%@", month, year], @"sd", nil];
            [client postPath:@"countervalue" parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                         NSData *responseData = (NSData *) responseObject;
                         NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                         NSDictionary *response = [jsonParser objectWithString:responseString];
                         id success = [response objectForKey:@"success"];
                         NSString *msg = [response objectForKey:@"msg"];
                         if ([@"0" isEqualToString:[success description]]) {
                             // failed
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:msg delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                             [alert show];
                         } else {
                             // success
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Сохранено" message:msg delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                             [alert show];
                             // reload table
                             
                             [client postPath:@"counter" parameters:[NSDictionary dictionaryWithObjectsAndKeys:self.counterId, @"counter", nil]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                                          NSData *responseData = (NSData *) responseObject;
                                          NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                          self.counterVals = [jsonParser objectWithString:responseString];
                                          UITableView *tableView = (UITableView *) self.view;
                                          [tableView reloadData];
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"fail to load counter vals");
                                      }];
                             
                         }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"failed to save counter value");
                     }];
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.counterVals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CounterValCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *counterVal = [self.counterVals objectAtIndex:indexPath.item];
    
    UILabel *valueLabel = (UILabel *) [cell viewWithTag:14];
    valueLabel.text = counterVal[@"val"];
    
    UILabel *sdLabel = (UILabel *) [cell viewWithTag:15];
    NSString *sd = [NSString stringWithFormat:@"Показание за: %@", counterVal[@"sd"]];
    sdLabel.text = sd;

    UILabel *svdLabel = (UILabel *) [cell viewWithTag:16];
    NSString *svd = [NSString stringWithFormat:@"Введено %@", counterVal[@"svd"]];
    svdLabel.text = svd;
            
    return cell;
}

#pragma mark - Table view delegate

@end
