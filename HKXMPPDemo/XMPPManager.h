//
//  XMPPManager.h
//  HKXMPPDemo
//
//  Created by houke on 2018/1/2.
//  Copyright © 2018年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPManager : NSObject<XMPPStreamDelegate, XMPPRosterDelegate>

//通信通道对象
@property (nonatomic, strong) XMPPStream *xmppStream;

//好友花名册管理对象
@property (nonatomic, strong) XMPPRoster *xmppRoster;

//信息归档对象
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;

//创建一个数据管理器
@property (nonatomic, strong) NSManagedObjectContext *context;

+(XMPPManager *)sharedManager;

-(void)loginWithUserName:(NSString *)userName
                password:(NSString *)password;

-(void)registerUserName:(NSString *)userName
               password:(NSString *)password;
@end
