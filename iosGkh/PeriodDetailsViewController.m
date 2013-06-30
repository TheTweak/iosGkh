//
//  PeriodDetailsViewController.m
//  iosGkh
//
//  Created by Sorokin E on 30.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "PeriodDetailsViewController.h"

@interface PeriodDetailsViewController ()

@end

@implementation PeriodDetailsViewController

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
    self.title = self.period;
    
    for (GkhRepresentation *representation in self.report.additionalRepresentationArray) {
        NSLog(@"representation: %@", representation);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    int numberOfPages = self.report.additionalRepresentationArray.count;
    self.pageControl.numberOfPages = numberOfPages;
    self.scrollView.contentSize = CGSizeMake(numberOfPages * self.scrollView.frame.size.width, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
