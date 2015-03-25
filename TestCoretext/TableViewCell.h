//
//  TableViewCell.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHCoreTextView.h"
#import "TableData.h"

@interface TableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *avatarBtn;
@property (strong, nonatomic) YHCoreTextView *nameTextView;
@property (strong, nonatomic) YHCoreTextView *contentTextView;
@property (strong, nonatomic) YHCoreTextView *praiseTextView;

@property(nonatomic,strong)UIButton *packBtn;

@property(nonatomic,strong)TableData *tableData;

-(CGFloat)cellHeight:(CGFloat)width;

@end
