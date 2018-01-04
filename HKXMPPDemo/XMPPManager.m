//
//  XMPPManager.m
//  HKXMPPDemo
//
//  Created by houke on 2018/1/2.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "XMPPManager.h"

//枚举
typedef NS_ENUM(NSInteger, ConnectToServePurpose) {
    ConnectToServePurposeLogin,
    ConnectToServePurposeRegister
};

@interface XMPPManager()<UIAlertViewDelegate>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) ConnectToServePurpose connectToServePurpose;

@property (nonatomic, strong) XMPPJID *fromJID;
@end

@implementation XMPPManager

+(XMPPManager *)sharedManager
{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //创建通信通道对象
        self.xmppStream = [[XMPPStream alloc] init];
        //设置服务器 IP地址
        self.xmppStream.hostName = kHostName;
        //设置服务器端口
        self.xmppStream.hostPort = kHostPort;
        //设置代理
       [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
        //创建花名册数据存储对象
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //创建一个花名册管理对象
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信通道
        [self.xmppRoster activate:self.xmppStream];
        //设置代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
        // 创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        // 创建信息归档对象
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        // 激活通信通道对象
        [self.xmppMessageArchiving activate:self.xmppStream];
        
        
        
        //创建数据管理器
        self.context = messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        
    }
    return self;
}

-(void)loginWithUserName:(NSString *)userName password:(NSString *)password
{
    self.connectToServePurpose = ConnectToServePurposeLogin;
    self.password = password;
    //连接服务器
    [self connectToServeWithUserName:userName];
    
}

-(void)registerUserName:(NSString *)userName password:(NSString *)password
{
    self.connectToServePurpose = ConnectToServePurposeRegister;
    self.password = password;
    [self connectToServeWithUserName:userName];
}
-(void)connectToServeWithUserName:(NSString *)userName
{
    //创建 xmpp JID对象
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    
    //设置通信通道对象的 JID
    self.xmppStream.myJID = jid;
    
    //发送请求
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        //先发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        
        //断开连接
        [self.xmppStream disconnect];
    }
    
    //向服务器发送请求
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    
    if (error != nil) {
        NSLog(@"%s____%d___%@| 连接失败",__FUNCTION__,__LINE__,[error localizedDescription]);
    }
    
}

#pragma mark StreamDelegate通信通道请求代理方法
//连接超时
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"%s_____%d |连接服务器超时",__FUNCTION__,__LINE__);
}
//连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    switch (self.connectToServePurpose) {
        case ConnectToServePurposeLogin:
            [self.xmppStream authenticateWithPassword:self.password error:nil];
            break;
        case ConnectToServePurposeRegister:
            [self.xmppStream registerWithPassword:self.password error:nil];
            break;
    }
}

-(void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"%s_____%d |即将连接",__FUNCTION__,__LINE__);
}

#pragma mark RosterDelegate 花名册代理方法

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    self.fromJID = presence.from;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //拒绝添加此好友
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJID];
            break;
        case 1:
            //同意添加此好友
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJID andAddToRoster:YES];
            break;
    }
}

@end














