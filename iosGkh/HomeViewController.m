//
//  HomeViewController.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 08.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "HomeViewController.h"
#import "MetricSelectionViewController.h"
#import "BarPlotSelectingArrow.h"
#import "HomeTableDataSource.h"
#import "CustomView.h"
#import "CustomViewController.h"
#import "Constants.h"
#import "BarPlotDelegate.h"
#import "PieChartDelegate.h"
#import "CorePlotUtils.h"
#import "BasicAuthModule.h"
#import "ActionSheetStringPicker.h"
#import "SBJsonParser.h"
#import "GkhReportPlotDataSource.h"
#import "GkhReportParamTableViewController.h"
#import "GkhReportParamTableDataSource.h"

@interface HomeViewController ()
@property (nonatomic, strong) HomeTableDataSource *tableDataSource;
@property (nonatomic, strong) NSMutableDictionary *graphDictionary;
@property (nonatomic, strong) UIActivityIndicatorView *loadingMask;
@property (nonatomic, strong) UIActivityIndicatorView *tableLoadingMask;
// mapping between param id and his plot data source
@property (nonatomic, strong) NSMutableDictionary *paramToCPDataSource;
// graph hosting view
@property (nonatomic, strong) CPTGraphHostingView *graphView;
// array of view controllers, that could be pages in the page control
// of the current on-screen graph
@property (nonatomic, strong) NSMutableArray *pageViewControllersArray;
@property (nonatomic) BOOL pageControlUsed;
// mapping between graph and array of pages to scroll between at
// bottom of the screen
@property (nonatomic, strong) NSMutableDictionary *graphToPagesDictionary;
// current on-screen plot's delegate
@property id<CPTPlotDelegate> plotDelegate;
// scope label
@property (nonatomic, strong) UILabel *scopeLabel;
@property CGRect portraitGraphViewRect;
@property CGRect portraitBottomViewRect;
@property CGSize contentSize;
@property float landscapePageSize;
@property float landscapeScrollViewHeight;
@property CGRect portraitPageIndicatorRect;
@property int onScreenPageNumber;
@property NSMutableArray *periodFieldControllerArray;
// выбранные значения для запроса графика
@property(nonatomic, strong) NSMutableDictionary *selectedValues;
// для выбора этих значений
@property UITableView *selectValuesView;
// индекс строки таблицы на которую нажали
@property NSInteger selectedRow;
// id отчета на который нажимали последний раз
@property NSString *selectedReportId;
// анимация при нажатии на строчку таблицы
@property (nonatomic)  CATransition *rowSelectAnimation;
@property (nonatomic)  UIColor *backgroundColor;
@property (nonatomic) UIColor *mainTextColor;
@property UIScrollView *bottomView;
@end

@implementation HomeViewController

CGFloat const CPDBarWidth    = 0.2f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize tableDataSource =              _tableDataSource;
@synthesize graphDictionary =              _graphDictionary;
@synthesize loadingMask =                  _loadingMask;
@synthesize tableView =                    _tableView;
@synthesize graphView =                    _graphView;
@synthesize tableLoadingMask =             _tableLoadingMask;
@synthesize paramToCPDataSource =          _paramToCPDataSource;
@synthesize pageControlView =              _pageControlView;
@synthesize pageViewControllersArray =     _pageViewControllersArray;
@synthesize graphToPagesDictionary =       _graphToPagesDictionary;
@synthesize scopeLabel =                   _scopeLabel;
@synthesize rowSelectAnimation =           _rowSelectAnimation;
@synthesize backgroundColor = _backgroundColor;
@synthesize bottomView = _bottomView;

-(UIColor *)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1.0];
    }
    return _backgroundColor;
}

-(UIColor *)mainTextColor {
    if (!_mainTextColor) {
        _mainTextColor = [UIColor darkTextColor];
    }
    return _mainTextColor;
}

#pragma mark UIView stuff

