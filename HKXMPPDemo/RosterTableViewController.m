//
//  RosterTableViewController.m
//  HKXMPPDemo
//
//  Created by houke on 2018/1/3.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "RosterTableViewController.h"
#import "XMPPManager.h"
#import "ChatTableViewController.h"

@interface RosterTableViewController ()<XMPPRosterDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation RosterTableViewController
- (IBAction)addFridenAction:(UIBarButtonItem *)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

#pragma alertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPJID *jid = [XMPPJID jidWithUser:textField.text
                                     domain:kDomin resource:kResource];
        [[XMPPManager sharedManager].xmppRoster addUser:jid withNickname:nil];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [XMPPManager sharedManager].xmppStream.myJID.user;
    self.dataArray = [NSMutableArray array];
    
    [[XMPPManager sharedManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark xmppRosterDelegate 花名册对象代理方法
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"%s____%d |开始检索填充好友",__FUNCTION__, __LINE__);
}

//检索到好友
-(void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item
{
    //取到 JID 字符串
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    //创建 JID 对象
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    //把 jid添加到数组中
    if([self.dataArray containsObject:jid]){
        return;
    }
    [self.dataArray addObject:jid];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"%s___%d | 检索好友结束",__FUNCTION__, __LINE__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //取出数组中的 JID 对象，给 cell 赋值
    XMPPJID *jid = self.dataArray[indexPath.row];
    cell.textLabel.text = jid.user;
    
    return cell;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //通过 segue取到聊天页面控制器
    ChatTableViewController *chat = segue.destinationViewController;
    
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //取出 JID
    XMPPJID *jid = self.dataArray[indexPath.row];
    
    chat.friendJID = jid;
}


@end
