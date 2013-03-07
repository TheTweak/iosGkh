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
#import "HomeTableDataSource.h"

@interface HomeViewController ()
- (void)addPlot:(NSString *)title
         ofType:(NSString *)type;
- (void)configureGraph:(NSString *)title
                ofType:(NSString *)type;
- (void)configureAxes;
@property (nonatomic, strong) CPTGraphHostingView *hostingView;
@property (nonatomic, strong) Nach                *nachDS;
@property (nonatomic, strong) CPTAnnotation       *leftSideAnnotation;
@property (nonatomic, strong) CPTAnnotation       *rightSideAnnotation;
@property (nonatomic, strong) CALayer             *strelka;
@property (nonatomic, strong) CALayer             *strelkaPie;
@property (nonatomic, strong) CALayer             *upperHalfBorderLayer;
@property (nonatomic, strong) CALayer             *bottomHalfBorderLayer;
@property (nonatomic, strong) HomeTableDataSource *tableDataSource;
@property (nonatomic, strong) NSMutableDictionary *graphDictionary;
@property (nonatomic) NSUInteger lastSelectedPieChartSliceIdx;
@end

@implementation HomeViewController

CGFloat const CPDBarWidth    = 0.2f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize navigationBar =                _navigationBar;
@synthesize toolbar =                      _toolbar;
@synthesize nachDS =                       _nachDS;
@synthesize strelka =                      _strelka;
@synthesize strelkaPie =                   _strelkaPie;
@synthesize hostingView =                  _hostingView;
@synthesize leftSideAnnotation =           _leftSideAnnotation;
@synthesize rightSideAnnotation =          _rightSideAnnotation;
@synthesize tableDataSource =              _tableDataSource;
@synthesize graphDictionary =              _graphDictionary;
@synthesize upperHalfBorderLayer =         _upperHalfBorderLayer;
@synthesize bottomHalfBorderLayer =        _bottomHalfBorderLayer;
@synthesize lastSelectedPieChartSliceIdx = _lastSelectedPieChartSliceIdx;

// enabling shake event!

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

// shake motion handler

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        CPTPlot *plot = [self.hostingView.hostedGraph.allPlots objectAtIndex:0];
        [plot reloadData];
        NSLog(@"SHAKEEE");
    }
}

//

-(Nach *)nachDS
{
    if(!_nachDS) _nachDS = [[Nach alloc] init];
    return _nachDS;
}

-(NSDictionary *)graphDictionary
{
    if (!_graphDictionary) _graphDictionary = [NSMutableDictionary dictionary];
    return _graphDictionary;
}

-(HomeTableDataSource *)tableDataSource
{
    if(!_tableDataSource) _tableDataSource = [[HomeTableDataSource alloc] init];
    return _tableDataSource;
}

- (CPTGraphHostingView *)hostingView
{
    if (!_hostingView) {
        CGRect hostViewRect = CGRectMake(self.view.frame.origin.x,
                                         0.0f + self.view.bounds.size.height / 2,
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height / 2);
        
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:hostViewRect];
        _hostingView = hostView;
    }
    return _hostingView;
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

/*
 Pie chart click handler
 */
- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSNumber *flsCount = [self.nachDS numberForPlot:plot field:CPTPieChartFieldSliceWidth recordIndex:idx];
        
    if (!self.leftSideAnnotation) {
        CPTLayerAnnotation *annotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:plot];
        CPTTextLayer *textLayer = [CPTTextLayer layer];
        CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
        annotationTextStyle.color = [CPTColor orangeColor];
        annotationTextStyle.fontName = @"Helvetica-Bold";
        annotationTextStyle.fontSize = 13.0f;
        
        textLayer.textStyle = annotationTextStyle;
        annotation.contentLayer = textLayer;
        
        annotation.displacement = CGPointMake(-100.0, -5.0);
        [plot addAnnotation:annotation];
        
        self.leftSideAnnotation = annotation;
    }
    
    if (!self.rightSideAnnotation) {
        CPTLayerAnnotation *annotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:plot];
        CPTTextLayer *textLayer = [CPTTextLayer layer];
        CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
        annotationTextStyle.color = [CPTColor orangeColor];
        annotationTextStyle.fontName = @"Helvetica-Bold";
        annotationTextStyle.fontSize = 13.0f;
        
        textLayer.textStyle = annotationTextStyle;
        annotation.contentLayer = textLayer;
        
        annotation.displacement = CGPointMake(80.0, -5.0);
        [plot addAnnotation:annotation];
        
        self.rightSideAnnotation = annotation;
    }
    
    CPTLayerAnnotation *leftLayerAnnotation = (CPTLayerAnnotation *) self.leftSideAnnotation;
    CPTTextLayer *leftAnnotationTextLayer = (CPTTextLayer *) leftLayerAnnotation.contentLayer;
    leftAnnotationTextLayer.text = [NSString stringWithFormat:@"Дом №%d", idx + 1];
    
    CPTLayerAnnotation *rightLayerAnnotation = (CPTLayerAnnotation *) self.rightSideAnnotation;
    CPTTextLayer *rightAnnotationTextLayer = (CPTTextLayer *) rightLayerAnnotation.contentLayer;
    rightAnnotationTextLayer.text = [NSString stringWithFormat:@"Кол-во ФЛС:%d",     [flsCount intValue]];
    
    /*
    CGFloat startAngle = 1.5 * M_PI;
    if (self.lastSelectedPieChartSliceIdx != -1) {
        startAngle = [plot medianAngleForPieSliceIndex:self.lastSelectedPieChartSliceIdx];
    }
    CGFloat medianAngle = [plot medianAngleForPieSliceIndex:idx];
        
//    self.strelkaPie.anchorPoint = CGPointMake(5.0, 5.0);
    
//    self.strelkaPie.transform = CATransform3DMakeRotation(medianAngle, 0.0, 0.0, 1.0);
    
    // Set rotation animation
    CATransform3D rotationTransform = CATransform3DMakeRotation(medianAngle, 0.0, 0.0, 1.0);
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    
    [self.strelkaPie addAnimation:rotationAnimation forKey:@"transform"];
    
    
    UIBezierPath *solidPath = [UIBezierPath bezierPathWithArcCenter:plot.position
                                                              radius:plot.pieRadius
                                                          startAngle:startAngle
                                                            endAngle:medianAngle
                                                           clockwise:YES];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];

//    anim.rotationMode = kCAAnimationRotateAuto;
    anim.duration = 1.0;
    anim.path = solidPath.CGPath;
    anim.delegate = self;
    anim.fillMode = kCAFillModeBoth;
    [anim setValue:@"pieChart" forKey:@"animType"];
//    [anim setValue:solidPath forKey:@"path"];
    [self.strelkaPie addAnimation:anim forKey:nil];
    */
//    self.lastSelectedPieChartSliceIdx = idx;
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

