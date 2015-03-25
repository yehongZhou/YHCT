//
//  TableData.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHCTData.h"
#import "User.h"

@interface TableData : NSObject{
    CGFloat _contentHeight;
    CGFloat _contentPackHeight;
    CGFloat _praiseHeight;
    BOOL _canPack;
    YHCTData *_contentData;
    YHCTData *_nameData;
    YHCTData *_praiseData;
}

@property(nonatomic,copy)NSString *content;//内容
@property(nonatomic,strong)User *user;//发布人
@property(nonatomic,strong)NSArray *praise;//点赞

@property(nonatomic,assign)BOOL isPack;//是否收起

-(void)calContentHeightByWidth:(CGFloat)width;
-(void)calPraiseHeightByWidth:(CGFloat)width;

#pragma mark
#pragma mark 以下属性使用calContentHeightByWidth、calPraiseHeightByWidth解析得到，用于textview显示
@property(nonatomic,readonly)YHCTData *contentData;
@property(nonatomic,readonly)YHCTData *nameData;
@property(nonatomic,readonly)YHCTData *praiseData;
@property(nonatomic,readonly)CGFloat contentHeight;//原始高度
@property(nonatomic,readonly)CGFloat contentPackHeight;//收起高度
@property(nonatomic,readonly)CGFloat praiseHeight;//点赞高度
@property(nonatomic,readonly)BOOL canPack;//能否收起（packHeight<height）

@end
