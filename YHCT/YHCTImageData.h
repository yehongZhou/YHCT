//
//  YHCTImageData.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YHCTImageData : NSObject

@property(nonatomic,copy)NSString *imageName;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)NSRange range;

@end
