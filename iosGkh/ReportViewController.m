//
//  ReportViewController.m
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "ReportViewController.h"
#import "GkhReport.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "GkhReportPlotDataSource.h"
#import "BarPlotDelegate.h"
#import "ActionSheetStringPicker.h"

@interface ReportViewController ()
@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;
@property (nonatomic, strong) NSArray *plotValues;
@property (nonatomic, strong) NSDecimalNumber *barPlotMaxHeight;
@property (nonatomic, strong) UIColor *mainTextColor;
@property (nonatomic, strong) id<CPTPlotDelegate> plotDelegate;
@end

@implementation ReportViewController

-(NSDictionary *)getBusinessValues:(NSInteger)idx
{
    return self.plotValues[idx];
}

-(UIColor *)mainTextColor {
    if (!_mainTextColor) {
        _mainTextColor = [UIColor darkTextColor];
    }
    return _mainTextColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = self.report.name;
}

-(void)viewWillAppear:(BOOL)animated
{
    CGRect graphHostingViewRect = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(graphHostingViewRect.size.width, 0);
    self.graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:graphHostingViewRect];
    [self.scrollView addSubview:self.graphHostingView];
}

#define REPORT_REQUEST_TYPE_KEY @"type"
#define REPORT_RESPONSE_PLOT_VALUES_KEY @"values"
#define REPORT_VALUES_REQUEST_PATH @"param/value"

-(void)viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    requestParameters[REPORT_REQUEST_TYPE_KEY] = self.report.id;
    for (GkhInputType *input in self.report.inputParamArray) {
        requestParameters[input.id] = input.value;
    }
//    [self showLoadingMask];
    AFHTTPClient *client = [BasicAuthModule httpClient];
    [client postPath:REPORT_VALUES_REQUEST_PATH parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Getting report plot data succeeded!");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseJson = [jsonParser objectWithString:responseString];
        self.plotValues = responseJson[REPORT_RESPONSE_PLOT_VALUES_KEY];
        [self addPlotWithTitle:self.report.id ofType:self.report.plotType];
//        [self hideLoadingMask];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Getting report plot data failed!");
//        [self hideLoadingMask];
    }];
}

#pragma mark Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.report.inputParamArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhInputType *param = self.report.inputParamArray[indexPath.row];
    UILabel *paramName = (UILabel *) [cell viewWithTag:14];
    paramName.text = param.value;
    UILabel *paramDesc = (UILabel *) [cell viewWithTag:15];
    paramDesc.text = param.description;
    return cell;
}

#pragma mark Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GkhInputType *param = self.report.inputParamArray[indexPath.row];
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
#warning TODO : loading mask
    [client postPath:@"param/value/list" parameters:@{@"param": param.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = responseJson[i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        [ActionSheetStringPicker showPickerWithTitle:param.description
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               NSString *value = selectedJson[@"name"];
                                               param.value = value;
                                               [tableView reloadData];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             
                                         }
                                              origin:tableView.superview];
        NSLog(@"Gettin %@ param's value list succeeded", param.id);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Gettin %@ param's value list failed", param.id);
    }];
}

#pragma mark Plot data source

