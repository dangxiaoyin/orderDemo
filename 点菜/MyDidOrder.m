//
//  MyDidOrder.m
//  点菜
//
//  Created by xyyf on 15/4/19.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "MyDidOrder.h"

@implementation MyDidOrder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        我的菜单视图
        self.frame = CGRectMake(30, 768-90, 150, 50);
        
        UIButton *myOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [myOrderBtn setBackgroundImage:[UIImage imageNamed:@"myorder"] forState:UIControlStateNormal];
        myOrderBtn.frame = CGRectMake(0, 0, 150, 50);
        [self addSubview:myOrderBtn];
        [myOrderBtn addTarget:self action:@selector(myOrderBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}

//   我的菜单按钮
-(void)myOrderBtnClick
{
    self.frame = CGRectMake(0, 0, 1024, 768);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView commitAnimations];
    
    _myOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _myOrderView.tag = 6;
    [self addSubview:_myOrderView];
    
    UIImageView *orderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    orderImageView.userInteractionEnabled = YES;
    orderImageView.image = [UIImage imageNamed:@"bgp6"];
    [_myOrderView addSubview:orderImageView];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(1024-60, 10, 40, 40);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeMyOrderView) forControlEvents:UIControlEventTouchUpInside];
    [orderImageView addSubview:closeBtn];
    
    
//    添加表
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(60, 166, 905, 528) style:UITableViewStylePlain];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    [orderImageView addSubview:_myTableView];
    
    
    _database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]];
    
//    从数据库中获取数据
    if (![_database open]) {
        [_database close];
        return;
    }
    
//    创建数组
    _menuNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _priceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _kindArray = [[NSMutableArray alloc] initWithCapacity:0];
    _idArray = [[NSMutableArray alloc] initWithCapacity:0];
    
//    份数  数组
    _menuNumArray = [[NSMutableArray alloc] initWithCapacity:0];

    
    FMResultSet *didOrderResultSet = [_database executeQuery:@"select *from orderTable"];
    while ([didOrderResultSet next])
    {
        int idNum = [didOrderResultSet intForColumn:@"id"];
        NSString *menuName = [didOrderResultSet stringForColumn:@"menuName"];
        NSString *price = [didOrderResultSet stringForColumn:@"Price"];
        NSString *kind = [didOrderResultSet stringForColumn:@"kind"];
        int menuNum = [didOrderResultSet intForColumn:@"menuNum"];
        
//        存放到数组
        [_idArray addObject:[NSString stringWithFormat:@"%d",idNum]];
        [_menuNameArray addObject:menuName];
        [_priceArray addObject:price];
        [_kindArray addObject:kind];
        
        [_menuNumArray addObject:[NSString stringWithFormat:@"%d",menuNum]];
    }
    
    [_database close];
    
    
//    添加参考价格label
    
    _allPriceSumArray = [[NSMutableArray alloc] initWithCapacity:0];
    
//    先获取到每个菜品的单价
    for (int i = 0; i<_priceArray.count; i++)
    {
        int priceNum = [[_priceArray objectAtIndex:i] intValue];
//        单价  *  份数
        int sumPrice = priceNum * [[_menuNumArray objectAtIndex:i] intValue];
        [_allPriceSumArray addObject:[NSString stringWithFormat:@"%d",sumPrice]];
    }
    
//    静态整形变量
    _sumAllNum = 0;
    
//    遍历数组
    for (NSString *numStr in _allPriceSumArray)
    {
        int num = [numStr intValue];
        _sumAllNum = _sumAllNum + num;
    }
    
//    参考价格label
    UILabel *sumPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(1024/2-50, 768-60, 90, 30)];
    sumPriceLabel.tag = 7;
//    sumPriceLabel.backgroundColor = [UIColor redColor];
    sumPriceLabel.textAlignment = NSTextAlignmentCenter;
    sumPriceLabel.text = [NSString stringWithFormat:@"%d",_sumAllNum];
    sumPriceLabel.textColor = [UIColor whiteColor];
    sumPriceLabel.font = [UIFont fontWithName:nil size:25];
    [orderImageView addSubview:sumPriceLabel];
    
    
//    送单按钮
    UIButton *sandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sandBtn.frame = CGRectMake(1024-130, 768-65, 100, 50);
