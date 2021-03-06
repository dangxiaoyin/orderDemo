//
//  ChaPaiViewController.m
//  点菜
//
//  Created by xyyf on 15/4/18.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "ChaPaiViewController.h"
#import "menuView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyDidOrder.h"
#import "OderLabelView.h"


@interface ChaPaiViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isOpen[3];
    FMDatabase *_database;
    NSMutableArray *_titleArray;
    NSMutableArray *_qingChaArray;
    NSMutableArray *_lvChaArray;
    NSMutableArray *_puErChaArray;
    NSMutableArray *_bigArray;
    NSMutableArray *_picNameArray;
    
//    记录上次选中行的索引路径
    NSIndexPath *_frontIndexPath;
    
//    价格数组
    NSMutableArray *_qingChaPriceArray;
    NSMutableArray *_lvChaPriceArray;
    NSMutableArray *_puErChaPriceArray;

    NSMutableArray *_priceBigArray;
    NSMutableArray *_selectDishArray;
    
//    定义一个bool变量  记录orderLabelView  是否存在的两种状态
    BOOL _isHasOrderLabelView;
    
}
@end

@implementation ChaPaiViewController

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
    
    
    //    添加菜单View
    menuView *m_view = [[menuView alloc] init];
    [self.view addSubview:m_view];
    [self.view bringSubviewToFront:m_view];

    
//    折合表
    
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    _leftTableView.backgroundColor = [UIColor clearColor];
    _leftTableView.separatorColor = [UIColor clearColor];
    
    
//    从数据库中获取数据
    _database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
    if (![_database open]) {
        [_database close];
        return;
    }
    
//    标题
    _titleArray = [[NSMutableArray alloc] initWithObjects:@"清茶",@"绿茶",@"普洱茶", nil];
    
    _qingChaArray = [[NSMutableArray alloc] initWithCapacity:0];
    _lvChaArray = [[NSMutableArray alloc] initWithCapacity:0];
    _puErChaArray = [[NSMutableArray alloc] initWithCapacity:0];
    
//    存放价格的数组
    _qingChaPriceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _lvChaPriceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _puErChaPriceArray = [[NSMutableArray alloc] initWithCapacity:0];

//    存放滑动视图图片的数组
    _picNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMResultSet *qingChaResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"清茶"];
    FMResultSet *lvChaResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"绿茶"];
    FMResultSet *puErChaResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"普洱茶"];

    FMResultSet *picNameResultSet = [_database executeQuery:@"select *from menuTable where groupID = 2"];

    
    
//    遍历结果集
    while ([qingChaResultSet next])
    {
        NSString *string = [qingChaResultSet stringForColumn:@"name"];
        NSString *qingChaPrice = [NSString stringWithFormat:@"%d",[qingChaResultSet intForColumn:@"price"]];
        [_qingChaArray addObject:string];
//        ARC下不允许  将一个int类型添加到一个id类型对象中
        [_qingChaPriceArray addObject:qingChaPrice];
    }

    while ([lvChaResultSet next])
    {
       NSString *string = [lvChaResultSet stringForColumn:@"name"];
        NSString *lvChaPrice = [NSString stringWithFormat:@"%d",[lvChaResultSet intForColumn:@"price"]];
        [_lvChaArray addObject:string];
        [_lvChaPriceArray addObject:lvChaPrice];
    }

    while ([puErChaResultSet next])
    {
        NSString *string = [puErChaResultSet stringForColumn:@"name"];
        NSString *puErChaPrice = [NSString stringWithFormat:@"%d",[puErChaResultSet intForColumn:@"price"]];
        [_puErChaArray addObject:string];
        [_puErChaPriceArray addObject:puErChaPrice];
    }
    
//    获取数组中图片名字
    while ([picNameResultSet next])
    {
        NSString *picNameStr = [picNameResultSet stringForColumn:@"picName"];
        [_picNameArray addObject:picNameStr];
    }

//    大数组
    _bigArray = [[NSMutableArray alloc] initWithObjects:_qingChaArray,_lvChaArray,_puErChaArray, nil];
    _priceBigArray = [[NSMutableArray alloc] initWithObjects:_qingChaPriceArray,_lvChaPriceArray,_puErChaPriceArray, nil];
    
    
