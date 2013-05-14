//
//  CounterValsViewController.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CounterValsViewController.h"
#import "CounterValTableCell.h"
#import "DateYearPicker.h"

@interface CounterValsViewController ()
@property DateYearPicker *datePicker;
@property UITextField *valueField;
@end

@implementation CounterValsViewController

@synthesize counterVals = _counterVals;
@synthesize datePicker = _datePicker;
@synthesize valueField = _valueField;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Добавить"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(addButtonHandler)];
    UITableView *tableView = (UITableView *) self.view;
    tableView.dataSource = self;
    [tableView registerClass:[CounterValTableCell class] forCellReuseIdentifier:@"CounterValCell"];
}

// Кнопка "Добавить"
- (void) addButtonHandler {
    UIAlertView *window = [[UIAlertView alloc] initWithTitle:nil
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"Отмена", @"Сохранить", nil];

    CGRect parentViewRect = self.view.frame;
    window.delegate = self;
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)willPresentAlertView:(UIAlertView *)alertView {
    alertView.frame = CGRectMake(0, 100,
                                 self.view.frame.size.width, self.view.frame.size.height - 100);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // добавить
        case 1: {
            NSLog(@"Dobavit");
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
    NSString *val = [counterVal objectForKey:@"val"];
    NSString *sd = [counterVal objectForKey:@"sd"];
    NSString *svd = [counterVal objectForKey:@"svd"];
    CGRect contentRect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    UIView *contentView = [[UIView alloc] initWithFrame:contentRect];
    CGFloat columnWidth = contentRect.size.width / 4;
    [cell.contentView addSubview:contentView];
    UILabel *sdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, columnWidth, contentRect.size.height)];
    sdLabel.text = sd;
    sdLabel.textColor = [UIColor grayColor];
    sdLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    sdLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *valLabel = [[UILabel alloc] initWithFrame:CGRectMake(sdLabel.frame.size.width, 0,
                                                                  columnWidth + 20.0, contentRect.size.height)];
    valLabel.text = val;
    valLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    valLabel.textAlignment = NSTextAlignmentRight;
    CGFloat svdWidth = contentRect.size.width - sdLabel.frame.size.width - valLabel.frame.size.width;
    UILabel *svdLabel = [[UILabel alloc] initWithFrame:CGRectMake(valLabel.frame.size.width + sdLabel.frame.size.width, 0,
                                                                  svdWidth, contentRect.size.height)];
    svdLabel.text = svd;
    svdLabel.textColor = [UIColor grayColor];
    svdLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    svdLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:sdLabel];
    [contentView addSubview:valLabel];
    [contentView addSubview:svdLabel];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerRect = CGRectMake(0, 0, tableView.frame.size.width, 32.0);
    UILabel *tableHeader = [[UILabel alloc] initWithFrame:headerRect];
    tableHeader.backgroundColor = [UIColor colorWithRed:0.6162 green:0.6872 blue:0.78 alpha:1.0];
    tableHeader.textColor = [UIColor whiteColor];
    tableHeader.shadowColor = [UIColor grayColor];
    tableHeader.text = @"    Дата            Показание          Дата ввода";
    tableHeader.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    return tableHeader;
}

@end
