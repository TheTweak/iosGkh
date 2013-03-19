//
//  PieChartDelegate.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "PieChartDelegate.h"
@interface PieChartDelegate ()
@property (nonatomic, strong) CPTAnnotation *leftSideAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideAnnotation;
@end

@implementation PieChartDelegate

- (void) pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx {
    if (plot.isHidden) {
        return;        
    }
    NSNumber *sliceValue = [plot.dataSource numberForPlot:plot
                                                    field:CPTPieChartFieldSliceWidth
                                              recordIndex:idx];
    if (!self.leftSideAnnotation) {
        CPTLayerAnnotation *annotation = [[CPTLayerAnnotation alloc]
                                          initWithAnchorLayer:plot];
        CPTTextLayer *textLayer = [CPTTextLayer layer];
        textLayer.textStyle = [CorePlotUtils orangeHelvetica];
        annotation.contentLayer = textLayer;
        annotation.displacement = CGPointMake(-100.0, -5.0);
        [plot addAnnotation:annotation];
        
        self.leftSideAnnotation = annotation;
    }
    if (!self.rightSideAnnotation) {
        CPTLayerAnnotation *annotation = [[CPTLayerAnnotation alloc]
                                          initWithAnchorLayer:plot];
        CPTTextLayer *textLayer = [CPTTextLayer layer];
        textLayer.textStyle = [CorePlotUtils orangeHelvetica];
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
    rightAnnotationTextLayer.text = [NSString stringWithFormat:@"Кол-во ФЛС:%d",
                                     [sliceValue intValue]];
}

@end
