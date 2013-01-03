//
//  HomeViewController.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 08.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "HomeViewController.h"
#import "MetricSelectionViewController.h"
#import "Nach.h"

@interface HomeViewController ()
- (void)addPlot:(NSString *)title;
- (void)configureGraph:(NSString *)title;
- (void)configurePlot:(CPTGraph *)graph;
- (void)configureAxes;
@property (nonatomic, strong) CPTGraphHostingView *hostingView;
@property (nonatomic, strong) Nach *nachDS;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *nachAnnotation;
@end

@implementation HomeViewController

CGFloat const CPDBarWidth = 0.2f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize navigationBar = _navigationBar;
@synthesize toolbar = _toolbar;
@synthesize nachDS = _nachDS;

-(Nach *)nachDS
{
    if(!_nachDS) _nachDS = [[Nach alloc] init];
    return _nachDS;
}

/*
 Plot click handler
 */
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    if (plot.isHidden) return;
    NSNumber *price = [self.nachDS numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:idx];
    NSNumber *month = [self.nachDS numberForPlot:plot field:CPTBarPlotFieldBarLocation recordIndex:idx];
    
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor whiteColor];
        style.fontSize = 12.0f;
        style.fontName = @"Helvetica-Bold";
    }
    
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    
    if (!self.nachAnnotation) {
        NSNumber *x = [NSNumber numberWithInt:0];
        NSNumber *y = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.nachAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    
    NSString *priceValue = [formatter stringFromNumber:price];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
    self.nachAnnotation.contentLayer = textLayer;
    
    // 7 - Get the anchor point for annotation
    CGFloat x = [month floatValue];
    NSNumber *anchorX = [NSNumber numberWithFloat:x];
    CGFloat y = [price floatValue] - 0.8f;
    NSNumber *anchorY = [NSNumber numberWithFloat:y];
    self.nachAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    // 8 - Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.nachAnnotation];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if ((recognizer.state == UIGestureRecognizerStateChanged) ||
        (recognizer.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGRect rect = CGRectMake(recognizer.view.frame.origin.x + translation.x, recognizer.view.frame.origin.y + translation.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
        recognizer.view.frame = rect;
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

- (IBAction)testPlot:(UIBarButtonItem *)sender {
    [self addPlot:@""];
}

- (void) addPlot:(NSString *)title {
    [self configureGraph:title];
    [self configureAxes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addPlot:@"Начисления"];
}

- (void) configureGraph:(NSString *)title {
    CGRect hostViewRect = CGRectMake(self.view.frame.origin.x,
                                     0.0f + self.view.bounds.size.height / 2 - self.tabBarController.tabBar.bounds.size.height,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height / 2);
    
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:hostViewRect];
    
    /*
    UIPanGestureRecognizer *pangr =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [hostView addGestureRecognizer:pangr];
    */
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostViewRect];
    hostView.hostedGraph = graph;
//    graph.title = title;
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    [graph.plotAreaFrame setPaddingLeft:25.0f];
    [graph.plotAreaFrame setPaddingTop:10.0f];
    [graph.plotAreaFrame setPaddingBottom:20.0f];
    graph.plotAreaFrame.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor;
    
    CGFloat xMin = 0.0f;
    CGFloat xMax = 4.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 20.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    
    [self.view addSubview:hostView];
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    xyAxisSet.xAxis.delegate = self.nachDS;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    
    CPTMutableTextStyle *axisLabelStyle = [CPTMutableTextStyle textStyle];
    axisLabelStyle.color = [[CPTColor grayColor] colorWithAlphaComponent:0.8f];
    axisLabelStyle.fontSize = 9.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.3f];
    
    xyAxisSet.yAxis.labelTextStyle = axisLabelStyle;

    //----------- major ticks
    
    xyAxisSet.yAxis.minorTickLength = 4.0f;
    xyAxisSet.yAxis.tickDirection = CPTSignPositive;
    xyAxisSet.yAxis.labelOffset = 15.0f;
    
    NSInteger minorIncrement = 5;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];

    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j*100] textStyle:xyAxisSet.yAxis.labelTextStyle];
        NSDecimal location = CPTDecimalFromInteger(j);
        label.tickLocation = location;
        label.offset = -xyAxisSet.yAxis.majorTickLength - xyAxisSet.yAxis.labelOffset;
        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
    }
    
    xyAxisSet.yAxis.axisLabels = yLabels;
    xyAxisSet.yAxis.majorTickLocations = yMajorLocations;
    //-----------------------
    
    
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.yAxis.axisLineStyle = nil;
    xyAxisSet.xAxis.axisLineStyle = nil;
//    xyAxisSet.yAxis.majorGridLineStyle = axisLineStyle;
    xyAxisSet.yAxis.majorGridLineStyle = axisLineStyle;
    xyAxisSet.yAxis.majorTickLineStyle = nil;

    xyAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xyAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    [self configureAxes];
    
    graph.paddingLeft = graph.paddingRight = graph.paddingBottom = graph.paddingTop = 5.0f;
    
    CPTPlotArea *plotArea = graph.plotAreaFrame.plotArea;
    
    plotArea.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
    [self configurePlot:graph];
}

- (void) configurePlot:(CPTGraph *)graph {
    CPTBarPlot *test = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    test.lineStyle = nil;
    test.dataSource = self.nachDS;
    test.delegate = self;
    test.barWidth = CPTDecimalFromDouble(CPDBarWidth);
    [graph addPlot:test];
}

- (void) configureAxes {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectMetrics"]) {
        MetricSelectionViewController *metricsVC = (MetricSelectionViewController *) segue.destinationViewController;
        metricsVC.metricConsumer = self;
    }
}

- (void) addNewMetricByString:(NSString *)identifier
{
    [self addPlot:identifier];
}

@end