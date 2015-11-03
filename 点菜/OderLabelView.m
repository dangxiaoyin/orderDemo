//
//  OderLabelView.m
//  点菜
//
//  Created by xyyf on 15/4/20.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "OderLabelView.h"

@implementation OderLabelView


//  从沙盒中获取数据
-(void)getDataFromSanxBox
{
    FMDatabase *_database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
    if (![_database open]) {
        [_database close];
        return;
    }
//    查询
    FMResultSet *resultSet = [_database executeQuery:@"select *from orderTable"];
    
//    数组
    _numberArray = [[NSMutableArray alloc] initWithCapacity:0];
//    遍历
    while ([resultSet next])
    {
        NSString *menuNanme = [resultSet stringForColumn:@"menuName"];
        [_numberArray addObject:menuNanme];
    }
    
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = CGRectMake(200, 768-70, 250, 60);
//        self.backgroundColor = [UIColor redColor];
        
//        从沙盒中获取数据
        [self getDataFromSanxBox];
        
//        创建  label
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
        
        NSString *labString = [NSString stringWithFormat:@"已经点了 %d 种菜",_numberArray.count+1];
        numLabel.text = labString;
        numLabel.textColor = [UIColor yellowColor];
        numLabel.font = [UIFont fontWithName:nil size:30];
        [self addSubview:numLabel];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
