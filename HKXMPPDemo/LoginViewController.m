//
//  LoginViewController.m
//  HKXMPPDemo
//
//  Created by houke on 2018/1/1.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"

@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Do any additional setup after loading the view.
}
- (IBAction)loginButtonClick:(id)sender {
    
    [[XMPPManager sharedManager] loginWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
}

#pragma mark 通信通道对象代理方法
//验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"%s___%d|登录成功",__FUNCTION__,__LINE__);
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager sharedManager].xmppStream sendElement:presence];
    [self performSegueWithIdentifier:@"roster" sender:nil];
}

//登录验证失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"%s__%d |验证失败",__FUNCTION__,__LINE__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
