//
//  User.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/24.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "User.h"

@implementation User

+(instancetype)instanceByUid:(long)uid name:(NSString*)name{
    User *user = [User new];
    user.uid = uid;
    user.name = name;
    return user;
}

-(NSString*)html{
    return [NSString stringWithFormat:@"<a href='"HREF_UER"://%ld'>%@</a>",_uid,_name];
}
@end
