//
//  YHCTUtil.m
//  TestCoretext
//
//  Created by zhouyehong on 15/3/9.
//  Copyright (c) 2015年 zhouyehong. All rights reserved.
//

#import "YHCTUtil.h"
#import "YHCTLinkData.h"
#import "YHCTImageData.h"

#define YHCT_A_PATTERN @"\\<a href='(\\w+)://(\\S+)'>(.*?)</a>"
#define YHCT_IMG_PATTERN @"\\[(\\w+)\\]"

#define YHCT_IMG_PLACEHOLDER @" "

@implementation YHCTUtil

+(void)parser:(NSString*)content result:(NSMutableString*)resultString links:(NSMutableArray*)linkDatas images:(NSMutableArray*)imgDatas{
    NSError *error = nil;
    NSRegularExpression *linkRegx = [[NSRegularExpression alloc] initWithPattern:YHCT_A_PATTERN
                                                                     options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error){
        
        NSRegularExpression *imgRegx = [[NSRegularExpression alloc] initWithPattern:YHCT_IMG_PATTERN
                                                                            options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error){
            
            NSArray *resultArr = [linkRegx matchesInString:content options:kNilOptions range:NSMakeRange(0, content.length)];
            if (resultArr.count) {
                NSMutableString *tempResult = [NSMutableString string];
                NSRange lastRange = NSMakeRange(0, 0);
                for (int i = 0; i<=resultArr.count; i++) {
                    NSRange range = NSMakeRange(0, 0);
                    if (i<resultArr.count) {
                        range = ((NSTextCheckingResult*)(resultArr[i])).range;
                    }else {
                        range = NSMakeRange(content.length, 0);
                    }
                    NSString *leftStr = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, range.location-(lastRange.location + lastRange.length))];
                    leftStr = [self _parserMobile:leftStr];
                    leftStr = [self _parserUrl:leftStr];
                    [tempResult appendString:leftStr];
                    [tempResult appendString:[content substringWithRange:range]];
                    lastRange = range;
                }
                content = tempResult;
            }else {
                content = [self _parserMobile:content];
                content = [self _parserUrl:content];
            }
            [self _doParser:content result:resultString byLinkRegx:linkRegx links:linkDatas byImgRegx:imgRegx images:imgDatas];
        }else {
            NSLog(@"init YHCT_IMG_PATTERN error");
        }
    }else {
        NSLog(@"init YHCT_A_PATTERN error");
    }
}

+(NSString*)_parserMobile:(NSString*)content{
    NSString *result = [self stringByReplacingOccurrencesOfString:content regex:@"(13[0-9]|14[0-9]|15[0-9]|17[0-9]|18[01235-9])\\d{8}" withString:@"<a href='tel://%1$@'>%1$@</a>"];
    return result;
}