#define BAR_PLOT_HEIGHT_VALUE_KEY @"y"
#define SECOND_BAR_PLOT_HEIGHT_VALUE_KEY @"y2"
#define DEFAULT_MAX_BAR_HEIGHT @"1"

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    self.barPlotMaxHeight = nil;
    NSDecimalNumber *maxH = [NSDecimalNumber zero];
    NSDecimalNumber *maxH2 = [NSDecimalNumber zero];
    for (NSDictionary *jsonObject in self.plotValues) {
        NSDecimalNumber *y = [NSDecimalNumber decimalNumberWithString:jsonObject[BAR_PLOT_HEIGHT_VALUE_KEY]];
        NSComparisonResult compare = [maxH compare:y];
        if (compare == NSOrderedAscending) {
            maxH = y;
        }
        NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:jsonObject[SECOND_BAR_PLOT_HEIGHT_VALUE_KEY]];
        NSComparisonResult compare2 = [maxH2 compare:y2];
        if (compare2 == NSOrderedAscending) {
            maxH2 = y2;
        }
    }
    NSComparisonResult compare = [maxH compare:[NSDecimalNumber zero]];
    if (compare != NSOrderedSame) {
        self.barPlotMaxHeight = maxH;
    } else {
        compare = [maxH2 compare:[NSDecimalNumber zero]];
        if (compare != NSOrderedSame) {
            self.barPlotMaxHeight = maxH2;
        }
    }

    if (!self.barPlotMaxHeight) {
        self.barPlotMaxHeight = [NSDecimalNumber decimalNumberWithString:DEFAULT_MAX_BAR_HEIGHT];
    }
    
    return self.plotValues.count;
}

#define BAR_PLOT_POSITION_KEY @"x"
#define BAR_PLOT_WIDTH_KEY @"width"
#define SCATTER_PLOT_X_KEY @"x"
#define SCATTER_PLOT_Y_KEY @"y"
#define SECOND_PLOT_TITLE @"sec"

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSDictionary *jsonObject = self.plotValues[idx];
    NSNumber *result;
    
    if ([plot isKindOfClass:[CPTScatterPlot class]]) {
        if (CPTScatterPlotFieldX == fieldEnum) {
            result = jsonObject[SCATTER_PLOT_X_KEY];
        } else if (CPTScatterPlotFieldY == fieldEnum) {
            result = jsonObject[SCATTER_PLOT_Y_KEY];
        }
    } else if ([plot isKindOfClass:[CPTBarPlot class]]) {
        NSNumber *width = jsonObject[BAR_PLOT_WIDTH_KEY];
        ((CPTBarPlot *)plot).barWidth = [width decimalValue];
        if (CPTBarPlotFieldBarLocation == fieldEnum) {
            result = jsonObject[BAR_PLOT_POSITION_KEY];
            result = [NSNumber numberWithDouble:[result doubleValue]];
        } else if (CPTBarPlotFieldBarTip == fieldEnum) {
            NSDecimalNumber *y;
            if ([SECOND_PLOT_TITLE isEqualToString:plot.title]) {
                y = [NSDecimalNumber decimalNumberWithString:jsonObject[SECOND_BAR_PLOT_HEIGHT_VALUE_KEY]];
            } else {
                y = [NSDecimalNumber decimalNumberWithString:jsonObject[BAR_PLOT_HEIGHT_VALUE_KEY]];
            }
            result = [y decimalNumberByDividingBy:self.barPlotMaxHeight];
        }
    }
    
    return result;
}

#pragma mark Bar fill colors

#define BAR_PLOT_BEGIN_COLOR_RED 124.0/255.0
#define BAR_PLOT_BEGIN_COLOR_GREEN 124.0/255.0
#define BAR_PLOT_BEGIN_COLOR_BLUE 124.0/255.0
#define BAR_PLOT_BEGIN_COLOR_ALPHA 1.0

#define BAR_PLOT_END_COLOR_RED 124.0/255.0
#define BAR_PLOT_END_COLOR_GREEN 124.0/255.0
#define BAR_PLOT_END_COLOR_BLUE 124.0/255.0
#define BAR_PLOT_END_COLOR_ALPHA 0.5

#define SECOND_BAR_PLOT_BEGIN_COLOR_RED 187.0/255.0
#define SECOND_BAR_PLOT_BEGIN_COLOR_GREEN 217.0/255.0
#define SECOND_BAR_PLOT_BEGIN_COLOR_BLUE 238.0/255.0
#define SECOND_BAR_PLOT_BEGIN_COLOR_ALPHA 1.0

