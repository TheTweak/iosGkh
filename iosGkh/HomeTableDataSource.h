//
//  HomeTableDataSource.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GkhReport.h"

@interface HomeTableDataSource : NSObject <UITableViewDataSource>

// Получить отчет из таблицы по его индексу
-(GkhReport *) gkhReportAt:(NSUInteger) index;
// Установить значения входного параметра для отчета
-(void) setValue:(id)value forInputParam:(NSString *) paramId atIndex:(NSUInteger) index;
@end