- (void) viewDidLoad {
    [super viewDidLoad];
    [self registerForNotifications];
    self.title = @"Отчеты";
    UITableView *tableView = self.tableView;
    tableView.backgroundColor = self.backgroundColor;
    tableView.separatorColor = [UIColor darkGrayColor];
    tableView.dataSource = self.tableDataSource;
    tableView.delegate = self;
    //self.pageControlView.numberOfPages = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    CGRect tableRect = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.rowHeight * 3);
    self.tableView.frame = tableRect;
    CGRect scrollViewRect = CGRectMake(0, tableRect.size.height,
                                       self.view.frame.size.width, self.view.frame.size.height - tableRect.size.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.bottomView = scrollView;
    scrollView.backgroundColor = self.backgroundColor;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    [navBar setTintColor:[UIColor colorWithRed:32.0/255.0 green:107.0/255.0 blue:164.0/255.0 alpha:1.0]];
    float graphViewWidth = self.bottomView.frame.size.width
        ,graphViewHeight = self.bottomView.frame.size.height;
    self.graphView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0,
                                                                           graphViewWidth,
                                                                           graphViewHeight)];
    self.bottomView.contentSize = CGSizeMake(graphViewWidth * 1, 0);
    [self.bottomView addSubview:self.graphView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *) scrollView {
    if (scrollView != self.bottomView) {
        return;
    }
    int pageNumber = [self determineCurrentPageNumber:scrollView.contentOffset.x];
    self.pageControlView.currentPage = pageNumber;
    if (pageNumber > 0) {
        CPTPlot *current = [self.graphView.hostedGraph.allPlots objectAtIndex:0];
        NSArray *pages = [self.graphToPagesDictionary valueForKey:[current title]];
        UIViewController *viewController = (UIViewController *) [pages objectAtIndex:pageNumber - 1];
        UITableView *tableView = (UITableView *) viewController.view;
        [tableView reloadData];
    }
    NSLog(@"EndDecelerating:%i", pageNumber);
}

#pragma mark UIViewController
#pragma mark Accessors

-(CATransition *)rowSelectAnimation {
    if (!_rowSelectAnimation) {
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 0.5;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = @"oglFlip";
        animation.subtype = @"fromLeft";
        animation.delegate = self;
        _rowSelectAnimation = animation;
    }
    return _rowSelectAnimation;
}

- (UILabel *) scopeLabel {
    if (!_scopeLabel) {
        CGRect frame = CGRectMake(5, 0,
                                  self.bottomView.frame.size.width, 32);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = self.backgroundColor;
        label.font = [UIFont fontWithName:@"Helvetica-Regular" size:16.0];
        label.textColor = self.mainTextColor;
        label.shadowColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        _scopeLabel = label;
        
        [self.bottomView addSubview:_scopeLabel];
    }
    return _scopeLabel;
}

- (NSDictionary *) graphDictionary {
    if (!_graphDictionary) _graphDictionary = [NSMutableDictionary dictionary];
    return _graphDictionary;
}

- (HomeTableDataSource *) tableDataSource {
    if(!_tableDataSource) _tableDataSource = [[HomeTableDataSource alloc] init];
    return _tableDataSource;
}

- (UIActivityIndicatorView *) loadingMask {
    if (!_loadingMask) {
        _loadingMask = [[UIActivityIndicatorView alloc] initWithFrame:self.graphView.bounds];
        [_loadingMask hidesWhenStopped];
        [self.graphView addSubview:_loadingMask];
    }
    return _loadingMask;
}

- (UIActivityIndicatorView *) tableLoadingMask {
    if (!_tableLoadingMask) {
        _tableLoadingMask = [[UIActivityIndicatorView alloc] initWithFrame:self.tableView.bounds];
        [_tableLoadingMask hidesWhenStopped];
        [self.tableView addSubview:_tableLoadingMask];
    }
    return _tableLoadingMask;
}

- (NSMutableDictionary *) paramToCPDataSource {
    if (!_paramToCPDataSource) {
        _paramToCPDataSource = [[NSMutableDictionary alloc] init];
    }
    return _paramToCPDataSource;
}

- (NSMutableDictionary *) graphToPagesDictionary {
    if (!_graphToPagesDictionary) {
        _graphToPagesDictionary = [[NSMutableDictionary alloc] init];
    }
    return _graphToPagesDictionary;
}

