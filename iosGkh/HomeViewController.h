//
//  HomeViewController.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 08.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "MetricConsumerProtocol.h"
#import "CorePlotUtils.h"

@interface HomeViewController : UIViewController <MetricConsumerProtocol, UITableViewDelegate,
                                                UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlView;
- (void) hideLoadingMask;
- (void) showLoadingMask;
- (void) updateRowAtIndex:(NSUInteger)row withData:(NSDictionary *)data;
// get meta-info about current selected parameter (table row)
- (NSDictionary *) selectedParameterMeta;
@end
