//
//  YHCTLinkData.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/10.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YHCTLinkData : NSObject

@property(nonatomic,copy)NSString *action;//tel
@property(nonatomic,copy)NSString *query;//13812341234
@property(nonatomic,copy)NSString *content;//138********
@property(nonatomic,assign)NSRange range;

@property(nonatomic,assign)BOOL highlight;

@end