- (NSMutableDictionary *) selectedValues {
    if (!_selectedValues) {
        _selectedValues = [NSMutableDictionary dictionary];
    }
    return _selectedValues;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
    // выбранный отчет
    GkhReport *report = [self.tableDataSource gkhReportAt:indexPath.row];
    if (self.selectedReportId && [self.selectedReportId isEqualToString:report.id]) {
        return;
    }
    self.selectedReportId = report.id;
    [self resetLabels];
    CALayer *layer = (CALayer *) self.graphView.layer;
    [layer addAnimation:self.rowSelectAnimation forKey:nil];
    
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    // necessary request param, unique identifier of requesting data
    [requestParameters setValue:report.id forKey:@"type"];
    
    // other, param-dependent parameters
    for (GkhInputType *input in report.inputParamArray) {
        [requestParameters setValue:input.value forKey:input.id];
    }
    [self showLoadingMask];
    [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post succeeded");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseJson = [jsonParser objectWithString:responseString];
        if ([responseJson valueForKey:@"scope"]) {
            NSString *label = [NSString stringWithFormat:@"%@/%@", [responseJson valueForKey:@"scope"], [responseJson valueForKey:@"year"]];
            self.scopeLabel.text = label;
        }
        NSArray *result = [responseJson objectForKey:@"values"];
        // создаем дата сорс для графика этого отчета
        GkhReportPlotDataSource *plotDataSource = [[GkhReportPlotDataSource alloc] init];
        plotDataSource.values = result;
        if (!report.plotDataSource) {
            report.plotDataSource = plotDataSource;
        }
        // draw graph
        [self addPlot:report.id ofType:report.plotType dataSource:report.plotDataSource];
        /*
         // clear views
         if (self.pageViewControllersArray) {
         for (int i = 0, l = self.pageViewControllersArray.count; i < l; i++) {
         UIViewController *controller = [self.pageViewControllersArray objectAtIndex:i];
         UIView *view = controller.view;
         [view removeFromSuperview];
         }
         }
         NSMutableArray *pageViewControllers = [NSMutableArray array];
         for (GkhRepresentation *representation in report.additionalRepresentationArray) {
         int i = 0;
         switch (representation.type) {
         case GkhRepresentationTypeTable: {
         UITableViewController *tableViewController = [[UITableViewController alloc]
         initWithStyle:UITableViewStylePlain];
         [pageViewControllers addObject:tableViewController];
         UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(320 * (i + 1), 0, 320, 200)];
         tableViewController.view = tableView;
         
         Nach *dataSource = [[Nach alloc] init];
         dataSource.tableNeedsReloading = NO;
         dataSource.paramId = representation.id;
         dataSource.homeTableDS = self.tableDataSource;
         if (!representation.dataSource) {
         representation.dataSource = dataSource;
         }
         
         tableView.dataSource = dataSource;
         tableView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
         tableView.separatorColor = [UIColor darkGrayColor];
         tableView.layer.cornerRadius = 8.0f;
         [self.bottomView addSubview:tableView];
         
         UITextField *period = [[UITextField alloc] initWithFrame:CGRectMake(320 * (i + 1) + 5,
         tableView.frame.size.height + 10,
         310, 40)];
         period.placeholder = @"Период";
         period.textAlignment = NSTextAlignmentCenter;
         period.delegate = self;
         period.borderStyle = UITextBorderStyleRoundedRect;
         period.font = [UIFont systemFontOfSize:15];
         period.clearButtonMode = UITextFieldViewModeWhileEditing;
         period.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
         period.backgroundColor = [UIColor underPageBackgroundColor];
         period.textColor = [UIColor yellowColor];
         period.tag = 14 + i;
         [self.bottomView addSubview:period];
         break;
         }
         default:
         break;
         }
         i++;
         }
         self.pageControlView.numberOfPages = pageViewControllers.count + 1;
         self.bottomView.contentSize = CGSizeMake((1 + pageViewControllers.count) * self.graphView.frame.size.width, 0);
         //    [self.graphToPagesDictionary setValue:pageViewControllers forKey:paramId];
         self.pageViewControllersArray = pageViewControllers;
         */
        [self hideLoadingMask];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        [self hideLoadingMask];
    }];
}

- (void)tableView:(UITableView *)tableView
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
    GkhReport *gkhReport = [self.tableDataSource gkhReportAt:indexPath.row];
    CGFloat width = self.view.frame.size.width,
            height = self.tableView.frame.size.height;
    if (!self.selectValuesView) {
        UITableView *paramTable = [[UITableView alloc] initWithFrame:CGRectMake(width, 0, width, height)
                                                               style:UITableViewStylePlain];
        
        paramTable.backgroundColor = self.backgroundColor;
        paramTable.separatorColor = [UIColor darkGrayColor];
        paramTable.editing = NO;
        [paramTable registerNib:[UINib nibWithNibName:@"ParamTableCell" bundle:nil]
         forCellReuseIdentifier:@"ParamTableCell"];
        self.selectValuesView = paramTable;
    }
    self.selectValuesView.dataSource = gkhReport.paramDataSource;
    self.selectValuesView.delegate = gkhReport.paramDataSource;
    [self.view addSubview:self.selectValuesView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.selectValuesView.frame = CGRectMake(0, 0, width, height);
                     } completion:^(BOOL finished) {
                         self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад"
                                                                                                  style:UIBarButtonItemStylePlain
                                                                                                 target:self
                                                                                                 action:@selector(backButtonHandler)];
                         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                                target:self
                                                                                                                action:@selector(refreshButtonHandler)];
                         
                     }];
}

