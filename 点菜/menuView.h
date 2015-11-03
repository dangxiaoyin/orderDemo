//
//  menuView.h
//  点菜
//
//  Created by xyyf on 15/4/18.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@interface menuView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_muneTableView;
    FMDatabase *_database;
    NSMutableArray *_kindArray;
    NSMutableArray *_kindHighArray;
    
    //    记录当前的索引
    NSIndexPath *_currentIndexPath;

}

@end
