//
//  ViewController.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/9.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "ViewController.h"
#import "YHCoreTextView.h"
#import "TableViewCell.h"
#import "TableData.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *contentTest;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TableViewCell *protoCell;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _testData];
    
    self.protoCell = [_tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
}

-(void)_testData{
    TableData *data1 = [TableData new];
    data1.content = @"自动解析手机号码1862345543233444自动解析超链接https://www.apple.com自动解析超链接http://www.baidu.com。";
    data1.user = [User instanceByUid:1 name:@"姓名1"];
    data1.praise = @[[User instanceByUid:101 name:@"用户1"],[User instanceByUid:102 name:@"用户2"],[User instanceByUid:103 name:@"用户3"]];
    TableData *data2 = [TableData new];
    data2.content = @"自动[ok]解析[hello]表情[下雨][亲亲][下雨]图片，如果中括号中的图片找不多，会原封不动的显示字符串[duang].";
    data2.user = [User instanceByUid:2 name:@"姓名2"];
    TableData *data3 = [TableData new];
    data3.content = @"自定义事件<a href='hehe://1023'>click me</a>，自定义事件2<a href='test://aaa'>啊啊啊</a>";
    data3.user = [User instanceByUid:3 name:@"姓名3"];
    data3.praise = @[[User instanceByUid:101 name:@"用户1"],[User instanceByUid:102 name:@"用户2"],[User instanceByUid:103 name:@"用户3"]];
    TableData *data4 = [TableData new];
    data4.content = @"自定义电话号码<a href='tel://18888886666'>186****6666</a>，自定义超链接<a href='http://www.baidu.com'>百度一下</a>，自定义查看用户<a href='user://10086'>user</a>。";
    data4.user = [User instanceByUid:4 name:@"姓名4"];
    data4.praise = @[[User instanceByUid:101 name:@"用户1"],[User instanceByUid:102 name:@"用户2"],[User instanceByUid:103 name:@"用户3"]];
    contentTest = @[data1,data2,data3,data4];
    
    [self _calDataHeight:self.interfaceOrientation];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return contentTest.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    [cell setTableData:contentTest[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    [_protoCell setTableData:contentTest[indexPath.row]];
    return [_protoCell cellHeight:tableView.frame.size.width];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self _calDataHeight:toInterfaceOrientation];
    [self.tableView reloadData];
}

-(void)_calDataHeight:(UIInterfaceOrientation)interfaceOrientation{
    CGFloat w = 0;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        w = CGRectGetHeight([UIScreen mainScreen].bounds);
    }else if (UIInterfaceOrientationIsPortrait(interfaceOrientation) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        w = CGRectGetHeight([UIScreen mainScreen].bounds);
    }else {
        w = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    [contentTest enumerateObjectsUsingBlock:^(TableData *obj, NSUInteger idx, BOOL *stop) {
        [obj calContentHeightByWidth:w-8-8];
        [obj calPraiseHeightByWidth:w-8-8];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