#pragma mark Core plot stuff

#pragma mark Configuring plots and graphs and axes

- (void) configureBarGraph:(NSString *)title dataSource:(id<CPTPlotDataSource>)ds {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphView.frame];
    [self.graphDictionary setObject:graph forKey:title];
    self.graphView.hostedGraph = graph;
    
    [graph.plotAreaFrame setPaddingLeft:10.0f];
    [graph.plotAreaFrame setPaddingRight:10.0f];
    [graph.plotAreaFrame setPaddingTop:65.0f];
    [graph.plotAreaFrame setPaddingBottom:25.0f];
    CGColorRef underPage = self.backgroundColor.CGColor;
    graph.plotAreaFrame.backgroundColor = underPage;
    
    //---- strelka
    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;
    
    CALayer *layer = [CALayer layer];
    [layer setFrame:CGRectMake(plotAreaFrame.bounds.origin.x + 16.0f,
                               plotAreaFrame.bounds.origin.y + 4.5f,
                               16.0f,
                               16.0f)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    layer.contents = (id)(image.CGImage);
    layer.contentsGravity = kCAGravityCenter;
    layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    [plotAreaFrame addSublayer:layer];

    BarPlotDelegate *barPlotDelegate = [[BarPlotDelegate alloc] init];
    barPlotDelegate.arrow = layer;
    barPlotDelegate.homeVC = self;
    self.plotDelegate = barPlotDelegate;
        
    CGFloat xMin = 0.0f;
    CGFloat xMax = 1.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 1.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin)
                                                    length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin)
                                                    length:CPTDecimalFromFloat(yMax)];
    
    // configure axes
    [self configureAxes:graph yMax:yMax];
    
    graph.paddingLeft = graph.paddingRight = graph.paddingTop = 5.0f;
    graph.paddingBottom = 25.0f;
    
    CPTPlotArea *plotArea = graph.plotAreaFrame.plotArea;
    plotArea.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:underPage]];
    plotArea.paddingLeft = 50.0f;
    
    [self configureBarPlot:graph withTitle:title dataSource:ds];
}

- (void) configurePieGraph:(NSString *)title dataSource:(id<CPTPlotDataSource>)ds {
    // set left and right annotations to nil
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphView.frame];
    [self.graphDictionary setObject:graph forKey:title];
    self.graphView.hostedGraph = graph;
    [graph.plotAreaFrame setPaddingLeft:0.0f];
    [graph.plotAreaFrame setPaddingRight:0.0f];
    [graph.plotAreaFrame setPaddingTop:0.0f];
    [graph.plotAreaFrame setPaddingBottom:0.0f];
    CGColorRef underPage = self.backgroundColor.CGColor;
    graph.plotAreaFrame.backgroundColor = underPage;
    graph.paddingBottom = 25.0f;
    // instantiating delegate
    PieChartDelegate *pieChartDelegate = [[PieChartDelegate alloc] init];
    self.plotDelegate = pieChartDelegate;
    
    [self configurePieChart:graph withTitle:title dataSource:ds];
    
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:underPage]];
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
    CGFloat legendPadding = -(self.view.bounds.size.width / 36);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