#define SECOND_BAR_PLOT_END_COLOR_RED 187.0/255.0
#define SECOND_BAR_PLOT_END_COLOR_GREEN 217.0/255.0
#define SECOND_BAR_PLOT_END_COLOR_BLUE 238.0/255.0
#define SECOND_BAR_PLOT_END_COLOR_ALPHA 0.5

#define GRADIENT_ANGLE 90.0

- (CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    CPTGradient *gradient;
    CPTColor *begin = [CPTColor colorWithComponentRed:BAR_PLOT_BEGIN_COLOR_RED
                                                green:BAR_PLOT_BEGIN_COLOR_GREEN
                                                 blue:BAR_PLOT_BEGIN_COLOR_BLUE
                                                alpha:BAR_PLOT_BEGIN_COLOR_ALPHA];
    CPTColor *end = [CPTColor colorWithComponentRed:BAR_PLOT_END_COLOR_RED
                                              green:BAR_PLOT_END_COLOR_GREEN
                                               blue:BAR_PLOT_END_COLOR_BLUE
                                              alpha:BAR_PLOT_END_COLOR_ALPHA];
    if ([SECOND_PLOT_TITLE isEqualToString:barPlot.title]) {
        CPTColor *begin = [CPTColor colorWithComponentRed:SECOND_BAR_PLOT_BEGIN_COLOR_RED
                                                    green:SECOND_BAR_PLOT_BEGIN_COLOR_GREEN
                                                     blue:SECOND_BAR_PLOT_BEGIN_COLOR_BLUE
                                                    alpha:SECOND_BAR_PLOT_BEGIN_COLOR_ALPHA];
        CPTColor *end = [CPTColor colorWithComponentRed:SECOND_BAR_PLOT_END_COLOR_RED
                                                  green:SECOND_BAR_PLOT_END_COLOR_GREEN
                                                   blue:SECOND_BAR_PLOT_END_COLOR_BLUE
                                                  alpha:SECOND_BAR_PLOT_END_COLOR_ALPHA];
        gradient = [CPTGradient gradientWithBeginningColor:begin
                                               endingColor:end];
    } else {
        gradient = [CPTGradient gradientWithBeginningColor:begin endingColor:end];
    }
    gradient.angle = GRADIENT_ANGLE;
    return [CPTFill fillWithGradient:gradient];
}

#pragma mark Plot creation methods

-(void) addPlotWithTitle:(NSString *) title ofType:(GkhPlotType) type
{
    switch (type) {
        case GkhPlotTypeBar:[self addBarGraphWithTitle:title];break;
        case GkhPlotTypeCircle:break;
        case GkhPlotTypeXY:break;
        default:break;
    }
}

// moving arrow options
#define ARROW_OFFSET_X 16.0f
#define ARROW_OFFSET_Y 4.5f
#define ARROW_WIDTH 16.0f
#define ARROW_HEIGHT 16.0f
#define ARROW_PICTURE @"triangle"
#define ARROW_PICTURE_TYPE @"png"

-(CALayer *) createMovingArrow:(CGRect) rect
{
    CALayer *layer = [CALayer layer];
    [layer setFrame:rect];
    NSString *path = [[NSBundle mainBundle] pathForResource:ARROW_PICTURE ofType:ARROW_PICTURE_TYPE];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    layer.contents = (id)(image.CGImage);
    layer.contentsGravity = kCAGravityCenter;
    layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    return layer;
}

#define PLOT_SPACE_X_MIN 0.0f
#define PLOT_SPACE_Y_MIN 0.0f
#define PLOT_SPACE_X_MAX 1.0f
#define PLOT_SPACE_Y_MAX 1.0f

#pragma mark Bar plot 

#define PLOT_AREA_FRAME_PADDING_LEFT 10.0f
#define PLOT_AREA_FRAME_PADDING_RIGHT 10.0f
#define PLOT_AREA_FRAME_PADDING_TOP 30.0f
#define PLOT_AREA_FRAME_PADDING_BOTTOM 100.0f

