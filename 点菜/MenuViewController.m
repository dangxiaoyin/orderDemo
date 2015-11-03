//
//  MenuViewController.m
//  点菜
//
//  Created by xyyf on 15/4/17.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "MenuViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "menuView.h"
#import "MyDidOrder.h"


@interface MenuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    NSMutableArray *_picArray;
    FMDatabase *_database;
    UITableView *_zhuChuTableView;
    NSMutableArray *_titleArray;
    UIScrollView *_scrollView;
//    声明一个bool数组
    BOOL _isOpen[5];
    NSMutableArray *_baoArray;
    NSMutableArray *_canArray;
    NSMutableArray *_chiArray;
    NSMutableArray *_yanArray;
    NSMutableArray *_jiaoArray;
    NSMutableArray *_bigArray;
    
//    定义一个静态变量，记录上一行
    NSIndexPath *_frontIndexPath;
    
}
@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
//    小图片的可交互性
    _bgImageView.userInteractionEnabled = YES;
    _zhuChuImageView.userInteractionEnabled = YES;
    
//    从沙盒中获取对象
    _picArray = [[NSMutableArray alloc] initWithCapacity:0];
    _database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
    
    if (![_database open])
    {
        [_database close];
        return;
    }
    
//    查询结果集
    FMResultSet *resultSet = [_database executeQuery:@"select *from menuTable where groupID = 1"];
    
//    遍历结果集
    while ([resultSet next])
    {
        [_picArray addObject: [resultSet stringForColumn:@"picName"]];
    }
    
    //    滑动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    _scrollView.contentSize = CGSizeMake(1024*_picArray.count, 768);
    _scrollView.pagingEnabled = YES;
    
    [self.bgImageView addSubview:_scrollView];
    
    
//    滑动视图中添加图片
    for (int i = 0; i< _picArray.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1024*i, 0, 1024, 768)];
     
        imageView.image = [UIImage imageNamed:[_picArray objectAtIndex:i]];
        [_scrollView addSubview:imageView];
    }
    
    
//    ------------------------------------------------------
    
//    主厨推荐  折合表
    _zhuChuTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 100, 260, 660-110) style:UITableViewStyleGrouped];
    
    _zhuChuTableView.delegate = self;
    _zhuChuTableView.dataSource = self;
    _zhuChuTableView.separatorColor = [UIColor clearColor];
//    表设置为透明色，显示背景图片的颜色
    _zhuChuTableView.backgroundColor = [UIColor clearColor];
    
    [self.zhuChuImageView addSubview:_zhuChuTableView];
    
//    区尾高度是0
    _zhuChuTableView.sectionFooterHeight = 0;
    
//    数组  存放区头的标题
    _titleArray  = [[NSMutableArray alloc] initWithObjects:@"鲍",@"参",@"翅",@"燕",@"胶", nil];
    
    
    
//    获取数据库中  主厨推荐的数据
//    鲍 数据
    _baoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _canArray = [[NSMutableArray alloc] initWithCapacity:0];
    _chiArray = [[NSMutableArray alloc] initWithCapacity:0];
    _yanArray = [[NSMutableArray alloc] initWithCapacity:0];
    _jiaoArray = [[NSMutableArray alloc] initWithCapacity:0];

    if (![_database open])
    {
        [_database close];
        return;
    }
    //    查询结果集
    FMResultSet *baoResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"鲍"];
    FMResultSet *canResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"参"];
    FMResultSet *chiResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"翅"];
    FMResultSet *yanResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"燕"];
    FMResultSet *jiaoResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"胶"];
    
    //    遍历结果集
    while ([baoResultSet next])
    {
        [_baoArray addObject: [baoResultSet stringForColumn:@"name"]];
    }
    while ([canResultSet next])
    {
        [_canArray addObject: [canResultSet stringForColumn:@"name"]];
    }
    while ([chiResultSet next])
    {
        [_chiArray addObject: [chiResultSet stringForColumn:@"name"]];
    }
    while ([yanResultSet next])
    {
        [_yanArray addObject: [yanResultSet stringForColumn:@"name"]];
    }
    while ([jiaoResultSet next])
    {
        [_jiaoArray addObject: [jiaoResultSet stringForColumn:@"name"]];
    }

