//
//  menuView.m
//  点菜
//
//  Created by xyyf on 15/4/18.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "menuView.h"
#import "MenuViewController.h"
#import "ChaPaiViewController.h"
#import "lengCaiViewController.h"
@implementation menuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame =CGRectMake(1024-70, 60, 40, 768-140);
        
        //    菜单视图 tableview
        _muneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 40, 768-140) style:UITableViewStylePlain];
        //    菜单行高
        _muneTableView.rowHeight = (768-140)/7;
        _muneTableView.delegate = self;
        _muneTableView.dataSource = self;
        
        //    区尾高度
        _muneTableView.sectionFooterHeight = 0;
        
        //    表设置为透明
        _muneTableView.backgroundColor = [UIColor clearColor];
        
        //  分割线设置为透明
        _muneTableView.separatorColor = [UIColor clearColor];
        
        
        [self addSubview:_muneTableView];
        [self bringSubviewToFront:_muneTableView];
        
        
        //    从数据库中获取数据
        _database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
        //    判断数据库是否正常打开
        if (![_database open]) {
            [_database close];
            return nil;
        }
        
        //    查询
        FMResultSet *resuleSet = [_database executeQuery:@"select *from groupTable"];
        
        //    用数组来接收数据库中取出的数据
        _kindArray = [[NSMutableArray alloc] initWithCapacity:0];
        _kindHighArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        //    遍历结果集
        while ([resuleSet next])
        {
            [_kindArray addObject:[resuleSet stringForColumn:@"image"]];
            [_kindHighArray addObject:[resuleSet stringForColumn:@"highlighted_image"]];
        }
        
    }
    return self;
}


//   菜单表
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _kindArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        
        //        选中行的状态
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, (768-140)/7)];
        imageView.tag = 1;
        [cell addSubview:imageView];
        
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = [UIImage imageNamed:[_kindArray objectAtIndex:indexPath.row]];
    
    
    return cell;
}


//  选中行的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentIndexPath == indexPath) {
        return;
    }
        //     设置NSIndexPath 来记录上次选中的行的索引值
        //     获取上一个选中的行
        UITableViewCell *frontCell = [tableView cellForRowAtIndexPath:_currentIndexPath];
        UIImageView *frontImageView = (UIImageView *)[frontCell viewWithTag:1];
        frontImageView.image = [UIImage imageNamed:[_kindArray objectAtIndex:_currentIndexPath.row]];
        
        //    通过indexPath获取cell
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        imageView.image = [UIImage imageNamed:[_kindHighArray objectAtIndex:indexPath.row]];
        _currentIndexPath = indexPath;
        
        //    进入下一个视图控制器
        [self enterNextViewController:indexPath];
}

-(void)enterNextViewController:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
        {
            MenuViewController *menuVC = [[MenuViewController alloc] init];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = menuVC;
        }
            break;
        case 1:
        {
            ChaPaiViewController *chaPaiVC = [[ChaPaiViewController alloc] init];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = chaPaiVC;
            
        }
            break;
            
        case 2:
        {
            lengCaiViewController *lengCaiVC = [[lengCaiViewController alloc] init];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = lengCaiVC;
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
            
        default:
            break;
    }
    
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
