//
//  MyDidOrder.h
//  点菜
//
//  Created by xyyf on 15/4/19.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
//  导入第三方库
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "OderLabelView.h"

@interface MyDidOrder : UIView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_myTableView;
    FMDatabase *_database;
    NSMutableArray *_nameArray;
    
    NSMutableArray *_menuNameArray;
    NSMutableArray *_priceArray;
    NSMutableArray *_kindArray;
    NSMutableArray *_idArray;
    
    NSMutableArray *_menuNumArray;
    NSMutableArray *_allPriceSumArray;
    int _sumAllNum;
    UIView *_myOrderView;
    
    NSMutableArray *_currentMenuNumArray;
    
    UIImageView *_detailSandOrderImageView;
    
    BOOL _clearTableView;
    BOOL _hasRoom;
    NSMutableArray *_groupIDArray;
    NSMutableArray *_remarkArray;
    int _groupID;
}
@end
