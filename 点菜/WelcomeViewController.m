//
//  WelcomeViewController.m
//  点菜
//
//  Created by xyyf on 15/4/17.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "WelcomeViewController.h"
#import "KindViewController.h"
#import "ViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "FMDatabase.h"

#import "checkView.h"

@interface WelcomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dateArray;
    NSMutableArray *_dataArray;
    NSMutableArray *_roomArray;
}
@end

@implementation WelcomeViewController

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
    
        
//    配置单元格  获取数据
    FMDatabase *database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
    if (![database open]) {
        [database close];
        NSLog(@"00000");
        return;
    }
//    数组来接收
    _dateArray = [[NSMutableArray alloc] initWithCapacity:0];
    _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    _roomArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMResultSet *resultSet = [database executeQuery:@"select *from group_recordTable"];
    while ([resultSet next])
    {
        NSString *dateStr = [resultSet stringForColumn:@"date"];
        [_dateArray addObject:dateStr];
        NSString *dataStr = [resultSet stringForColumn:@"time"];
        [_dataArray addObject:dataStr];
        NSString *room = [resultSet stringForColumn:@"room"];
        [_roomArray addObject:room];
    }
}

//  返回到上一个视图控制器
- (IBAction)backButtonClick:(id)sender
{
}

- (IBAction)chineseEnter:(id)sender
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:window cache:YES];
    [UIView commitAnimations];

    KindViewController *kindVC = [[KindViewController alloc] init];
    window.rootViewController = kindVC;
}

- (IBAction)back:(id)sender
{
}

//   历史菜单
- (IBAction)didOrderMenu:(id)sender
{
//    新建一个View
    UIView *historyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    historyView.tag = 5;
    [self.view addSubview:historyView];
    
    UIImageView *historyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    historyImageView.userInteractionEnabled = YES;
    historyImageView.image = [UIImage imageNamed:@"hrbg"];
    [historyView addSubview:historyImageView];
    
//    添加表
    UITableView *historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 165, 1024-100, 460) style:UITableViewStylePlain];
    
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    [historyImageView addSubview:historyTableView];
    
//    返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(1024-50, 0, 50, 50);
    [historyImageView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(historyViewBack) forControlEvents:UIControlEventTouchUpInside];
}

-(void)historyViewBack
{
    UIView *historyView = [self.view viewWithTag:5];
    [historyView removeFromSuperview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dateArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//        自定义label的位置
        UILabel *dateLab = [[UILabel alloc] initWithFrame:CGRectMake(230, 7, 150, 30)];
        dateLab.tag = 1;
        dateLab.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:dateLab];
        
        UILabel *dataLab = [[UILabel alloc] initWithFrame:CGRectMake(250+140, 7, 100, 30)];
        dataLab.textAlignment = NSTextAlignmentCenter;
        dataLab.tag = 2;
        [cell addSubview:dataLab];
        
        UILabel *roomLab = [[UILabel alloc] initWithFrame:CGRectMake(250+140+140, 7, 100, 30)];
        roomLab.textAlignment = NSTextAlignmentCenter;
        roomLab.tag = 3;
        [cell addSubview:roomLab];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        
//        添加查阅按钮
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //  设置tag
        checkBtn.tag = indexPath.row +101;
        
        checkBtn.frame = CGRectMake(250+280+160, 0, 50, 44);
        [checkBtn setTitle:@"查阅" forState:UIControlStateNormal];
        [checkBtn setTitle:@"check" forState:UIControlStateHighlighted];
        [checkBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [checkBtn addTarget:self action:@selector(historyCheckBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:checkBtn];
    }
    
    UILabel *dateLab = (UILabel *)[cell viewWithTag:1];
    dateLab.text = [_dateArray objectAtIndex:indexPath.row];
    
    UILabel *dataLab = (UILabel *)[cell viewWithTag:2];
    dataLab.text = [_dataArray objectAtIndex:indexPath.row];
    
    UILabel *roomLab = (UILabel *)[cell viewWithTag:3];
    roomLab.text = [_roomArray objectAtIndex:indexPath.row];
    
    return cell;
}


-(void)historyCheckBtnClick:(UIButton *)btn
{
//    NSLog(@"btn.tag = %d",btn.tag);
    
//    NSUserDefault 存值  存放btn的tag值
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", btn.tag] forKey:@"btnTagKey"];
    

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:window cache:YES];
    [UIView commitAnimations];
    
    
    checkView *checkV = [[checkView alloc] init];
    [self.view addSubview:checkV];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
