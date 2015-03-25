//
//  YHCTData.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YHCTData : NSObject

@property(nonatomic,assign)CGFloat fontsize;
@property(nonatomic,strong)UIColor *textColor;
@property(nonatomic,strong)UIColor *linkColor;
@property(nonatomic,strong)UIColor *selectedBgColor;

@property(nonatomic,strong)NSMutableAttributedString *drawTextAttribute;
@property(nonatomic,copy)NSString *originText;//文本，用于“复制”等操作
@property(nonatomic,strong)NSMutableArray *linkDatas;
@property(nonatomic,strong)NSMutableArray *imageDatas;

-(CGFloat)heightByLines:(NSUInteger)lines width:(CGFloat)width;

+(YHCTData*)instanceYHCTDataWith:(NSString*)str originText:(NSString*)originText;

-(void)useDefaultSetting;
-(void)useSetting:(CGFloat)fontsize textColor:(UIColor*)textColor linkColor:(UIColor*)linkColor selectedBgColor:(UIColor*)selectedBgColor;
@end
