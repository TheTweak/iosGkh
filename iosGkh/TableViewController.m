//
//  TableViewController.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [[UIViewController alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:tableView.bounds];
    view.backgroundColor = [UIColor orangeColor];
    viewController.view = view;
    UINavigationController *navigationController = self.navigationController;
    NSLog(@"tapped");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"oglFlip";
    animation.subtype = @"fromLeft";
    animation.delegate = self;
    NSString *value;
    UIViewController *parentViewController = self.navigationController.parentViewController;
    NSDictionary *graphDict = [parentViewController valueForKey:@"graphDictionary"];
    CPTPlotAreaFrame *plotAreaFrame;
    switch (indexPath.row) {
        case 0:
        {
            CPTGraph *graph = (CPTGraph *) [graphDict valueForKey:@"nach"];
            if (graph) {
                [parentViewController setValue:graph forKeyPath:@"hostingView.hostedGraph"];
            } else {
            [(id<CPTGraphHolderProtocol>) parentViewController addPlot:@"nach"
                                                                    ofType:@"bar"];
            }
            break;
        }
        case 1:
        {
            [(id<CPTGraphHolderProtocol>) parentViewController addPlot:@"fls"
                                                                ofType:@"pie"];
            break;
        }
        case 2:
        {
            [(id<CPTGraphHolderProtocol>) parentViewController addPlot:@"ДПУ"
                                                                ofType:@"xy"];
            break;
        }
        default:
            break;
    }
    [animation setValue:value forKey:@"animType"];
    if (!plotAreaFrame) {
        CALayer *layer = (CALayer *) [parentViewController valueForKeyPath:@"hostingView.layer"];
        [layer addAnimation:animation forKey:nil];
    } else {
        //    [plotAreaFrame addAnimation:animation forKey:nil];
    }

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