//1[ok]23<a href='aaa'>abc</a>b18618427263pppp
+(NSString*)_parserUrl:(NSString*)content{
    NSString *result = [self stringByReplacingOccurrencesOfString:content regex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" withString:@"<a href='%1$@'>%1$@</a>"];
    return result;
}

+(void)_doParser:(NSString*)content
          result:(NSMutableString*)resultString
      byLinkRegx:(NSRegularExpression*)linkRegx
           links:(NSMutableArray*)linkDatas
      byImgRegx:(NSRegularExpression*)imgRegx
           images:(NSMutableArray*)imgsDatas{
    if (content.length == 0) {
        return;
    }
    
    NSRange searchRange = NSMakeRange(0, [content length]);

    NSTextCheckingResult *checkingImgResult = [imgRegx firstMatchInString:content options:kNilOptions range:searchRange];
    NSTextCheckingResult *checkingLinkResult = [linkRegx firstMatchInString:content options:kNilOptions range:searchRange];
    
    int parserType = 0;
    if (checkingImgResult &&  checkingLinkResult) {
        if (checkingImgResult.range.location < checkingLinkResult.range.location) {
            parserType = 1;
        }else {
            parserType = 2;
        }
    }else if (checkingImgResult){
        parserType = 1;
    }else if(checkingLinkResult){
        parserType = 2;
    }
    
    if (parserType == 1) {
        //先找到图片
        NSUInteger line = [checkingImgResult numberOfRanges];
        YHCTImageData *yhCTImageData = [YHCTImageData new];
        NSRange originRange;
        for (int i = 0; i<line; i++) {
            NSRange tempRange = [checkingImgResult rangeAtIndex:i];
            if (tempRange.location != NSNotFound) {
                NSString *tempStr = [content substringWithRange:tempRange];
                if (i == 0) {
                    originRange = tempRange;
                }else if (i == 1) {
                    yhCTImageData.image = tempStr;
                }
            }
        }
        [resultString appendString:[content substringToIndex:originRange.location]];
        if (yhCTImageData.image) {
            if ([self imageWithName:yhCTImageData.image]) {
                yhCTImageData.range = NSMakeRange(resultString.length, YHCT_IMG_PLACEHOLDER.length);
                [resultString appendString:YHCT_IMG_PLACEHOLDER];
                [imgsDatas addObject:yhCTImageData];
            }else {
                [resultString appendString:[content substringWithRange:originRange]];
            }
        }
        content = [content substringFromIndex:originRange.location + originRange.length];
        [self _doParser:content result:resultString byLinkRegx:linkRegx links:linkDatas byImgRegx:imgRegx images:imgsDatas];
    }else if (parserType == 2){
        //先找到link
        NSUInteger line = [checkingLinkResult numberOfRanges];
        
        YHCTLinkData *yhCTLinkData = [YHCTLinkData new];
        NSRange originRange;
        for (int i = 0; i<line; i++) {
            NSRange tempRange = [checkingLinkResult rangeAtIndex:i];
            if (tempRange.location != NSNotFound) {
                NSString *tempStr = [content substringWithRange:tempRange];
                if (i == 0) {
                    originRange = tempRange;
                }else if (i == 1) {
                    yhCTLinkData.action = tempStr;
                }else if (i == 2){
                    yhCTLinkData.query = tempStr;
                }else if (i == 3){
                    yhCTLinkData.content = tempStr;
                }
            }
        }
        [resultString appendString:[content substringToIndex:originRange.location]];
        if (yhCTLinkData.action && yhCTLinkData.query && yhCTLinkData.content) {
            yhCTLinkData.range = NSMakeRange(resultString.length, yhCTLinkData.content.length);
            [resultString appendString:yhCTLinkData.content];
            [linkDatas addObject:yhCTLinkData];
        }
        content = [content substringFromIndex:originRange.location + originRange.length];
        [self _doParser:content result:resultString byLinkRegx:linkRegx links:linkDatas byImgRegx:imgRegx images:imgsDatas];
    }else {
        [resultString appendString:content];
    }
}

+(NSString*)stringByReplacingOccurrencesOfString:(NSString*)content regex:(NSString*)regex withString:(NSString*)withString{
    NSError *error = nil;
    NSRegularExpression *linkRegx = [[NSRegularExpression alloc] initWithPattern:regex
                                                                        options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error){
        NSArray *resultArr = [linkRegx matchesInString:content options:kNilOptions range:NSMakeRange(0, content.length)];
        if (resultArr.count) {
            NSMutableString *tempResult = [NSMutableString string];
            NSRange lastRange = NSMakeRange(0, 0);
            for (int i = 0; i<=resultArr.count; i++) {
                NSRange range = NSMakeRange(0, 0);
                NSString *matchString = nil;
                if (i<resultArr.count) {
                    NSTextCheckingResult *checkingResult = (NSTextCheckingResult*)resultArr[i];
                    range = checkingResult.range;
                    matchString = [NSString stringWithFormat:withString,[content substringWithRange:range]];
                }else {
                    range = NSMakeRange(content.length, 0);
                }
                NSString *leftStr = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, range.location-(lastRange.location + lastRange.length))];
                [tempResult appendString:leftStr];
                if (matchString) {
                    [tempResult appendString:matchString];                    
                }

                lastRange = range;
            }
            return tempResult;
        }else {
            return content;
        }
    }else {
        return content;
    }
}

+(UIImage*)imageWithName:(NSString *)name{
//    name= [NSString stringWithFormat:@"%@@2x",name];
//    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:@"face"];
//    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return [UIImage imageNamed:name];
}
@end
