//
//  lengCaiViewController.m
//  点菜
//
//  Created by xyyf on 15/4/19.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "lengCaiViewController.h"
#import "menuView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyDidOrder.h"
#import "OderLabelView.h"


@interface lengCaiViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isOpen[3];
    FMDatabase *_database;
    NSMutableArray *_titleArray;
    NSMutableArray *_heFengArray;
    NSMutableArray *_xiShiArray;
    
    NSMutableArray *_bigArray;
    NSMutableArray *_picNameArray;
    
    //    记录上次选中行的索引路径
    NSIndexPath *_frontIndexPath;
    
    //    价格数组
    NSMutableArray *_heFengPriceArray;
    NSMutableArray *_xiShiPriceArray;
    
    NSMutableArray *_priceBigArray;
    NSMutableArray *_selectDishArray;
    
    BOOL _isHasOrderLabelView;
    
}
@end

@implementation lengCaiViewController

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
    _titleArray = [[NSMutableArray alloc] initWithObjects:@"和风",@"西式", nil];
    
    _heFengArray = [[NSMutableArray alloc] initWithCapacity:0];
    _xiShiArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    存放价格的数组
    _heFengPriceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _xiShiPriceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    存放滑动视图图片的数组
    _picNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMResultSet *heFengResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"和风"];
    FMResultSet *xiShiResultSet = [_database executeQuery:@"select *from menuTable where iKind = ?",@"西式"];
    
    FMResultSet *picNameResultSet = [_database executeQuery:@"select *from menuTable where groupID = 3"];
    
    
    
    //    遍历结果集
    while ([heFengResultSet next])
    {
        NSString *string = [heFengResultSet stringForColumn:@"name"];
        NSString *heFengPrice = [NSString stringWithFormat:@"%d",[heFengResultSet intForColumn:@"price"]];
        [_heFengArray addObject:string];
        //        ARC下不允许  将一个int类型添加到一个id类型对象中
        [_heFengPriceArray addObject:heFengPrice];
    }
    
    while ([xiShiResultSet next])
    {
        NSString *string = [xiShiResultSet stringForColumn:@"name"];
        NSString *xiShiPrice = [NSString stringWithFormat:@"%d",[xiShiResultSet intForColumn:@"price"]];
        [_xiShiArray addObject:string];
        [_xiShiPriceArray addObject:xiShiPrice];
    }
    
    
    //    获取数组中图片名字
    while ([picNameResultSet next])
    {
        NSString *picNameStr = [picNameResultSet stringForColumn:@"picName"];
        [_picNameArray addObject:picNameStr];
    }
    
    //    大数组
    _bigArray = [[NSMutableArray alloc] initWithObjects:_heFengArray,_xiShiArray, nil];
    _priceBigArray = [[NSMutableArray alloc] initWithObjects:_heFengPriceArray,_xiShiPriceArray, nil];
    
    
    //    滑动视图
    _aScrollView.contentSize = CGSizeMake(459*_picNameArray.count , 525);
    _aScrollView.pagingEnabled = YES;
    
    for (int i = 0; i<_picNameArray.count; i++)
    {
        if (i < _xiShiArray.count)
        {
//        滑动视图图片显示顺序 ： 西式菜品放到和风菜品的后面
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(459*(i+_heFengArray.count), 0, 459, 525)];
            imageView.image = [UIImage imageNamed:[_picNameArray objectAtIndex:i]];
            [_aScrollView addSubview:imageView];
        }
        else
        {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(459*(i-_xiShiArray.count), 0, 459, 525)];
        imageView.image = [UIImage imageNamed:[_picNameArray objectAtIndex:i]];
        [_aScrollView addSubview:imageView];
        }
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
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 150, 30)];
        nameLab.tag = 2;
        nameLab.textColor = [UIColor whiteColor];
        [cell addSubview:nameLab];
        
        UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(150, 7, 100, 30)];
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
            if (selectRowPicID-47 < _xiShiArray.count)
            {
                [_aScrollView setContentOffset:CGPointMake(459*(selectRowPicID-47 + _heFengArray.count), 0) animated:NO];
            }
            
            else
            {
                [_aScrollView setContentOffset:CGPointMake(459*(selectRowPicID-47 - _xiShiArray.count), 0) animated:NO];
            }
            
        }
    }
}

//   详细信息按钮
- (IBAction)detailView:(id)sender
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
    
    int selectRowID = x/459;
    
    
    if (selectRowID < _heFengArray.count)
    {
        selectRowID = selectRowID + _xiShiArray.count+47;
    }
    else
    {
        selectRowID = selectRowID - _heFengArray.count+47;
    }
    
    
    
    //    从数据库中获取id = selectRowID 的图片名字
    if (![_database open]) {
        [_database close];
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
- (IBAction)didOrder:(id)sender
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
    
    int selectRowID = x/459;
    
    
    if (selectRowID < _heFengArray.count)
    {
        selectRowID = selectRowID + _xiShiArray.count+47;
    }
    else
    {
        selectRowID = selectRowID - _heFengArray.count+47;
    }

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
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(392, 107, 459, 525)];
        imageView.image = [UIImage imageNamed:selectRowPicName];
        [self.view addSubview:imageView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        imageView.frame = CGRectMake(392, 107+525, 0, 0);
        [UIView commitAnimations];

        //        菜名、价格、菜品类
        NSString *menuName = [selectRowResultSet stringForColumn:@"name"];
        NSString *price = [selectRowResultSet stringForColumn:@"price"];
        NSString *kind = [selectRowResultSet stringForColumn:@"iKind"];
        
        
//        数组使用前，先清空
        [_selectDishArray removeAllObjects];
        
        if ([menuName isEqualToString:@"象拔蚌刺身"])
        {
            [_selectDishArray addObject:@"象拔蚌刺身"];
            [_selectDishArray addObject:[NSString stringWithFormat:@"%d",800]];
            [_selectDishArray addObject:kind];
        }
        else if([menuName isEqualToString:@"龙虾刺身"])
        {
            [_selectDishArray addObject:@"龙虾刺身"];
            [_selectDishArray addObject:[NSString stringWithFormat:@"%d",680]];
            [_selectDishArray addObject:kind];
        }
        else
        {
            [_selectDishArray addObject:menuName];
            [_selectDishArray addObject:price];
            [_selectDishArray addObject:kind];
        }
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
