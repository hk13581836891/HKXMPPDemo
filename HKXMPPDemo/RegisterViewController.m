//
//  RegisterViewController.m
//  HKXMPPDemo
//
//  Created by houke on 2018/1/3.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"

@interface RegisterViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark 通信通道对象代理方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"%s___%d |注册成功", __FUNCTION__, __LINE__);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"%s__%d |注册失败", __FUNCTION__, __LINE__);
    
}

- (IBAction)registerButtonClick:(UIButton *)sender {
    
    [[XMPPManager sharedManager] registerUserName:self.userNameTextField.text password:self.passwordTextField.text];
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
