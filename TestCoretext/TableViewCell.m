//
//  TableViewCell.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "TableViewCell.h"
#import "UIView+ViewHelper.h"

@implementation TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.avatarBtn setImage:[UIImage imageNamed:@"g_ns_1"] forState:UIControlStateNormal];
    self.avatarBtn.frame = CGRectMake(8, 8, 44, 44);
    self.avatarBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.avatarBtn];
    
    float nameLeft = self.avatarBtn.left + self.avatarBtn.width + 8;
    self.nameTextView = [[YHCoreTextView alloc] initWithFrame:CGRectMake(nameLeft, self.avatarBtn.top + 12, self.width-8-nameLeft, 25)];
    self.nameTextView.canHighlight = NO;
    self.nameTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.nameTextView];
    
    float contentLeft = 8;
    self.contentTextView = [[YHCoreTextView alloc] initWithFrame:CGRectMake(contentLeft, self.avatarBtn.top + self.avatarBtn.height + 8, self.width-8-contentLeft, 20)];
    self.contentTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.contentTextView];
    
    self.praiseTextView = [[YHCoreTextView alloc] initWithFrame:CGRectMake(contentLeft, 0, self.width-8-8, 20)];
    self.praiseTextView.canHighlight = NO;
    self.praiseTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.praiseTextView];
    
    self.packBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.packBtn.frame = CGRectMake(contentLeft, 0, 44, 44);
    self.packBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.packBtn addTarget:self action:@selector(packSelfAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.packBtn];
    
    void(^linkClickAction)(YHCTLinkData* linkData) = ^(YHCTLinkData* linkData){
        NSString *action = linkData.action;
        if ([action isEqualToString:HREF_UER]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查看用户" message:linkData.query delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else if ([action isEqualToString:@"http"] || [action isEqualToString:@"https"]){
            NSString *url = [NSString stringWithFormat:@"%@://%@",action,linkData.query];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开网页" message:url delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else if ([action isEqualToString:@"tel"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:linkData.query delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else {
            NSString *msg = [NSString stringWithFormat:@"action:%@ params:%@",linkData.action,linkData.query];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定义" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    };
    self.nameTextView.linkClickAction = linkClickAction;
    self.contentTextView.linkClickAction = linkClickAction;
    self.praiseTextView.linkClickAction = linkClickAction;
    
    self.contentTextView.otherMenus = @[@"收藏",@"举报"];
    self.contentTextView.otherMenuClickAction = ^(NSString *title){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    };
}

-(void)packSelfAction{
    self.tableData.isPack = !self.tableData.isPack;
    [[self _tableView:self] reloadData];
}

-(void)setTableData:(TableData *)tableData{
    _tableData = tableData;
    self.contentTextView.yhctData = tableData.contentData;
    self.nameTextView.yhctData = tableData.nameData;
    self.praiseTextView.yhctData = tableData.praiseData;
    self.packBtn.hidden = !tableData.canPack;
    [self.packBtn setTitle:tableData.isPack?@"展开":@"收起" forState:UIControlStateNormal];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutTextView:self.width];
}

-(CGFloat)layoutTextView:(CGFloat)width{
    self.praiseTextView.height = self.tableData.praiseHeight;
    if (self.tableData.canPack) {
        if (self.tableData.isPack) {
            self.contentTextView.height = self.tableData.contentPackHeight;
        }else {
            self.contentTextView.height = self.tableData.contentHeight;
        }
    }else {
        self.contentTextView.height = self.tableData.contentHeight;
    }
    
    CGFloat top = self.contentTextView.top + self.contentTextView.height + 8;
    if (!self.packBtn.hidden) {
        self.packBtn.top = top;
        top += self.packBtn.height;
    }
    if (self.tableData.praise.count) {
        self.praiseTextView.top = top;
        self.praiseTextView.hidden = NO;
        top = self.praiseTextView.top + self.praiseTextView.height + 8;
    }else{
        self.praiseTextView.hidden = YES;
    }
    return top;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat)cellHeight:(CGFloat)width{
    return [self layoutTextView:width];
}

-(UITableView*)_tableView:(UIView*)view{
    if (view == nil) {
        return nil;
    }
    if ([view isKindOfClass:[UITableView class]]) {
        return (UITableView*)view;
    }else{
        return [self _tableView:view.superview];
    }
}

@end
