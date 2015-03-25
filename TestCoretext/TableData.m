//
//  TableData.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "TableData.h"

#define MAX_LINES 2

@implementation TableData

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

-(void)calContentHeightByWidth:(CGFloat)width{
    _contentData = [YHCTData instanceYHCTDataWith:_content originText:_content];
    [_contentData useDefaultSetting];
    _contentHeight = [_contentData heightByLines:FLT_MAX width:width];
    if (_contentHeight > MAX_LINES * _contentData.fontsize) {//这里初略计算是否可以收起
        _contentPackHeight = [_contentData heightByLines:MAX_LINES width:width];//最少4行
        if (_contentHeight > _contentPackHeight) {
            _canPack = YES;
            _isPack = YES;
        }else {
            _canPack = NO;
        }
    }
}
-(void)calPraiseHeightByWidth:(CGFloat)width{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[_praise count]];
    [_praise enumerateObjectsUsingBlock:^(User *obj, NSUInteger idx, BOOL *stop) {
        [temp addObject:[obj html]];
    }];
    _praiseData = [YHCTData instanceYHCTDataWith:[NSString stringWithFormat:@"👍 %@",[temp componentsJoinedByString:@","]] originText:nil];
    [_praiseData useSetting:14 textColor:nil linkColor:nil selectedBgColor:nil];
     _praiseHeight = [_praiseData heightByLines:FLT_MAX width:width];
}

-(void)setUser:(User *)user{
    _user = user;
    _nameData = [YHCTData instanceYHCTDataWith:[user html] originText:user.name];
    [_nameData useDefaultSetting];
}
@end
