//
//  HomeTableDataSource.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "HomeTableDataSource.h"

@implementation HomeTableDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor orangeColor];
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Начисления";
            cell.detailTextLabel.text = @"начисления по периодам за год";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"coins48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Количество ФЛС";
            cell.detailTextLabel.text = @"количество ФЛС по домам";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"fls48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Динамика показаний ДПУ";
            cell.detailTextLabel.text = @"изменение показаний ДПУ за период";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"stocks48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

@end
