//
//  GkhReport.h
//  iosGkh
//
//  Отчет, то что загружается в таблицу на главном экране пользователя с ролью УК.
//
//  Created by Sorokin E on 24.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GkhRepresentationTypeTable
} GkhRepresentationType;

// Описывает дополнительные представления отчета, в дополнение к графику. Они отображаются
// в scrollView вместе с графиком. Пока поддерживается только таблица.
@interface GkhRepresentation : NSObject

@property(readonly) NSString *id;
@property(readonly) GkhRepresentationType type;
+(id) representation:(NSString *) id ofType:(GkhRepresentationType) type;
+(GkhRepresentationType) representationTypeOf:(NSString *) type;
@end

// Тип контрола для параметра
typedef enum {
    GkhInputRepresentationTypeCombo // UITextField с выбором в виде UIActionSheet
} GkhInputRepresentationType;

// Типы входных параметров
@interface GkhInputType : NSObject

@property(readonly) NSString *id;
@property(readonly) NSString *description;
@property(readonly) GkhInputRepresentationType representationType;
@property id value; // значение параметра, которое посылается на сервер
+(id) inputParam:(NSString *) id description:(NSString *) description
  representation:(GkhRepresentationType) repType value:(id) value;
+(GkhInputRepresentationType) representationTypeOf:(NSString *) type;
@end

// Типы графиков
typedef enum {
    GkhPlotTypeBar, // гистограмма
    GkhPlotTypeXY,
    GkhPlotTypeCircle
} GkhPlotType;

@interface GkhReport : NSObject

@property(readonly) NSString *id;
@property(readonly) NSString *name;
@property(readonly) NSString *description;
@property(copy, readonly) NSArray *additionalRepresentationArray;
@property(copy, readonly) NSArray *inputParamArray;
@property(readonly) GkhPlotType plotType;

-(GkhInputType *) getInputParam:(NSString *) id;
+(id)               report:(NSString *) id
                  withName:(NSString *) name
               description:(NSString *) description
 additionalRepresentations:(NSArray *) additionalReps
                    inputs:(NSArray *) inputs
                  plotType:(GkhPlotType) plotType;
+(GkhPlotType) plotTypeOf:(NSString *) type;
@end
