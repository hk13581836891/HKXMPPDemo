//
//  ChatTableViewController.m
//  HKXMPPDemo
//
//  Created by houke on 2018/1/3.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "ChatTableViewController.h"
#import "XMPPManager.h"

@interface ChatTableViewController ()<XMPPStreamDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageArray;
@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageArray = [NSMutableArray array];
    
    //给通信通道对象添加代理
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //检索信息
    [self reloadMessages];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)reloadMessages
{
    NSManagedObjectContext *context = [XMPPManager sharedManager].context;
    
    // 创建查询类
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 创建实体描述类
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entityDescription];
    
    // 创建谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@", self.friendJID.bare, [XMPPManager sharedManager].xmppStream.myJID.bare];
    [fetchRequest setPredicate:predicate];
    
    // 创建排序类
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    // 从临时数据库中查找聊天信息
    NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:nil];
    
    if (fetchArray.count != 0) {
        
        if (self.messageArray.count != 0) {
            [self.messageArray removeAllObjects];
        }
        
        [self.messageArray addObjectsFromArray:fetchArray];
        
        [self.tableView reloadData];
        
        
        if (self.messageArray.count != 0) {
            // 动画效果
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (IBAction)sendAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送消息" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:textField.text];
        [[XMPPManager sharedManager].xmppStream sendElement:message];
    }
}
#pragma mark xmppStreamDelegate 通信通道对象代理
//消息发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessages];
    });
    
}

//消息接收成功
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    [self reloadMessages];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    

    //取出数据源中的消息
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
    
    if (message.isOutgoing) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        UILabel *textLabel = [cell.contentView viewWithTag:10];
        textLabel.text = [NSString stringWithFormat:@"%@--%@",[XMPPManager sharedManager].xmppStream.myJID.user, message.body];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
        UILabel *textLabel = [cell.contentView viewWithTag:10];
        textLabel.text = [NSString stringWithFormat:@"%@--%@", message.body, _friendJID.user]; 
        return cell;
    }
    // Configure the cell...
    
    return nil;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