- (void) configureXYGraph:(NSString *)title dataSource:(id<CPTPlotDataSource>)ds {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphView.frame];
    self.graphView.hostedGraph = graph;
    CGColorRef underPage = self.backgroundColor.CGColor;
    graph.plotAreaFrame.backgroundColor = underPage;
    graph.paddingLeft = graph.paddingRight = graph.paddingTop = 5.0f;
    graph.paddingBottom = 25.0f;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(10)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(21)];
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingRight:5.0f];
    [graph.plotAreaFrame setPaddingTop:30.0f];
    [graph.plotAreaFrame setPaddingBottom:25.0f];
    
    // axes
    
    // label text style
    CPTMutableTextStyle *axisLabelStyle = [CPTMutableTextStyle textStyle];
    axisLabelStyle.color = [[CPTColor grayColor] colorWithAlphaComponent:0.8f];
    axisLabelStyle.fontSize = 9.0f;
    // title axis style
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [[CPTColor darkGrayColor] colorWithAlphaComponent:1.0f];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 13.0f;
    // axis line style
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.8f];
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    // x axis title
    CPTLineCap *lineCap = [CPTLineCap solidArrowPlotLineCap];
    lineCap.lineStyle = axisLineStyle;
    xyAxisSet.xAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.xAxis.title = @"Период";
    xyAxisSet.xAxis.titleOffset = 5.0f;
    xyAxisSet.xAxis.axisLineStyle = axisLineStyle;
    xyAxisSet.xAxis.labelTextStyle = nil;
    xyAxisSet.xAxis.axisLineCapMax = lineCap;
    // y axis
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.yAxis.title = @"Показания";
    xyAxisSet.yAxis.titleOffset = 5.0f;
    xyAxisSet.yAxis.axisLineStyle = axisLineStyle;
    xyAxisSet.yAxis.labelTextStyle = nil;
    xyAxisSet.yAxis.axisLineCapMax = lineCap;
    // ticks
    
    // plot
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    CPTMutableShadow *shadow = [CPTMutableShadow shadow];
    shadow.shadowColor = [CPTColor darkGrayColor];
    shadow.shadowBlurRadius = 0.5;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    plot.shadow = shadow;
    plot.interpolation = CPTScatterPlotInterpolationCurved;
    plot.dataSource = ds;
    plot.labelTextStyle = nil;
    CPTColor *begin = [CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:1];
    CPTColor *end = [CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:.2];
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:begin endingColor:end];
    gradient.angle = 90.0f;
//    plot.areaFill = [CPTFill fillWithGradient:gradient];
    plot.areaBaseValue = [[NSNumber numberWithFloat:0.0] decimalValue];
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineColor = [CPTColor greenColor];
    lineStyle.lineWidth = 2.0;
    plot.dataLineStyle = lineStyle;
    [graph addPlot:plot];
}

- (void) configureBarPlot:(CPTGraph *)graph withTitle: (NSString *) title
               dataSource:(id<CPTPlotDataSource>)ds {
    CPTBarPlot *plot = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    plot.lineStyle = nil;
    plot.dataSource = ds;
    plot.delegate = self.plotDelegate;
    /*CPTMutableShadow *shadow = [CPTMutableShadow shadow];
    shadow.shadowColor = [CPTColor blackColor];
    shadow.shadowBlurRadius = 1;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    plot.shadow = shadow;*/
    plot.shadowRadius = 20.0;
    plot.shadowOffset = CGSizeMake(1.0, 1.0);
    plot.shadowColor = [[CPTColor blackColor] cgColor];
    plot.barCornerRadius = 5.0;
    plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
    plot.identifier = title;
    [graph addPlot:plot];
    
    CPTBarPlot *plot2 = [[CPTBarPlot alloc] initWithFrame:graph.frame];
    plot2.lineStyle = nil;
    plot2.dataSource = ds;
    plot2.delegate = self.plotDelegate;
    plot2.title = @"sec";
    plot2.barWidth = CPTDecimalFromDouble(CPDBarWidth);
    plot2.barCornerRadius = 5.0;
    plot2.identifier = [title stringByAppendingString:@"2"];
    [graph addPlot:plot2];
}

- (void) configurePieChart:(CPTGraph *)graph withTitle: (NSString *) title
                dataSource:(id<CPTPlotDataSource>)ds {
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = ds;
    pieChart.delegate = self.plotDelegate;
    pieChart.title = title;
    CGFloat pieRadius = (self.graphView.bounds.size.height * 0.7) / 2;
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
}

- (void) configureGraph:(NSString *)title ofType:(GkhPlotType)type
             dataSource:(id<CPTPlotDataSource>)ds {
    switch (type) {
        case GkhPlotTypeBar    : [self configureBarGraph:title dataSource:ds]; break;
        case GkhPlotTypeCircle : [self configurePieGraph:title dataSource:ds]; break;
        case GkhPlotTypeXY     : [self configureXYGraph:title dataSource:ds];  break;
        default: break;
    }
}

