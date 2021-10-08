//
//  NSURLSession+YT.m
//  Capture
//
//  Created by zwh on 2021/9/29.
//

#import "NSURLSession+YT.h"
#import <objc/runtime.h>

void YTRegist(void) {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([cls respondsToSelector:sel]) {
        // 通过http和https的请求，同理可通过其他的Scheme 但是要满足ULR Loading System
        [cls performSelector:sel withObject:@"http"];
        [cls performSelector:sel withObject:@"https"];
    }
#pragma clang diagnostic pop
}
