//
//  KRConcatsController.m
//  酷跑
//
//  Created by guoaj on 15/10/24.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "KRConcatsController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "UIImageView+KRRoundImageView.h"
#import "KRFriendCell.h"
@interface KRConcatsController()<NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSArray *friends;
@property (nonatomic,strong) NSFetchedResultsController *fetchController;
@end
@implementation KRConcatsController
- (void) viewDidLoad
{
    [self loadFriend2];
}
/** 加载好友列表 */
- (void) loadFriend
{
    // 获得上下文
    NSManagedObjectContext *context = [KRXMPPTool sharedKRXMPPTool].xmppRoserStore.mainThreadManagedObjectContext;
    // NSFetchRequest 关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:
        @"XMPPUserCoreDataStorageObject"];
    // 设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:
        @"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jid];
    request.predicate = pre;
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    // 排序
    request.sortDescriptors = @[nameSort];
    NSError *error = nil;
    self.friends = [context  executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

/** 新的加载好友列表方式  */
- (void) loadFriend2
{
    // 获得上下文
    NSManagedObjectContext *context = [KRXMPPTool sharedKRXMPPTool].xmppRoserStore.mainThreadManagedObjectContext;
    // NSFetchRequest 关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:
                               @"XMPPUserCoreDataStorageObject"];
    // 设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:
                        @"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jid];
    request.predicate = pre;
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    // 排序
    request.sortDescriptors = @[nameSort];
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController  performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return self.friends.count;
    return  [self.fetchController.fetchedObjects count];
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier = @"roseCell";
    KRFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    XMPPUserCoreDataStorageObject *roser = self.fetchController.fetchedObjects[indexPath.row];
    NSData * data = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvtar photoDataForJID:roser.jid];
    
    if (data) {
        cell.headImageView.image = [UIImage imageWithData:data];
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"placehoder"];
    }
    cell.jidStrLabel.text = roser.jidStr;
    [cell.headImageView setRoundLayer];
    cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cellselect"]];
    return cell;
}
@end
