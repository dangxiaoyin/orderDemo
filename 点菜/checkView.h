//
//  checkView.h
//  点菜
//
//  Created by xyyf on 15/4/25.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WelcomeViewController.h"

@interface checkView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    FMDatabase *_database;
    NSMutableArray *_allMenuArray;
    NSMutableArray *_nameArray;
    NSMutableArray *_priceArray;
    NSMutableArray *_kindArray;
    NSMutableArray *_numArray;
    NSMutableArray *_remarkArray;

    
}


@property (nonatomic,assign) int selectBtnTag;

@end