#define GRAPH_PADDING_RIGHT 5.0f
#define GRAPH_PADDING_LEFT 5.0f
#define GRAPH_PADDING_TOP 5.0f
#define GRAPH_PADDING_BOTTOM 20.0f

#define PLOT_AREA_PADDING_LEFT 0.0f
#define PLOT_AREA_PADDING_BOTTOM 100.0f

-(void) addBarGraphWithTitle:(NSString *) title
{
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphHostingView.frame];
    self.graphHostingView.hostedGraph = graph;
    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;
    [plotAreaFrame setPaddingLeft:PLOT_AREA_FRAME_PADDING_LEFT];
    [plotAreaFrame setPaddingRight:PLOT_AREA_FRAME_PADDING_RIGHT];
    [plotAreaFrame setPaddingTop:PLOT_AREA_FRAME_PADDING_TOP];
    [plotAreaFrame setPaddingBottom:PLOT_AREA_FRAME_PADDING_BOTTOM];
    
    CGRect arrowRect = CGRectMake(plotAreaFrame.bounds.origin.x + ARROW_OFFSET_X,
                                  plotAreaFrame.bounds.origin.y + ARROW_OFFSET_Y,
                                  ARROW_WIDTH,
                                  ARROW_HEIGHT);
    CALayer *arrow = [self createMovingArrow:arrowRect];
    [plotAreaFrame addSublayer:arrow];
    BarPlotDelegate *barPlotDelegate = [[BarPlotDelegate alloc] init];
    barPlotDelegate.arrow = arrow;
    self.plotDelegate = barPlotDelegate;
            
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(PLOT_SPACE_X_MIN)
                                                    length:CPTDecimalFromFloat(PLOT_SPACE_X_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(PLOT_SPACE_Y_MIN)
                                                    length:CPTDecimalFromFloat(PLOT_SPACE_Y_MAX)];
    [self configureBarGraphAxes:graph];
    graph.paddingLeft = GRAPH_PADDING_LEFT;
    graph.paddingRight = GRAPH_PADDING_RIGHT;
    graph.paddingTop = GRAPH_PADDING_TOP;
    graph.paddingBottom = GRAPH_PADDING_BOTTOM;
    
    CPTPlotArea *plotArea = graph.plotAreaFrame.plotArea;
    plotArea.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor whiteColor].CGColor]];
    
    [self addBarPlot:graph withTitle:title];
}

#define BAR_PLOT_SHADOW_RADIUS 20.0f
#define BAR_PLOT_SHADOW_OFFSET_WIDTH 1.0f
#define BAR_PLOT_SHADOW_OFFSET_HEIGHT 1.0f
#define BAR_PLOT_CORNER_RADIUS 5.0f
#define BAR_PLOT_WIDTH 0.2f
#define SECOND_PLOT_POSTFIX @"2"

-(void) addBarPlot:(CPTGraph *) graph withTitle:(NSString *) title
{
    CPTBarPlot *plot = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    plot.lineStyle = nil;
    plot.dataSource = self;
    plot.delegate = self.plotDelegate;
    plot.shadowRadius = BAR_PLOT_SHADOW_RADIUS;
    plot.shadowOffset = CGSizeMake(BAR_PLOT_SHADOW_OFFSET_WIDTH, BAR_PLOT_SHADOW_OFFSET_HEIGHT);
    plot.shadowColor = [[CPTColor blackColor] cgColor];
    plot.barCornerRadius = BAR_PLOT_CORNER_RADIUS;
    plot.barWidth = CPTDecimalFromDouble(BAR_PLOT_WIDTH);
    plot.identifier = title;
    [graph addPlot:plot];
    
    CPTBarPlot *plot2 = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    plot2.lineStyle = nil;
    plot2.dataSource = self;
    plot2.delegate = self.plotDelegate;
    plot2.title = SECOND_PLOT_TITLE;
    plot2.barWidth = CPTDecimalFromDouble(BAR_PLOT_WIDTH);
    plot2.barCornerRadius = BAR_PLOT_CORNER_RADIUS;
    plot2.identifier = [title stringByAppendingString:SECOND_PLOT_POSTFIX];
    [graph addPlot:plot2];
}

