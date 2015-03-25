//
//  YHCTLinkData.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/10.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHCTLinkData.h"

@implementation YHCTLinkData

-(NSString*)description{
    NSString *str = [NSString stringWithFormat:@"action:%@ query:%@ content:%@ range:%@",_action,_query,_content,NSStringFromRange(_range)];
    return str;
}

@end
