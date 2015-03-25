//
//  User.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/24.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HREF_UER @"user"

@interface User : NSObject
@property(nonatomic,assign)long uid;
@property(nonatomic,copy)NSString *name;

+(instancetype)instanceByUid:(long)uid name:(NSString*)name;

-(NSString*)html;
@end