- (void) configureAxes:(CPTGraph *)graph yMax:(CGFloat)yMax {
    CPTMutableTextStyle *axisLabelStyle = [CPTMutableTextStyle textStyle];
    axisLabelStyle.color = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.8f];
    axisLabelStyle.fontSize = 9.0f;
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *) graph.axisSet;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithCGColor:self.mainTextColor.CGColor];
    axisTitleStyle.fontName = @"Helvetica";
    axisTitleStyle.fontSize = 13.0f;
    
    xyAxisSet.xAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.xAxis.title = @"Период";
    xyAxisSet.xAxis.titleOffset = 5.0f;
    
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
//    xyAxisSet.yAxis.title = @"Начислено";
    xyAxisSet.yAxis.titleOffset = 260.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.3f];
    
    xyAxisSet.yAxis.labelTextStyle = axisLabelStyle;
    
    //----------- major ticks
    xyAxisSet.yAxis.minorTickLength = 4.0f;
    xyAxisSet.yAxis.tickDirection = CPTSignPositive;
    xyAxisSet.yAxis.labelOffset = 15.0f;
    
    CGFloat minorInc = 0.1;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    
    for (CGFloat j = minorInc; j <= yMax; j += minorInc) {
//        NSString *text = [NSString stringWithFormat:@"%f", j];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:@""
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
    //-----------------------
    xyAxisSet.yAxis.titleTextStyle = axisTitleStyle;
    xyAxisSet.yAxis.axisLineStyle = nil;
    xyAxisSet.xAxis.axisLineStyle = nil;
    xyAxisSet.yAxis.majorGridLineStyle = axisLineStyle;
    xyAxisSet.yAxis.majorTickLineStyle = nil;
    
    xyAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xyAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
}

#pragma mark Other stuff

- (void) resetLabels {
    self.scopeLabel.text = @"";
    [self.graphView.hostedGraph.plotAreaFrame.plotArea removeAllAnnotations];
}

- (void) addScopeLabel:(NSNotification *)notification {
    [self resetLabels];
    NSString *text = [notification.userInfo valueForKey:@"scopeLabel"];
    self.scopeLabel.text = text;
}

- (void) pan:(UIPanGestureRecognizer *)recognizer {
    if ((recognizer.state == UIGestureRecognizerStateChanged) ||
        (recognizer.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGRect rect = CGRectMake(recognizer.view.frame.origin.x + translation.x
                                 ,recognizer.view.frame.origin.y + translation.y
                                 ,recognizer.view.frame.size.width
                                 ,recognizer.view.frame.size.height);
        recognizer.view.frame = rect;
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

- (void) addPlot:(NSString *)title ofType:(GkhPlotType)type dataSource:(id<CPTPlotDataSource>) ds {
    [self configureGraph:title ofType:type dataSource:ds];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectMetrics"]) {
        MetricSelectionViewController *metricsVC = (MetricSelectionViewController *) segue.destinationViewController;
        metricsVC.metricConsumer = self;
    }
}

- (void) addNewMetricByString:(NSString *)identifier {
    
}

- (int) determineCurrentPageNumber:(float) offset {
    return offset / self.view.frame.size.width;
}

// get status bar size
- (CGRect)statusBarFrameViewRect:(UIView*)view {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
    CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
    return statusBarViewRect;
}

#pragma mark Notifications

- (void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingMask)
                                                 name:@"ShowLoadingMask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTableLoadingMask)
                                                 name:@"ShowTableLoadingMask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingMask)
                                                 name:@"HideLoadingMask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTableLoadingMask)
                                                 name:@"HideTableLoadingMask"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataForCurrentOnScreenPlot)
                                                 name:@"ReloadCurrentGraph"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableData:)
                                                 name:@"UpdateTableData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addScopeLabel:)
                                                 name:@"ShowScopeLabel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentPeriodField:)
                                                 name:@"UpdatePeriodField"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paramInputFieldTapped:)
                                                 name:@"ParamInputFieldTapped"
                                               object:nil];
}

#pragma mark Notification handlers

// Show loading indicator
- (void) showLoadingMask {
    NSLog(@"showing load mask");
    [self.loadingMask startAnimating];
}

- (void) showTableLoadingMask {
    NSLog(@"showing table load mask");
    [self.tableLoadingMask startAnimating];
}

// Hide loading indicator
- (void) hideLoadingMask {
    NSLog(@"hiding load mask");
    [self.loadingMask stopAnimating];
}

- (void) hideTableLoadingMask {
    NSLog(@"hiding table loading mask");
    [self.tableLoadingMask stopAnimating];
}

- (void) reloadDataForCurrentOnScreenPlot {
    NSLog(@"reloading current graph");
    [self.graphView.hostedGraph reloadData];
}

// update current page period text field
-(void) updateCurrentPeriodField:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    [self _updateCurrentPeriodField:[userInfo objectForKey:@"period"]
     reloadTable:[[userInfo objectForKey:@"needReload"] boolValue]];
}

