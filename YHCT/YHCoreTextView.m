//
//  YHCoreTextView.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/9.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHCoreTextView.h"
#import <CoreText/CoreText.h>
#import "YHCTUtil.h"
#import "YHCTImageData.h"

#define OTHER_MENU_MOTHED @"otherMenuAction_"

@interface YHCoreTextView(){
    CTTypesetterRef typesetter;
    CGRect hilghtFirstLineRect;
    //    NSUInteger _originLines;
}
@property(nonatomic,strong)UILongPressGestureRecognizer *longGest ;
@end

@implementation YHCoreTextView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

-(void)_init{
    self.backgroundColor = [UIColor clearColor];
    
    self.longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    [self addGestureRecognizer:_longGest];
    
    self.canHighlight = YES;
    self.canPassHighlight = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHideNtf:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

-(void)setCanHighlight:(BOOL)canHighlight{
    _canHighlight = canHighlight;
    _longGest.enabled = canHighlight;
}

-(void)menuWillHideNtf:(id)sender{
    if (!self.window) {
        return;
    }
    YHCTLinkData *highlightData = [self _getHighlightLinkData];
    BOOL needDraw = NO;
    if (highlightData) {
        [self _resetLinkHighlight];
        needDraw = YES;
    }
    if (self.highlight) {
        _highlight = NO;
        needDraw = YES;
    }
    if (needDraw) {
        [self setNeedsDisplay];
    }
}

-(void)setYhctData:(YHCTData*)yhctData{
    _yhctData = yhctData;
    if (typesetter) {
        CFRelease(typesetter);
    }
    typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)_yhctData.drawTextAttribute);
    [self restHighlight];
}