- (void) addPlot:(NSString *)title ofType:(NSString *)type
{
    [self configureGraph:title ofType:type];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.hostingView];
    float width = self.view.bounds.size.width,
          height = self.view.bounds.size.height,
          borderWidth = 3.0f;
    
    CGRect upperHalfRect = CGRectMake(0.0f, 0.0f, width, height / 2 - 5.0f);
    
    CGRect bottomHalfRect = CGRectMake(0.0f, height / 2 - 3.0f, width, height / 2 - 2.0f);
    
    CGRect upperHalfRectForTableView = CGRectMake(5.0f, 45.0f, width - 10.0f, height / 2 - 47.0f);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:upperHalfRectForTableView
                                                          style:UITableViewStylePlain];
    
    tableView.backgroundColor = [UIColor blackColor];
    tableView.separatorColor = [UIColor darkGrayColor];
    tableView.dataSource = self.tableDataSource;
    tableView.delegate = self;
    // --------- Table header
    CGRect tableLabelRect = CGRectMake(0.0f, 0.0f, width, 44.0f);
    UILabel *tableLabel = [[UILabel alloc] initWithFrame:tableLabelRect];
    tableLabel.text = @"МосЭнерго";
    tableLabel.textAlignment = NSTextAlignmentCenter;
    tableLabel.textColor = [UIColor orangeColor];
    tableLabel.backgroundColor = [UIColor darkGrayColor];
    // Create the path (with only the top-left, and top-right corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:tableLabel.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = tableLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the label view's layer
    tableLabel.layer.mask = maskLayer;
    
    [self.view addSubview:tableLabel];
    
    [self.view addSubview:tableView];
    // --------- top screen layer
    CALayer *layer = [CALayer layer];
    [layer setFrame:upperHalfRect];
    [layer setCornerRadius:12.0];
    [layer setBorderWidth:borderWidth];
    [layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [layer setOpacity:0.75];
    self.upperHalfBorderLayer = layer;
    
    [[self.view layer] addSublayer:layer];
    // --------- bottom screen layer
    CALayer *bottomLayer = [CALayer layer];
    [bottomLayer setFrame:bottomHalfRect];
    [bottomLayer setCornerRadius:12.0];
    [bottomLayer setBorderWidth:borderWidth];
    [bottomLayer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [bottomLayer setOpacity:0.75];
    self.bottomHalfBorderLayer = bottomLayer;
    
    [[self.view layer] addSublayer:bottomLayer];
}

- (void) configureBarGraph:(NSString *)title {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.bottomHalfBorderLayer.frame];
    [self.graphDictionary setObject:graph forKey:title];
    self.hostingView.hostedGraph = graph;
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:27.0f];
    [graph.plotAreaFrame setPaddingBottom:35.0f];
    graph.plotAreaFrame.backgroundColor = [UIColor blackColor].CGColor;
    
    //---- strelka
    
    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;
    
    CALayer *layer = [CALayer layer];
    [layer setFrame:CGRectMake(plotAreaFrame.bounds.origin.x + 16.0f,
                               plotAreaFrame.bounds.origin.y + 18.0f,
                               16.0f,
                               16.0f)];
    
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
    xyAxisSet.yAxis.titleOffset = 260.0f;
    
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
    [self configureBarPlot:graph withTitle:title];
}

- (void) configurePieGraph:(NSString *)title
{
    // set left and right annotations to nil
    
    self.rightSideAnnotation = nil;
    self.leftSideAnnotation = nil;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.frame];
    [self.graphDictionary setObject:graph forKey:title];
    self.hostingView.hostedGraph = graph;
    [graph.plotAreaFrame setPaddingLeft:0.0f];
    [graph.plotAreaFrame setPaddingRight:0.0f];
    [graph.plotAreaFrame setPaddingTop:0.0f];
    [graph.plotAreaFrame setPaddingBottom:0.0f];
    graph.plotAreaFrame.backgroundColor = [UIColor blackColor].CGColor;
    
    [self configurePieChart:graph withTitle:title];
    
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
    CPTMutableLineStyle *legendLineStyle = [CPTMutableLineStyle lineStyle];
    legendLineStyle.lineColor = [CPTColor darkGrayColor];
    legendLineStyle.lineWidth = 2.0f;
    CPTMutableTextStyle *legendTextStyle = [CPTMutableTextStyle textStyle];
    legendTextStyle.color = [CPTColor whiteColor];
    theLegend.textStyle = legendTextStyle;
    theLegend.borderLineStyle = legendLineStyle;
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 22);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

- (void) configureBarPlot:(CPTGraph *)graph withTitle: (NSString *) title {
    CPTBarPlot *plot = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    plot.lineStyle = nil;
    plot.dataSource = self.nachDS;
    plot.delegate = self;
    plot.title = title;
    plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
    [graph addPlot:plot];
}

- (void)configurePieChart:(CPTGraph *)graph withTitle: (NSString *) title
{
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self.nachDS;
    pieChart.delegate = self;
    pieChart.title = title;
    CGFloat pieRadius = (self.hostingView.bounds.size.height * 0.7) / 2;
    pieChart.pieRadius = pieRadius;
    pieChart.pieInnerRadius = pieRadius / 4;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    pieChart.labelOffset = -pieRadius + pieRadius * 3/7;
    CPTMutableShadow *shadow = [CPTMutableShadow shadow];
    shadow.shadowColor = [CPTColor blackColor];
    shadow.shadowOffset = CGSizeMake(1.0f, -1.0f);
    shadow.shadowBlurRadius = 0.0f;
    pieChart.labelShadow = shadow;
    // 4 - Add chart to graph
    [graph addPlot:pieChart];
        
    //set to -1 last selected idx
    self.lastSelectedPieChartSliceIdx = -1;
}