//  大数组来存放5个小数组
    _bigArray = [[NSMutableArray alloc] initWithObjects:_baoArray,_canArray,_chiArray,_yanArray,_jiaoArray, nil];
    
    
//    添加菜单View
    menuView *m_view = [[menuView alloc] init];
    [self.view addSubview:m_view];
    [self.view bringSubviewToFront:m_view];
   
    
//    添加我的菜单视图
    MyDidOrder *myOrder = [[MyDidOrder alloc] init];
    [self.view addSubview:myOrder];
}


//   主厨推荐表
//   设置行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    合
    if (_isOpen[section] == NO)
    {
        return 0;
    }
    NSMutableArray *smallArray = [_bigArray objectAtIndex:section];
    return smallArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        
//        选中行的状态
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableArray *smallArray = [_bigArray objectAtIndex:indexPath.section];

    for (int i = 0; i < _bigArray.count; i++)
    {
        if (indexPath.section == i)
        {
            cell.textLabel.text = [smallArray objectAtIndex:indexPath.row];
            cell.textLabel.tag = 2;
        }
    }
    
    return cell;
}

//  设置区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

// 自定义区头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor redColor];
    
//    折合按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 260, 60);
//   当前的区  作为button的tag值
    button.tag = section;
//    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    
//    标题
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 20, 60)];
    titleLable.text = [_titleArray objectAtIndex:section];
    titleLable.font = [UIFont fontWithName:nil size:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLable];
    
//    底线 图片
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 260, 40)];
    lineImageView.image = [UIImage imageNamed:@"line31"];
    [view addSubview:lineImageView];
    
    
    return view;
}

//  折合按钮的方法体
-(void)buttonClick:(UIButton *)btn
{
//    清除cell的底线图片
    UITableViewCell *frontCell = [_zhuChuTableView cellForRowAtIndexPath:_frontIndexPath];
    UIImageView *frontImageView = (UIImageView *)[frontCell viewWithTag:1];
    [frontImageView removeFromSuperview];

    _isOpen[btn.tag] = !_isOpen[btn.tag];
    
//    [_zhuChuTableView reloadData];   // 刷新的效率低
    
//    添加折合的动画
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag];
    [_zhuChuTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

//  选中当前行的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_frontIndexPath == indexPath)
    {
        return;
    }
    else
    {
        UITableViewCell *frontCell = [_zhuChuTableView cellForRowAtIndexPath:_frontIndexPath];
        UIImageView *frontImageView = (UIImageView *)[frontCell viewWithTag:1];
        [frontImageView removeFromSuperview];
        
        //     通过indexPath  获取当前的cell
        UITableViewCell *cell = [_zhuChuTableView cellForRowAtIndexPath:indexPath];
        
        //     添加底线的图片
        //     添加动画
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cell cache:YES];
        [UIView commitAnimations];
        
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 40)];
        lineImageView.image = [UIImage imageNamed:@"line32"];
        lineImageView.tag = 1;
        [cell addSubview:lineImageView];
        
        //    记录当前选中行的索引路径
        _frontIndexPath = indexPath;

        
//        切换图片
        
//        先获取到当前cell的菜名
        UILabel *textLab = (UILabel *)[cell viewWithTag:2];
        NSString *nameStr = textLab.text;
        
//        从数据库中获取图片
        if (![_database open]) {
            [_database close];
            return;
        }
        
        FMResultSet *selectRowResultSet = [_database executeQuery:@"select *from menuTable where name = ?",nameStr];
        
        while ([selectRowResultSet next])
        {
            int selectRowPicID = [selectRowResultSet intForColumn:@"id"];
//        滑动视图显示出选中的图片
            [_scrollView setContentOffset:CGPointMake(1024*(selectRowPicID-1), 0) animated:NO];
        }
        
    }
}

//   滑动视图时，改变选中行
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
