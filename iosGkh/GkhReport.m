//
//  GkhReport.m
//  iosGkh
//
//
//  Created by Sorokin E on 24.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "GkhReport.h"

@interface GkhReport ()
@property NSString *id;
@property NSString *name;
@property NSString *description;
@property NSArray *additionalRepresentationArray;
@property NSArray *inputParamArray;
@property GkhPlotType plotType;
// для быстрого получения параметра по его айди
@property NSDictionary *paramIndexToId;
@end

@interface GkhRepresentation ()
@property NSString *id;
@property GkhRepresentationType type;
@end

@implementation GkhRepresentation

@synthesize dataSource = _dataSource;

static NSDictionary* _typeByString;

+(GkhRepresentationType)representationTypeOf:(NSString *)type {
    if (!_typeByString) {
        _typeByString = @{@"table": [NSNumber numberWithInt:GkhRepresentationTypeTable]};
    }
    return (GkhRepresentationType)[[_typeByString objectForKey:type] intValue];
}

+(id)representation:(NSString *)id ofType:(GkhRepresentationType)type {
    GkhRepresentation *representation = [[GkhRepresentation alloc] init];
    representation.id = id;
    representation.type = type;
    return representation;
}
@end

@interface GkhInputType ()
@property NSString *id;
@property NSString *description;
@property GkhInputRepresentationType representationType;
@end

@implementation GkhInputType

static NSDictionary* _inputTypeByString;

+(id)inputParam:(NSString *)id description:(NSString *)description representation:(GkhRepresentationType)repType value:(id)value {
    GkhInputType *input = [[GkhInputType alloc] init];
    input.id = id;
    input.description = description;
    input.representationType = repType;
    input.value = [value copy];
    return input;
}
+(GkhInputRepresentationType)representationTypeOf:(NSString *)type {
    if (!_inputTypeByString) {
        _inputTypeByString = @{@"combo": [NSNumber numberWithInt:GkhInputRepresentationTypeCombo]};
    }
    return (GkhInputRepresentationType) [[_inputTypeByString objectForKey:type] intValue];
}
@end

@implementation GkhReport

static NSDictionary* _plotTypeByString;

+(GkhPlotType)plotTypeOf:(NSString *)type {
    if (!_plotTypeByString) {
        _plotTypeByString = @{@"BAR_PLOT": [NSNumber numberWithInt:GkhPlotTypeBar],
                              @"PIE_CHART": [NSNumber numberWithInt:GkhPlotTypeCircle],
                              @"XY_PLOT" : [NSNumber numberWithInt:GkhPlotTypeXY]};
    }
    return (GkhPlotType) [[_plotTypeByString objectForKey:type] intValue];
}

+(id)              report:(NSString *)id
                 withName:(NSString *)name
              description:(NSString *)description
additionalRepresentations:(NSArray *)additionalReps
                   inputs:(NSArray *)inputs
                 plotType:(GkhPlotType)plotType {
                     GkhReport *report = [[GkhReport alloc] init];
                     report.id = id;
                     report.name = name;
                     report.description = description;
                     report.plotType = plotType;
                     report.inputParamArray = inputs;
                     report.additionalRepresentationArray = additionalReps;
                     
                     NSMutableDictionary *paramIdxToId = [NSMutableDictionary dictionary];
                     for (int i = inputs.count - 1; i >= 0; i--) {
                         GkhInputType *input = (GkhInputType *) [inputs objectAtIndex:i];
                         NSNumber *paramIndex = [NSNumber numberWithInt:i];
                         [paramIdxToId setValue:paramIndex forKey:input.id];
                     }
                     report.paramIndexToId = [paramIdxToId copy];
                     
                     return report;
}

-(GkhInputType *)getInputParam:(NSString *)id {
    NSNumber *paramIndex = [self.paramIndexToId objectForKey:id];
    return [self.inputParamArray objectAtIndex:paramIndex];
}

@end
