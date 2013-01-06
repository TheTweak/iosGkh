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
#import "BarPlotSelectingArrow.h"

@interface HomeViewController ()
- (void)addPlot:(NSString *)title;
- (void)configureGraph:(NSString *)title;
- (void)configurePlot:(CPTGraph *)graph;
- (void)configureAxes;
@property (nonatomic, strong) CPTGraphHostingView *hostingView;
@property (nonatomic, strong) Nach *nachDS;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *leftSideAnnotation;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *rightSideAnnotation;
@property (nonatomic, strong) CALayer *strelka;
@end

@implementation HomeViewController

CGFloat const CPDBarWidth = 0.2f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize navigationBar = _navigationBar;
@synthesize toolbar = _toolbar;
@synthesize nachDS = _nachDS;
@synthesize strelka = _strelka;
@synthesize hostingView = _hostingView;
@synthesize leftSideAnnotation = _leftSideAnnotation;
@synthesize rightSideAnnotation = _rightSideAnnotation;

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
    
    price = [NSNumber numberWithInt:([price intValue] * 100)];
    
    NSArray *monthsArray = [NSArray arrayWithObjects:@"Январь", @"Февраль",
                            @"Март", @"Апрель", @"Май",
                            @"Июнь", @"Июль", @"Август",
                            @"Сентябрь", @"Октябрь", @"Ноябрь",
                            @"Декабрь", nil];
    
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor orangeColor];
        style.fontSize = 13.0f;
        style.fontName = @"Helvetica-Bold";
    }
    
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
        [formatter setUsesGroupingSeparator:YES];
        [formatter setGroupingSize:3];
        [formatter setGroupingSeparator:@" "];
    }
    
    if (!self.leftSideAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:0.25f];
        NSNumber *y = [NSNumber numberWithFloat:21.5f];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.leftSideAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }

    if (!self.rightSideAnnotation) { 
        NSNumber *x = [NSNumber numberWithFloat:3.5f];
        NSNumber *y = [NSNumber numberWithFloat:21.5f];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.rightSideAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    
    NSString *priceValue = [[formatter stringFromNumber:price] stringByAppendingString:@"р."];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
    self.rightSideAnnotation.contentLayer = textLayer;
    
    NSString *monthValue = [monthsArray objectAtIndex:idx];
    textLayer = [[CPTTextLayer alloc] initWithText:monthValue style:style];
    self.leftSideAnnotation.contentLayer = textLayer;
    
    NSDecimal plotPoint[2]; // "plot" point coords
    plotPoint[CPTCoordinateX] = month.decimalValue;
    plotPoint[CPTCoordinateY] = price.decimalValue;
    CGPoint cgPlotPoint = [plot.plotSpace plotAreaViewPointForPlotPoint:plotPoint]; // plot view area coords
//    NSLog(@"plot point=%@", NSStringFromCGPoint(cgPlotPoint));
    
    CGPoint dataPoint = [plot.graph.plotAreaFrame convertPoint:cgPlotPoint fromLayer:plot.graph.plotAreaFrame.plotArea];
//    NSLog(@"converted plot point=%@", NSStringFromCGPoint(dataPoint));
    // 8 - Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.leftSideAnnotation];
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.rightSideAnnotation];
    
    //animation for strelka
    CABasicAnimation *animation = [CABasicAnimation animation];
    CGPoint newStrelkaPosition = CGPointMake(dataPoint.x, self.strelka.position.y);
    animation.toValue = [NSValue valueWithCGPoint:newStrelkaPosition];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    [self.strelka addAnimation:animation forKey:@"position"];
    [self.strelka setPosition:newStrelkaPosition];
//    CGPoint convertedPoint = [self.strelka convertPoint:newStrelkaPosition ];
//    NSLog(@"converted=%@", NSStringFromCGPoint(convertedPoint));
//    NSLog(@"position=%@", NSStringFromCGPoint(self.strelka.position));
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
    
    // --------- Layer playing
    CALayer *layer = [CALayer layer];
    [layer setFrame:CGRectMake(0.0f,
                               0.0f,
                               self.view.bounds.size.width,
                               self.view.bounds.size.height / 2 - self.tabBarController.tabBar.bounds.size.height)];
    [layer setCornerRadius:15.0];
    [layer setBorderWidth:3.0];
    [layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [layer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [layer setOpacity:0.75];
//    [layer setAnchorPoint:CGPointMake(1.0, 1.0)];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOffset:CGSizeMake(5.0, 5.0)];
    [layer setShadowOpacity:.8];
    [[self.view layer] addSublayer:layer];

    /*CABasicAnimation *animation = [CABasicAnimation animation];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(100.0, 100.0)]];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(100.0, 250.0)];
    [layer addAnimation:animation forKey:@"position"];*/
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
    [graph.plotAreaFrame setPaddingLeft:35.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:27.0f];
    [graph.plotAreaFrame setPaddingBottom:35.0f];
    graph.plotAreaFrame.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor;
    
    //---- strelka
    
    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;
    
    CALayer *layer = [CALayer layer];
    [layer setFrame:CGRectMake(plotAreaFrame.bounds.origin.x + 16.0f,
                               plotAreaFrame.bounds.origin.y + 18.0f,
                               16.0f,
                               16.0f)];
//    [layer setBorderWidth:1.0];
//    [layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
//    [layer setBackgroundColor:[[UIColor orangeColor] CGColor]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    layer.contents = (id)(image.CGImage);
    layer.contentsGravity = kCAGravityCenter;
    layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    [plotAreaFrame addSublayer:layer];
    
    self.strelka = layer;
    
    CGFloat xMin = 0.0f;
    CGFloat xMax = 4.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 20.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    
    
    CPTMutableTextStyle *axisLabelStyle = [CPTMutableTextStyle textStyle];
    axisLabelStyle.color = [[CPTColor grayColor] colorWithAlphaComponent:0.8f];
    axisLabelStyle.fontSize = 9.0f;
     
    [self.view addSubview:hostView];
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [[CPTColor grayColor] colorWithAlphaComponent:0.8f];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 13.0f;
    
    xyAxisSet.xAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.xAxis.title = @"Период";
    xyAxisSet.xAxis.titleOffset = 15.0f;
    
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.yAxis.title = @"Начислено";
    xyAxisSet.yAxis.titleOffset = 250.0f;
    
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