//    sandBtn.backgroundColor = [UIColor redColor];
    [sandBtn setBackgroundImage:[UIImage imageNamed:@"sdbtn2"] forState:UIControlStateNormal];
    [_myOrderView addSubview:sandBtn];
    
    [sandBtn addTarget:self action:@selector(sandBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
}


//   送单视图
-(void)sandBtnClick
{
    UIView *sandView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    sandView.tag = 50;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView commitAnimations];
    
    
//    添加送单详细信息视图
    _detailSandOrderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _detailSandOrderImageView.userInteractionEnabled = YES;
    _detailSandOrderImageView.image = [UIImage imageNamed:@"pg80.jpg"];
    [sandView addSubview:_detailSandOrderImageView];
    
//    添加按钮
    UIButton *selectRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectRoomBtn.tag = 40;
    selectRoomBtn.frame = CGRectMake(1024/2-42, 768-320, 140, 30);
    
    
//    创建一个观察者   self  来接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBtnTitle:) name:@"10086" object:nil];
    
    [_detailSandOrderImageView addSubview:selectRoomBtn];
    [selectRoomBtn addTarget:self action:@selector(selectRoomBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
//    返回按钮
    UIButton *sandViewBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sandViewBackBtn.frame = CGRectMake(1024-110, 170, 40, 40);
    [sandView addSubview:sandViewBackBtn];
    [sandViewBackBtn addTarget:self action:@selector(sandViewBackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
//    送单按钮
    UIButton *didSandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    didSandBtn.frame = CGRectMake(1024-190, 768-220, 80, 50);
    [sandView addSubview:didSandBtn];
    [didSandBtn addTarget:self action:@selector(didSandBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:sandView];
}

//   送单按钮方法体
-(void)didSandBtnClick
{
    if (_hasRoom == NO)
    {
//        弹窗  请选择room
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择房间" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    else
    {
//    先记录在数据库  group_recordTable表中  日期:date  时间:time  桌号:room  查阅按钮
//     获取到当前的日期和时间
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [dateFormatter stringFromDate:date];

    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *dataNow = [dateFormatter stringFromDate:date];
    
//    获取选中的餐位号
//    创建观察者来获取餐位
    UIButton *selectRoomBtn = (UIButton *)[_detailSandOrderImageView viewWithTag:40];
    NSString *roomName = selectRoomBtn.titleLabel.text;
    
//    插入到数据库中
    if (![_database open]) {
        [_database close];
        return;
    }
    
    [_database executeUpdate:@"insert into group_recordTable (date,time,room) values (?,?,?)",dateStr,dataNow,roomName];
    
    [_database close];
    
//    ----------------------------------------------------------------
        
//        先把数据存入数据库recordTable表中  stateNum  menuName  menuName  menuPrice  menuKind  menuNum  menuRemark   groupID
        
        if (![_database open]) {
            [_database close];
            return;
        }
         //  查询groupID
        FMResultSet *rs = [_database executeQuery:@"select MAX(id) from group_recordTable order by id"];

        while ([rs next])
        {
            _groupID = [rs intForColumn:@"MAX(id)"];
        }
        [rs close];
        [_database close];
        
        
        //  查询remark
        if (![_database open]) {
            [_database close];
            return;
        }
        _remarkArray = [[NSMutableArray alloc] init];
        
        FMResultSet *remarkRS = [_database executeQuery:@"select *from orderTable"];
        while ([remarkRS next]) {
            NSString *remarkStr = [remarkRS stringForColumn:@"remark"];
            [_remarkArray addObject:remarkStr];
        }
        [remarkRS close];
        [_database close];
        
        
         //  插入recordTable
        if (![_database open]) {
            [_database close];
            return;
        }
        
        for (int i = 0; i<_menuNameArray.count; i++)
        {
            [_database executeUpdate:@"insert into recordTable (stateNum,menuName,menuPrice,menuKind,menuNum,menuRemark ,groupID) values (?,?,?,?,?,?,?)",roomName,[_menuNameArray objectAtIndex:i],[_priceArray objectAtIndex:i],[_kindArray objectAtIndex:i],[_menuNumArray objectAtIndex:i],[_remarkArray objectAtIndex:i],[NSString stringWithFormat:@"%d",_groupID]];
        }
        
        [_database close];
        
//    ---------------------------------------------------------------
        
//    删除orderTable数据库中所有数据
    
    if (![_database open]) {
        [_database close];
        return;
    }
    [_database executeUpdate:@"delete from orderTable"];
    [_database close];
    
//    返回
    [self sandViewBackBtnClick];
    
//    清空表  声明一个bool变量
    _clearTableView = YES;
    
//    参考价格  归零
    UILabel *priceLabel = (UILabel *)[_myOrderView viewWithTag:7];
    priceLabel.text = @"0";
    
//    刷新表
    [_myTableView reloadData];
    
    _clearTableView = NO;
        
        _hasRoom = NO;
    }
}


-(void)sandViewBackBtnClick
{
    UIView *sandView = [self viewWithTag:50];
    [sandView removeFromSuperview];
}

//   观察者改变button标题的方法体
-(void)changeBtnTitle:(UIButton *)btn
{
    UIButton *selectRoomBtn = (UIButton *)[_detailSandOrderImageView viewWithTag:40];
    
//   btn 的tag 值已经被保存   通过此方法获取到tag
    int roomBtnTag = [[NSUserDefaults standardUserDefaults] integerForKey:@"btnTagKey"];
    switch (roomBtnTag) {
        case 31:
        {
            [selectRoomBtn setTitle:@"文华轩" forState:UIControlStateNormal];

        }
            break;
            
        case 32:
        {
            [selectRoomBtn setTitle:@"威斯汀" forState:UIControlStateNormal];

        }
            break;
     
        case 33:
        {
            [selectRoomBtn setTitle:@"朗廷" forState:UIControlStateNormal];

        }
            break;
        case 34:
        {
            [selectRoomBtn setTitle:@"万豪庄" forState:UIControlStateNormal];
            
        }
            break;
        case 35:
        {
            [selectRoomBtn setTitle:@"铂尔曼" forState:UIControlStateNormal];
            
        }
            break;
        case 36:
        {
            [selectRoomBtn setTitle:@"四季轩" forState:UIControlStateNormal];
            
        }
            break;
        case 37:
        {
            [selectRoomBtn setTitle:@"万丽" forState:UIControlStateNormal];
            
        }
            break;
        default:
            break;
    }
    
    _hasRoom = YES;
    
}


//   创建的观察者对象，在dealloc方法中移除(不能少，否则出现内存错误crush)
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//   选择餐位
-(void)selectRoomBtnClick
{
    UIView *selectRoomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    selectRoomView.tag = 16;
    [self addSubview:selectRoomView];
    
    UIImageView *selectRoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    selectRoomImageView.userInteractionEnabled = YES;
    selectRoomImageView.image = [UIImage imageNamed:@"res.jpg"];
    [selectRoomView addSubview:selectRoomImageView];
    
//    返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(1024-60, 0, 60, 60);
    [selectRoomImageView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
//    各个餐位的透明按钮
    for (int i = 0; i<7; i++)
    {
        UIButton *roomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        roomBtn.tag = 31+i;
        [selectRoomImageView addSubview:roomBtn];
        [roomBtn addTarget:self action:@selector(roomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *roomBtn = (UIButton *)[selectRoomImageView viewWithTag:31];
    roomBtn.frame = CGRectMake(45, 400, 80, 80);
    
    UIButton *roomBtn2 = (UIButton *)[selectRoomImageView viewWithTag:32];
    roomBtn2.frame = CGRectMake(45+80, 300, 100, 80);
    
    UIButton *roomBtn3 = (UIButton *)[selectRoomImageView viewWithTag:33];
    roomBtn3.frame = CGRectMake(1024/2, 220, 80, 80);
    
    UIButton *roomBtn4 = (UIButton *)[selectRoomImageView viewWithTag:34];
    roomBtn4.frame = CGRectMake(500-100, 400, 220, 80);
    
    UIButton *roomBtn5 = (UIButton *)[selectRoomImageView viewWithTag:35];
    roomBtn5.frame = CGRectMake(1024/2+120, 350, 300, 80);
    
    UIButton *roomBtn6 = (UIButton *)[selectRoomImageView viewWithTag:36];
    roomBtn6.frame = CGRectMake(1024-140, 240, 80, 80);
    
    UIButton *roomBtn7 = (UIButton *)[selectRoomImageView viewWithTag:37];
    roomBtn7.frame = CGRectMake(150, 768-300, 80, 80);

    
}

//   选择餐位  按钮的方法体
-(void)roomButtonClick:(UIButton *)roomBtn
{
    UIView *selectRoomView = [self viewWithTag:16];
    [selectRoomView removeFromSuperview];
    
//    创建通知中心
//   保存当前的tag值
    [[NSUserDefaults standardUserDefaults] setInteger:roomBtn.tag forKey:@"btnTagKey"];
//    创建通知中心
    [[NSNotificationCenter defaultCenter] postNotificationName:@"10086" object:nil];
    
}



//返回按钮
-(void)backBtnClick
{
    UIView *selectRoomView = [self viewWithTag:16];
    [selectRoomView removeFromSuperview];
    
}


//   关闭myOrder视图
-(void)closeMyOrderView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:YES];
    [UIView commitAnimations];
    
    UIView *MyOrderView = [self viewWithTag:6];
    [MyOrderView removeFromSuperview];
    
    self.frame = CGRectMake(30, 768-90, 150, 50);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_clearTableView == YES)
    {
        return 0;
    }
    else
    {
        return _menuNameArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        UILabel *idNumLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 7, 50, 30)];
        idNumLab.tag = 1;
        [cell addSubview:idNumLab];
        
        UILabel *menuNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10+100, 7, 160, 30)];
        menuNameLab.tag = 2;
        menuNameLab.textColor = [UIColor blackColor];
        [cell addSubview:menuNameLab];
        
        
        UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(10+100+300, 7, 100, 30)];
        priceLab.tag = 3;
        [cell addSubview:priceLab];
        
        
        UILabel *kindLab = [[UILabel alloc] initWithFrame:CGRectMake(10+100+300+150, 7, 100, 30)];
        kindLab.tag = 4;
        [cell addSubview:kindLab];
        
        
//        份数  textField
        UITextField *numTextField = [[UITextField alloc] initWithFrame:CGRectMake(550+10+90, 7, 80, 30)];
        numTextField.borderStyle = UITextBorderStyleRoundedRect;
        numTextField.tag = indexPath.row + 20;
        
//        保存上次选择的份数
        int a = 0;
        if (a == 1)
        {
            numTextField.text = [_currentMenuNumArray objectAtIndex:indexPath.row];
        }
        else
        {
            numTextField.text = [_menuNumArray objectAtIndex:indexPath.row];
            a = 1;
        }
        
        [cell addSubview:numTextField];
//        输入框绑定方法
        [numTextField addTarget:self action:@selector(numTextFieldClick:) forControlEvents:UIControlEventEditingDidEnd];
        
//        备注
        UITextField *addTextField = [[UITextField alloc] initWithFrame:CGRectMake(650+110, 7, 80, 30)];
        addTextField.borderStyle = UITextBorderStyleRoundedRect;
        addTextField.tag = indexPath.row + 30;
        [cell addSubview:addTextField];
        [addTextField addTarget:self action:@selector(addTextFieldClick:) forControlEvents:UIControlEventEditingDidEnd];
    }
    
//    自定义单元格
    
    UILabel *idNumLab = (UILabel *)[cell viewWithTag:1];
    idNumLab.text = [_idArray objectAtIndex:indexPath.row];
    
    UILabel *menuNameLab = (UILabel *)[cell viewWithTag:2];
    menuNameLab.text = [_menuNameArray objectAtIndex:indexPath.row];
    
    UILabel *priceLab = (UILabel *)[cell viewWithTag:3];
    priceLab.text = [_priceArray objectAtIndex:indexPath.row];
    
    UILabel *kindLab = (UILabel *)[cell viewWithTag:4];
    kindLab.text = [_kindArray objectAtIndex:indexPath.row];

    
    
    return cell;
}

//   份数 输入框的方法
-(void)numTextFieldClick:(UITextField *)textField
{
    NSString *numText = [NSString stringWithFormat:@"%@",textField.text];
    int number = [numText intValue];
    
//    NSLog(@"number = %d",number);
    
//    更改数据库中数据
    if (![_database open]) {
        [_database close];
        return;
    }
    
//    更新
    [_database executeUpdate:@"update orderTable set menuNum = ? where id = ?",[NSString stringWithFormat:@"%d",number],[NSString stringWithFormat:@"%d",textField.tag - 20+1]];
    
    
//    更新参考价格中的数值
    
    if (![_database open]) {
        [_database close];
        return;
    }
    _currentMenuNumArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMResultSet *resultSet = [_database executeQuery:@"select *from orderTable"];
    
    while ([resultSet next]) {
        int currentMenuNum = [resultSet intForColumn:@"menuNum"];
        [_currentMenuNumArray addObject:[NSString stringWithFormat:@"%d",currentMenuNum]];
    }
    
    
//        使用数组前，先清空
    [_allPriceSumArray removeAllObjects];

    for (int i = 0; i<_priceArray.count; i++)
    {
        int priceNum = [[_priceArray objectAtIndex:i] intValue];
        //        单价  *  份数
        int sumPrice = priceNum * [[_currentMenuNumArray objectAtIndex:i] intValue];
        
        [_allPriceSumArray addObject:[NSString stringWithFormat:@"%d",sumPrice]];
    }
    
    //    静态整形变量
    _sumAllNum = 0;
    
    //    遍历数组
    for (NSString *numStr in _allPriceSumArray)
    {
        int num = [numStr intValue];
        _sumAllNum = _sumAllNum + num;
    }
    
    
    UILabel *updateSumPriceLab = (UILabel *)[_myOrderView viewWithTag:7];
    updateSumPriceLab.text = [NSString stringWithFormat:@"%d",_sumAllNum];
    
}


//   备注输入框的方法
-(void)addTextFieldClick:(UITextField *)textField
{
//    NSString *addText = [NSString stringWithFormat:@"%@",textField.text];
    
    //    更改数据库中数据
    if (![_database open]) {
        [_database close];
        return;
    }
    
    //    更新
    [_database executeUpdate:@"update orderTable set remark = ? where id = ?",textField.text,[NSString stringWithFormat:@"%d",textField.tag - 30+1]];
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}


//  点击表  也让键盘下去
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
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
