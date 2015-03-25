//
//  YHCTUtil.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/9.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YHCTUtil : NSObject

+(void)parser:(NSString*)content result:(NSMutableString*)resultString links:(NSMutableArray*)linkDatas images:(NSMutableArray*)imgDatas;

+(UIImage*)imageWithName:(NSString*)name;
@end