#define AXIS_LABEL_COLOR_ALPHA 0.8f
#define AXIS_FONT_SIZE 9.0f
#define AXIS_TITLE_FONT_SIZE 13.0f
#define AXIS_TITLE_FONT_NAME @"Helvetica"

#define X_AXIS_TITLE @"Период"
#define X_AXIS_TITLE_OFFSET 0.0f

#define Y_AXIS_TITLE @"Начислено"
#define Y_AXIS_TITLE_OFFSET 0.0f

#define AXIS_LINE_WIDTH 1.0f
#define AXIS_LINE_COLOR_ALPHA 0.3f

#define Y_AXIS_MINOR_TICK_LENGTH 4.0f
#define Y_AXIS_LABEL_OFFSET 0.0f
#define Y_AXIS_TICK_MINOR_INC 0.1f
#define Y_AXIS_MAJOR_TICK_LABEL @""

-(void) configureBarGraphAxes:(CPTGraph *) graph
{
    CPTMutableTextStyle *axisLabelStyle = [CPTMutableTextStyle textStyle];
    axisLabelStyle.color = [[CPTColor darkGrayColor] colorWithAlphaComponent:AXIS_LABEL_COLOR_ALPHA];
    axisLabelStyle.fontSize = AXIS_FONT_SIZE;
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithCGColor:self.mainTextColor.CGColor];
    axisTitleStyle.fontName = AXIS_TITLE_FONT_NAME;
    axisTitleStyle.fontSize = AXIS_TITLE_FONT_SIZE;
    
    xyAxisSet.xAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.xAxis.title = X_AXIS_TITLE;
    xyAxisSet.xAxis.titleOffset = X_AXIS_TITLE_OFFSET;
    
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    //    xyAxisSet.yAxis.title = Y_AXIS_TITLE;
    xyAxisSet.yAxis.titleOffset = Y_AXIS_TITLE_OFFSET;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = AXIS_LINE_WIDTH;
    axisLineStyle.lineColor = [[CPTColor darkGrayColor] colorWithAlphaComponent:AXIS_LINE_COLOR_ALPHA];
    
    xyAxisSet.yAxis.labelTextStyle = axisLabelStyle;
    
    //----------- major ticks
    xyAxisSet.yAxis.minorTickLength = Y_AXIS_MINOR_TICK_LENGTH;
    xyAxisSet.yAxis.tickDirection = CPTSignPositive;
    xyAxisSet.yAxis.labelOffset = Y_AXIS_LABEL_OFFSET;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    
    for (CGFloat j = Y_AXIS_TICK_MINOR_INC; j <= PLOT_SPACE_Y_MAX; j += Y_AXIS_TICK_MINOR_INC) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:Y_AXIS_MAJOR_TICK_LABEL
                                                       textStyle:axisLabelStyle];
        NSDecimal location = CPTDecimalFromCGFloat(j);
        label.tickLocation = location;
        label.offset = -xyAxisSet.yAxis.majorTickLength - xyAxisSet.yAxis.labelOffset;
        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
    }
    
    xyAxisSet.yAxis.axisLabels = yLabels;
    xyAxisSet.yAxis.majorTickLocations = yMajorLocations;

    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.yAxis.axisLineStyle = nil;
    xyAxisSet.xAxis.axisLineStyle = nil;
    xyAxisSet.yAxis.majorGridLineStyle = axisLineStyle;
    xyAxisSet.yAxis.majorTickLineStyle = nil;
    
    xyAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xyAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
}

@end
