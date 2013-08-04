//
//  PeriodDetailsViewController.m
//  iosGkh
//
//  Created by Sorokin E on 30.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "PeriodDetailsViewController.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "CorePlotUtils.h"

@interface PeriodDetailsViewController ()
// array of arrays of table data
@property (nonatomic, strong) NSMutableArray *valuesArrayByPageIndex;
@property int currentPage;
@end

@implementation PeriodDetailsViewController

-(NSMutableArray *)valuesArrayByPageIndex
{
    if (!_valuesArrayByPageIndex) {
        _valuesArrayByPageIndex = [NSMutableArray array];
    }
    return _valuesArrayByPageIndex;
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
    self.title = self.period;
    self.scrollView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    int numberOfPages = self.report.additionalRepresentationArray.count;
    self.pageControl.numberOfPages = numberOfPages;
    self.scrollView.contentSize = CGSizeMake(numberOfPages * self.scrollView.frame.size.width, 0);
    if (numberOfPages != 0) {
        // load first page
        [self loadDataForRepresentation:0];
        self.currentPage = 0;
    }
}

#define TABLE_DATA_PATH @"param/value"
#define REQUEST_REPRESENTATION_TYPE_KEY @"type"
#define REQUEST_PERIOD_KEY @"period"
#define RESPONSE_VALUES_KEY @"values"

#define TABLE_CELL_NIB_NAME @"AdditionalRepresentationCell"
#define TABLE_CELL_IDENTIFIER @"AdditionRepCell"

-(NSMutableDictionary *) getRequestParameters
{
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    for (GkhInputType *input in self.report.inputParamArray) {
        requestParameters[input.id] = input.value;
    }
    return requestParameters;
}

#define TABLEVIEW_TAG_BASE 500

- (void)loadDataForRepresentation:(int) index
{
    if (index >= self.report.additionalRepresentationArray.count) {
        return;
    }
    GkhRepresentation *representation = self.report.additionalRepresentationArray[index];
    AFHTTPClient *client = [BasicAuthModule httpClient];
    NSMutableDictionary *requestParams = [self getRequestParameters];
    requestParams[REQUEST_REPRESENTATION_TYPE_KEY] = representation.id;
    requestParams[REQUEST_PERIOD_KEY] = self.period;
    int arrayLength = self.valuesArrayByPageIndex.count;
    // if array length equal to index, that means the representation of index is not loaded
    // for example array length = 2 ([0, 1]), index = 2 ([0, 1, 2]), so index 2 is not yet loaded
    if (arrayLength == index) {
        CGFloat scrollViewWidth = self.scrollView.frame.size.width;
        CGFloat scrollViewHeight = self.scrollView.frame.size.height;
        CGFloat x = index * scrollViewWidth;
        CGSize indicatorSize = self.activityIndicator.frame.size;
        self.activityIndicator.frame = CGRectMake(x + scrollViewWidth / 2 - indicatorSize.width / 2,
                                                  scrollViewHeight / 2 - indicatorSize.height / 2,
                                                  indicatorSize.width, indicatorSize.height);
        [self.activityIndicator startAnimating];
        CGRect tableViewRect = CGRectMake(x, 0, scrollViewWidth, self.scrollView.frame.size.height);
        [client postPath:TABLE_DATA_PATH parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.activityIndicator stopAnimating];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *valuesAndPeriod = [jsonParser objectWithString:responseString];
            NSArray *values = valuesAndPeriod[RESPONSE_VALUES_KEY];
            self.valuesArrayByPageIndex[index] = values;
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
            UINib *cell = [UINib nibWithNibName:TABLE_CELL_NIB_NAME bundle:nil];
            [tableView registerNib:cell forCellReuseIdentifier:TABLE_CELL_IDENTIFIER];
            tableView.dataSource = self;
            tableView.tag = TABLEVIEW_TAG_BASE + index;
            [self.scrollView addSubview:tableView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.activityIndicator stopAnimating];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Scroll view

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pageNumber = [self determineCurrentPageNumber:scrollView.contentOffset.x];
    self.currentPage = pageNumber;
    self.pageControl.currentPage = pageNumber;
    [self loadDataForRepresentation:pageNumber];
}

- (int) determineCurrentPageNumber:(float) offset
{
    return offset / self.view.frame.size.width;
}

#pragma mark Table view datasource

#define PAY_VALUE_KEY @"pay"
#define PERCENT_VALUE_KEY @"percent"
#define NACH_VALUE_KEY @"nach"
#define SCOPE_VALUE_KEY @"scope"

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int currentPage = self.currentPage;
    NSArray *values = self.valuesArrayByPageIndex[currentPage];
    return values.count;
}

#define SCOPE_VIEW_TAG 14
#define NACH_VIEW_TAG 15
#define PAY_VIEW_TAG 16
#define PERCENT_VIEW_TAG 17

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_IDENTIFIER];
    NSArray *values = self.valuesArrayByPageIndex[self.currentPage];
    NSDictionary *value = values[indexPath.row];
    
    UILabel *scopeView = (UILabel *)[cell viewWithTag:SCOPE_VIEW_TAG];
    scopeView.text = value[SCOPE_VALUE_KEY];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    UILabel *nachView = (UILabel *)[cell viewWithTag:NACH_VIEW_TAG];
    NSDecimalNumber *nachVal = [NSDecimalNumber decimalNumberWithString:value[NACH_VALUE_KEY]];
    NSString *nach = [formatter stringFromNumber:nachVal];
    nachView.text = nach;
    
    UILabel *payView = (UILabel *)[cell viewWithTag:PAY_VIEW_TAG];
    NSDecimalNumber *payVal = [NSDecimalNumber decimalNumberWithString:value[PAY_VALUE_KEY]];
    NSString *pay = [formatter stringFromNumber:payVal];
    payView.text = pay;
    
    UILabel *percentView = (UILabel *)[cell viewWithTag:PERCENT_VIEW_TAG];
    percentView.text = [value[PERCENT_VALUE_KEY] stringByAppendingString:@"%"];
    
    return cell;
}

#pragma mark Rotate handler
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIScrollView *scrollView = self.scrollView;
    CGRect scrollFrame = scrollView.frame;
    float scrollViewHeight = scrollFrame.size.height;
    float scrollViewWidth = scrollFrame.size.width;
    scrollView.contentSize = CGSizeMake(self.pageControl.numberOfPages * scrollViewWidth, 0);
    int pages = self.pageControl.numberOfPages;
    for (int i = 0; i < pages; i++) {
        int tableViewTag = TABLEVIEW_TAG_BASE + i;
        UIView *tableView = [self.scrollView viewWithTag:tableViewTag];
        CGRect tableFrameRect = CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, scrollViewHeight);
        if (i == self.currentPage) {
            [UIView animateWithDuration:duration animations:^{
                tableView.frame = tableFrameRect;
            }];
        } else {
            tableView.frame = tableFrameRect;
        }
    }
    CGPoint point = CGPointMake(self.scrollView.frame.size.width * self.currentPage, 0);
    [self.scrollView setContentOffset:point animated:YES];
}

@end