-(void) _updateCurrentPeriodField:(NSString *) period
                      reloadTable:(BOOL) reload{
}

// обработчик нажатия на поле выбора параметра графика
- (void)paramInputFieldTapped:(NSNotification *)notification {
    NSLog(@"param input field tapped");
    if (!notification) return;
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
    NSString *paramId = [notification.userInfo valueForKey:@"inputId"];
    NSString *fieldDescription = [notification.userInfo valueForKey:@"pickerDescription"];
    
    if (!paramId) return;
#warning TODO : loading mask
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:paramId, @"param", nil];
    if ([@"uk" isEqualToString:paramId]) {
        NSString *selectedKladr = [self.selectedValues valueForKey:@"kladr"];
        if (selectedKladr) {
            [requestParams setValue:selectedKladr forKey:@"value"];
            [requestParams setValue:@"kladr" forKey:@"prevParam"];
        }
    } else if ([@"serv" isEqualToString:paramId]) {
        NSString *selectedUK = [self.selectedValues valueForKey:@"uk"];
        if (selectedUK) {
            [requestParams setValue:selectedUK forKey:@"value"];
            [requestParams setValue:@"uk" forKey:@"prevParam"];            
        }
    }
    [client postPath:@"param/value/list" parameters:requestParams success:^(AFHTTPRequestOperation *operation,
                                                                            id responseObject) {
        NSLog(@"post succeeded");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = [responseJson objectAtIndex:i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:fieldDescription
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex,
                                                       id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               UITextField *inputField = (UITextField *) notification.object;
                                               NSString *value = [selectedJson valueForKey:@"name"];
                                               inputField.text = value;
                                               [self.selectedValues setValue:[selectedJson valueForKey:@"id"]
                                                                      forKey:paramId];
                                               NSLog(@"selected: %@", selectedJson);
                                               // Загрузить 
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"cancel");
                                         }
                                              origin:self.view];
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}

#pragma mark UITextField delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"period field tapped");
    
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
#warning TODO : loading mask
    NSDictionary *requestParams = @{@"param": @"period"};
    [client postPath:@"param/value/list" parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post succeeded");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = [responseJson objectAtIndex:i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"Период"
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               [self _updateCurrentPeriodField:[selectedJson valueForKey:@"name"]
                                                                   reloadTable:YES];
                                               NSLog(@"selected: %@", selectedJson);
                                         }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"cancel");
                                         }
                                              origin:self.view];
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
    return NO;
}

#pragma mark Обработчики кнопок на панели задания параметров графика

// кнопка Назад на экране выбора параметров для графика
-(void) backButtonHandler {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGFloat width = self.view.frame.size.width,
                         height = self.tableView.frame.size.height;
                         self.selectValuesView.frame = CGRectMake(width, 0, width, height);
                     } completion:^(BOOL finished) {
                         [self.selectValuesView removeFromSuperview];
                     }];
}

// Кнопка обновить на экране выбора параметров для графика
-(void)refreshButtonHandler {
    NSLog(@"refresh button clicked");
    
    /*CPTBarPlot *barPlot = [self.graphView.hostedGraph.allPlots objectAtIndex:0];
    [CorePlotUtils setAnchorPoint:CGPointMake(0.0, 0.0) forPlot:barPlot];
    CABasicAnimation *scaling = [CABasicAnimation
                                 animationWithKeyPath:@"transform.scale.y"];
    scaling.fromValue = [NSNumber numberWithFloat:1.0];
    scaling.toValue = [NSNumber numberWithFloat:1.2];
    scaling.duration = 1.0f; // Duration
    scaling.removedOnCompletion = NO;
    scaling.fillMode = kCAFillModeForwards;
    [barPlot addAnimation:scaling forKey:@"scaling"];*/
    
    // выбранный отчет
    GkhReport *report = [self.tableDataSource gkhReportAt:self.selectedRow];
    
    AFHTTPClient *client = [BasicAuthModule httpClient];
    
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    // necessary request param, unique identifier of requesting data
    [requestParameters setValue:report.id forKey:@"type"];
    
    // other, param-dependent parameters
    for (GkhInputType *input in report.inputParamArray) {
        [requestParameters setValue:input.value forKey:input.id];
    }
    [self showLoadingMask];
    [self resetLabels];
    [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Reloading report %@ succeeded", report.id);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseJson = [jsonParser objectWithString:responseString];
        if ([responseJson valueForKey:@"scope"]) {
            NSString *label = [NSString stringWithFormat:@"%@/%@", [responseJson valueForKey:@"scope"], [responseJson valueForKey:@"year"]];
            self.scopeLabel.text = label;
        }
        NSArray *result = [responseJson objectForKey:@"values"];
        // создаем дата сорс для графика этого отчета
        if (!report.plotDataSource) {
            GkhReportPlotDataSource *plotDataSource = [[GkhReportPlotDataSource alloc] init];
            plotDataSource.values = result;
            report.plotDataSource = plotDataSource;
        }
        ((GkhReportPlotDataSource *) report.plotDataSource).values = result;
        [self reloadDataForCurrentOnScreenPlot];
        [self hideLoadingMask];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Reloading report %@ failed", report.id);
        [self hideLoadingMask];
    }];
}

