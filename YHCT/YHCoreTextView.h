//
//  YHCoreTextView.h
//  TestCoretext
//
//  Created by zhouyehong on 15/3/9.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHCTData.h"
#import "YHCTLinkData.h"

#define YHCT_LINESPACING 4
#define YHCT_LONGPRESS_DURATION .5f

#define YHCT_IMAGE_WIDTH 18
#define YHCT_IMAGE_H_PADDING 1
#define YHCT_IMAGE_V_PADDING 3
#define YHCT_FACE_IMAGE @"YHCT_FACE_IMAGE"

@interface YHCoreTextView : UIView

@property(nonatomic,assign)NSUInteger numberLines;//设置的行数，default：FLT_MAX

@property(nonatomic,strong)YHCTData *yhctData;

@property(nonatomic,assign)BOOL canHighlight;//是否允许高亮，default：YES
@property(nonatomic,assign)BOOL canPassHighlight;//是否允许高亮传递（长按超链接后高亮整个组件）,default：YES

@property(nonatomic,assign)BOOL highlight;//当前状态是否高亮

@property(nonatomic,copy)void(^linkClickAction)(YHCTLinkData* linkData);

@property(nonatomic,strong)NSArray *otherMenus;
@property(nonatomic,copy)void(^otherMenuClickAction)(NSString* title);

-(void)restHighlight;
@end