//    滑动视图
    _aScrollView.contentSize = CGSizeMake(465*_picNameArray.count , 499);
    _aScrollView.pagingEnabled = YES;
    
    for (int i = 0; i<_picNameArray.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(465*i, 0, 465, 499)];
        imageView.image = [UIImage imageNamed:[_picNameArray objectAtIndex:i]];
        [_aScrollView addSubview:imageView];
    }
    
//    添加我的菜单视图
    MyDidOrder *myOrder = [[MyDidOrder alloc] init];
    [self.view addSubview:myOrder];
    
}

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
        
        //        选中行的状态
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 100, 30)];
        nameLab.tag = 2;
        nameLab.textColor = [UIColor whiteColor];
        [cell addSubview:nameLab];
        
        UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 7, 100, 30)];
        priceLab.tag = 3;
        priceLab.textColor = [UIColor whiteColor];
        [cell addSubview:priceLab];
        
    }
//    配置单元格
    for (int i = 0; i< _titleArray.count; i++)
    {
        if (indexPath.section == i)   //  判断选中的区
        {
            UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
            nameLab.text = [[_bigArray objectAtIndex:i] objectAtIndex:indexPath.row];
            
            UILabel *priceLab = (UILabel *)[cell viewWithTag:3];
            priceLab.text = [NSString stringWithFormat:@"%@元/位",[[_priceBigArray objectAtIndex:i] objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

//区头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}


//  自定义区头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    //    view.backgroundColor = [UIColor redColor];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 60, 40)];
    titleLab.text = [_titleArray objectAtIndex:section];
    titleLab.textColor = [UIColor whiteColor];
    [view addSubview:titleLab];
    
    
    //    折合按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 260, 60);
    //   当前的区  作为button的tag值
    button.tag = section;
    //    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    //    底线 图片
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 260, 40)];
    lineImageView.image = [UIImage imageNamed:@"line31"];
    [view addSubview:lineImageView];
    
    return view;
}

-(void)buttonClick:(UIButton *)btn
{
    UITableViewCell *frontCell = [_leftTableView cellForRowAtIndexPath:_frontIndexPath];
    UIImageView *frontImageView = (UIImageView *)[frontCell viewWithTag:1];
    [frontImageView removeFromSuperview];

    _isOpen[btn.tag] = !_isOpen[btn.tag];
        
    //    添加折合的动画
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag];
    [_leftTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}


//   选中当前行的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (_frontIndexPath == indexPath)
    {
        return;
    }
    else
    {
        UITableViewCell *frontCell = [_leftTableView cellForRowAtIndexPath:_frontIndexPath];
        UIImageView *frontImageView = (UIImageView *)[frontCell viewWithTag:1];
        [frontImageView removeFromSuperview];
        
        //     通过indexPath  获取当前的cell
        UITableViewCell *cell = [_leftTableView cellForRowAtIndexPath:indexPath];
        
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
            [_aScrollView setContentOffset:CGPointMake(465*(selectRowPicID-17), 0) animated:NO];
        }
    }
}

//   详细信息
- (IBAction)detailBtnClick:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    
    UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    detailView.tag = 10;
    [self.view addSubview:detailView];
    
    UIImageView *detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 80, 650, 600)];
    detailImageView.userInteractionEnabled = YES;
    detailImageView.image = [UIImage imageNamed:@"bgp5"];
    [detailView addSubview:detailImageView];
    
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(650-60, 10, 50, 50);
    [detailImageView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    判断当前选中的菜名
    int x = _aScrollView.contentOffset.x;
    int selectRowID = x/465 +17;
    
//    从数据库中获取id = selectRowID 的图片名字
    if (![_database open]) {
        [_database close];
        NSLog(@"数据库未正常打开");
        return;
    }
    
//    查询
    FMResultSet *selectRowResultSet = [_database executeQuery:@"select *from menuTable where id = ?",[NSString stringWithFormat:@"%d", selectRowID]];
    
//    遍历
    while ([selectRowResultSet next])
    {
        NSString *selectRowPicName = [selectRowResultSet stringForColumn:@"picName"];
        UIImageView *seleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 18+100, 375, 562-200)];
        seleteImageView.image = [UIImage imageNamed:selectRowPicName];
        [detailImageView addSubview:seleteImageView];
        
        NSString *selectName = [selectRowResultSet stringForColumn:@"name"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(450, 40, 150, 40)];
        label.text = selectName;
        label.font = [UIFont fontWithName:nil size:23];
        label.textColor = [UIColor whiteColor];
        [detailImageView addSubview:label];
    }
    
    
}


