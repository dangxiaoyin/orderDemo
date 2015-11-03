//
//  checkView.m
//  点菜
//
//  Created by xyyf on 15/4/25.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "checkView.h"

@implementation checkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        self.frame= CGRectMake(0, 0, 1024, 768);
        self.tag = 6;
        
        UIImageView *checkBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        checkBgImageView.userInteractionEnabled = YES;
        checkBgImageView.image = [UIImage imageNamed:@"bgp6"];
        [self addSubview:checkBgImageView];
        
        //   返回
        UIButton *checkBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBackBtn.frame = CGRectMake(1024-40, 0, 40, 40);
        [checkBackBtn setBackgroundImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
        [checkBgImageView addSubview:checkBackBtn];
        [checkBackBtn addTarget:self action:@selector(checkBackBtnClick) forControlEvents:UIControlEventTouchUpInside];

        //  添加表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(57, 200-35, 1024-57*2, 500+28) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self addSubview:tableView];
        
        
        //   获取数据
        _database = [FMDatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]] ;
        if (![_database open]) {
            [_database close];
            return nil;
        }
        
        
        //   NSUserDefaults  存值
        int selectBtnTag = [[NSUserDefaults standardUserDefaults] integerForKey:@"btnTagKey"];
//        NSLog(@"接收tag = %d",selectBtnTag);
        
        
        
        FMResultSet *resultSet = [_database executeQuery:@"select *from recordTable where groupID = ?",[NSString stringWithFormat:@"%d",selectBtnTag-100]];
        _allMenuArray = [[NSMutableArray alloc] initWithCapacity:0];
        _nameArray = [[NSMutableArray alloc] init];
        _priceArray = [[NSMutableArray alloc] init];
        _kindArray = [[NSMutableArray alloc] init];
        _numArray = [[NSMutableArray alloc] init];
        _remarkArray = [[NSMutableArray alloc] init];
        
        //  遍历   menuName  menuPrice kind menuNum remark
        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:@"menuName"];
            [_nameArray addObject:name];
            NSString *price = [resultSet stringForColumn:@"menuPrice"];
            [_priceArray addObject:price];
            NSString *kind = [resultSet stringForColumn:@"menuKind"];
            [_kindArray addObject:kind];
            NSString *num = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"menuNum"]];
            [_numArray addObject:num];
            NSString *remark = [resultSet stringForColumn:@"menuRemark"];
            [_remarkArray addObject:remark];
        }
        [resultSet close];
        [_database close];
        
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nameArray.count;
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
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(10+100+300+150+120, 7, 100, 30)];
        numLab.tag = 5;
        [cell addSubview:numLab];
        
        UILabel *remarkLab = [[UILabel alloc] initWithFrame:CGRectMake(10+100+300+150+220, 7, 100, 30)];
        remarkLab.tag = 6;
        [cell addSubview:remarkLab];
    }
    
    
    
    
    //    自定义单元格
    
    UILabel *idNumLab = (UILabel *)[cell viewWithTag:1];
    idNumLab.text = [NSString stringWithFormat:@"%d",indexPath.row +1];
    
    UILabel *menuNameLab = (UILabel *)[cell viewWithTag:2];
    menuNameLab.text = [_nameArray objectAtIndex:indexPath.row];
    UILabel *priceLab = (UILabel *)[cell viewWithTag:3];
    priceLab.text = [_priceArray objectAtIndex:indexPath.row];
    UILabel *kindLab = (UILabel *)[cell viewWithTag:4];
    kindLab.text = [_kindArray objectAtIndex:indexPath.row];
    UILabel *numLab = (UILabel *)[cell viewWithTag:5];
    numLab.text = [_numArray objectAtIndex:indexPath.row];
    UILabel *remarkLab = (UILabel *)[cell viewWithTag:6];
    remarkLab.text = [_remarkArray objectAtIndex:indexPath.row];
    
    
    return cell;
}





-(void)checkBackBtnClick
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[UIApplication sharedApplication].keyWindow cache:YES];
    [UIView commitAnimations];
    
    UIView *checkView = [self viewWithTag:6];
    [checkView removeFromSuperview];
    
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
