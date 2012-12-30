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
@synthesize desktopView = _desktopView;
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

- (void) configureGraph:(NSString *)title {
    CGRect hostViewRect = CGRectMake(self.desktopView.frame.origin.x, self.desktopView.frame.origin.y, self.desktopView.bounds.size.width, self.desktopView.bounds.size.height/2);
    
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:hostViewRect];
    
    UIPanGestureRecognizer *pangr =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [hostView addGestureRecognizer:pangr];
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostViewRect];
    hostView.hostedGraph = graph;
//    graph.title = title;

    CGFloat xMin = 0.4f;
    CGFloat xMax = 4.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 20.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    
    [self.view addSubview:hostView];
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    xyAxisSet.xAxis.delegate = self.nachDS;
    
    [self configureAxes];
    [self configurePlot:graph];
}

- (void) configurePlot:(CPTGraph *)graph {
    CPTBarPlot *test = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    test.lineStyle = nil;
    test.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.5f green:0.8f blue:0.1f alpha:0.85f]];
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