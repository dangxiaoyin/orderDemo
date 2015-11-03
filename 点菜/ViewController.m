//
//  ViewController.m
//  点菜
//
//  Created by xyyf on 15/4/17.
//  Copyright (c) 2015年 zhiyou. All rights reserved.
//

#import "ViewController.h"
#import "WelcomeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
//    数据库放置在工程中是不能操作的，需要存放到沙盒中，通过NSFileManger方法
    
    NSBundle *bundle = [NSBundle mainBundle];
//    获取资源文件的路径
    NSString *path = [bundle pathForResource:@"database" ofType:@"sqlite"];
    
//    把数据库复制到沙盒中
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    if (![fileManger fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"]])
    {
        [fileManger copyItemAtPath:path toPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.sqlite"] error:nil];
    }

}


- (IBAction)webBtnClick:(id)sender
{
    
//    UIWebView *webView= [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];  //web视图
//    [self.view addSubview:webView];
//    NSURL *url = [NSURL URLWithString:@"http:www.baidu.com"];   // 创建链接
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];  //  创建请求
//    [webView loadRequest:request];    // 加载请求
    
//    使用系统的浏览器打开网页
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
}


- (IBAction)enterOrderSystem:(id)sender
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:window cache:YES];
    [UIView commitAnimations];

    WelcomeViewController *welcomeVC = [[WelcomeViewController alloc] init];
    window.rootViewController = welcomeVC;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