//  关闭详情视图的按钮
-(void)closeBtnClick
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [UIView commitAnimations];
    
    UIView *aView = [self.view viewWithTag:10];
    [aView removeFromSuperview];
    
}



//   点菜按钮
- (IBAction)didOrderBtn:(id)sender
{
//    点击点菜按钮  显示已经点了n种菜  label
    if (_isHasOrderLabelView == NO)
    {
    //    添加已点菜 的label
        OderLabelView *orderView = [[OderLabelView alloc] init];
        orderView.tag = 11;
        [self.view addSubview:orderView];
        _isHasOrderLabelView = YES;
    }
    else
    {
        UIView *frontView = (UIView *)[self.view viewWithTag:11];
        [frontView removeFromSuperview];
        //    添加已点菜 的label
        OderLabelView *orderView = [[OderLabelView alloc] init];
        orderView.tag = 11;
        [self.view addSubview:orderView];
        _isHasOrderLabelView = YES;
    }
    
    
    
    //    判断当前选中的菜名
    int x = _aScrollView.contentOffset.x;
    int selectRowID = x/465 +17;
    
    //    从数据库中获取id = selectRowID 的图片名字
    if (![_database open]) {
        [_database close];
        return;
    }
    
    //    查询
    FMResultSet *selectRowResultSet = [_database executeQuery:@"select *from menuTable where id = ?",[NSString stringWithFormat:@"%d", selectRowID]];
    
    //    创建数组来存放  已点菜的信息
    _selectDishArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    遍历
    while ([selectRowResultSet next])
    {
        NSString *selectRowPicName = [selectRowResultSet stringForColumn:@"picName"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(388, 140, 465, 499)];
        imageView.image = [UIImage imageNamed:selectRowPicName];
        [self.view addSubview:imageView];
        
//        添加动画
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        imageView.frame = CGRectMake(388, 140+499, 0, 0);
        [UIView commitAnimations];
        
        
//        菜名、价格、菜品类
        NSString *menuName = [selectRowResultSet stringForColumn:@"name"];
        NSString *price = [selectRowResultSet stringForColumn:@"price"];
        NSString *kind = [selectRowResultSet stringForColumn:@"iKind"];
        
        
//        数组使用前，先清空
        [_selectDishArray removeAllObjects];
        
        [_selectDishArray addObject:menuName];
        [_selectDishArray addObject:price];
        [_selectDishArray addObject:kind];
    }
    
    
    
//    把选中菜的信息写到沙盒中 字段： id  menuName  Price（text）  kind  menuNum（份数 integer）  remark（备注 text）
    if (![_database open]) {
        [_database close];
        return;
    }

    [_database executeUpdate:@"insert into orderTable (menuName,Price,kind,menuNum,remark) values (?,?,?,?,?)",[_selectDishArray objectAtIndex:0],[_selectDishArray objectAtIndex:1],[_selectDishArray objectAtIndex:2],[NSString stringWithFormat:@"%d",1],@"null"];
    [_database close];
    
    
//     数据库更新数据
        [self getDate];
    
}


-(void)getDate
{
    if (![_database open]) {
        [_database close];
        return;
    }
    
    FMResultSet *selectResultSet = [_database executeQuery:@"select *from orderTable"];
    while ([selectResultSet next])
    {
//        NSString *name = [selectResultSet stringForColumn:@"menuName"];
        [selectResultSet stringForColumn:@"Price"];
        [selectResultSet stringForColumn:@"Kind"];
        [selectResultSet intForColumn:@"menuNum"];
        [selectResultSet stringForColumn:@"remark"];
    }
    [_database close];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