- (void) configureGraph:(NSString *)title ofType:(NSString *)type
{
    if ([@"bar" isEqualToString:type]) {
        [self configureBarGraph:title];
    } else if([@"pie" isEqualToString:type]) {
        [self configurePieGraph:title];
    }
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

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"oglFlip";
    animation.subtype = @"fromLeft";
    animation.delegate = self;
    NSString *value;
    CPTPlotAreaFrame *plotAreaFrame;
    switch (indexPath.row) {
        case 0:
        {
            CPTGraph *graph = (CPTGraph *) [self.graphDictionary valueForKey:@"nach"];
            if (graph) {
                self.hostingView.hostedGraph = graph;
            } else {
                [self addPlot:@"nach" ofType:@"bar"];
            }
            break;
        }
        case 1:
        {
//            value = @"fls";
            [self addPlot:@"fls" ofType:@"pie"];
            break;
        }
        case 2:
        {
//            value = @"dpu";
            [self addPlot:@"ДПУ" ofType:@"xy"];
            break;
        }
        default:
            break;
    }
    [animation setValue:value forKey:@"animType"];
    if (!plotAreaFrame) {
        [self.hostingView.layer addAnimation:animation forKey:nil];
    } else {
        //    [plotAreaFrame addAnimation:animation forKey:nil];
    }
}

- (void) animationDidStart:(CAAnimation *)anim
{
    NSLog(@"strelka start pos=%@", NSStringFromCGPoint(self.strelkaPie.position));
    NSString *value = [anim valueForKey:@"animType"];
    if ([@"nach" isEqualToString:value]) {
        NSLog(@"nachAnim");
    } else if([@"fls" isEqualToString:value]) {
        NSLog(@"flsAnim");
    }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString *value = [anim valueForKey:@"animType"];
    if ([@"nach" isEqualToString:value]) {
        
    } else if([@"fls" isEqualToString:value]) {
        NSLog(@"flsAnim");
    } else if([@"pieChart" isEqualToString:value]) {
        NSLog(@"strelka end pos=%@", NSStringFromCGPoint(self.strelkaPie.position));
        /*CAKeyframeAnimation *keyFrameAnim = (CAKeyframeAnimation *) anim;
        CGPathRef pathRef = keyFrameAnim.path;
        NSMutableArray* a = [NSMutableArray arrayWithObject:[NSNumber numberWithBool:YES]];
        CGPathApply(pathRef, (__bridge void *)(a), MyCGPathApplierFunc);
        CGPoint endPoint;
        for (NSInteger i = 1, l = [a count]; i < l; i++)
        {
            NSDictionary* d = [a objectAtIndex:i];
            int type = [[d objectForKey:@"type"] intValue];
            
            CGPoint* points = (CGPoint*) [[d objectForKey:@"points"] bytes];

            if (type == kCGPathElementAddCurveToPoint) {
                NSLog(@"point=%@", NSStringFromCGPoint(*points));
                endPoint = *points;
            }
        }
        self.strelkaPie.position = endPoint;*/
    }
}

// Callback function for CGPathRef
// used to get path endpoint
static void MyCGPathApplierFunc (void *info, const CGPathElement *element)
{
    NSMutableArray* a = (__bridge NSMutableArray*) info;
	int nPoints;
	switch (element->type)
	{
		case kCGPathElementMoveToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddLineToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddQuadCurveToPoint:
			nPoints = 2;
			break;
		case kCGPathElementAddCurveToPoint:
			nPoints = 3;
			break;
		case kCGPathElementCloseSubpath:
			nPoints = 0;
			break;
		default:
			return;
	}
    
    NSNumber* type = [NSNumber numberWithInt:element->type];
	NSData* points = [NSData dataWithBytes:element->points length:nPoints*sizeof(CGPoint)];
	[a addObject:[NSDictionary dictionaryWithObjectsAndKeys:type,@"type",points,@"points",nil]];
}

@end