#pragma mark Rotate handler

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                 duration:(NSTimeInterval)duration {
    self.onScreenPageNumber = [self determineCurrentPageNumber:self.bottomView.contentOffset.x];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (![self.tableView isHidden]) {
            // landscape
            [self.tableView setHidden:YES];
            [self.navigationController.navigationBar setHidden:YES];
            CGRect rect = self.graphView.frame;
            if (CGRectIsEmpty(self.portraitGraphViewRect)) {
                self.portraitGraphViewRect = rect;
            }
            if (CGRectIsEmpty(self.portraitBottomViewRect)) {
                self.portraitBottomViewRect = self.bottomView.frame;
            }
            if (CGRectIsEmpty(self.portraitPageIndicatorRect)) {
                self.portraitPageIndicatorRect = self.pageControlView.frame;
            }
            self.pageControlView.frame = CGRectMake(self.view.window.frame.size.width / 4,
                                                    self.view.window.frame.size.height / 2
                                                    + self.portraitPageIndicatorRect.size.height - 8,
                                                    self.portraitPageIndicatorRect.size.width,
                                                    self.portraitPageIndicatorRect.size.height);
            self.contentSize = self.bottomView.contentSize;
            CGRect statusBarRect = [self statusBarFrameViewRect:self.view];
            float height = self.view.frame.size.height
            + self.navigationController.navigationBar.frame.size.height
            + statusBarRect.size.height;
            if (self.landscapePageSize == 0) {
                self.landscapePageSize = height;
            }
            [self.graphView setFrame:CGRectMake(rect.origin.x, rect.origin.y, height, rect.size.height)];
            self.bottomView.frame = self.graphView.frame;
            if (self.landscapeScrollViewHeight == 0) {
                self.landscapeScrollViewHeight = self.bottomView.frame.size.height;
            }
            for (int i = 0, l = [self.pageViewControllersArray count]; i < l; i++) {
                UIViewController *controller = [self.pageViewControllersArray objectAtIndex:i];
                UIView *view = controller.view;
                CGRect frame = CGRectMake(height * (i + 1), 0, height, rect.size.height);
                [view setFrame:frame];
            }
            self.bottomView.contentSize = CGSizeMake((1 + self.pageViewControllersArray.count) * height, 0);
        }
    } else {
        // portrait
        [self.tableView setHidden:NO];
        [self.navigationController.navigationBar setHidden:NO];
        [self.graphView setFrame:self.portraitGraphViewRect];
        self.bottomView.contentSize = self.contentSize;
        self.bottomView.frame = self.portraitBottomViewRect;
        self.pageControlView.frame = self.portraitPageIndicatorRect;
        for (int i = 0, l = [self.pageViewControllersArray count]; i < l; i++) {
            UIViewController *controller = [self.pageViewControllersArray objectAtIndex:i];
            UIView *view = controller.view;
            CGRect rect = self.portraitGraphViewRect;
            CGRect frame = CGRectMake(rect.size.width * (i + 1), 0, rect.size.width, self.portraitBottomViewRect.size.height);
            [view setFrame:frame];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // reload current table view
    int pageNumber = self.onScreenPageNumber;
    if (pageNumber - 1 != -1) {
        UIViewController *controller = [self.pageViewControllersArray objectAtIndex:pageNumber - 1];
        UIView *view = controller.view;
        UITableView *tableView = (UITableView *) view;
        [tableView reloadData];
    }
    CGPoint point;
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        point = CGPointMake(self.portraitBottomViewRect.size.width * pageNumber, 0);
    } else {
        point = CGPointMake(self.landscapePageSize * pageNumber, 0);
    }
    [self.bottomView setContentOffset:point animated:YES];
}

@end