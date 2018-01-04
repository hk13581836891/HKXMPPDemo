//
//  ChatTableViewController.h
//  HKXMPPDemo
//
//  Created by houke on 2018/1/3.
//  Copyright © 2018年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface ChatTableViewController : UITableViewController

@property (nonatomic, strong) XMPPJID *friendJID;
@end
