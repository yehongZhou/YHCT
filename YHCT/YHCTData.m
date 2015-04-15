//
//  YHCTData.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/11.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHCTData.h"
#import "YHCTUtil.h"
#import "YHCTLinkData.h"
#import "YHCTImageData.h"
#import "YHCoreTextView.h"
#import <CoreText/CoreText.h>

@implementation YHCTData

+(YHCTData*)instanceYHCTDataWith:(NSString*)str originText:(NSString*)originText{
    if (str == nil) {
        return nil;
    }
    YHCTData *yhctData = [YHCTData new];
    yhctData.originText= originText;
    NSMutableString *drawTextString = [NSMutableString string];
    yhctData.linkDatas= [NSMutableArray array];
    yhctData.imageDatas = [NSMutableArray array];
    
    [YHCTUtil parser:str result:drawTextString links:yhctData.linkDatas images:yhctData.imageDatas];
//    NSLog(@"content:%@",str);
//    NSLog(@"result:%@",drawTextString);
//    NSLog(@"linkDatas:%@",yhctData.linkDatas);
//    NSLog(@"_imageDatas:%@",yhctData.imageDatas);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:drawTextString];
    
    [attrString beginEditing];
    [yhctData.imageDatas enumerateObjectsUsingBlock:^(YHCTImageData *obj, NSUInteger idx, BOOL *stop) {
        [attrString addAttribute:YHCT_FACE_IMAGE value:obj.image range:obj.range];
        CTRunDelegateRef imgDelegateRef = newEmotionRunDelegate();
        [attrString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)imgDelegateRef range:obj.range];
        CFRelease(imgDelegateRef);
    }];
    [attrString endEditing];
    
    yhctData.drawTextAttribute = attrString;
    return yhctData;
}

-(CGFloat)heightByLines:(NSUInteger)lines width:(CGFloat)width{
    YHCoreTextView *textView = [[YHCoreTextView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    textView.yhctData = self;
    textView.numberLines = lines;
    return [textView sizeThatFits:CGSizeMake(width, FLT_MAX)].height;
}

-(void)useDefaultSetting{
    [self useSetting:0 textColor:nil linkColor:nil selectedBgColor:nil];
}

-(void)useSetting:(CGFloat)fontsize textColor:(UIColor*)textColor linkColor:(UIColor*)linkColor selectedBgColor:(UIColor*)selectedBgColor{
    self.fontsize = fontsize == 0?15:fontsize;
    self.textColor = textColor == nil?[UIColor blackColor]:textColor;
    self.linkColor = linkColor == nil?[UIColor colorWithRed:108/255.0 green:176/255.0 blue:241/255.0 alpha:1]:linkColor;
    self.selectedBgColor = selectedBgColor == nil?[UIColor colorWithWhite:0.824 alpha:1.000]:selectedBgColor;
    
    NSInteger length = self.drawTextAttribute.length;
    [self.drawTextAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:_fontsize] range:NSMakeRange(0, length)];
    [self.drawTextAttribute addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, length)];
    
    [self.linkDatas enumerateObjectsUsingBlock:^(YHCTLinkData *obj, NSUInteger idx, BOOL *stop) {
        [self.drawTextAttribute addAttribute:NSForegroundColorAttributeName value:_linkColor range:obj.range];
    }];
}

CTRunDelegateRef newEmotionRunDelegate(){
    static NSString *emotionRunName = @"yhct.face.image";//可以使用当前图片，控制每一个图片的宽高。这里是表情统一宽高
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = WFRunDelegateDeallocCallback;
    imageCallbacks.getAscent = WFRunDelegateGetAscentCallback;
    imageCallbacks.getDescent = WFRunDelegateGetDescentCallback;
    imageCallbacks.getWidth = WFRunDelegateGetWidthCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks,
                                                       (__bridge void *)(emotionRunName));
    
    return runDelegate;
}

#pragma mark - Run delegate
void WFRunDelegateDeallocCallback( void* refCon ){
    
}

CGFloat WFRunDelegateGetAscentCallback( void *refCon ){
    return YHCT_IMAGE_WIDTH;
}

CGFloat WFRunDelegateGetDescentCallback(void *refCon){
    return 0.0;
}

CGFloat WFRunDelegateGetWidthCallback(void *refCon){
    return  2*YHCT_IMAGE_H_PADDING + YHCT_IMAGE_WIDTH;
}

@end