-(void)longAction:(UILongPressGestureRecognizer*)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            [self longpress];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            if (!menu.isMenuVisible) {
                
                YHCTLinkData *highlightData = [self _getHighlightLinkData];
                if (highlightData) {
                    [self _resetLinkHighlight];
                    [self setNeedsDisplay];
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            self.highlight = NO;
            break;
        }
        default:
            break;
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat y = 0;
    CFIndex start = 0;
    NSInteger length = [_yhctData.drawTextAttribute length];
    __block BOOL hitLinkData = NO;
    while (start < length){
        CFIndex count = CTTypesetterSuggestClusterBreak(typesetter, start, w);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
        CGFloat ascent, descent;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        
        CGRect lineFrame = CGRectMake(0, -y, lineWidth, ascent + descent);
        
        if (CGRectContainsPoint(lineFrame, point)) {
            CFIndex index = CTLineGetStringIndexForPosition(line, point);
            [_yhctData.linkDatas enumerateObjectsUsingBlock:^(YHCTLinkData *obj, NSUInteger idx, BOOL *stop) {
                if (index > obj.range.location && index <= obj.range.location + obj.range.length) {
                    obj.highlight = YES;
                    hitLinkData = YES;
                }else {
                    obj.highlight = NO;
                }
            }];
        }
        start += count;
        y -= self.yhctData.fontsize + YHCT_LINESPACING;
        CFRelease(line);
    }
    self.highlight = NO;
    if (!hitLinkData) {
        [super touchesBegan:touches withEvent:event];        
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (self.canHighlight) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpress) object:nil];
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (!menu.isMenuVisible) {
        
        YHCTLinkData *highlightData = [self _getHighlightLinkData];
        if (highlightData) {
            if (self.linkClickAction) {
                self.linkClickAction(highlightData);
            }
            [self _resetLinkHighlight];
            [self setNeedsDisplay];
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    YHCTLinkData *highlightData = [self _getHighlightLinkData];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (highlightData != nil && self.highlight==NO && !menu.menuVisible) {
        //有高亮item，但是组件本身没有高亮起来 （刚按住然后拖动视图）
        [self _resetLinkHighlight];
        [self setNeedsDisplay];
    }
}

-(void)longpress{
    if (self.canPassHighlight) {
        [self _resetLinkHighlight];
        self.highlight = YES;
        [self _showMenu];
    }else {
        YHCTLinkData *highlightData = [self _getHighlightLinkData];
        if (highlightData) {
            [self _showMenu];
        }else{
            self.highlight = YES;
            [self _showMenu];
        }
    }
}

#pragma mark show menu
-(void)_showMenu{
    [self becomeFirstResponder];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyAction:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menusItem = [NSMutableArray arrayWithObject:copyItem];
    [self.otherMenus enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *selStr = [NSString stringWithFormat:OTHER_MENU_MOTHED@"%zd",idx];
        UIMenuItem *__item = [[UIMenuItem alloc] initWithTitle:obj action:NSSelectorFromString(selStr)];
        [menusItem addObject:__item];
    }];
    [menu setMenuItems:menusItem];
    hilghtFirstLineRect.origin.y = ABS(hilghtFirstLineRect.origin.y);
    CGRect rect = [self.superview convertRect:hilghtFirstLineRect fromView:self];
    [menu setTargetRect:rect inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)copyAction:(id)sender{
    YHCTLinkData *highlightData = [self _getHighlightLinkData];
    NSString *beCopyStr = nil;
    if (highlightData) {
        beCopyStr = highlightData.content;
    }else {
        beCopyStr = self.yhctData.originText;
    }
    [self restHighlight];
    NSLog(@"YHCoreTextView copy:%@",beCopyStr);
    if (beCopyStr != nil) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = beCopyStr;
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector{
    NSString *sel = NSStringFromSelector(aSelector);
    if ([sel hasPrefix:OTHER_MENU_MOTHED]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

-(void)otherMenuAction:(NSString*)sender{
    if (self.otherMenuClickAction) {
        self.otherMenuClickAction(sender);
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    NSString *sel = NSStringFromSelector(selector);
    if ([sel hasPrefix:OTHER_MENU_MOTHED]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }else {
        return [super methodSignatureForSelector:selector];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    NSString *sel = NSStringFromSelector([invocation selector]);
    if ([sel hasPrefix:OTHER_MENU_MOTHED]) {
        NSArray *temp = [sel componentsSeparatedByString:@"_"];
        if (temp.count != 2) {
            [super forwardInvocation:invocation];
            return;
        }
        NSInteger index = [[temp lastObject] integerValue];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuItems.count > index+1) {
            UIMenuItem *item = menu.menuItems[index+1];
            NSString *itemTitle = item.title;
            [invocation setSelector: @selector(otherMenuAction:)];
            [invocation setArgument:&itemTitle atIndex:2];
            [invocation invokeWithTarget:self];
            return;
        }
    }
    [super forwardInvocation:invocation];
}

-(void)_resetLinkHighlight{
    for (YHCTLinkData *obj in _yhctData.linkDatas) {
        obj.highlight = NO;
    }
}

-(BOOL)_isHighlight:(YHCTLinkData*)highlightData range:(CFRange)range{
    if (range.location >= highlightData.range.location && range.location+range.length <= highlightData.range.location + highlightData.range.length) {
        return YES;
    }
    return NO;
}

-(YHCTLinkData*)_getHighlightLinkData{
    for (YHCTLinkData *obj in _yhctData.linkDatas) {
        if (obj.highlight) {
            return obj;
        }
    }
    return nil;
}

-(void)drawRect:(CGRect)rect{
    hilghtFirstLineRect = CGRectZero;
    YHCTLinkData *highlightData = [self _getHighlightLinkData];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    CGContextScaleCTM(context, 1.0 ,-1.0);
    CGContextTranslateCTM(context , 0 ,-self.yhctData.fontsize);
    
    if (self.canHighlight && self.highlight) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.yhctData.selectedBgColor.CGColor);
        CGContextFillRect(context, CGRectMake(rect.origin.x, -rect.size.height+self.yhctData.fontsize, rect.size.width, rect.size.height));
        CGContextRestoreGState(context);
    }
    
    CGFloat y= 0;
    CFIndex x = 0;
    NSUInteger length = [_yhctData.drawTextAttribute length];
    NSUInteger lines = 0;
    while (x < length  && lines < self.numberLines) {
        CFIndex count = CTTypesetterSuggestClusterBreak(typesetter, x, self.bounds.size.width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(x, count));
        CGContextSetTextPosition(context, 0, y);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        NSUInteger runsCount = CFArrayGetCount(runs);
        for (int i=0; i<runsCount; i++) {
            CTRunRef runRef = CFArrayGetValueAtIndex(runs, i);
            
            CFDictionaryRef attributes = CTRunGetAttributes(runRef);
            UIImage *image = (UIImage *)CFDictionaryGetValue(attributes, YHCT_FACE_IMAGE);
            if (image){
                CGImageRef img = [image CGImage];
                const CGPoint *runPoint = CTRunGetPositionsPtr(runRef);
                CGRect imageRect = CGRectMake(runPoint->x+YHCT_IMAGE_H_PADDING, y - YHCT_IMAGE_V_PADDING, YHCT_IMAGE_WIDTH, YHCT_IMAGE_WIDTH);
                CGContextDrawImage(context, imageRect, img);
            }else{
                if (highlightData) {
                    CFRange stringRange = CTRunGetStringRange(runRef);
                    BOOL highlight = [self _isHighlight:highlightData range:stringRange];
                    if (highlight) {
                        CGPoint *posPtr=(CGPoint *)CTRunGetPositionsPtr(runRef);
                        CGPoint *pos = NULL;
                        if (!posPtr){
                            pos = malloc(sizeof(CGPoint));
                            CTRunGetPositions(runRef, CFRangeMake(0, 1), pos);
                            posPtr = pos;
                        }
                        CGFloat runAscent,runDescent;
                        float RunWidth=CTRunGetTypographicBounds(runRef, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                        CGFloat runHeight = runAscent + (runDescent);
                        CGRect highlightRect = CGRectMake(posPtr[0].x-1, y-(runDescent), RunWidth+2, runHeight);
                        if (CGRectIsEmpty(hilghtFirstLineRect)) {
                            hilghtFirstLineRect = highlightRect;
                        }else if(highlightRect.origin.x > hilghtFirstLineRect.origin.x){
                            hilghtFirstLineRect.size.width = highlightRect.origin.x + highlightRect.size.width - hilghtFirstLineRect.origin.x;
                        }else{
                            //换行 了
                            hilghtFirstLineRect.origin.x = highlightRect.origin.x;
                            hilghtFirstLineRect.size.width = rect.size.width;
                        }
                        UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:highlightRect cornerRadius:2];
                        CGContextSaveGState(context);
                        CGContextAddPath(context, bp.CGPath);
                        CGContextSetFillColorWithColor(context, self.yhctData.selectedBgColor.CGColor);
                        CGContextFillPath(context);
                        CGContextRestoreGState(context);
                    }
                    
                }
                CTRunDraw(runRef, context, CFRangeMake(0, 0));
            }
        }
        y -= self.yhctData.fontsize + YHCT_LINESPACING;
        CFRelease(line);
        x += count;
        lines ++;
    }
}

-(CGSize)sizeThatFits:(CGSize)size{
    CGFloat y= 0;
    CFIndex x = 0;
    NSUInteger length = [_yhctData.drawTextAttribute length];
    NSUInteger lines = 0;
    while (x < length && lines < self.numberLines) {
        CFIndex count = CTTypesetterSuggestClusterBreak(typesetter, x, size.width);
        y -= self.yhctData.fontsize + YHCT_LINESPACING;
        x += count;
        lines ++;
    }
    return CGSizeMake(size.width, -y);
}

-(void)restHighlight{
    [self _resetLinkHighlight];
    self.highlight = NO;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO];
}

-(void)setHighlight:(BOOL)highlight{
    _highlight = highlight;
    if (highlight) {
        hilghtFirstLineRect = self.bounds;
    }
    [self setNeedsDisplay];
}

-(NSUInteger)numberLines{
    if (_numberLines == 0) {
        return NSUIntegerMax;
    }
    return _numberLines;
}

-(void)dealloc{
    if (typesetter) {
        CFRelease(typesetter);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
